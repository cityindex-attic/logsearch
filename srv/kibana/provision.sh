#!/bin/bash

set -e


#
# kibana
#

if [ ! -e $APP_VENDOR_DIR/kibana ] ; then
    KIBANA_VERSION="050ee74c10851ae9178d471e71d752c5d76986fc"
    echo "Download kibana-dev-$KIBANA_VERSION..."

    pushd $APP_VENDOR_DIR/
    curl --location -o kibana.zip "https://github.com/elasticsearch/kibana/archive/$KIBANA_VERSION.zip"
    unzip -q kibana
    mv "kibana-$KIBANA_VERSION" kibana
    echo "$KIBANA_VERSION" > kibana/VERSION_DEV
    rm kibana.zip
    popd
fi

echo "kibana:dev-$(cat $APP_VENDOR_DIR/kibana/VERSION_DEV)"
