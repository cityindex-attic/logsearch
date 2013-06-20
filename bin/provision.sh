#!/bin/bash

set -e

. $PWD/.env

#
# directories
#

mkdir -p $APP_VENDOR_DIR
mkdir -p $APP_LOG_DIR
mkdir -p $APP_RUN_DIR
mkdir -p $APP_TMP_DIR
mkdir -p $APP_DATA_DIR


#
# elasticsearch
#

if [ ! -e $APP_VENDOR_DIR/elasticsearch ] ; then
    echo "Downloading elasticsearch-0.90.1..."

    pushd $APP_VENDOR_DIR/
    curl --location -o elasticsearch-0.90.1.tar.gz https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-0.90.1.tar.gz
    tar -xzf elasticsearch-0.90.1.tar.gz
    mv elasticsearch-0.90.1 elasticsearch
    rm elasticsearch-0.90.1.tar.gz
    popd
fi

echo "elasticsearch:$($APP_VENDOR_DIR/elasticsearch/bin/elasticsearch -v | awk -F ':|,' '/Version/ { print $2 }')"


#
# logstash
#

if [ ! -e $APP_VENDOR_DIR/logstash.jar ] ; then
    echo "Downloading logstash-1.1.13..."

    curl --location -o $APP_VENDOR_DIR/logstash.jar https://logstash.objects.dreamhost.com/release/logstash-1.1.13-flatjar.jar
fi

echo "logstash:$(java -jar $APP_VENDOR_DIR/logstash.jar -v | awk -F ' ' '/logstash/ { print $2 }')"


#
# kibana
#

if [ ! -e $APP_VENDOR_DIR/kibana ] ; then
    KIBANA_VERSION="050ee74c10851ae9178d471e71d752c5d76986fc"
    echo "Download kibana-dev-$KIBANA_VERSION..."

    pushd $APP_VENDOR_DIR/
    curl --location -o kibana.zip "https://github.com/elasticsearch/kibana/archive/$KIBANA_VERSION.zip"
    unzip -q kibana
    mv "kibana-$KIBANA_VERSION" kibana
    echo "$KIBANA_VERSION" > kibana/VERSION_DEV
    rm kibana.zip
    popd
fi

echo "kibana:dev-$(cat $APP_VENDOR_DIR/kibana/VERSION_DEV)"


#
# redis
#

if [ ! -e $APP_VENDOR_DIR/redis ] ; then
    echo "Downloading redis-2.6.14..."

    pushd $APP_VENDOR_DIR/
    curl --location -o redis-2.6.14.tar.gz http://redis.googlecode.com/files/redis-2.6.14.tar.gz
    tar -xzf redis-2.6.14.tar.gz
    mv redis-2.6.14 redis
    rm redis-2.6.14.tar.gz
    pushd redis/
    make
    popd
fi

echo "redis:$($APP_VENDOR_DIR/redis/src/redis-server -v | awk -F '=' '/v=/ { print $2 }')"


#
# ruby deps
#

pushd $APP_APP_DIR
echo "Configuring build dependancies"
bundle install
popd
