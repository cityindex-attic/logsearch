#!/bin/bash

set -e


#
# kibana
#

if [ ! -e $APP_VENDOR_DIR/kibana ] ; then
    KIBANA_VERSION="e57aba10da909768d3191aec4e672b2531e21f18"
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
