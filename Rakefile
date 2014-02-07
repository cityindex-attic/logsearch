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

desc "Upload a directory of CloudFormation templates."
task :upload_cloudformation_templates, :local, :bucket, :prefix do | t, args |
    sh "aws s3 sync --exclude '*' --include '*.template' #{args[:local]} s3://#{args[:bucket]}/#{args[:prefix]}"
end

desc "Deploy an AWS CloudFormation Stack."
task :deploy_aws_cloudformation_stack, :environment_name, :service_name, :config_dir, :passthru_cfn do |t, args|
    deploy = DateTime.now.strftime '%Y%m%d%H%M%S'
    commit = `git rev-parse HEAD`.chomp

    raise "The commit #{commit} does not seem to be available upstream." unless system "git branch -r --contains #{commit} | grep -e '^\s*origin/' > /dev/null"

    config = JSON.parse(IO.read("#{args[:config_dir]}/cloudformation.json"))

    deploy_ref = commit
    deploy_tag = "release-#{args[:environment_name]}-#{args[:service_name]}-#{deploy}"

    puts "\n==> Tagging Release..."
    sh "git tag #{deploy_tag} #{commit}"

    if 'live' == args[:environment_name]
        puts "==> Don't forget to run: git push origin #{deploy_tag}"
#        puts "\n==> Pushing Release Tag..."
#        sh "git push origin #{deploy_tag}"
#        puts ""

#        deploy_ref = commit
    end

    puts ""


    puts "\n==> Uploading Templates..."

    Rake::Task['upload_cloudformation_templates'].invoke '.build/aws/cloudformation', config['S3Bucket'], "deploy/#{args[:environment_name]}/#{args[:service_name]}/template/"

    if File.exists?("#{args[:config_dir]}/aws-cloudformation")
        Rake::Task['upload_cloudformation_templates'].reenable
        Rake::Task['upload_cloudformation_templates'].invoke "#{args[:config_dir]}/aws-cloudformation", config['S3Bucket'], "deploy/#{args[:environment_name]}/#{args[:service_name]}/template/"
    end

    puts ""


    puts "\n==> Generating, Uploading post-script..."
    sh "( cd #{args[:config_dir]} && rake generate_post_provision_script ) > post-script-#{Process.pid}.sh"
    sh "aws s3api put-object --bucket '#{config['S3Bucket']}' --key 'deploy/#{args[:environment_name]}/#{args[:service_name]}/post-script.sh' --acl private --body post-script-#{Process.pid}.sh"
    sh "rm post-script-#{Process.pid}.sh"
    puts ""


    puts "\n==> Finding Stack..."
    stack = JSON.parse(`aws cloudformation describe-stacks --stack-name #{args[:environment_name]}-#{args[:service_name]} || echo '{"Stacks":[]}'`)
    puts ""

    cmd = "aws cloudformation "

    if 1 == stack['Stacks'].length
        puts "==> Updating Stack..."

        cmd += "update-stack"
    else
        puts "==> Creating Stack..."

        cmd += "create-stack"
    end

    cmd += " --stack-name #{args[:environment_name]}-#{args[:service_name]}"
    cmd += " --template-url 'https://s3.amazonaws.com/#{config['S3Bucket']}/deploy/#{args[:environment_name]}/#{args[:service_name]}/template/#{config['CloudFormationTemplate']}'"
    cmd += " --capabilities \"CAPABILITY_IAM\""
    cmd += " --parameters"

    config['CloudFormationParams']['S3StackBase'] = "https://s3.amazonaws.com/#{config['S3Bucket']}/deploy/#{args[:environment_name]}/#{args[:service_name]}/template"
    config['CloudFormationParams']['InstancePostScript'] = ". /app/.env && /usr/local/bin/aws s3api get-object --bucket #{config['S3Bucket']} --key deploy/#{args[:environment_name]}/#{args[:service_name]}/post-script.sh /tmp/post-script.sh > /dev/null && /bin/bash /tmp/post-script.sh && rm /tmp/post-script.sh"
    config['CloudFormationParams']['RepositoryCommit'] = deploy_ref
    config['CloudFormationParams']['EnvironmentName'] = args[:environment_name]
    config['CloudFormationParams']['ServiceName'] = args[:service_name]

    if args[:passthru_cfn]
        args[:passthru_cfn].gsub(/"$/, '').split('";').each do | v |
            rv = v.split('="', 2)

            config['CloudFormationParams'][rv[0]] = rv[1]
        end
    end

    config['CloudFormationParams'].each do |k, v|
        cmd += " ParameterKey=#{k.shellescape},ParameterValue=#{v.shellescape}"
    end

    sh cmd
end

def process_erb(input, output, args = nil)
  @args=args

  f = File.new(output,'w')
  f.puts(ERB.new(File.read(File.expand_path(input))).result())
  f.close
end
