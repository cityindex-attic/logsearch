elasticsearch-development-flow
==============================

A development environment for ElasticSearch &amp; Kibana 3 projects


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
    rake import:file[iis_default,ciapipreprod.IIS7.logs/u_ex130605.log]
