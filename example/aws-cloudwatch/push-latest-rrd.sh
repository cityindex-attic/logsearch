#!/bin/bash

# args: rrd_file, environment_name, service_name, metric_name

# * * * * * (. /app/.env ; /app/app/example/aws-cloudwatch/push-latest-rrd.sh dev logsearch-repodev QueueSize /var/lib/collectd/rrd/$(/bin/hostname --fqdn)/redis_logstash/gauge-llen_logstash.rrd) >> /app/var/log/cron.log 2>&1
# * * * * * (. /app/.env ; /app/app/example/aws-cloudwatch/push-latest-rrd.sh dev logsearch-repodev IndexLag /var/lib/collectd/rrd/$(/bin/hostname --fqdn)/elasticsearch_logstash/gauge-lag.rrd) >> /app/var/log/cron.log 2>&1

set -e

RRD_FILE=$1
ENVIRONMENT_NAME=$2
SERVICE_NAME=$3
ROLE_NAME=$4

INSTANCE_ID=$(ec2metadata --instance-id)
RRD_LINE=$(rrdtool lastupdate $RRD_FILE | tail -n1)

if [[ ! `echo $RRD_LINE | grep -E ": -nan(\$| )"` ]] ; then
    RRD_DATE=`echo $RRD_LINE | awk -F ':' '{ system("date --date=\"@" $1 "\" +%Y-%m-%dT%H:%M:%SZ") }'`
    RRD_STAT=$((echo -n 'print eval ' ; echo $RRD_LINE | sed -r "s/.*: ([^ ]+)(\$| ).*/\1/") | perl)

    if [[ ! `echo $RRD_STAT | grep \\\\.` ]] ; then
        RRD_STAT="$RRD_STAT.0"
    fi

    ARG1=$(cat <<EOF
    {
        "Dimensions" : [
            {
                "Name" : "Service",
                "Value" : "$SERVICE_NAME"
            }
        ],
        "MetricName" : "$ROLE_NAME",
        "Timestamp" : "$RRD_DATE",
        "Unit" : "Count",
        "Value" : $RRD_STAT
    }
EOF
    )

    /usr/local/bin/aws cloudwatch put-metric-data --namespace "$ENVIRONMENT_NAME" --metric-data "$ARG1" > /dev/null
fi
