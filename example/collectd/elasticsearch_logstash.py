import collectd

from datetime import datetime
import math
import urllib2
import json

ES_HOST = 'localhost'
ES_PORT = '6379'

def config_callback(conf):
    global ES_HOST, ES_PORT

    for node in conf.children:
        if node.key == 'Host':
            ES_HOST = node.values[0]
        elif node.key == 'Port':
            ES_PORT = str(int(node.values[0]))
        else:
            collectd.warning('elasticsearch_delay plugin: Unknown config key: %s.' % node.key)


def read_callback():
    now = datetime.utcnow()

    reqData = {
        "query": {
            "filtered": {
                "query": {
                    "bool": {
                        "should": [
                            {
                                "query_string": {
                                    "query": "*"
                                }
                            }
                        ]
                    }
                },
                "filter": {
                    "bool": {
                        "must": [
                            {
                                "range": {
                                    "@timestamp": {
                                        "to": now.strftime('%Y-%m-%dT%H:%M:%S.999Z'),
                                        "from": "2001-01-01T00:00:00.000Z"
                                    }
                                }
                            }
                        ]
                    }
                }
            }
        },
        "size": 1,
        "sort": [
            {
                "@timestamp": {
                    "order": "desc"
                }
            }
        ]
    }
    
    res = urllib2.urlopen(
        'http://' + ES_HOST + ':' + ES_PORT + '/logstash-' + now.strftime('%Y.%m.%d') + '/_search',
        json.dumps(reqData),
        30
    )
    
    resData = json.loads(res.read())
    res.close()
    
    then = datetime.strptime(resData['hits']['hits'][0]['_source']['@timestamp'], '%Y-%m-%dT%H:%M:%S.%fZ')

    val = collectd.Values(plugin = 'elasticsearch_logstash')
    val.type = 'gauge'
    val.type_instance = 'lag'
    val.values = [ math.floor((now - then).total_seconds()) ]
    val.dispatch()


collectd.register_config(config_callback)
collectd.register_read(read_callback)
