#!/bin/bash

set -x
set -e


#
# logstash
#

if [ ! -e $APP_VENDOR_DIR/logstash.jar ] ; then
    echo "Downloading logstash-1.2.2..."

    curl --location -o $APP_VENDOR_DIR/logstash.jar https://download.elasticsearch.org/logstash/logstash/logstash-1.2.2-flatjar.jar
fi

echo "logstash:$(java -jar $APP_VENDOR_DIR/logstash.jar version | awk -F ' ' '/logstash/ { print $2 }')"
