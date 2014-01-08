#!/bin/bash

set -e

. /app/.env

for DATE in 20130702 20130704 ; do
    echo "Collating $DATE..."

    mkdir $DATE/
    cd $DATE/

    for FILE in $(aws s3 list-objects --bucket ci-logsearch | grep '"Key": "' | sed -r 's/.*: "([^"]+)",.*$/\1/' | grep $DATE) ; do
        echo " + $FILE"

        aws s3 get-object --bucket ci-logsearch --key $FILE `echo $FILE | openssl md5 | cut -c10-`.zip > /dev/null
    done

    unzip -qq -B '*.zip' 1>/dev/null 2>&1
    rm *.zip

    ruby /app/app/example/log-collator/main.rb * > ~/$DATE.log

    cd ../
    rm -fr $DATE/

    echo "Importing $DATE..."

    (cd /app/app/ ; rake logstash:pv_to_redis[ci_log4net,/home/ubuntu/$DATE.log])

    sleep 120
done

echo 'Waiting for queue to drain...'

QUEUELEN='1234'

while [ $QUEUELEN -gt 0 ]; do
    QUEUELEN=`/app/vendor/redis/src/redis-cli -h $APP_CONFIG_REDIS_IPADDRESS --raw llen logstash | awk '{ print $0 }'`

    sleep 2
done
