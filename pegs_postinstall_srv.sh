#!/bin/bash

# Install extra ppa's
_timestamp=$(date +"%Y-%m-%d_%H.%M.%S,%3N")
_logline="$_timestamp-1/7 ###### installing extra PPA's #############################"
echo $_logline 2>&1 | tee -a $PEGS_LOGFILE
echo 'deb http://archive.ubuntu.com/ubuntu main restricted universe multiverse proposed backports' >> /tmp/pegsaddition.list
mv /tmp/pegsaddition.list /etc/apt/sources.list.d/

#add-apt-repository -y ppa:juju/stable >>"$PEGS_LOGFILE" 2>&1
#add-apt-repository -y ppa:landscape/17.03 >>"$PEGS_LOGFILE" 2>&1

######################################################
_timestamp=$(date +"%Y-%m-%d_%H.%M.%S,%3N")
_logline="$_timestamp-2/7 ###### Updating apt cache #################################"
echo $_logline 2>&1 | tee -a $PEGS_LOGFILE
apt-get -qqy update 2>&1 | tee -a $PEGS_LOGFILE

######################################################
_timestamp=$(date +"%Y-%m-%d_%H.%M.%S,%3N")
_logline="$_timestamp-3/7 ###### installing updates #################################"
echo $_logline 2>&1 | tee -a $PEGS_LOGFILE
apt-get -qqy --allow-unauthenticated upgrade 2>&1 | tee -a $PEGS_LOGFILE

######################################################
_timestamp=$(date +"%Y-%m-%d_%H.%M.%S,%3N")
_logline="$_timestamp-4/7 ###### installing extra packages ##########################"
echo $_logline 2>&1 | tee -a $PEGS_LOGFILE
apt-get -qqy --allow-unauthenticated install mc trash-cli python3-crontab lxc lxd lxd-tools bridge-utils xfsutils-linux criu 2>&1 | tee -a $PEGS_LOGFILE  2>&1

######################################################
_timestamp=$(date +"%Y-%m-%d_%H.%M.%S,%3N")
_logline="$_timestamp-5/7 ###### cleaning up obsolete packages ######################"
echo $_logline 2>&1 | tee -a $PEGS_LOGFILE
apt-get -qqy autoremove 2>&1 | tee -a $PEGS_LOGFILE

######################################################
_timestamp=$(date +"%Y-%m-%d_%H.%M.%S,%3N")
_logline="$_timestamp-6/7 ###### installing extra software ##########################"
echo $_logline 2>&1 | tee -a $PEGS_LOGFILE
### teamviewer
 wget -nv https://download.teamviewer.com/download/teamviewer_i386.deb 2>&1 | tee -a $PEGS_LOGFILE
gdebi -n teamviewer_i386.deb 2>&1 | tee -a $PEGS_LOGFILE
rm teamviewer_i386.deb 2>&1 | tee -a $PEGS_LOGFILE
apt-get install -f 2>&1 | tee -a $PEGS_LOGFILE

######################################################
_timestamp=$(date +"%Y-%m-%d_%H.%M.%S,%3N")
_logline="$_timestamp-7/7 ###### Adding maintenance script to crontab ###############"
echo $_logline 2>&1 | tee -a $PEGS_LOGFILE
cp pegs_maintenance.sh /etc/pegs_maintenance.sh
chmod 555 /etc/pegs_maintenance.sh
chown root:root /etc/pegs_maintenance.sh
echo -e "\n### Added by Pegs Linux Administration Tools ###\n0 * * 4 0 bash /etc/pegs_maintenance.sh\n\n" >> /etc/crontab

######################################################
_timestamp=$(date +"%Y-%m-%d_%H.%M.%S,%3N")
_logline="$_timestamp ###### DONE ###################################################"
echo $_logline 2>&1 | tee -a $PEGS_LOGFILE
