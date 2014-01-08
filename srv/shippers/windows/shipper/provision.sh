#!/bin/bash

set -e

function display_file_info {
	ls -oh $1 | awk '{ print $8 " " $5 " " $6 " " $4; }'
}

#
# logstash
#

if [ ! -e $DEST/logstash.jar ] ; then
    echo "Downloading logstash-1.1.13-pr19b5(patched)..."
    
    curl --location -o $DEST/logstash.jar http://ci-logsearch.s3.amazonaws.com/logstash-1.1.13-monolithic-pr19b5.jar
fi

echo "logstash:$(display_file_info $DEST/logstash.jar)"

#
# Service wrapper
#

if [ ! -e $DEST/windows-shipper-service.exe ] ; then
    echo "Downloading service wrapper (winsw-1.13) ..."

    curl --location -o $DEST/windows-shipper-service.exe http://repo.jenkins-ci.org/releases/com/sun/winsw/winsw/1.13/winsw-1.13-bin.exe
fi

echo "service wrapper:$(display_file_info $DEST/windows-shipper-service.exe)"


