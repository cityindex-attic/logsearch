#!/bin/bash

set -x
set -e


#
# kibana
#

if [ ! -e $APP_VENDOR_DIR/kibana ] ; then
  KIBANA_VERSION="4918c89e03992e869b70d51881e9965312319a7e"
  echo "Download cityindex/kibana#$KIBANA_VERSION..."

  pushd $APP_VENDOR_DIR/
  mkdir -p kibana-tmp/
  wget -O - "https://github.com/cityindex/kibana/archive/$KIBANA_VERSION.tar.gz" | tar -xzC $APP_VENDOR_DIR/kibana-tmp --strip-components 1
  mv kibana-tmp/src kibana
  echo "cityindex/kibana#$KIBANA_VERSION" > kibana/VERSION_DEV
  rm -fr kibana-tmp
  popd
fi

echo "kibana:dev-$(cat $APP_VENDOR_DIR/kibana/VERSION_DEV)"
