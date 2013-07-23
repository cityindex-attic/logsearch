#!/bin/bash

# args logical-resource-id

set -e

RESULT=$(aws cloudformation list-stack-resources --stack-name "$USER-logstash-`basename $PWD`")
PHYSICALID=$(echo $RESULT | sed -E "s/.*\"PhysicalResourceId\": \"([^\"]+)\", \"LogicalResourceId\": \"$1\".*/\1/")
INSTANCE=$(aws ec2 describe-instances --instance-id $PHYSICALID)
echo $INSTANCE | sed -E 's/.*"PublicIpAddress": "([^"]+)".*/\1/'
