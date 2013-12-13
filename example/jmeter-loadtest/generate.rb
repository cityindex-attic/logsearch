#!/usr/bin/env ruby

require 'erb'
require 'json'
require 'optparse'

@target = nil
@users = 1
@concurrency = 1
@maxrate = 10
@maxhits = nil

OptionParser.new do | opts |
  opts.banner = "Usage: generate.rb [options] target"

  opts.on('--target [string]', "Specify the target server for requests (required)") do | v |
    @target = v.split(':')
  end

  opts.on('--virtual-users [int]', Integer, "Specify the number of virtual users (default: #{@users})") do | v |
    @users = v
  end

  opts.on('--virtual-user-clones [int]', Integer, "Specify the number of each virtual user clones (default: #{@concurrency})") do | v |
    @concurrency = v
  end

  opts.on('--max-request-rate [float]', Float, "Specify the maximum requests per minute (default: #{@maxrate})") do | v |
    @maxrate = v
  end

  opts.on('--max-hits [int]', Integer, "Maximum number of hits to generate jmeter requests (default: #{@maxhits})") do | v |
    @maxhits = v
  end

  opts.on('-h', '--help', 'Display this help') do 
    puts opts

    exit
  end
end.parse!

raise OptionParser::InvalidOption if @target.nil?


json = JSON.parse ARGF.read
@buckets = Array.new(@users) { Array.new }

json['hits']['hits'].each_with_index do | hit, i |
  next if not @maxhits.nil? and i > @maxhits

  source = hit['_source']

  next if '/_bulk' == source['path']

  @buckets[i % @users].push(
    {
      :id => hit['_index'] + ':' + hit['_id'],
      :method => source['method'],
      :path => source['path'],
      :querydata => source['querystr'],
      :requestdata => source['data'],
    }
  )
end

template = ERB.new File.new("jmeter.jmx.erb").read, nil, "%"

puts template.result(binding)
