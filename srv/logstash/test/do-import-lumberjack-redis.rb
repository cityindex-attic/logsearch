require_relative 'common'

log_file = ARGV[1]
logstash_redis_logfile = "/var/log/app/logstash_redis-1.log"

#
# import path is:  file -> lumberjack shipper -> lumberjack endpoint -> redis -> parser -> elasticsearch
#

puts "---> Restarting app-logstash_redis to ensure its using the latest config and a flush_size of 1"
ENV['APP_CONFIG_REDIS_FLUSH_SIZE'] = "1"
ENV['DEBUG_OUTPUT'] = "true" #FIXME: these aren't getting passed through to the service...
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
system "cd #{File.dirname(__FILE__)}/../../../ && rake lumberjack:ship_to_lumberjack_endpoint[#{log_file}]"

raise "Failed to import #{log_file} using lumberjack" if 0 < $?.exitstatus

until_line = `tail -n1 #{log_file}`.strip
puts "---> Waiting for #{logstash_redis_logfile} to contain last line of #{log_file} ('#{until_line}')"
def wait_for(file, until_line)
  f = File.open(file,"r")
  f.seek(0,IO::SEEK_END)
  not_found = true
  while not_found do
    select([f])
    line = f.gets
    print "."
    if line =~ /.*#{Regexp.escape(until_line)}.*/
      puts " found #{until_line} in #{file}" 
      not_found = false
    end
    sleep 1
  end
end

wait_for(logstash_redis_logfile,until_line)

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
