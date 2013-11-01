require 'erb'
require 'dotenv'

$LOGSTASH_MESSAGE_MAXSIZE=1048576

Dotenv.load('../.env')

Dir.glob('srv/**/Rakefile').each { |r| import r}

desc "Erase all environment data"
task :erase do
    restart_elasticsearch = false

    if File.exists?("/etc/init/app-elasticsearch-1.conf")
        if /start\/running/ =~ `service app-elasticsearch status` 
            restart_elasticsearch = true

            puts "==> Stopping app-elasticsearch"
            sh "service app-elasticsearch stop"

            sh "while nc -vz #{ENV['APP_CONFIG_ES_IPADDRESS']} 9200 2>/dev/null ; do sleep 2 ; done"
        end
    end

    puts "==> Erasing all environment data!"
    sh "rm -fr #{ENV['APP_DATA_DIR']}/*"

    if restart_elasticsearch
        puts "==> Starting app-elasticsearch"
        sh "service app-elasticsearch start"

        sh "while ! nc -vz #{ENV['APP_CONFIG_ES_IPADDRESS']} 9200 2>/dev/null ; do sleep 2 ; done"
    end
end

desc "Install the foreman tasks as system services (requires sudo)"
task :install_system_services do
    sh "foreman export --app app --user #{ENV['APP_USER']} upstart /etc/init"
    sh "sed -i '1s/^/limit nofile 32000 64000\\n/' /etc/init/app-elasticsearch-1.conf"
end

def process_erb(input, output, args = nil)
  @args=args

  f = File.new(output,'w')
  f.puts(ERB.new(File.read(File.expand_path(input))).result())
  f.close
end
