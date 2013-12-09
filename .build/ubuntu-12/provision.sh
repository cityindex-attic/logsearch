#!/bin/bash
set -x
set -e

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

apt-get update

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
  sudo update-alternatives --auto ruby
  sudo update-alternatives --auto gem

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


#
# system: ntpd
#

if ! (which ntpd 1>/dev/null 2>&1) ; then
    echo "Installing ntpd..."

    sudo apt-get install -y ntp
fi


#
# system: java
#

if ! (which java 1>/dev/null 2>&1) ; then
    echo "Installing java..."

    sudo apt-get install -y openjdk-7-jre-headless
fi

echo "java:$(java -version 2>&1 | awk -F '\\"' '/version/ { print $2 }')"


#
# system: nginx
#

if ! (which nginx 1>/dev/null 2>&1) ; then
    echo "Installing nginx..."

    sudo apt-get install -y nginx
fi

echo "nginx:$(nginx -v 2>&1 | awk -F '/' '/nginx/ { print $2 }')"

sudo update-rc.d -f nginx remove
sudo service nginx stop


#
# system: pv
#

if ! (which pv 1>/dev/null 2>&1) ; then
    echo "Installing pv..."

    sudo apt-get install -y pv
fi

echo "pv:$(pv -V | head -n1 | awk -F ' ' '/pv/ { print $2 }')"

#
# system: zip
#

if ! (which zip 1>/dev/null 2>&1) ; then
    echo "Installing zip..."

    sudo apt-get install -y zip
fi

echo "zip:$(zip -v | head -n2)"
