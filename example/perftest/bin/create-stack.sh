#!/bin/bash

# args: ssh-key-name, ssh-key-path

set -e

STACK_NAME="$USER-logstash-`basename $PWD`"
IPADDR=`curl -s ifconfig.me`

echo 'Creating stack...'

CREATE_STACK=$(aws cloudformation create-stack \
    --parameters "[{\"parameter_key\":\"KeyName\",\"parameter_value\":\"$1\"},{\"parameter_key\":\"ClusterName\",\"parameter_value\":\"$STACK_NAME\"},{\"parameter_key\":\"ExternalAccessCidrRange\",\"parameter_value\":\"$IPADDR/32\"}]" \
    --stack-name $STACK_NAME \
    --tags '{"1":{"name":"cost-centre","value":"logsearch-dev"}}' \
    --template-body "`cat formation.template`"
)

echo 'Waiting for stack creation to complete...'

DESCRIBE_STACK=''

while ! (echo $DESCRIBE_STACK | grep '"StackStatus": "CREATE_COMPLETE"') > /dev/null ; do
    sleep 15

    DESCRIBE_STACK=$(aws cloudformation describe-stacks --stack-name $STACK_NAME)
done

echo 'Waiting a little longer...'

sleep 300

echo 'Patching...'

for NODE in * ; do
    if [ -d $NODE ] ; then
        echo $NODE
        IPADDRESS=$(../../bin/find-instance-ip.sh $NODE)
        rsync --progress -auze "ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i $2" $NODE/ ubuntu@$IPADDRESS:~/perftest-patch

        if [ -f $NODE/patch.sh ] ; then
            ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i $2 ubuntu@$IPADDRESS -t "~/perftest-patch/patch.sh"
        fi
    fi
done

echo 'Sleeping to quiet the nodes...'

SESSION_START=`date -u +%Y-%m-%dT%TZ`
echo "SESSION_START='$SESSION_START'"

sleep 360

echo 'Running...'

./run.sh $1 $2

echo 'Sleeping to quiet the nodes...'

sleep 360

SESSION_STOP=`date -u +%Y-%m-%dT%TZ`
echo "SESSION_STOP='$SESSION_STOP'"

echo 'Gathering stats...'

sleep 60

for NODE in $(aws cloudformation list-stack-resources --stack-name $STACK_NAME | tr ' ' '\n' | grep 'Instance"' | grep -v '"AWS::EC2::Instance",' | sed -E 's/^"(.*)"$/\1/') ; do
    echo $NODE
    IPADDRESS=$(../../bin/find-instance-ip.sh $NODE)

    ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i $2 ubuntu@$IPADDRESS "cd /app/app/ ; ./bin/upload-stats ci-logsearch report-stats/ '$SESSION_START' '$SESSION_STOP'"
done
