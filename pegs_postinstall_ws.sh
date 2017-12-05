#!/bin/bash
################################################################################
## Pegasus' Linux Administration Tools                             VER0.5BETA ##
## (C)2017 Mattijs Snepvangers                          pegasus.ict@gmail.com ##
## pegs_postinstall_ws.sh     postinstall script desktop version   VER0.5BETA ##
## License: GPL v3                         Please keep my name in the credits ##
################################################################################

# Make sure only root can run our script
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

_now=$(date +"%Y-%m-%d_%H.%M.%S.%3N")
PEGS_LOGFILE="/var/log/pegsPostInstall_$_now.log"
# Install extra ppa's
_timestamp=$(date +"%Y-%m-%d_%H.%M.%S,%3N")
_logline="$_timestamp-1/7 ## installing extra PPA's #############################"
echo $_logline 2>&1 | tee -a $PEGS_LOGFILE
echo 'deb http://archive.ubuntu.com/ubuntu-mate main restricted universe multiverse proposed backports' >/tmp/pegsaddition.list
echo 'deb http://archive.ubuntu.com/ubuntu main restricted universe multiverse proposed backports' >> /tmp/pegsaddition.list
sudo mv /tmp/pegsaddition.list /etc/apt/sources.list.d/
# add-apt-repository -y ppa:......./..... 2>&1 | tee -a $PEGS_LOGFILE

######################################################
_timestamp=$(date +"%Y-%m-%d_%H.%M.%S,%3N")
_logline="$_timestamp-2/7 ## updating apt cache #################################"
echo $_logline 2>&1 | tee -a $PEGS_LOGFILE
apt-get -qqy update 2>&1 | tee -a $PEGS_LOGFILE

######################################################
_timestamp=$(date +"%Y-%m-%d_%H.%M.%S,%3N")
_logline="$_timestamp-3/7 ## installing updates #################################"
echo $_logline 2>&1 | tee -a $PEGS_LOGFILE
apt-get -qqy --allow-unauthenticated upgrade 2>&1 | tee -a $PEGS_LOGFILE

######################################################
_timestamp=$(date +"%Y-%m-%d_%H.%M.%S,%3N")
_logline="$_timestamp-4/7 ## installing extra packages ##########################"
echo $_logline 2>&1 | tee -a $PEGS_LOGFILE
apt-get -qqy --allow-unauthenticated install tilda synaptic plank adb fastboot gmusicbrowser audacious forensics-all forensics-extra forensics-extra-gui forensics-full chromium-browser gparted wine-stable playonlinux winetricks gadmin-proftpd 2>&1 | tee -a $PEGS_LOGFILE  2>&1
apt-get -qqy --allow-unauthenticated install mc trash-cli python3-crontab >>$PEGS_LOGFILE  2>&1

######################################################
_timestamp=$(date +"%Y-%m-%d_%H.%M.%S,%3N")
_logline="$_timestamp-5/7 ## cleaning up obsolete packages ######################"
echo $_logline 2>&1 | tee -a $PEGS_LOGFILE
apt-get -qqy autoremove 2>&1 | tee -a $PEGS_LOGFILE

######################################################
_timestamp=$(date +"%Y-%m-%d_%H.%M.%S,%3N")
_logline="$_timestamp-6/7 ## installing extra software ##########################"
echo $_logline 2>&1 | tee -a $PEGS_LOGFILE
### teamviewer
 wget -nv https://download.teamviewer.com/download/teamviewer_i386.deb 2>&1 | tee -a $PEGS_LOGFILE
gdebi -n teamviewer_i386.deb 2>&1 | tee -a $PEGS_LOGFILE
rm teamviewer_i386.deb 2>&1 | tee -a $PEGS_LOGFILE
apt-get install -f
### staruml
wget -nv http://nl.archive.ubuntu.com/ubuntu/pool/main/libg/libgcrypt11/libgcrypt11_1.5.3-2ubuntu4.5_amd64.deb 2>&1 | tee -a $PEGS_LOGFILE
gdebi -n libgcrypt11_1.5.3-2ubuntu4.5_amd64.deb 2>&1 | tee -a $PEGS_LOGFILE
rm libgcrypt11_1.5.3-2ubuntu4.5_amd64.deb 2>&1 | tee -a $PEGS_LOGFILE
wget -nv http://staruml.io/download/release/v2.8.0/StarUML-v2.8.0-64-bit.deb 2>&1 | tee -a $PEGS_LOGFILE
gdebi -n StarUML-v2.8.0-64-bit.deb 2>&1 | tee -a $PEGS_LOGFILE
rm StarUML-v2.8.0-64-bit.deb 2>&1 | tee -a $PEGS_LOGFILE

######################################################
_timestamp=$(date +"%Y-%m-%d_%H.%M.%S,%3N")
_logline="$_timestamp-7/7 ## Adding maintenance script to anacron ###############"
echo $_logline 2>&1 | tee -a $PEGS_LOGFILE
cp pegs_maintenance.sh /etc/pegs_maintenance.sh
chmod 555 /etc/pegs_maintenance.sh
chown root:root /etc/pegs_maintenance.sh
echo -e "\n###Added by Pegs Linux Administration Tools ###\n@weekly\t10\tpegs.maintenance\tbash /etc/pegs_maintenance.sh\n### /PLAT ###\n" >> /etc/anacrontab
######################################################
_timestamp=$(date +"%Y-%m-%d_%H.%M.%S,%3N")
_logline="$_timestamp-###### Done ###############################################"
echo $_logline >> 2>&1
echo $_logline 2>&1 | tee -a $PEGS_LOGFILE
