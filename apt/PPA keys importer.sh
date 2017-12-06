#!/bin/bash
################################################################################
## Pegasus' Linux Administration Tools                             VER1.0BETA ##
## (C)2017 Mattijs Snepvangers                          pegasus.ict@gmail.com ##
## plat_PPA_keys_importer.sh    PPA keys importer                  VER0.1BETA ##
## License: GPL v3                         Please keep my name in the credits ##
################################################################################

# Make sure only root can run this script
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

_now=$(date +"%Y-%m-%d_%H.%M.%S.%3N")
PEGS_LOGFILE="/var/log/pegsPostInstall_$_now.log"
printf "################################################################################\n" 2>&1 | tee -a $PEGS_LOGFILE
printf "## Pegasus' Linux Administration Tools - PPA keys importer           V1.0Beta ##\n" 2>&1 | tee -a $PEGS_LOGFILE
printf "## (c) 2017 Mattijs Snepvangers                         pegasus.ict@gmail.com ##\n" 2>&1 | tee -a $PEGS_LOGFILE
printf "################################################################################\n" 2>&1 | tee -a $PEGS_LOGFILE
printf "\n" 2>&1 | tee -a $PEGS_LOGFILE

## Dropbox
apt-key adv --keyserver pgp.mit.edu --recv-keys 5044912E

## GetDeb
wget -q -O- http://archive.getdeb.net/getdeb-archive.key | apt-key add -

## GIMP
apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 614C4B38

## Gnome3 extras
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 3B1510FD

## Google Chrome
wget -q https://dl.google.com/linux/linux_signing_key.pub -O- | apt-key add -

## High Explosive Graphics
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 93330B78

#### MKVToolnix - http://www.bunkus.org/videotools/mkvtoolnix/
wget -q http://www.bunkus.org/gpg-pub-moritzbunkus.txt -O- | apt-key add -

#### muCommander - http://www.mucommander.com/
wget -O - http://apt.mucommander.com/apt.key | apt-key add -

#### Opera - http://www.opera.com/
wget -O - http://deb.opera.com/archive.key | apt-key add -

#### Opera Beta - http://www.opera.com/
wget -O - http://deb.opera.com/archive.key | apt-key add -

#### ownCloud Desktop Client - http://owncloud.org/
wget -q http://download.opensuse.org/repositories/isv:ownCloud:community/xUbuntu_16.04/Release.key -O- | apt-key add -

#### Syncthing - https://syncthing.net/
curl -s https://syncthing.net/release-key.txt | apt-key add -
