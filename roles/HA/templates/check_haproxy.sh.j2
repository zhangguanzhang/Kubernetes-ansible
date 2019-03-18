#!/bin/bash
VIRTUAL_IP={{ VIP }}

errorExit() {
    echo "*** $*" 1>&2
    exit 1
}

if ip addr | grep -q $VIRTUAL_IP ; then
    curl -s --max-time 2 --insecure https://${VIRTUAL_IP}:8443/ -o /dev/null || errorExit "Error GET https://${VIRTUAL_IP}:8443/"
fi
