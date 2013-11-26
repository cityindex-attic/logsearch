require_relative 'common'

#
# import path is:  file -> lumberjack shipper -> lumberjack endpoint -> redis -> parser -> elasticsearch
#

def ensure_service_running(service_name)
  unless /start\/running/ =~ `service #{service_name} status` 
    raise "service #{service_name} must be running.\nRun 'sudo start app' before running this test"
  end
end

#ensure required services are running
ensure_service_running "app-elasticsearch"
ensure_service_running "app-redis"
ensure_service_running "app-lumberjack_redis"
ensure_service_running "app-logstash_redis"

# Make sure the app-logstash_redis is running the latest config file
`sudo service app-logstash_redis restart`

# ensure lumberjack and lumberjack keys are installed
system "cd #{File.dirname(__FILE__)}/../../../ && rake lumberjack:provision"
system "cd #{File.dirname(__FILE__)}/../../../ && rake lumberjack:generate_keys"

# ship the test log file via lumberjack shipper -> lumberjack endpoint -> redis
system "cd #{File.dirname(__FILE__)}/../../../ && rake lumberjack:ship_to_lumberjack_endpoint[#{ARGV[0]}]"

raise "Failed to import using lumberjack config '#{ARGV[0]}'" if 0 < $?.exitstatus

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

