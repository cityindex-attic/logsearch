#!/bin/bash

set -e

if [ ! -e /home/vagrant/current ] ; then
    ln -s /vagrant /home/vagrant/current
fi

mkdir -p /home/vagrant/shared/app
mkdir -p /home/vagrant/shared/var/log
mkdir -p /home/vagrant/shared/var/run

if [ ! -e /home/vagrant/current/app ] ; then
    ln -s /home/vagrant/shared/app /home/vagrant/current/app
fi

if [ ! -e /home/vagrant/current/var ] ; then
    ln -s /home/vagrant/shared/var /home/vagrant/current/var
fi

cd /home/vagrant/current

if [[ ! "$(locale)" =~ "en_US.utf8" ]]; then
  echo "Setting perl:locale to en_US.UTF8"
  export LANGUAGE=en_US.UTF-8
  export LANG=en_US.UTF-8
  export LC_ALL=en_US.UTF-8
  locale-gen en_US.UTF-8
  sudo dpkg-reconfigure locales
fi

if [ "`tail -1 /root/.profile`" = "mesg n" ]; then
  echo 'Patching basebox to prevent future `stdin: is not a tty` errors...'
  sed -i '$d' /root/.profile
  cat << 'EOH' >> /root/.profile
  if `tty -s`; then
    mesg n
  fi
EOH
fi

if [ ! -f /usr/bin/curl ]; then
  echo "Installing curl"
  sudo apt-get install curl -y
fi
echo "curl:\t$(curl --version)" | head -n 1

if [[ ! "$(ruby --version)" =~ "ruby 1.9.3" ]]; then
  echo "Upgrading ruby to 1.9.1"
  sudo apt-get install ruby1.9.1 ruby1.9.1-dev \
    rubygems1.9.1 irb1.9.1 ri1.9.1 rdoc1.9.1 \
    build-essential libopenssl-ruby1.9.1 libssl-dev zlib1g-dev \
    libxslt-dev libxml2-dev -y
   
  sudo update-alternatives --install /usr/bin/ruby ruby /usr/bin/ruby1.9.1 400 \
           --slave   /usr/share/man/man1/ruby.1.gz ruby.1.gz \
                          /usr/share/man/man1/ruby1.9.1.1.gz \
          --slave   /usr/bin/ri ri /usr/bin/ri1.9.1 \
          --slave   /usr/bin/irb irb /usr/bin/irb1.9.1 \
          --slave   /usr/bin/rdoc rdoc /usr/bin/rdoc1.9.1
   
  # choose your interpreter
  # changes symlinks for /usr/bin/ruby , /usr/bin/gem
  # /usr/bin/irb, /usr/bin/ri and man (1) ruby
  sudo update-alternatives --config ruby || true
  sudo update-alternatives --config gem  || true

  echo -e "#Ensure gems are in path\nexport PATH=\$PATH:/var/lib/gems/1.9.1/bin/" >> /etc/profile
fi
echo "ruby:\t$(ruby --version)"

if [[ "$(gem query -n bundler -d | wc -l)" =~ "1" ]]; then
  sudo gem install bundle --no-ri --no-rdoc
else
  bundle --version
fi

if [ ! -f /usr/bin/git ]; then
  echo "Installing git"
  sudo apt-get install git-core -y
fi
echo "git:\t$(git --version)"

if [ ! -f /usr/bin/stackato ]; then
    sudo curl -k --location -o /tmp/stackato.zip http://downloads.activestate.com/stackato/client/v1.7.2/stackato-1.7.2-linux-glibc2.3-x86_64.zip 
    sudo apt-get install unzip -y 
    sudo unzip /tmp/stackato.zip -d /tmp
    sudo mv /tmp/stackato-1.7.2-linux-glibc2.3-x86_64/stackato /usr/bin
    sudo rm -rf /tmp/stackato*
fi
echo "stackato:$(stackato --version)"


#
# java
#

if ! (which java 1>/dev/null 2>&1) ; then
    echo "Installing java..."

    sudo apt-get install -y openjdk-7-jre-headless
fi

echo "java:$(java -version 2>&1 | awk -F '\\"' '/version/ { print $2 }')"


#
# nginx
#

if ! (which nginx 1>/dev/null 2>&1) ; then
    echo "Installing nginx..."

    sudo apt-get install -y nginx
fi

echo "nginx:$(nginx -v 2>&1 | awk -F '/' '/nginx/ { print $2 }')"


#
# elasticsearch
#

if [ ! -e app/elasticsearch ] ; then
    echo "Downloading elasticsearch-0.90.1..."

    pushd app/
    curl --location -o elasticsearch-0.90.1.tar.gz https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-0.90.1.tar.gz
    tar -xzf elasticsearch-0.90.1.tar.gz
    mv elasticsearch-0.90.1 elasticsearch
    rm elasticsearch-0.90.1.tar.gz
    popd
fi

echo "elasticsearch:$(app/elasticsearch/bin/elasticsearch -v | awk -F ':|,' '/Version/ { print $2 }')"


#
# logstash
#

if [ ! -e app/logstash.jar ] ; then
    echo "Downloading logstash-1.1.13..."

    curl --location -o app/logstash.jar https://logstash.objects.dreamhost.com/release/logstash-1.1.13-flatjar.jar
fi

echo "logstash:$(java -jar app/logstash.jar -v | awk -F ' ' '/logstash/ { print $2 }')"


#
# kibana
#

if [ ! -e app/kibana ] ; then
    KIBANA_VERSION="050ee74c10851ae9178d471e71d752c5d76986fc"
    echo "Download kibana-dev-$KIBANA_VERSION..."

    pushd app/
    curl --location -o kibana.zip "https://github.com/elasticsearch/kibana/archive/$KIBANA_VERSION.zip"
    unzip -q kibana
    mv "kibana-$KIBANA_VERSION" kibana
    echo "$KIBANA_VERSION" > kibana/VERSION_DEV
    rm kibana.zip
    popd
fi

echo "kibana:dev-$(cat app/kibana/VERSION_DEV)"
    

echo "Configuring build dependancies"
pushd /vagrant
bundle install
popd


chown -R vagrant:vagrant /home/vagrant/shared


echo "=-=-=-=-=-=-=-=-=-=-=-="
echo "Provisioning completed!"
echo "=-=-=-=-=-=-=-=-=-=-=-="