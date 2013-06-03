Vagrant.configure("2") do |config|                                                                                                                                                        
  config.vm.box = "precise-server-cloudimg-amd64-vagrant-20130603"
  config.vm.box_url = "http://cloud-images.ubuntu.com/vagrant/precise/20130603/precise-server-cloudimg-amd64-vagrant-disk1.box"

  config.vm.network :forwarded_port, guest: 8080, host: 4567

  config.vm.provider :virtualbox do |v|
    v.customize ["modifyvm", :id, "--memory", "1024"]
  end

  config.vm.provision :shell, :path => ".build/dev_server/provision.sh"
end

