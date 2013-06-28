#!/bin/bash

set -e


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
