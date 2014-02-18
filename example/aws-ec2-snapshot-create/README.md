# About

    usage: run [-h] [--description DESCRIPTION] [--verbose]
               envname servicename [rolename]

    Utility for snapshotting a collection of volumes for a particular
    environment/service. If a role is not specified, a snapshot is created for all
    volumes. This copies over volume tags to the snapshot.

    positional arguments:
      envname               Environment name for (e.g. dev, prod, test)
      servicename           Service name (e.g. logsearch)
      rolename              Role name (e.g. elasticsearch)

    optional arguments:
      -h, --help            show this help message and exit
      --description DESCRIPTION
                            Snapshot Description
      --verbose, -v         Use multiple times to increase verbosity: none =
                            quiet, 1 = completions, 2 = summaries, 3 = details


# Installation

Take a look at [`bin/provision`](./bin/provision) for the requirements and install steps.


# Notes

This assumes the AWS credentials can be discovered via environment variables or EC2 IAM role. You still need to specify
the `AWS_DEFAULT_REGION` environment variable for API calls.


# Example

    $ ./bin/run -v --description 'Hot Backup' live logsearch
    enumerated volumes
    started snapshot from vol-7df8027f/elasticsearch (snap-375ed1d2)
    added volume tags to snap-375ed1d2
    started snapshot from vol-c03a13ec/redis (snap-3d5ed1d8)
    added volume tags to snap-3d5ed1d8
    started snapshot from vol-bd311891/elasticsearch (snap-025ed1e7)
    added volume tags to snap-025ed1e7


# Docker

## Build

    docker build -t logsearch/aws-ec2-snapshot-create example/aws-ec2-snapshot-create

## Run

    docker run -e AWS_DEFAULT_REGION -e AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY \
        logsearch/aws-ec2-snapshot-create \
        -v 'Hot Backup' live logsearch
