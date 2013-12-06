The `aggregate.rb` script consumes log4net messages streamed to STDIN, aggregating by hour and minute. 

`process-logs.sh` script fetches logs from S3 and streams them into the aggregation script.  Invoke as follows:

```
export BASE=~/workspace/logsearch/examples/log-event-rate-measurer
mkdir ~/tmp-logs/
cd ~/tmp-logs/
$BASE/process-logs.sh "ruby $BASE/aggregate.rb"
```
