#!/bin/bash

set -x
set -e


#
# kibana
#

if [ ! -e $APP_VENDOR_DIR/kibana ] ; then
    KIBANA_VERSION="v3.0.0milestone4"
    echo "Download kibana-dev-$KIBANA_VERSION..."

    pushd $APP_VENDOR_DIR/
    mkdir -p kibana-tmp/
    wget -O - "https://github.com/elasticsearch/kibana/archive/$KIBANA_VERSION.tar.gz" | tar -xzC $APP_VENDOR_DIR/kibana-tmp --strip-components 1
    mv kibana-tmp/src kibana
    echo "$KIBANA_VERSION" > kibana/VERSION_DEV
    rm -fr kibana-tmp
    popd
fi

echo "kibana:dev-$(cat $APP_VENDOR_DIR/kibana/VERSION_DEV)"
