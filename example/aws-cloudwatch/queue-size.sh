#!/bin/bash

# * * * * * (. /app/.env ; /app/app/example/aws-cloudwatch/queue-size.sh logsearch-ppe) >> /app/var/log/cron.log 2>&1
# args: cluster-name

INSTANCE_ID=$(ec2metadata --instance-id)
STAT_VAL=$($APP_VENDOR_DIR/redis/src/redis-cli -h $APP_CONFIG_REDIS_IPADDRESS llen $APP_CONFIG_REDIS_KEY)

if [[ "$?" -eq 0 ]]; then
    STAT_NOW=$(date +%Y-%m-%dT%H:%M:%SZ)

    ARG1=$(cat <<EOF
    {
        "dimensions" : [
            {
                "name" : "ClusterName",
                "value" : "$1"
            },
            {
                "name" : "InstanceId",
                "value" : "$INSTANCE_ID"
            }
        ],
        "metric_name" : "QueueSize",
        "timestamp" : "$STAT_NOW",
        "unit" : "Count",
        "value" : $STAT_VAL.0
    }
EOF
    )

    /usr/local/bin/aws cloudwatch put-metric-data --namespace "logsearch" --metric-data "$ARG1" >> /dev/null
fi
