require_relative 'common'

#
# import the test data
#

system "cd #{File.dirname(__FILE__)}/../ && rake import:fileslow[#{ARGV[0]},#{ARGV[1]}]"

raise "Failed to import '#{ARGV[1]}' as #{ARGV[0]}" if 0 < $?.exitstatus

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
    for event in res['hits']['hits']
        puts JSON.pretty_generate(event)
    end

    raise "Some log events were not parsed correctly (#{res['hits']['total']} events) - the most recent 10 are shown"
end
