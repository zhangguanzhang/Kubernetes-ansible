#!/bin/bash
set -e

function fhelp (){
	cat<<-EOF
	Usage: $0 [OPTION]...
	Save docker all images to a tar.gz or load from a tar.gz

	-f filename
	-F [save|load]
	Example: $0 -f images.tar.gz -F save
	EOF
}

function save (){
	[ -f "$filename" ] && { echo 'file exist,please Usage other name';exit 5; }
	docker save $(docker images --format {{.Repository}}:{{.Tag}}) | gzip - > $filename
}

function load (){
	[ ! -f "$filename" ] && { echo 'file not exist!';exit 6; }
	docker load -i $filename
}
while getopts ':f:F:h' args;do
	case $args in
	    f)
	        filename=$OPTARG
	        ;;
	    F)
			[[ $OPTARG =~ save|load ]] || { fhelp;exit 1; }
	        func=$OPTARG
	        ;;
        h)
			fhelp;exit 0;
			;;
    	?)
			fhelp;exit 1;
			;;
	esac
done

[[ -z "$filename" || -z "$func" ]] && {
	echo '-f with -F must be simultaneously exist';fhelp
	exit 1;
}

$func $filename


