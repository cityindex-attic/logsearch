require 'erb'
require 'dotenv'

Dotenv.load('../.env')

Dir.glob('srv/*/Rakefile').each { |r| import r}

desc "Connect to development VM"
task :connect do
  sh "vagrant up"
  puts "SSHing into development VM"  
  sh "vagrant ssh"
end

desc "Start up the elasticsearch backend and kibana frontend service"
task :run do
  sh "foreman start"
end

desc "Erase all environment data"
task :erase do
    puts "==> Erasing all environment data!"

    sh "rm -fr #{ENV['APP_DATA_DIR']}/*"
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
