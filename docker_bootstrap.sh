#!/usr/bin/env bash
# Odd, 2014-12-13 00:36:06

export DEBIAN_FRONTEND=noninteractive
ln -fs /usr/share/zoneinfo/Europe/Stockholm /etc/localtime
apt-get -qq update
apt-get install -y --only-upgrade bash
cpanm DateTime
cpanm Mojolicious
mkdir /srv/lhlunch

# cleanup
apt-get clean autoclean
apt-get autoremove -y
rm -rf /var/lib/{apt,dpkg,cache,log}/
rm -f /tmp/dropbox.tgz
