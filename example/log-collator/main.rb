#!/usr/bin/env ruby

# collates files from arguments into a single stream, ordered by timestamp

require 'date'

file_handles = {}
file_positions = {}

def parse_date ( line )
  # http://stackoverflow.com/questions/2982677/ruby-1-9-invalid-byte-sequence-in-utf-8/8856993#8856993
  line = line.unpack('C*').pack('U*') if !line.valid_encoding?

  if line =~ /^..... (\d{4})-(\d{2})-(\d{2}) (\d{2}):(\d{2}):(\d{2}),(\d+)/
    DateTime.strptime("#{$1}#{$2}#{$3}#{$4}#{$5}#{$6}#{$7}", '%Y%m%d%H%M%S%N')
  end
end

def find_useful_line ( file )
  begin
    line = file.gets
    return nil if nil == line

    datetime = parse_date line
  end while not datetime

  { :raw => line, :ts => datetime }
end

ARGV.each do | arg |
  file_handles[arg] = File.open(arg)
  file_positions[arg] = find_useful_line file_handles[arg]
end

while 0 < file_handles.length
  found = file_positions
    .sort_by { | file, position | position[:ts] }
    .first

  puts found[1][:raw]

  upcoming = find_useful_line file_handles[found[0]]

  if nil == upcoming then
    file_handles.delete found[0]
    file_positions.delete found[0]
  else
    file_positions[found[0]] = upcoming
  end
end
