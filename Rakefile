require 'erb'
require 'dotenv'

Dotenv.load('../.env')

desc "Connect to development VM"
task :connect do
  sh "vagrant up"
  puts "SSHing into development VM"  
  sh "vagrant ssh"
end

desc "Run ElasticSearch & Kibana"
task :run do
  puts "==> Configuring..."
  process_erb("#{ENV['APP_APP_DIR']}/config/src/nginx.conf.erb", "#{ENV['APP_APP_DIR']}/config/nginx.conf")
  process_erb("#{ENV['APP_APP_DIR']}/config/src/elasticsearch-standalone.json.erb", "#{ENV['APP_APP_DIR']}/config/elasticsearch.json")
  process_erb("#{ENV['APP_APP_DIR']}/config/src/logstash-standalone.conf.erb", "#{ENV['APP_APP_DIR']}/config/logstash.conf")
  process_erb("#{ENV['APP_APP_DIR']}/config/src/kibana-config.js.erb", "#{ENV['APP_VENDOR_DIR']}/kibana/config.js")

  puts "==> Starting..."
  sh "foreman start"
end

desc "Import existing data"
namespace :import do

  desc "Import existing data from a file"
  task :file, :logstash_type, :path do |t, args|
    puts "==> Make sure elasticsearch is already running!"
    puts "==> Importing data from file..."

    process_erb("#{ENV['APP_APP_DIR']}/config/src/logstash-import-file.conf.erb", "#{ENV['APP_TMP_DIR']}/import-file.conf", args)
        sh "pv -ept #{args[:path]} | java -jar '#{ENV['APP_VENDOR_DIR']}/logstash.jar' agent -f '#{ENV['APP_TMP_DIR']}/import-file.conf'"
    end

end

def process_erb(input, output, args = nil)
  @args=args

  f = File.new(output,'w')
  f.puts(ERB.new(File.read(File.expand_path(input))).result())
  f.close
end
