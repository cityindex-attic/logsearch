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


#
# sudo-dependent
#

if (which collectd 1>/dev/null 2>&1) ; then
    if [ "$APP_CONFIG_REDIS_IPADDRESS" -eq '0.0.0.0' ] ; then
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
