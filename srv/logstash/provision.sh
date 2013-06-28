#!/bin/bash

set -e


#
# logstash
#

if [ ! -e $APP_VENDOR_DIR/logstash.jar ] ; then
    echo "Downloading logstash-1.1.13..."

    curl --location -o $APP_VENDOR_DIR/logstash.jar https://logstash.objects.dreamhost.com/release/logstash-1.1.13-flatjar.jar
fi

echo "logstash:$(java -jar $APP_VENDOR_DIR/logstash.jar -v | awk -F ' ' '/logstash/ { print $2 }')"
