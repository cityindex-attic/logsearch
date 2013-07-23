dpb587-logstash-perftest-parser4n
=================================

This quadruples the number of parsers that are moving the messages from redis to elasticsearch.

Hypothesis:

 * this may saturate the network bandwidth (observed by low CPU usage)
 * this may saturate the elasticsearch primary node (either cpu or disk, probably cpu)
