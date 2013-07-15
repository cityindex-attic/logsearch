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
    sudo /bin/bash <<EOF
        if ! grep 'Import redis_info' /etc/collectd/collectd.conf ; then
            wget -qO /opt/collectd/lib/collectd/plugins/python/redis_info.py 'https://raw.github.com/powdahound/redis-collectd-plugin/master/redis_info.py'
            sed -ri 's@(^    # python-placeholder)@\1\n\
        Import "redis_info"\n\
        <Module redis_info>\n\
            Host "$APP_CONFIG_REDIS_IPADDRESS"\n\
            Port 6379\n\
            Verbose false\n\
        </Module>@' /etc/collectd/collectd.conf
            service collectd restart
        fi
EOF
fi
