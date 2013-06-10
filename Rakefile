require 'erb'
require 'dotenv'

Dotenv.load('../.env')

desc "Connect to development VM"
task :connect do
  sh "vagrant up"
  puts "SSHing into development VM"  
  sh "vagrant ssh"
end

desc "Generate configuration files"
task :configure do
  puts "==> Configuring..."
  process_erb("#{ENV['APP_APP_DIR']}/config/src/nginx.conf.erb", "#{ENV['APP_APP_DIR']}/config/nginx.conf")
  process_erb("#{ENV['APP_APP_DIR']}/config/src/elasticsearch-standalone.json.erb", "#{ENV['APP_APP_DIR']}/config/elasticsearch.json")
  process_erb("#{ENV['APP_APP_DIR']}/config/src/logstash-standalone.conf.erb", "#{ENV['APP_APP_DIR']}/config/logstash.conf")
  process_erb("#{ENV['APP_APP_DIR']}/config/src/kibana-config.js.erb", "#{ENV['APP_VENDOR_DIR']}/kibana/config.js")
end

desc "Run ElasticSearch & Kibana"
task :run => :configure do
  puts "==> Starting..."
  sh "foreman start"
end

namespace :run do
  task :elasticsearch => :configure do
    sh "foreman start elasticsearch"
  end
end

desc "Import existing data"
namespace :import do

  desc "Import existing data from a file"
  task :file, :logstash_type, :path do |t, args|
    puts "==> Importing data from file..."

    process_erb("#{ENV['APP_APP_DIR']}/config/src/logstash-import-file.conf.erb", "#{ENV['APP_TMP_DIR']}/import-file.conf", args)
        sh "pv -ept #{args[:path]} | java -jar '#{ENV['APP_VENDOR_DIR']}/logstash.jar' agent -f '#{ENV['APP_TMP_DIR']}/import-file.conf'"
    end

end

namespace :test do
    desc "Run all available integration tests"
    task :end2end do
        puts "==> Running nginx tests"
        Rake::Task["test:type:nginx"].invoke
    end

    namespace :type do
        desc "Run nginx tests"
        task :nginx => [ :erase ] do
            run_integration_test("nginx_combined", "nginx")
        end
    end
end

desc "Erase all environment data"
task :erase do
    puts "==> Erasing all environment data!"

    sh "rm -fr #{ENV['APP_DATA_DIR']}/*"
end

def process_erb(input, output, args = nil)
  @args=args

  f = File.new(output,'w')
  f.puts(ERB.new(File.read(File.expand_path(input))).result())
  f.close
end

def run_integration_test(type, name)
    pid = fork do
        exec "rake run:elasticsearch > /dev/null"
        Kernel.exit!
    end

    # dependencies would have marked erase to not run again, so reset that
    Rake::Task['erase'].reenable

    begin
        # wait until elasticsearch is ready
        puts "==> Waiting for elasticsearch..."
        sh "while ! nc -vz localhost 9200 2>/dev/null ; do sleep 2 ; done"

        # then we can start importing our test data
        puts "==> Importing test data..."
        sh "ruby test/do-import.rb #{type} test/#{name}.log > /dev/null"

        # and run our test queries
        sh "ruby test/#{name}.rb"
    ensure
        Process.kill("TERM", File.read("#{ENV['APP_RUN_DIR']}/elasticsearch.pid").to_i)
        Process.waitpid(pid)
    end
end
