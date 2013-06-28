#!/bin/bash

cd $APP_APP_DIR/

while true ; do
    TASK=`$APP_VENDOR_DIR/redis/src/redis-cli -h $APP_CONFIG_REDIS_IPADDRESS --raw BLPOP $APP_CONFIG_IMPORTQUEUE_KEY 0 | sed '2q;d'`

    if [ $? -gt 0 ] ; then
        exit $?
    fi

    echo '$>' $TASK
    $TASK
done
