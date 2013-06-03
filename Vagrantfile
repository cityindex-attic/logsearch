Vagrant.configure("2") do |config|                                                                                                                                                        
  config.vm.box = "precise-server-cloudimg-amd64-vagrant-20130603"
  config.vm.box_url = "http://cloud-images.ubuntu.com/vagrant/precise/20130603/precise-server-cloudimg-amd64-vagrant-disk1.box"

  config.vm.network :forwarded_port, guest: 5000, host: 5000
  config.vm.network :forwarded_port, guest: 6000, host: 6000

  config.vm.provider :virtualbox do |v|
    v.customize ["modifyvm", :id, "--memory", "1024"]
  end

  config.vm.provision :shell, :path => ".build/dev_server/provision.sh"
end

