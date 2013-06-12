elasticsearch-development-flow
==============================

A development environment for ElasticSearch &amp; Kibana 3 projects


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


#### iis_default

Fields:

 * `datetime`
 * `s_sitename`
 * `s_computername`
 * `s_ip`
 * `cs_method`
 * `cs_uri_stem`
 * `cs_uri_query
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


### Quick Guide

**Initialize the application**

    git clone git://github.com/cityindex/elasticsearch-development-flow.git
    cd elasticsearch-development-flow/
    vagrant up

**Connect to the application**

    vagrant ssh
    cd /app/app/

**Start the services** - this starts the elasticsearch server, kibana web server, and a default logstash configuration
which monitors the application logs. Open [localhost:4567](http://localhost:4567) to see things.

    rake run

**Backfill data** - once the elasticsearch server has started, you can backfill logs if you have them laying around.

    rake import:file[nginx_combined,backfill/labs.cityindex.com.nginx.logs/access.log*]
    rake import:file[iis_default,backfill/ciapipreprod.IIS7.logs/u_ex130605.log]
