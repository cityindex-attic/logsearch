#!/bin/bash

# args: ssh-command, resize-args...

set -o errexit
set -o xtrace

if [[ "-" != "$1" ]]; then
    $1 &
    SSHPID=$!
    sleep 15
fi

./bin/resize.rb "$2" "$3" "$4" "$5" "$6"

if [[ "-" != "$1" ]] ; then
    kill -s TERM $SSHPID

    wait $SSHPID
fi
