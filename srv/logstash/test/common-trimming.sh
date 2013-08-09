#!/bin/bash

# dump tenfold the data limit to be parsed and be sure it was marked _groktrimmed; return the length so we can verify
MSGLEN=$(head -c 1$1 /dev/urandom | base64 --wrap=0 | rake logstash:debug[other] | grep _groktrimmed | awk "{ print length }")

# verify it was just over the limit (allowing extra space for logstash fields)
exit $([[ "$MSGLEN" -gt $1 ]] && [[ "$MSGLEN" -lt "$1+2048" ]])
