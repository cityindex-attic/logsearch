#!/bin/bash

set -e


#
# elasticsearch
#

if [ ! -e $APP_VENDOR_DIR/elasticsearch ] ; then
    echo "Downloading elasticsearch-0.90.1..."

    pushd $APP_VENDOR_DIR/
    echo $PWD
    curl --location -o elasticsearch-0.90.1.tar.gz https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-0.90.1.tar.gz
    tar -xzf elasticsearch-0.90.1.tar.gz
    mv elasticsearch-0.90.1 elasticsearch
    rm elasticsearch-0.90.1.tar.gz
    popd
fi


#
# elasticsearch/cloud-aws
#

if [ ! -e $APP_VENDOR_DIR/elasticsearch/plugins/cloud-aws ] ; then
    echo "Downloading elasticsearch/cloud-aws-1.12.0..."

    pushd $APP_VENDOR_DIR/elasticsearch/
    ./bin/plugin -install elasticsearch/elasticsearch-cloud-aws/1.12.0
    popd
fi


#
# sudo-dependent
#

if (which collectd 1>/dev/null 2>&1) ; then
    sudo /bin/bash <<EOF
        if ! grep 'Import elasticsearch' /etc/collectd/collectd.conf ; then
            wget -qO /opt/collectd/lib/collectd/plugins/python/elasticsearch.py 'https://raw.github.com/phobos182/collectd-elasticsearch/master/elasticsearch.py'
            sed -ri 's@(^    # python-placeholder)@\1\n\
        Import "elasticsearch"\n\
        <Module elasticsearch>\n\
            Host "$APP_CONFIG_ES_IPADDRESS"\n\
            Port 9200\n\
        </Module>@' /etc/collectd/collectd.conf
            service collectd restart
        fi
    EOF
fi
