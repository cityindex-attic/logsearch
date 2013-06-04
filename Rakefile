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
  process_erb("src/kibana.js.erb", "app/kibana/config.js")

  puts "==> Starting..."
  sh "foreman start"
end

desc "Import existing data"
namespace :import do

  desc "Import existing data from a file"
  task :file, :logstash_type, :path do |t, args|
    puts "==> Make sure elasticsearch is already running!"
    puts "==> Importing data from file..."

    process_erb("src/logstash-import-file.conf.erb", "var/tmp/import-file.conf", args)
        sh "cat #{args[:path]} | java -jar '#{Dir.getwd}/app/logstash.jar' agent -f '#{Dir.getwd}/var/tmp/import-file.conf'"
    end

end

def process_erb(input, output, args = nil)
    @args=args
  f = File.new(output,'w')
  f.puts(ERB.new(File.read(File.expand_path(input))).result())
  f.close
end
