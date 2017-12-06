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
PLAT_LOGFILE="/var/log/plat_ppa_installer_$_now.log"
echo "################################################################################" 2>&1 | tee -a $PLAT_LOGFILE
echo "## Pegasus' Linux Administration Tools - PPA keys importer           V1.0Beta ##" 2>&1 | tee -a $PLAT_LOGFILE
echo "## (c) 2017 Mattijs Snepvangers                         pegasus.ict@gmail.com ##" 2>&1 | tee -a $PLAT_LOGFILE
echo "################################################################################" 2>&1 | tee -a $PLAT_LOGFILE
echo "" 2>&1 | tee -a $PLAT_LOGFILE

echo "################################################################################" 2>&1 | tee -a $PLAT_LOGFILE
## Dropbox
apt-key adv --keyserver pgp.mit.edu --recv-keys 5044912E

echo "################################################################################" 2>&1 | tee -a $PLAT_LOGFILE
## GetDeb
wget -q -O- http://archive.getdeb.net/getdeb-archive.key | apt-key add -

echo "################################################################################" 2>&1 | tee -a $PLAT_LOGFILE
## GIMP
apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 614C4B38

echo "################################################################################" 2>&1 | tee -a $PLAT_LOGFILE
## Gnome3 extras
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 3B1510FD

echo "################################################################################" 2>&1 | tee -a $PLAT_LOGFILE
## Google Chrome
wget -q https://dl.google.com/linux/linux_signing_key.pub -O- | apt-key add -

echo "################################################################################" 2>&1 | tee -a $PLAT_LOGFILE
## High Explosive Graphics
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 93330B78

echo "################################################################################" 2>&1 | tee -a $PLAT_LOGFILE
#### MKVToolnix - http://www.bunkus.org/videotools/mkvtoolnix/
wget -q http://www.bunkus.org/gpg-pub-moritzbunkus.txt -O- | apt-key add -

echo "################################################################################" 2>&1 | tee -a $PLAT_LOGFILE
#### muCommander - http://www.mucommander.com/
wget -O - http://apt.mucommander.com/apt.key | apt-key add -

echo "################################################################################" 2>&1 | tee -a $PLAT_LOGFILE
#### Opera (and Opera Beta) - http://www.opera.com/
wget -O - http://deb.opera.com/archive.key | apt-key add -

echo "################################################################################" 2>&1 | tee -a $PLAT_LOGFILE
#### ownCloud Desktop Client - http://owncloud.org/
wget -q http://download.opensuse.org/repositories/isv:ownCloud:community/xUbuntu_16.04/Release.key -O- | apt-key add -

echo "################################################################################" 2>&1 | tee -a $PLAT_LOGFILE
#### Syncthing - https://syncthing.net/
curl -s https://syncthing.net/release-key.txt | apt-key add -

echo "################################################################################" 2>&1 | tee -a $PLAT_LOGFILE
#### VirtualBox - http://www.virtualbox.org
wget -q http://download.virtualbox.org/virtualbox/debian/oracle_vbox_2016.asc -O- | apt-key add -

echo "################################################################################" 2>&1 | tee -a $PLAT_LOGFILE
#### Webmin - http://www.webmin.com
wget http://www.webmin.com/jcameron-key.asc -O- | apt-key add -

echo "################################################################################" 2>&1 | tee -a $PLAT_LOGFILE
#### WebUpd8 PPA - http://www.webupd8.org/
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 4C9D234C

#### Wine PPA - https://launchpad.net/~ubuntu-wine/+archive/ppa/
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 883E8688397576B6C509DF495A9A06AEF9CB8DB0
