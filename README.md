elasticsearch-development-flow
==============================

A development environment with logstash + ElasticSearch + Kibana 3.


### Quick Guide

**Initialize the application**

    git clone git://github.com/cityindex/elasticsearch-development-flow.git
    cd elasticsearch-development-flow/
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


### Supported Log Formats

The following formats have been configured for parsing. Fields are generally named favoring vendor-defined terminology.
For more details, see the local [config](./config/src/logstash-common-filters.conf.erb) or built-in
[logstash](https://github.com/garethr/logstash-patterns/blob/master/patterns/logstash) patterns.


#### apache_combined

Documentation: [httpd.apache.org](http://httpd.apache.org/docs/current/mod/mod_log_config.html)

Fields:

 * `clientip`
 * `ident`
 * `auth`
 * `timestamp`
 * `verb`
 * `request`
 * `httpversion`
 * `response`
 * `bytes`
 * `referrer`
 * `agent`

Example:

    127.0.0.1 - - [03/Jun/2013:22:41:31 -0600] "GET / HTTP/1.0" 200 3785 "-" "Reeder/1.5.7 CFNetwork/609 Darwin/13.0.0"


#### ci_appmetrics

Documentation: [fandrei/AppMetrics](https://github.com/fandrei/AppMetrics/blob/master/samples/ReportingToAppMetrics/Program.cs#L49)

Fields:

 * `time`
 * `name`
 * `value`

Example:

    2013-05-14 00:08:15.6680000	System_ComputerName	AMAZONA-123456


#### ci_log4net

Fields:

 * `level`
 * `datetime`
 * `thread`
 * `logger`
 * `message`

Example:

    INFO  2013-06-20 08:59:59,996 Margin_4 MarginCalculation Order: 483553318 filtered


#### iis_default

Fields:

 * `datetime`
 * `s_sitename`
 * `s_computername`
 * `s_ip`
 * `cs_method`
 * `cs_uri_stem`
 * `cs_uri_query`
 * `s_port`
 * `cs_username`
 * `c_ip`
 * `cs_version`
 * `cs_user_agent`
 * `cs_cookie`
 * `cs_referer`
 * `cs_host`
 * `sc_status`
 * `sc_substatus`
 * `win32_status`
 * `sc_bytes
 * `cs_bytes`
 * `time_taken`

Example:

    2013-06-05 00:00:01 W3SVC1 PKH-PPE-WEB24 172.16.68.7 HEAD /TradingAPI/Scripts/tradingApi.js - 444 - 172.16.68.245 HTTP/1.1 - - - ciapipreprod.cityindextest9.co.uk 200 0 0 293 92 484


#### nginx_combined

Documentation: [wiki.nginx.org](http://wiki.nginx.org/HttpLogModule#log_format)

Fields:

 * `remote_addr`
 * `remote_user`
 * `time_local`
 * `request_method`
 * `request_uri`
 * `request_httpversion`
 * `status`
 * `body_bytes_sent`
 * `http_referer`
 * `http_user_agent`

Example:

    72.14.199.85 - - [06/Jun/2013:06:49:17 +0000] "GET / HTTP/1.1" 302 2810 "-" "Mozilla/5.0 (compatible; GoogleDocs GoogleApps; script; +http://script.google.com/bot.html)"


#### stackato_apptail

Documentation: [docs.stackato.com](http://docs.stackato.com/server/logging.html#log-format)

Fields:

 * `Text`
 * `LogFilename`
 * `UnixTime`
 * `HumanTime`
 * `Source`
 * `InstanceIndex`
 * `AppID`
 * `AppName`
 * `NodeID`

Example:

    {"Text":"10.11.12.13 - - [2013-06-10 14:51:06] \"GET / HTTP/1.1\" 200 7237 \"-\" \"-\"","LogFilename":"stderr.log","UnixTime":1370875986,"HumanTime":"2013-06-09T14:53:06+00:00","Source":"app","InstanceIndex":0,"AppID":172,"AppName":"httpbin","NodeID":"10.11.12.13"}


#### stackato_event

Documentation: [docs.stackato.com](http://docs.stackato.com/server/logging.html#log-format)

Fields:

 * `Type`
 * `Desc`
 * `Severity`
 * `Info.*`
 * `Process`
 * `UnixTime`
 * `NodeID`

Example:

    {"Type":"dea_stop","Desc":"Stopping application 'httpbin' on DEA c43157","Severity":"INFO","Info":{"app_id":172,"app_name":"httpbin","dea_id":"c43157","instance":0},"Process":"dea","UnixTime":1370878583,"NodeID":"10.11.12.13"}


#### stackato_systail

Documentation: [docs.stackato.com](http://docs.stackato.com/server/logging.html#log-format)

Fields:

 * `Name`
 * `NodeID`
 * `Text`
 * `UnixTime`

Example:

    {"Name":"logyard","NodeID":"10.11.12.13","Text":"2013/06/10 14:52:44 INFO -- [drain:logstash.apptail] Choosing retry limit 0","UnixTime":1370875964}


### License

[Apache License, Version 2.0](./LICENSE.md)
