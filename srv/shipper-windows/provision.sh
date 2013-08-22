#!/bin/bash

set -e

function display_file_info {
	ls -oh $1 | awk '{ print $8 " " $5 " " $6 " " $4; }'
}

#
# logstash
#

if [ ! -e $DEST/logstash.jar ] ; then
    echo "Downloading logstash-1.1.13..."

    curl --location -o $DEST/logstash.jar https://logstash.objects.dreamhost.com/release/logstash-1.1.13-flatjar.jar
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

#
# Plink (SSH tunnel)
#

if [ ! -e $DEST/plink.exe ] ; then
    echo "Downloading plink(winsw-1.13) ..."

    curl --location -o $DEST/plink.exe http://the.earth.li/~sgtatham/putty/latest/x86/plink.exe
fi

echo "SSH tunnel client (plink):$(display_file_info $DEST/plink.exe)"

