#!/bin/bash

# args: organization-id, api-key

set -e

if ! (which bprobe 1>/dev/null 2>&1) ; then
  curl -3 -s https://app.boundary.com/assets/downloads/setup_meter.sh > setup_meter.sh
  chmod +x setup_meter.sh
  ./setup_meter.sh -d -i "$1:$2"
  rm setup_meter.sh
fi
