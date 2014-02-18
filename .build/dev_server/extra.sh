#!/bin/bash

# adds some additional tools; most notably:
#  * aws-cli - for running aws commands
#  * munin - localhost stats gathering

set -x
set -e

if ! (which easy_install 1>/dev/null 2>&1) ; then
  sudo sh -c 'wget https://bitbucket.org/pypa/setuptools/raw/bootstrap/ez_setup.py -O - | python'
fi

if ! (which pip 1>/dev/null 2>&1) ; then
  curl -O https://raw.github.com/pypa/pip/1.4.1/contrib/get-pip.py
  sudo python get-pip.py
fi

if ! (which aws 1>/dev/null 2>&1) ; then
  sudo pip install awscli
fi

if ! (which collectd 1>/dev/null 2>&1) ; then
  sudo /bin/bash <<EOF
    apt-get install -y collectd
    service collectd stop
    sed -i "s/#Interval 10/Interval 60/" /etc/collectd/collectd.conf
    mkdir -p /opt/collectd/lib/collectd/plugins/python

    (
      echo '<LoadPlugin python>'
      echo '  Globals true'
      echo '</LoadPlugin>'
      echo ''
      echo '<Plugin python>'
      echo '  ModulePath "/opt/collectd/lib/collectd/plugins/python"'
      echo '  # python-placeholder'
      echo '</Plugin>'
    ) >> /etc/collectd/collectd.conf
  
    rm -fr /var/lib/collectd/rrd/*
    service collectd start
EOF
fi
