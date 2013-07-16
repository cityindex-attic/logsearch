import collectd
import socket

REDIS_HOST = 'localhost'
REDIS_PORT = 6379


def fetch_results():
    res = {}

    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.connect((REDIS_HOST, REDIS_PORT))
    except socket.error, e:
        collectd.error('redis_logstash plugin: Error connecting to %s:%d - %r' % (REDIS_HOST, REDIS_PORT, e))

        return None

    fp = s.makefile('r')

    s.sendall('llen logstash\r\n')

    res['llen logstash'] = int(fp.readline()[1:-1])

    s.close()

    return res


def dispatch(key, type, value):
    val = collectd.Values(plugin = 'redis_logstash')
    val.type = type
    val.type_instance = key
    val.values = [ value ]
    val.dispatch()


def config_callback(conf):
    global REDIS_HOST, REDIS_PORT

    for node in conf.children:
        if node.key == 'Host':
            REDIS_HOST = node.values[0]
        elif node.key == 'Port':
            REDIS_PORT = int(node.values[0])
        else:
            collectd.warning('redis_logstash plugin: Unknown config key: %s.' % node.key)


def read_callback():
    res = fetch_results()

    dispatch('llen_logstash', 'gauge', res['llen logstash'])


collectd.register_config(config_callback)
collectd.register_read(read_callback)
