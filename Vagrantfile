Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu-precise-server-amd64"
  config.vm.box_url = "http://cloud-images.ubuntu.com/precise/current/precise-server-cloudimg-vagrant-amd64-disk1.box"

  config.vm.network :forwarded_port, guest: 80, host: 4567   # kibana (with proxied readonly ES calls)
  config.vm.network :forwarded_port, guest: 9200, host: 9200 # elasticsearch

  config.vm.provider :virtualbox do |v|
    v.customize ["modifyvm", :id, "--memory", "1700"]
  end

  config.vm.provider :aws do |aws, override|
    aws.region = 'us-east-1'
    aws.ami = 'ami-d0f89fb9' # aka ubuntu-12.04-x64
    aws.instance_type = 't1.micro'
    aws.keypair_name = ENV['AWS_KEYPAIR_NAME']
    aws.security_groups = [ 'vagrant', 'logstash-default' ]
    aws.tags = {
      'Name' => "#{ENV['USER']}-#{File.basename(Dir.getwd)}",
    }

#    config.vm.provision :shell, :inline => "echo export APP_CONFIG_ES_IPADDRESS=`ec2metadata | grep local-ipv4 | awk -F ' ' '{ print $2 }'` >> /app/.env"

    override.ssh.username = 'ubuntu'
    override.ssh.private_key_path = ENV['AWS_PRIVATE_KEY_PATH']
  end

  config.vm.provision :shell, :path => ".build/dev_server/provision.sh"
  config.vm.synced_folder ".", "/app/app"
end

load "Vagrantfile.local" if File.exists? "Vagrantfile.local"
