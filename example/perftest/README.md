In doing some performance testing, it's helpful to have a consistent, repeatable structure to do so. These scripts assume the AWS cloud platform for running the tests.

Each folder in [`profile`](./perftest) should be a unique performance test for a hypothesis. Inside the profile's folder, there are three key files:

 * `README.md` - human-friendly description of the test
 * `formation.template` - a CloudFormation template for provisioning all the resources
 * `run.sh` - a script for kicking off the test suite

Any subdirectories must be named after the CloudFormation EC2 Instance Logical Name. They'll get rsynced into `~/perftest-patch` on the instance. If there's a `patch.sh` script, it'll be run on the instance after the normal CloudFormation provisioning process finishes. Use it to apply any patches you want to test out.

Usage
=====

To get started, change into the profile directory you want to test and run:

    ../../bin/create-stack.sh {ssh-key-name} {ssh-key-path}

The command takes care of creating the stack, provisioning/patching the nodes, running the test, gathering up the statistics, and uploading them to S3 for later review. It includes additional sleep time to better isolate stats. You'll want to include AWS credentials or an IAM role which allows uploading the final stats.

Once it has completed, you can login to the nodes to investigate further or manually terminate the stack.

To analyze the statistics, pull down the files from S3, or use the included report-stats graph page. For example, here are the baseline profile results (while available):

 * [http://ci-logsearch.s3.amazonaws.com/report-stats/index.html?perftest/baseline/broker-n0.json](http://ci-logsearch.s3.amazonaws.com/report-stats/index.html?perftest/baseline/broker-n0.json)
 * [http://ci-logsearch.s3.amazonaws.com/report-stats/index.html?perftest/baseline/elasticsearch-p0.json](http://ci-logsearch.s3.amazonaws.com/report-stats/index.html?perftest/baseline/elasticsearch-p0.json)
 * [http://ci-logsearch.s3.amazonaws.com/report-stats/index.html?perftest/baseline/elasticsearch-r0.json](http://ci-logsearch.s3.amazonaws.com/report-stats/index.html?perftest/baseline/elasticsearch-r0.json)
 * [http://ci-logsearch.s3.amazonaws.com/report-stats/index.html?perftest/baseline/parser-n0.json](http://ci-logsearch.s3.amazonaws.com/report-stats/index.html?perftest/baseline/parser-n0.json)
 * [http://ci-logsearch.s3.amazonaws.com/report-stats/index.html?perftest/baseline/shipper-n0.json](http://ci-logsearch.s3.amazonaws.com/report-stats/index.html?perftest/baseline/shipper-n0.json)

There's also a second report-stats [summary page](http://ci-logsearch.s3.amazonaws.com/report-stats/summarize.html) which takes a look at the raw JSON files to pull out some of the more notable stats into a more readable report. Just paste the list of uploaded JSON files and wait a few seconds for them to download and be analyzed; for example:

 * http://ci-logsearch.s3.amazonaws.com/report-stats/perftest/baseline/broker-n0.json
 * http://ci-logsearch.s3.amazonaws.com/report-stats/perftest/baseline/elasticsearch-p0.json
 * http://ci-logsearch.s3.amazonaws.com/report-stats/perftest/baseline/elasticsearch-r0.json
 * http://ci-logsearch.s3.amazonaws.com/report-stats/perftest/baseline/parser-n0.json
 * http://ci-logsearch.s3.amazonaws.com/report-stats/perftest/baseline/shipper-n0.json
