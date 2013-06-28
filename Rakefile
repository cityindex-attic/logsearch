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

def process_erb(input, output, args = nil)
  @args=args

  f = File.new(output,'w')
  f.puts(ERB.new(File.read(File.expand_path(input))).result())
  f.close
end
