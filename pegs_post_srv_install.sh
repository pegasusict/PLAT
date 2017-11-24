#!/bin/bash
################################################################################
## Pegasus' Linux Administration Tools                             VER0.5BETA ##
## (C)2017 Mattijs Snepvangers                          pegasus.ict@gmail.com ##
## pegs_post_srv_install.sh   postinstall server script            VER0.5BETA ##
## License: GPL v3                         Please keep my name in the credits ##
################################################################################

# Make sure only root can run our script
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

_now=$(date +"%Y%m%d.%H%M%S%3N")
PEGS_LOGFILE="/var/log/pegsPostInstall_$_now.log"
# Install extra ppa's
_timestamp=$(date +"%Y%m%d.%H%M%S%3N")
_logline="$_timestamp-1/7 ## installing extra PPA's #############################"
echo _logline >> 2>&1
echo _logline >>"$PEGS_LOGFILE" 2>&1
#echo 'deb http://archive.ubuntu.com/ubuntu main restricted universe multiverse proposed backports' >> /tmp/pegsaddition.list
#sudo cp /tmp/pegsaddition.list /etc/apt/sources.list.d/
#rm /tmp/pegsaddition.list
add-apt-repository -y ppa:juju/stable >>"$PEGS_LOGFILE" 2>&1
add-apt-repository -y ppa:landscape/17.03 >>"$PEGS_LOGFILE" 2>&1
######################################################
_timestamp=$(date +"%Y%m%d.%H%M%S%3N")
_logline="$_timestamp-2/7 ## Updating apt cache #################################"
echo _logline >> 2>&1
echo _logline >>"$PEGS_LOGFILE" 2>&1
apt-get -qqy update >>"$PEGS_LOGFILE" 2>&1
######################################################
_timestamp=$(date +"%Y%m%d.%H%M%S%3N")
_logline="$_timestamp-3/7 ## installing updates #################################"
echo _logline >> 2>&1
echo _logline >>"$PEGS_LOGFILE" 2>&1
apt-get -qqy --allow-unauthenticated upgrade >>"$PEGS_LOGFILE" 2>&1
######################################################
_timestamp=$(date +"%Y%m%d.%H%M%S%3N")
_logline="$_timestamp-4/7 ## installing extra packages ##########################"
echo _logline >> 2>&1
echo _logline >>"$PEGS_LOGFILE" 2>&1
apt-get -qqy --allow-unauthenticated install mc trash-cli python3-crontab landscape-server-quickstart >>PEGS_LOGFILE  2>&1
snap install conjure-up --classic
######################################################
_timestamp=$(date +"%Y%m%d.%H%M%S%3N")
_logline="$_timestamp-5/7 ## cleaning up obsolete packages ######################"
echo _logline >> 2>&1
echo _logline >>"$PEGS_LOGFILE" 2>&1
apt-get -qqy autoremove >>"$PEGS_LOGFILE" 2>&1
######################################################
_timestamp=$(date +"%Y%m%d.%H%M%S%3N")
_logline="$_timestamp-6/7 ## installing extra software ##########################"
echo _logline >> 2>&1
echo _logline >>"$PEGS_LOGFILE" 2>&1
wget -nv https://download.teamviewer.com/download/teamviewer_i386.deb >>"$PEGS_LOGFILE" 2>&1
gdebi -n teamviewer_i386.deb >>"$PEGS_LOGFILE" 2>&1
rm teamviewer_i386.deb >>"$PEGS_LOGFILE" 2>&1
apt-get install -f
######################################################
_timestamp=$(date +"%Y%m%d.%H%M%S%3N")
_logline="$_timestamp-7/7 ## Adding maintenance script to anacron ###############"
echo _logline >> 2>&1
echo _logline >>"$PEGS_LOGFILE" 2>&1
cp pegs_maintenance.sh /etc/pegs_maintenance.sh
chmod 555 /etc/pegs_maintenance.sh
chown root:root /etc/pegs_maintenance.sh
echo -e "\n###Added by Pegs Linux Administration Tools ###\n@weekly\t10\tpegs.maintenance\tbash /etc/pegs_maintenance.sh\n### /PLAT ###\n" >> /etc/anacrontab
######################################################
_timestamp=$(date +"%Y%m%d.%H%M%S%3N")
_logline="$_timestamp-###### Done ###############################################"
echo _logline >> 2>&1
echo _logline >>"$PEGS_LOGFILE" 2>&1
