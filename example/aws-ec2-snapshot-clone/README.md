# About

    usage: run [-h] --availability-zone AVAILABILITY_ZONE
               [--clone-envname CLONE_ENVNAME]
               [--clone-servicename CLONE_SERVICENAME]
               [--clone-rolename CLONE_ROLENAME] [--verbose]
               description envname servicename [rolename]

    Utility for restoring a set of snapshots, optionally under a different
    environment and service name.

    positional arguments:
      description           Snapshot description
      envname               Environment name for (e.g. dev, prod, test)
      servicename           Service name (e.g. logsearch)
      rolename              Role name (e.g. elasticsearch)

    optional arguments:
      -h, --help            show this help message and exit
      --availability-zone AVAILABILITY_ZONE
                            AWS Availability Zone to create the volumes
      --clone-envname CLONE_ENVNAME
                            New environment name for (e.g. dev, prod, test)
      --clone-servicename CLONE_SERVICENAME
                            New service name (e.g. logsearch)
      --clone-rolename CLONE_ROLENAME
                            New role name (e.g. elasticsearch)
      --verbose, -v         Use multiple times to increase verbosity: none =
                            quiet, 1 = completions, 2 = summaries, 3 = details


# Installation

Take a look at [`bin/provision`](./bin/provision) for the requirements and install steps.


# Notes

This assumes the AWS credentials can be discovered via environment variables or EC2 IAM role. You still need to specify
the `AWS_DEFAULT_REGION` environment variable for API calls.


# Example

    $ ./bin/run -v --availability-zone eu-west-1a --clone-envname dev --clone-servicename logsearch-dpb587-test1 'Hot Backup' live logsearch
    enumerated snapshots
    created volume from snap-3d5ed1d8/redis (vol-ae202582)
    added snapshot tags to vol-ae202582
    created volume from snap-025ed1e7/elasticsearch (vol-0d202521)
    added snapshot tags to vol-0d202521
    created volume from snap-375ed1d2/elasticsearch (vol-982025b4)
    added snapshot tags to vol-982025b4


# Docker

## Build

    docker build -t logsearch/aws-ec2-snapshot-clone example/aws-ec2-snapshot-clone

## Run

    docker run -e AWS_DEFAULT_REGION -e AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY \
        logsearch/aws-ec2-snapshot-clone \
        -v --availability-zone eu-west-1a --clone-envname dev --clone-servicename logsearch-dpb587-test1 'Hot Backup' live logsearch
