#!/bin/bash

# dump 2mb random data to be parsed and be sure it was marked _groktrimmed; return the length so we can verify
MSGLEN=$(head -c 2097152 /dev/urandom | base64 --wrap=0 | rake logstash:debug[other] | grep _groktrimmed | awk "{ print length }")

# verify it was just over 1mb (allowing extra space for logstash fields)
exit $([[ "$MSGLEN" -gt 1048576 ]] && [[ "$MSGLEN" -lt 1068576 ]])
