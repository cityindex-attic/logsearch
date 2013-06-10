require 'json'
require 'net/http'

def eslog_search(path, data)
  req = Net::HTTP::Post.new(path, { 'Content-Type' => 'application/json' })
  req.body = data.to_json

  res = Net::HTTP.new('localhost', '9200').start { |http| http.request(req) }

  raise "Query did not return successfully (status = #{res.code})" unless 200 == res.code.to_i

  res_data = JSON.parse(res.body)

  raise "Query timed out" unless false == res_data['timed_out']

  return res_data
end
