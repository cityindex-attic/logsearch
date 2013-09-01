#!/bin/bash

# args: cluster_name, rrd_file, metric_name

# * * * * * (. /app/.env ; /app/app/example/aws-cloudwatch/push-latest-rrd.sh logsearch-ppe /var/lib/collectd/rrd/$(/bin/hostname --fqdn)/redis_logstash/gauge-llen_logstash.rrd  QueueSize) >> /app/var/log/cron.log 2>&1
# * * * * * (. /app/.env ; /app/app/example/aws-cloudwatch/push-latest-rrd.sh logsearch-ppe /var/lib/collectd/rrd/$(/bin/hostname --fqdn)/elasticsearch_logstash/gauge-lag.rrd  IndexLag) >> /app/var/log/cron.log 2>&1

set -e

CLUSTER_NAME=$1
RRD_FILE=$2
METRIC_NAME=$3

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
                "Name" : "ClusterName",
                "Value" : "$CLUSTER_NAME"
            }
        ],
        "MetricName" : "$METRIC_NAME",
        "Timestamp" : "$RRD_DATE",
        "Unit" : "Count",
        "Value" : $RRD_STAT
    }
EOF
    )

    /usr/local/bin/aws cloudwatch put-metric-data --namespace "logsearch" --metric-data "$ARG1" > /dev/null
fi
