#!/bin/bash

# adds some additional tools; most notably:
#  * aws-cli - for running aws commands
#  * munin - localhost stats gathering

set -e

if ! (which easy_install 1>/dev/null 2>&1) ; then
    sudo sh -c 'wget https://bitbucket.org/pypa/setuptools/raw/0.7.5/ez_setup.py -O - | python'
fi

if ! (which pip 1>/dev/null 2>&1) ; then
    curl -O https://raw.github.com/pypa/pip/master/contrib/get-pip.py
    sudo python get-pip.py
fi

if ! (which aws 1>/dev/null 2>&1) ; then
    sudo pip install awscli
fi

if ! (which collectd 1>/dev/null 2>&1) ; then
    sudo apt-get install -y collectd
    sudo service collectd stop
    sudo sh -c 'sed -i "s/#Interval 10/Interval 60/" /etc/collectd/collectd.conf'
    sudo rm -fr /var/lib/collectd/rrd/*
    sudo service collectd start
fi
