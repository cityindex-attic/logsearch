#!/bin/bash

set -e

function display_file_info {
	ls -oh $1 | awk '{ print $8 " " $5 " " $6 " " $4; }'
}

#
# logstash
#

if [ ! -e $DEST/lumberjack.exe ] ; then
    echo "Downloading lumberjack_0.1.2_win64.exe"
    
    curl --location -o $DEST/lumberjack.exe https://s3.amazonaws.com/ci-elasticsearch-development-flow/lumberjack_0.1.2_win64.exe
fi

echo "lumberjack:$(display_file_info $DEST/lumberjack.exe)"

#
# Service wrapper
#

if [ ! -e $DEST/windows-shipper-service.exe ] ; then
    echo "Downloading service wrapper (winsw-1.13) ..."

    curl --location -o $DEST/windows-shipper-service.exe http://repo.jenkins-ci.org/releases/com/sun/winsw/winsw/1.13/winsw-1.13-bin.exe
fi

echo "service wrapper:$(display_file_info $DEST/windows-shipper-service.exe)"


