#!/usr/bin/env ruby

require 'date'
require 'json'
require 'net/http'

host = ARGV[0] || 'localhost'
port = ARGV[1] || 9200

es = Net::HTTP.new(host, port)
req = Net::HTTP::Get.new('/_aliases', { 'Content-Type' => 'application/json' })
res = es.start { |http| http.request(req) }

for index, aliases in JSON.parse(res.body).sort
  ireq = Net::HTTP::Get.new("/#{index}/_stats", { 'Content-Type' => 'application/json' })
  ires = es.start { |http| http.request(ireq) }
  idat = JSON.parse(ires.body)

  if 0 == idat['indices'].length and not idat['_all']['primaries'].has_key?('docs')
    puts "curl -XDELETE #{host}:#{port}/#{index}"
  end
end
