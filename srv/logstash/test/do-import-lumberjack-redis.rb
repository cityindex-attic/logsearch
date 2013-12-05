require_relative 'common'

log_file = ARGV[1]
logstash_redis_logfile = "/var/log/app/logstash_redis-1.log"

#
# import path is:  file -> lumberjack shipper -> lumberjack endpoint -> redis -> parser -> elasticsearch
#

puts "---> Stopping app-logstash_redis service..."
puts `sudo service app-logstash_redis stop`


puts "---> Ensuring other required services are running"
ensure_service_running "app-elasticsearch"
ensure_service_running "app-redis"
ensure_service_running "app-lumberjack_redis"

puts "---> Ensuring lumberjack and lumberjack keys are installed"
unless File.exists? "#{ENV['APP_VENDOR_DIR']}/lumberjack"
  system "cd #{File.dirname(__FILE__)}/../../../ && rake lumberjack:provision"
end
unless File.exists? "#{ENV['APP_DATA_DIR']}/lumberjack.key"
  system "cd #{File.dirname(__FILE__)}/../../../ && rake lumberjack:generate_keys"
  puts `sudo service app-lumberjack_redis restart`
  puts "Restarting app-lumberjack_redis to ensure its running the latest config file..."
  sleep 10
end

puts "---> Shipping the test log file via lumberjack shipper -> lumberjack endpoint -> redis"
system "cd #{File.dirname(__FILE__)}/../../../ && rake lumberjack:ship_to_lumberjack_endpoint[#{log_file}]"

raise "Failed to import #{log_file} using lumberjack" if 0 < $?.exitstatus

puts "---> redis -> parser -> elasticsearch"
puts "running rake logstash:redis_to_elasticsearch until 2 seconds after 'timestamp' detected in output"
run_until "cd #{File.dirname(__FILE__)}/../../../ && APP_CONFIG_REDIS_FLUSH_SIZE=1 DEBUG_OUTPUT=true rake logstash:redis_to_elasticsearch",\
          /.*#{Regexp.escape("timestamp")}.*/, 2

puts "---> Restarting app-logstash_redis service..."
puts `sudo service app-logstash_redis start`
# logstash takes forever to restart and might cause later tests to fail
sleep 60

#
# make sure everything parsed okay
#

res = eslog_search(
  "_search",
  {
    "query" => {
      "filtered" => {
        "query" => {
          "query_string" => {
            "query" => "@tags:\"_grokparsefailure\""
          }
        }
      }
    },
    "size" => 10,
    "sort" => [
      {
        "@timestamp" => {
          "order" => "desc"
        }
      }
    ]
  }
)

if (0 < res['hits']['total'])
    raise "Some log events were not parsed correctly (#{res['hits']['total']} events) " +
          "- the most recent 10 are shown: #{JSON.pretty_generate(res)}"
end
