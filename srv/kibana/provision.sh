#!/bin/bash

set -e


#
# kibana
#

if [ ! -e $APP_VENDOR_DIR/kibana ] ; then
    KIBANA_VERSION="v3.0.0milestone4"
    echo "Download kibana-dev-$KIBANA_VERSION..."

    pushd $APP_VENDOR_DIR/
    curl --location -o kibana.zip "https://github.com/elasticsearch/kibana/archive/$KIBANA_VERSION.zip"
    unzip -q kibana
    mv "kibana-*" kibana
    echo "$KIBANA_VERSION" > kibana/VERSION_DEV
    rm kibana.zip
    popd
fi

echo "kibana:dev-$(cat $APP_VENDOR_DIR/kibana/VERSION_DEV)"
