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

###################### WS #################################
echo "########## adding GIMP PPA #####################################################" 2>&1 | tee -a $PLAT_LOGFILE
apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 614C4B38

echo "########## adding Gnome3 Extras PPA ############################################" 2>&1 | tee -a $PLAT_LOGFILE
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 3B1510FD

echo "########## adding Google Chrome PPA ############################################" 2>&1 | tee -a $PLAT_LOGFILE
wget -q https://dl.google.com/linux/linux_signing_key.pub -O- | apt-key add -

echo "########## adding Highly Explosive (Tools for Photographers) PPA ###############" 2>&1 | tee -a $PLAT_LOGFILE
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 93330B78

echo "########## adding MKVToolnix PPA ###############################################" 2>&1 | tee -a $PLAT_LOGFILE
wget -q http://www.bunkus.org/gpg-pub-moritzbunkus.txt -O- | apt-key add -

echo "########## adding Opera (Beta) PPA #############################################" 2>&1 | tee -a $PLAT_LOGFILE
wget -O - http://deb.opera.com/archive.key | apt-key add -

echo "########## adding OwnCloud Desktop Client PPA ##################################" 2>&1 | tee -a $PLAT_LOGFILE
wget -q http://download.opensuse.org/repositories/isv:ownCloud:community/xUbuntu_16.04/Release.key -O- | apt-key add -

echo "########## adding GetDeb PPA ###################################################" 2>&1 | tee -a $PLAT_LOGFILE
wget -q -O- http://archive.getdeb.net/getdeb-archive.key | apt-key add -

echo "########## adding Syncthing PPA ################################################" 2>&1 | tee -a $PLAT_LOGFILE
curl -s https://syncthing.net/release-key.txt | apt-key add -

echo "########## adding WebUpd8 PPA ##################################################" 2>&1 | tee -a $PLAT_LOGFILE
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 4C9D234C

echo "########## adding Wine PPA #####################################################" 2>&1 | tee -a $PLAT_LOGFILE
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 883E8688397576B6C509DF495A9A06AEF9CB8DB0

####################### SRV ##############################
echo "########## adding GetDeb PPA ###################################################" 2>&1 | tee -a $PLAT_LOGFILE
wget -q -O- http://archive.getdeb.net/getdeb-archive.key | apt-key add -

echo "########## adding Syncthing PPA ################################################" 2>&1 | tee -a $PLAT_LOGFILE
curl -s https://syncthing.net/release-key.txt | apt-key add -

echo "########## adding VirtualBox PPA ###############################################" 2>&1 | tee -a $PLAT_LOGFILE
wget -q http://download.virtualbox.org/virtualbox/debian/oracle_vbox_2016.asc -O- | apt-key add -

echo "########## adding Webmin PPA ###################################################" 2>&1 | tee -a $PLAT_LOGFILE
wget http://www.webmin.com/jcameron-key.asc -O- | apt-key add -

echo "########## adding WebUpd8 PPA ##################################################" 2>&1 | tee -a $PLAT_LOGFILE
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 4C9D234C
