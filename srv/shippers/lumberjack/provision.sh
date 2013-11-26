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
    
    curl --location -o $DEST/lumberjack.zip https://s3.amazonaws.com/logsearch-ciapi_latency_monitor-bot/lumberjack.nix.zip
    sudo apt-get install unzip
    unzip $DEST/lumberjack.zip
    chmod +x $DEST/lumberjack
fi

echo "lumberjack:$(display_file_info $DEST/lumberjack)"
