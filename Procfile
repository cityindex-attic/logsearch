elasticsearch: "$PWD/app/elasticsearch/bin/elasticsearch" -f -Des.config="$PWD/etc/elasticsearch.json"
nginx: nginx -c "$PWD/etc/nginx.conf"
logstash: java -jar "$PWD/app/logstash.jar" agent -f "$PWD/etc/logstash.conf"
