require_relative 'common'

#
# import path is:  file -> lumberjack shipper -> lumberjack endpoint -> redis -> parser -> elasticsearch
#

def ensure_service_running(service_name)
  puts "Ensuring #{service_name} is running..."
  unless /start\/running/ =~ `service #{service_name} status` 
    raise "service #{service_name} must be running.\nRun 'sudo start app' before running this test"
  end
end

#ensure required services are running
ensure_service_running "app-elasticsearch"
ensure_service_running "app-redis"
ensure_service_running "app-lumberjack_redis"
ensure_service_running "app-logstash_redis"

# ensure lumberjack and lumberjack keys are installed
# system "cd #{File.dirname(__FILE__)}/../../../ && rake lumberjack:provision"
# system "cd #{File.dirname(__FILE__)}/../../../ && rake lumberjack:generate_keys"

# # Make sure the app-logstash_redis is running the latest config file
# puts "Waiting for app-lumberjack_redis to be ready..."
# puts `sudo service app-lumberjack_redis stop`
# sleep 2
# puts `sudo service app-lumberjack_redis start`
# system "while ! nc -vz 127.0.0.1 5043 2>/dev/null ; do echo -n . & sleep 2 ; done"

puts "\nShipping the test log file via lumberjack shipper -> lumberjack endpoint -> redis"
system "cd #{File.dirname(__FILE__)}/../../../ && rake lumberjack:ship_to_lumberjack_endpoint[#{ARGV[1]}]"

raise "Failed to import #{ARGV[1]} using lumberjack" if 0 < $?.exitstatus

# logstash workers have a slight delay with queueing/flushing
sleep 15

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

