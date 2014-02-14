#!/bin/bash

set -o errexit
set -o xtrace

apt-get update

if [[ ! "$(ruby --version)" =~ "ruby 1.9.3" ]]; then
  apt-get purge libruby1.8 ruby1.8 ruby1.8-dev rubygems1.8 -y

  apt-get install ruby1.9.1 ruby1.9.1-dev \
    rubygems1.9.1 irb1.9.1 ri1.9.1 rdoc1.9.1 \
    build-essential libopenssl-ruby1.9.1 libssl-dev zlib1g-dev \
    libxslt-dev libxml2-dev -y
   
  update-alternatives \
    --install /usr/bin/ruby ruby \
            /usr/bin/ruby1.9.1 400 \
    --slave /usr/share/man/man1/ruby.1.gz ruby.1.gz \
            /usr/share/man/man1/ruby1.9.1.1.gz \
    --slave /usr/bin/ri ri /usr/bin/ri1.9.1 \
    --slave /usr/bin/irb irb /usr/bin/irb1.9.1 \
    --slave /usr/bin/rdoc rdoc /usr/bin/rdoc1.9.1

  update-alternatives --auto ruby
  update-alternatives --auto gem
fi

if [[ "$(gem query -n bundler -d | wc -l)" =~ "1" ]]; then
  gem install bundle --no-ri --no-rdoc
fi

if ! (which python 1>/dev/null 2>&1) ; then
  apt-get -y install python
fi

if ! (which pip 1>/dev/null 2>&1) ; then
  apt-get -y install python-pip
fi

if ! (which aws 1>/dev/null 2>&1) ; then
  pip install awscli
fi

if ! (which ssh 1>/dev/null 2>&1) ; then
  apt-get -y install openssh-client
fi

bundle install
