require_relative 'common'

#
# import the test data
#

system "cd #{File.dirname(__FILE__)}/../../../ && rake logstash:load_file_to_redis[#{ARGV[0]},#{ARGV[1]}]"

raise "Failed to import '#{ARGV[1]}' as #{ARGV[0]}" if 0 < $?.exitstatus

print '==> Waiting for data to be ready...'

done = false

for i in 0..90
    sleep 2

    print '.'

    begin
        res = eslog_search "_search", { "query" => { "match_all" => { } } }

#        puts "#{ARGV[2]} vs #{res['hits']['total']}"

        if ARGV[2].to_i == res['hits']['total']
            done = true
            break
        end
    rescue
        # sometimes errors with 503 while loading
    end
end

raise "Timed out waiting to import '#{ARGV[1]}'." unless done

puts 'done'

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
