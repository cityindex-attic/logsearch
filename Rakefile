require 'dotenv'
require 'erb'
require 'json'
require 'shellwords'

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
            sh "sudo service app-elasticsearch stop"

            sh "while nc -vz #{ENV['APP_CONFIG_ES_IPADDRESS']} 9200 2>/dev/null ; do sleep 2 ; done"
        end
    end

    puts "==> Erasing all environment data!"
    sh "rm -fr #{ENV['APP_DATA_DIR']}/*"

    if restart_elasticsearch
        puts "==> Starting app-elasticsearch"
        sh "sudo service app-elasticsearch start"

        sh "while ! nc -vz #{ENV['APP_CONFIG_ES_IPADDRESS']} 9200 2>/dev/null ; do sleep 2 ; done"
    end
end

desc "Install the foreman tasks as system services (requires sudo)"
task :install_system_services do
    sh "foreman export --app app --log #{ENV['APP_LOG_DIR']} --user #{ENV['APP_USER']} upstart /etc/init"
    sh "sed -i '1s/^/limit nofile 32000 64000\\n/' /etc/init/app-elasticsearch-1.conf"
end

desc "Deploy an AWS CloudFormation Stack."
task :deploy_aws_cloudformation_stack, :stack_name, :s3_bucket, :config_dir, :cfn_template, :passthru_cfn do |t, args|
    commit = `git rev-parse HEAD`.chomp

    puts "\n==> Uploading Templates..."
    sh "./bin/upload-aws-cloudformation #{args[:s3_bucket]} logsearch-deploy/#{args[:stack_name]}/template/"
    puts ""

    puts "\n==> Generating, Uploading post-script..."
    sh "( cd #{args[:config_dir]} && rake generate_post_provision_script ) > post-script-#{Process.pid}.sh"
    sh "aws s3api put-object --bucket #{args[:s3_bucket]} --key 'logsearch-deploy/#{args[:stack_name]}/post-script.sh' --acl private --body post-script-#{Process.pid}.sh"
    sh "rm post-script-#{Process.pid}.sh"
    puts ""

    puts "\n==> Creating Stack..."

    cmd = "aws cloudformation create-stack"
    cmd += " --stack-name #{Shellwords.escape(args[:stack_name])}"
    cmd += " --template-url 'https://s3.amazonaws.com/#{args[:s3_bucket]}/logsearch-deploy/#{args[:stack_name]}/template/#{args[:cfn_template]}.template'"
    cmd += " --capabilities \"CAPABILITY_IAM\""
    cmd += " --parameters"
    cmd += " ParameterKey=S3StackBase,ParameterValue='https://s3.amazonaws.com/#{args[:s3_bucket]}/logsearch-deploy/#{args[:stack_name]}/template'"
    cmd += " ParameterKey=InstancePostScript,ParameterValue='. /app/.env && /usr/local/bin/aws s3api get-object --bucket #{args[:s3_bucket]} --key logsearch-deploy/#{args[:stack_name]}/post-script.sh /tmp/post-script.sh > /dev/null && /bin/bash /tmp/post-script.sh && rm /tmp/post-script.sh'"
    cmd += " ParameterKey=RepositoryCommit,ParameterValue=#{commit}"

    JSON.parse(IO.read("#{args[:config_dir]}/cloudformation.json")).each do |k, v|
        cmd += " ParameterKey=#{k.shellescape},ParameterValue=#{v.shellescape}"
    end

    cmd += " #{args[:passthru_cfn].gsub(';', ',')}"

    sh cmd
end

def process_erb(input, output, args = nil)
  @args=args

  f = File.new(output,'w')
  f.puts(ERB.new(File.read(File.expand_path(input))).result())
  f.close
end
