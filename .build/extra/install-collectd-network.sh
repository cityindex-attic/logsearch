#!/bin/bash

# args: host, [port]

set -e

if [ ! -e /etc/collectd/collectd.d/network.conf ] ; then
    if [ ! -d /etc/collectd/collectd.d ] ; then
        mkdir /etc/collectd/collectd.d
        echo 'Include "/etc/collectd/collectd.d/*.conf"' >> /etc/collectd/collectd.conf
    fi

    if [ "" == "$2" ]; then
        COLLECTD_PORT="25826"
    else
        COLLECTD_PORT="$2"
    fi

    cat <<EOF > /etc/collectd/collectd.d/network.conf
LoadPlugin network
<Plugin network>
    Server "$1" "$COLLECTD_PORT"
</Plugin>
EOF
    service collectd restart
fi
