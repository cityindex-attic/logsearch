require_relative 'common'

#
# import path is:  file -> lumberjack shipper -> lumberjack endpoint -> redis -> parser -> elasticsearch
#

puts "---> Restarting app-logstash_redis"
puts `sudo service app-logstash_redis restart`

def ensure_service_running(service_name)
  puts "  Ensuring #{service_name} is running..."
  unless /start\/running/ =~ `service #{service_name} status` 
    raise "service #{service_name} must be running.\nRun 'sudo start app' before running this test"
  end
end

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
system "cd #{File.dirname(__FILE__)}/../../../ && rake lumberjack:ship_to_lumberjack_endpoint[#{ARGV[1]}]"

raise "Failed to import #{ARGV[1]} using lumberjack" if 0 < $?.exitstatus

puts "---> Waiting for logstash-redis"
sleep 30

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
