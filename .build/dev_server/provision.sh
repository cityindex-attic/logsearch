#!/bin/bash
set -x
set -e

#
# system-wide deps
#
/app/app/.build/ubuntu-12/provision.sh
/app/app/.build/dev_server/extra.sh


#
# app
#
if [ "$TRAVIS" = "true" ]; then
    APP_USER=travis
    SUDO="rvmsudo"
elif [ -e /home/vagrant ] ; then
    APP_USER=vagrant
    SUDO="sudo"
else
    APP_USER=$(ls /home/)
    SUDO="sudo"
fi

echo "APP_USER detected as: $APP_USER"

mkdir -p /app

if [ 'vagrant' != "$APP_USER" ] ; then
    if [ ! -e /app/app ] ; then
        mv /vagrant /app/app
        ln -s /app/app /vagrant
    fi
fi

chown $APP_USER:$APP_USER /app

echo '$APP_USER soft nofile 32000' > /etc/security/limits.d/$APP_USER.conf
echo '$APP_USER hard nofile 64000' >> /etc/security/limits.d/$APP_USER.conf

/app/app/bin/default-app-dir > /app/.env
echo "export APP_USER='$APP_USER'" >> /app/.env
echo 'export APP_CONFIG_ES_IPADDRESS=0.0.0.0' >> /app/.env
echo 'export APP_CONFIG_REDIS_IPADDRESS=0.0.0.0' >> /app/.env
echo 'export APP_CONFIG_REDIS_KEY=logstash' >> /app/.env
echo 'export APP_CONFIG_IMPORTQUEUE_KEY=importqueue' >> /app/.env
chmod +x /app/.env

$SUDO -H -u $APP_USER /bin/bash << 'EOF'
    set -x
    set -e
    
    cd /app/app/

    echo "PWD: $(pwd)"
    
    . /app/.env
    
    mkdir -p $APP_VENDOR_DIR
    mkdir -p $APP_LOG_DIR
    mkdir -p $APP_RUN_DIR
    mkdir -p $APP_TMP_DIR
    mkdir -p $APP_DATA_DIR

    bundle install

    ./srv/elasticsearch/provision.sh
    ./srv/logstash/provision.sh
    ./srv/kibana/provision.sh
    ./srv/redis/provision.sh
EOF

. /app/.env

if [ ! -d $APP_TMP_DIR/heap-dump ] ; then
    if [ -d /mnt ] ; then
        $SUDO mkdir -p /mnt/app-tmp-heap-dump
        $SUDO chown $APP_USER:$APP_USER /mnt/app-tmp-heap-dump
        [ -e $APP_TMP_DIR/heap-dump ] || ln -s /mnt/app-tmp-heap-dump $APP_TMP_DIR/heap-dump
    else
        mkdir -p $APP_TMP_DIR/heap-dump
    fi
fi

#
# vagrant hacks
#

# workaround to avoid the alert about it not being writable - http://wiki.nginx.org/CoreModule#error_log
touch /var/log/nginx/error.log
chown $APP_USER /var/log/nginx/error.log

# a custom fastcgi_cache_path doesn't seem to be respected in nginx.conf; this is a hack workaround
chown -R $APP_USER:$APP_USER /var/lib/nginx


echo "=-=-=-=-=-=-=-=-=-=-=-="
echo "Provisioning completed!"
echo "=-=-=-=-=-=-=-=-=-=-=-="
