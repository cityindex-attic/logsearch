elasticsearch: "$APP_VENDOR_DIR/elasticsearch/bin/elasticsearch" -f -Des.config="$APP_APP_DIR/config/elasticsearch.json"
nginx: nginx -c "$APP_APP_DIR/config/nginx.conf"
logstash: java -Djava.io.tmpdir="$APP_TMP_DIR" -jar "$APP_VENDOR_DIR/logstash.jar" agent -f "$APP_APP_DIR/config/logstash.conf"
