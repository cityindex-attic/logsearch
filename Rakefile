require 'erb'

desc "Connect to development VM"
task :connect do
  sh "vagrant up"
  puts "SSHing into development VM"  
  sh "vagrant ssh"
end

desc "Run ElasticSearch & Kibana"
task :run do
  puts "==> Building..."
  process_erb("src/nginx.conf.erb", "etc/nginx.conf")
  process_erb("src/elasticsearch-standalone.json.erb", "etc/elasticsearch.json")
  process_erb("src/logstash-standalone.conf.erb", "etc/logstash.conf")

  puts "==> Starting..."
  sh "foreman start"
end

def process_erb(input, output)
  f = File.new(output,'w')
  f.puts(ERB.new(IO.readlines(input).to_s).result())
  f.close
end
