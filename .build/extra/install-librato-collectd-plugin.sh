#!/bin/bash

# args: email, api-token, optional:source-name

set -e

if [ ! -e /etc/collectd/collectd.d/librato.conf ] ; then
    if [ ! -d /etc/collectd/collectd.d ] ; then
        mkdir /etc/collectd/collectd.d
        echo 'Include "/etc/collectd/collectd.d/*.conf"' >> /etc/collectd/collectd.conf
    fi

    if [ "" == "$3" ]; then
        export SOURCE_NAME="$APP_CLUSTER_NAME.$APP_NODE_NAME.$APP_DEPLOY_NAME.`hostname`"
    else
        export SOURCE_NAME="$3"
    fi

    wget -qO /opt/collectd/lib/collectd/plugins/python/collectd-librato.py 'https://raw.github.com/librato/collectd-librato/master/lib/collectd-librato.py'

    . /app/.env

    cat <<EOF > /etc/collectd/collectd.d/librato.conf
<Plugin python>
    ModulePath "/opt/collectd/lib/collectd/plugins/python/"
    Import "collectd-librato"
    <Module "collectd-librato">
        Source "$SOURCE_NAME"
        Email "$1"
        APIToken "$2"
        IncludeRegex "collectd\.cpu-.*,collectd\.df\..*,collectd\.disk-.*,collectd\.elasticsearch\..*,collectd\.entropy\..*,collectd\.interface\..*,collectd\.load\..*,collectd\.memory\..*,collectd\.processes\..*,collectd\.redis_.*,collectd\.users\..*"
    </Module>
</Plugin>
EOF
    service collectd restart
fi
