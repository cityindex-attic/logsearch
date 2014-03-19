#!/bin/bash

set -x
set -e


#
# elasticsearch
#

if [ ! -e $APP_VENDOR_DIR/elasticsearch ] ; then
  echo "Downloading elasticsearch-1.0.1..."

  pushd $APP_VENDOR_DIR/
  echo $PWD
  curl --location -o elasticsearch-1.0.1.tar.gz https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-1.0.1.tar.gz
  tar -xzf elasticsearch-1.0.1.tar.gz
  mv elasticsearch-1.0.1 elasticsearch
  rm elasticsearch-1.0.1.tar.gz
  popd
fi


#
# elasticsearch/cloud-aws
#

if [ ! -e $APP_VENDOR_DIR/elasticsearch/plugins/cloud-aws ] ; then
  echo "Downloading elasticsearch/cloud-aws-2.0.0.RC1..."

  pushd $APP_VENDOR_DIR/elasticsearch/
  ./bin/plugin -install elasticsearch/elasticsearch-cloud-aws/2.0.0.RC1
  popd
fi


#
# royrusso/elasticsearch-HQ
#

if [ ! -e $APP_VENDOR_DIR/elasticsearch/plugins/HQ ] ; then
  echo "Downloading royrusso/elasticsearch-HQ..."

  pushd $APP_VENDOR_DIR/elasticsearch/
  ./bin/plugin -install royrusso/elasticsearch-HQ
  popd
fi


#
# elasticsearch-jetty
#

if [ ! -e $APP_VENDOR_DIR/elasticsearch/plugins/jetty-1.0.1-beta ] ; then
  echo "Downloading elasticsearch-jetty-1.0.1-beta..."

  pushd $APP_VENDOR_DIR/elasticsearch/
  ./bin/plugin -url https://ci-logsearch.s3.amazonaws.com/elasticsearch-jetty-1.0.1-beta.zip -install jetty-1.0.1-beta
  popd
fi


#
# sudo-dependent
#

if (which collectd 1>/dev/null 2>&1) ; then
  if [ "$APP_CONFIG_ES_IPADDRESS" == '0.0.0.0' ] ; then
    APP_CONFIG_ES_IPADDRESS="127.0.0.1"
  fi

  sudo /bin/bash <<EOF
    if ! grep 'Import elasticsearch_logstash' /etc/collectd/collectd.conf ; then
      cp /app/app/example/collectd/elasticsearch_logstash.py /opt/collectd/lib/collectd/plugins/python/elasticsearch_logstash.py
      sed -ri 's@(^  # python-placeholder)@\1\n\
  Import "elasticsearch_logstash"\n\
  <Module elasticsearch_logstash>\n\
      Host "$APP_CONFIG_ES_IPADDRESS"\n\
      Port 9200\n\
  </Module>@' /etc/collectd/collectd.conf
      service collectd restart
    fi

    if ! grep 'Import elasticsearch' /etc/collectd/collectd.conf ; then
      wget -qO /opt/collectd/lib/collectd/plugins/python/elasticsearch.py 'https://raw.github.com/phobos182/collectd-elasticsearch/7691797dd0e4bb59212648489066dc9a0abab21d/elasticsearch.py'
      sed -ri 's@(^  # python-placeholder)@\1\n\
  Import "elasticsearch"\n\
  <Module elasticsearch>\n\
      Host "$APP_CONFIG_ES_IPADDRESS"\n\
      Port 9200\n\
  </Module>@' /etc/collectd/collectd.conf
      service collectd restart
    fi
EOF
fi
