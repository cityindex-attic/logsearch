 #!/usr/bin/env ruby
require 'date'

aggMinute = {}
aggHour = {}

ARGF.each_line do | line |
    # http://stackoverflow.com/questions/2982677/ruby-1-9-invalid-byte-sequence-in-utf-8/8856993#8856993
    line = line.unpack('C*').pack('U*') if !line.valid_encoding?

    if line =~ /^..... (\d{4}-\d{2}-\d{2} \d{2}:\d{2})/
        aggMinute[$1] = { :count => 0, :bytes => 0 } unless aggMinute.key? $1
        aggMinute[$1][:count] += 1
        aggMinute[$1][:bytes] += line.length

        h = $1[0..12]
        aggHour[h] = { :count => 0, :bytes => 0 } unless aggHour.key? h
        aggHour[h][:count] += 1
        aggHour[h][:bytes] += line.length
    end
end

def summarize ( level, data )
    data
        .sort_by { | datetime, stats | stats[:count] }
        .last(96)
        .reverse_each do | value |
            puts "#{level}\tcount\t#{value[0]}\t#{value[1][:count]}"
        end

    data
        .sort_by { | datetime, stats | stats[:bytes] }
        .last(96)
        .reverse_each do | value |
            puts "#{level}\tbytes\t#{value[0]}\t#{value[1][:bytes]}"
        end
end

summarize 'minute', aggMinute
summarize 'hour', aggHour