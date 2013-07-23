#!/bin/bash

set -e

ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i $2 -t ubuntu@`../../bin/find-instance-ip.sh Shipper0Instance` "~/perftest-patch/run.sh"
