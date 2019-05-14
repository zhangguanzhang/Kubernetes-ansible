#!/bin/bash
set -e
[ -z "$1" ] && { 
    KUBE_APISERVER=`kubectl config view  --output=jsonpath='{.clusters[].cluster.server}' | head -n1 `
} || KUBE_APISERVER=$1


set +e

kubectl get clusterrole | grep flanne ||  \
 cat << EOF | kubectl apply -f -
---
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  name: flannel
rules:
  - apiGroups: ['extensions']
    resources: ['podsecuritypolicies']
    verbs: ['use']
    resourceNames: ['psp.flannel.unprivileged']
  - apiGroups:
      - ""
    resources:
      - pods
    verbs:
      - get
  - apiGroups:
      - ""
    resources:
      - nodes
    verbs:
      - list
      - watch
  - apiGroups:
      - ""
    resources:
      - nodes/status
    verbs:
      - patch
---
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  name: flannel
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: flannel
subjects:
- kind: ServiceAccount
  name: flannel
  namespace: kube-system
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: flannel
  namespace: kube-system
EOF


CLUSTER_NAME="kubernetes"
KUBE_CONFIG="flanneld.kubeconfig"

SECRET=$(kubectl -n kube-system get sa/flannel \
    --output=jsonpath='{.secrets[0].name}')

JWT_TOKEN=$(kubectl -n kube-system get secret/$SECRET \
    --output=jsonpath='{.data.token}' | base64 -d)

kubectl config set-cluster ${CLUSTER_NAME} \
  --certificate-authority=/etc/kubernetes/pki/ca.crt \
  --embed-certs=true \
  --server=${KUBE_APISERVER} \
  --kubeconfig=/etc/kubernetes/${KUBE_CONFIG}

kubectl config set-context ${CLUSTER_NAME} \
  --cluster=${CLUSTER_NAME} \
  --user=${CLUSTER_NAME} \
  --kubeconfig=/etc/kubernetes/${KUBE_CONFIG}

kubectl config set-credentials ${CLUSTER_NAME} --token=${JWT_TOKEN} --kubeconfig=/etc/kubernetes/${KUBE_CONFIG}

kubectl config use-context ${CLUSTER_NAME} --kubeconfig=/etc/kubernetes/${KUBE_CONFIG}

kubectl config view --kubeconfig=/etc/kubernetes/${KUBE_CONFIG}

