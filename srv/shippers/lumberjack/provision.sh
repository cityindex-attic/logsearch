#!/bin/bash

set -e

DEST=${1:-$DEST} 

function display_file_info {
	ls -oh $1 | awk '{ print $8 " " $5 " " $6 " " $4; }'
}

#
# logstash
#

if [ ! -e $DEST/lumberjack ] ; then
    echo "Downloading lumberjack..."
    
    curl https://s3.amazonaws.com/ci-labs-buildpack-downloads/lumberjack/lumberjack-1f1f44bc60cb7a271f2bd06f3db1ed666c1a9b22.tar.gz | tar -C $DEST -zx
    chmod +x $DEST/lumberjack
fi

echo "lumberjack:$(display_file_info $DEST/lumberjack)"
