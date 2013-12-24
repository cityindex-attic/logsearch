#!/bin/bash

set -x
set -e


#
# redis
#

if ! (which redis-server 1>/dev/null 2>&1) ; then
    echo "Installing redis..."

    echo "deb http://ppa.launchpad.net/rwky/redis/ubuntu precise main" | sudo tee -a /etc/apt/sources.list
    sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 5862E31D
    sudo apt-get update
    sudo apt-get install redis-server
    sudo service redis-server stop
    sudo rm /etc/init/redis-server.conf
    sudo rm /etc/init.d/redis-server
fi

echo "redis:$(redis-server -v | awk -F '=' '/v=/ { print $2 }')"


#
# sudo-dependent
#

if (which collectd 1>/dev/null 2>&1) ; then
    if [ "$APP_CONFIG_REDIS_IPADDRESS" == '0.0.0.0' ] ; then
        APP_CONFIG_REDIS_IPADDRESS="127.0.0.1"
    fi

    sudo /bin/bash <<EOF
        if ! grep 'Import redis_info' /etc/collectd/collectd.conf ; then
            wget -qO /opt/collectd/lib/collectd/plugins/python/redis_info.py 'https://raw.github.com/powdahound/redis-collectd-plugin/master/redis_info.py'
            sed -ri 's@(^    # python-placeholder)@\1\n\
        Import "redis_info"\n\
        <Module redis_info>\n\
            Host "$APP_CONFIG_REDIS_IPADDRESS"\n\
            Port 6379\n\
        </Module>@' /etc/collectd/collectd.conf
        fi

        if ! grep 'Import redis_logstash' /etc/collectd/collectd.conf ; then
            cp /app/app/example/collectd/redis_logstash.py /opt/collectd/lib/collectd/plugins/python/redis_logstash.py
            sed -ri 's@(^    # python-placeholder)@\1\n\
        Import "redis_logstash"\n\
        <Module redis_logstash>\n\
            Host "$APP_CONFIG_REDIS_IPADDRESS"\n\
            Port 6379\n\
        </Module>@' /etc/collectd/collectd.conf
        fi

        service collectd restart
EOF
fi
