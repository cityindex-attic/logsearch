import os
from fabric.context_managers import shell_env, settings
from fabric.api import put, run, sudo
from fabric.state import env
from fabric.utils import puts
from boto import ec2

# APP_ENVIRONMENT_NAME=dev \
# APP_SERVICE_NAME=logsearch-dpb587-test1 \
#   fab -i ~/.ssh/mykey.pem -f example/fabfile.py \
#     runfile:path=patch.sh,withsudo=1

env.user = 'ubuntu'

if 0 == len(env.hosts):
    env.hosts = []

    conn = ec2.connect_to_region(os.environ['AWS_DEFAULT_REGION'])

    filters = {}

    if 'APP_ENVIRONMENT_NAME' in os.environ:
        filters['tag:Environment'] = os.environ['APP_ENVIRONMENT_NAME']
    if 'APP_SERVICE_NAME' in os.environ:
        filters['tag:Service'] = os.environ['APP_SERVICE_NAME']
    if 'APP_ROLE_NAME' in os.environ:
        filters['tag:Service'] = os.environ['APP_ROLE_NAME']

    reservations = conn.get_all_instances(filters = filters)

    for reservation in reservations:
        for instance in reservation.instances:
            env.hosts.append(instance.ip_address)

# tasks

def pushfile(path):
    put(
        os.path.abspath(path),
        '/app/app/' + path,
        mirror_local_mode=True,
    )

def runfile(path, withsudo = '0'):
    put(
        os.path.abspath(path),
        '/tmp/fabfile-runfile',
        mirror_local_mode=True,
    )

    with settings(warn_only = True):
        if '1' == withsudo:
            sudo('/tmp/fabfile-runfile')
        else:
            run('/tmp/fabfile-runfile')

    run('rm /tmp/fabfile-runfile')

def githead():
    run('cd /app/app/ && git rev-parse HEAD')

def gitpull():
    run('cd /app/app/ && git pull --ff-only')

def uploadstats(bucket, start, stop, path = "report-stats/"):
    with shell_env(AWS_ACCESS_KEY = os.environ['AWS_ACCESS_KEY_ID'], AWS_SECRET_ACCESS_KEY = os.environ['AWS_SECRET_ACCESS_KEY']):
        run('cd /app/app ; ./bin/upload-stats "{0}" "{1}" "{2}" "{3}"'.format(bucket, path, start, stop))

def uptime():
    run('uptime')

def whoami():
    run('whoami')
