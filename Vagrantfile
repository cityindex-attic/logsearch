Vagrant.configure("2") do |config|
  config.vm.synced_folder ".", "/app/app"

  config.vm.provision :shell, :inline => "cd /app/app/ && .build/dev_server/provision.sh && rake install_system_services && service app restart"

  config.vm.network :forwarded_port, guest: 80, host: 4567   # kibana (with proxied readonly ES calls)
  config.vm.network :forwarded_port, guest: 9200, host: 9200 # elasticsearch
  config.vm.network :forwarded_port, guest: 5043, host: 5043 # lumberjack


  config.vm.provider :virtualbox do | virtualbox, override |
    override.vm.box = "ubuntu-precise-server-amd64"
    override.vm.box_url = "http://cloud-images.ubuntu.com/precise/current/precise-server-cloudimg-vagrant-amd64-disk1.box"

    virtualbox.customize ["modifyvm", :id, "--memory", "1536"]
  end

  config.vm.provider :aws do | aws, override |
    override.vm.box = "dummy-aws"
    override.vm.box_url = "https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box"

    aws.region = 'eu-west-1'
    aws.ami = 'ami-8e987ef9' # aka ubuntu-12.04-x64

    aws.use_iam_profile = 'true' == ENV['AWS_VAGRANT_USE_IAM']
    aws.access_key_id = ENV['AWS_ACCESS_KEY_ID']
    aws.secret_access_key = ENV['AWS_SECRET_ACCESS_KEY']

    aws.iam_instance_profile_name = ENV['AWS_VAGRANT_IAM_PROFILE_NAME']
    aws.instance_type = 'c1.medium'
    aws.keypair_name = ENV['AWS_KEYPAIR_NAME']
    aws.security_groups = [ 'vagrant' ]

    aws.tags = {
      'cost-centre' => 'logsearch-dev',
      'Environment' => 'dev',
      'Service' => 'logsearch-repodev',
      'Name' => "logsearch-#{ENV['USER']}-#{File.basename(Dir.getwd)}",
    }

    override.ssh.username = 'ubuntu'
    override.ssh.private_key_path = ENV['AWS_PRIVATE_KEY_PATH']
  end
end

load "Vagrantfile.local" if File.exists? "Vagrantfile.local"
