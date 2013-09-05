logsearch-development-flow
==============================

A development environment with [logstash](http://logstash.net/) + [Elasticsearch](http://www.elasticsearch.org/) + [Kibana 3](http://three.kibana.org/).


### Quick Guide

**Initialize the application**

    git clone git://github.com/cityindex/logsearch-development-flow.git
    cd logsearch-development-flow/
    vagrant up

**Connect to the application**

    vagrant ssh
    cd /app/app/

**Start the services** - this will start all the services so you can easily have a look at the various aspects. Open
[localhost:4567](http://localhost:4567) (via vagrant) to see the frontend.

    rake run

**Backfill data** - once the elasticsearch server has started, you can backfill logs if you have them laying around.

    rake logstash:pv_to_elasticsearch[nginx_combined,/on_vm/path/to/logs/labs.cityindex.com.nginx.logs/access.log*]
    rake logstash:pv_to_elasticsearch[iis_default,/on_vm/path/to/logs/ciapipreprod.IIS7.logs/u_ex130605.log]


### Configuration

Environment variables are used for differentiating configurations.


#### Deploying via Vagrant

Vagrant can be used to quickly deploy machines running this application. A default application configuration will be
used and the application will be installed into `/app/app`.

You may override the default `Vagrantfile` settings by creating a your own `Vagrantfile.local` file. It will be loaded
after the default file.

If you'd like to install the foreman tasks as system services, try:

    cd /app/app/
    . ../.env
    sudo foreman export --app app --user $APP_USER --env /app/.env upstart /etc/init
    sudo start app


##### AWS EC2 Provider

When using the [`vagrant-aws` provider plugin](https://github.com/mitchellh/vagrant-aws) the following environment variables are expected to exist:

    export AWS_ACCESS_KEY="XXXXXXXXXXXXXXXXX"
    export AWS_SECRET_KEY="YYYYYYYYYYYYYYYYYYYYYYY/YYYYYYYYYYY"
    export AWS_KEYPAIR_NAME="my-private-ec2-keypair"
    export AWS_PRIVATE_KEY_PATH="$HOME/.ssh/my-private-ec2-keypair.pem"

#### Running the Application

##### VirtualBox

```
$ vagrant up
$ vagrant ssh
vagrant$ cd /app/app
vagrant$ rake run
```

Access Kibana via http://localhost:3456/

##### AWS EC2

```
$ vagrant up --provider=aws
$ vagrant ssh
vagrant$ ec2metadata | grep public-hostname -> gives you the EC2 public DNS name
vagrant$ cd /app/app
vagrant$ rake run
```

Access Kibana via http://{public-hostname}/

##### Runtime default settings

By default, the application loads the environment from `/app/.env`. The following variables are expected to exist:

 * Runtime
    * `APP_USER` - account the services run under (e.g. `vagrant`, `ubuntu`)
    * `APP_ROOT_DIR` - top-level deploy directory (e.g. `/app`)
    * `APP_APP_DIR` - application source code directory (e.g. `/app/app`)
    * `APP_VENDOR_DIR` - directory with vendor libraries and code (e.g. `/app/vendor`)
    * `APP_LOG_DIR` - directory for logging (e.g. `/app/log`)
    * `APP_RUN_DIR` - directory to maintain PIDs and sockets (e.g. `/app/run`)
    * `APP_TMP_DIR` - temporary directory (e.g. `/app/tmp`)
    * `APP_DATA_DIR` - persistent data directory (e.g. `/app/data`)
 * Elasticsearch service
    * `APP_CONFIG_ES_CLUSTER` - name of the elasticsearch cluster (e.g. `default`, [learn more](http://www.elasticsearch.org/guide/reference/modules/discovery/))
    * `APP_CONFIG_ES_IPADDRESS` - the IP address to bind to (e.g. `127.0.0.1`)
    * `APP_CONFIG_ES_AWS_ACCESS_KEY` - an AWS access key to enable elasticsearch cloud clustering; if missing, IAM roles will be attempted ([learn more](http://www.elasticsearch.org/guide/reference/modules/discovery/ec2/))
    * `APP_CONFIG_ES_AWS_SECRET_KEY` - an AWS secret key to enable elasticsearch cloud clustering; if missing, IAM roles will be attempted ([learn more](http://www.elasticsearch.org/guide/reference/modules/discovery/ec2/))
    * `APP_CONFIG_ES_AWS_EC2_GROUP` - an AWS EC2 security group to restrict clustered nodes ([learn more](http://www.elasticsearch.org/guide/reference/modules/discovery/ec2/))
 * Redis service
    * `APP_CONFIG_REDIS_IPADDRESS` - the IP address to bind to (e.g. `127.0.0.1`)
    * `APP_CONFIG_REDIS_KEY` - the name of redis list or channel (e.g. `logstash`)


### Helpful Hints


#### Debug Parsing

If you need to investigate how log messages are being parsed, try the following:

    cat | rake logstash:debug[$LOGSTASH_TYPE] | while read line ; do echo $line | python -mjson.tool ; done

You can interactively paste log lines and they'll be output in pretty JSON format for you to inspect. Press `Ctrl D` to
exit cleanly.


### Learn More

 * [Log Formats (grok)](https://github.com/cityindex/logsearch-development-flow/wiki/Grok)


### License

[Apache License, Version 2.0](./LICENSE.md)
