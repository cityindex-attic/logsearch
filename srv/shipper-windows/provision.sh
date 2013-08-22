#!/bin/bash

set -e


#
# logstash
#

if [ ! -e $DEST/logstash.jar ] ; then
    echo "Downloading logstash-1.1.13..."

    curl --location -o $DEST/logstash.jar https://logstash.objects.dreamhost.com/release/logstash-1.1.13-flatjar.jar
fi

echo "logstash:$(java -jar $DEST/logstash.jar -v | awk -F ' ' '/logstash/ { print $2 }')"


#
# Service wrapper
#

if [ ! -e $DEST/windows-shipper-service.exe ] ; then
    echo "Downloading service wrapper (winsw-1.13) ..."

    curl --location -o $DEST/windows-shipper-service.exe http://repo.jenkins-ci.org/releases/com/sun/winsw/winsw/1.13/winsw-1.13-bin.exe
fi

echo "service wrapper:$(ls -la $DEST/windows-shipper-service.exe)"

#
# Plink (SSH tunnel)
#

if [ ! -e $DEST/plink.exe ] ; then
    echo "Downloading plink(winsw-1.13) ..."

    curl --location -o $DEST/plink.exe http://the.earth.li/~sgtatham/putty/latest/x86/plink.exe
fi

echo "SSH tunnel client (plink):$(ls -la $DEST/plink.exe)"

