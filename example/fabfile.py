import os
from fabric.context_managers import shell_env
from fabric.api import put, run, sudo
from fabric.state import env
from fabric.utils import puts
from boto import ec2

# APP_CLUSTER_NAME=logsearch-test1 fab githead

env.user = 'ubuntu'

# optionally, auto-configure hosts from ec2

if 0 == len(env.hosts):
    env.hosts = []

    conn = ec2.connect_to_region(os.environ['AWS_DEFAULT_REGION'])

    reservations = conn.get_all_instances(filters = { 'tag:logsearch-cluster' : os.environ['APP_CLUSTER_NAME'] });

    for reservation in reservations:
        for instance in reservation.instances:
            env.hosts.append(instance.ip_address)

# tasks

def pushfile(path):
    put(
        os.path.dirname(__file__) + '/' + path,
        '/app/app/' + path,
        mirror_local_mode=True
    )

def githead():
    run('cd /app/app/ && git rev-parse HEAD')

def up2date():
    run('cd /app/app/ && git pull --ff-only')

def uploadstats(bucket, start, stop, path = "report-stats/"):
    with shell_env(AWS_ACCESS_KEY = os.environ['AWS_ACCESS_KEY_ID'], AWS_SECRET_ACCESS_KEY = os.environ['AWS_SECRET_ACCESS_KEY']):
        run('cd /app/app ; ./bin/upload-stats "{0}" "{1}" "{2}" "{3}"'.format(bucket, path, start, stop))

def uptime():
    run('uptime')

def whoami():
    run('whoami')
