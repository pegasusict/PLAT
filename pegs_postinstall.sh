#!/bin/bash
################################################################################
## Pegasus' Linux Administration Tools                             VER0.2BETA ##
## (C)2017 Mattijs Snepvangers                          pegasus.ict@gmail.com ##
## pegs_postinstall.sh        postinstall script                   VER0.2BETA ##
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
echo "######################## installing extra PPA's #############################"
echo "######################## installing extra PPA's #############################" >>"$PEGS_LOGFILE" 2>&1
echo 'deb http://archive.ubuntu.com/ubuntu-mate main restricted universe multiverse proposed backports' >/tmp/pegsaddition.list
echo 'deb http://archive.ubuntu.com/ubuntu main restricted universe multiverse proposed backports' >> /tmp/pegsaddition.list
sudo cp /tmp/pegsaddition.list /etc/apt/sources.list.d/
rm /tmp/pegsaddition.list
#webupd8 y-ppa-manager
add-apt-repository -y ppa:webupd8team/y-ppa-manager >>"$PEGS_LOGFILE" 2>&1
add-apt-repository -y ppa:juju/stable >>"$PEGS_LOGFILE" 2>&1
#caja-extensions
add-apt-repository -y ppa:atareao/caja-extensions >>"$PEGS_LOGFILE" 2>&1
#webupd8
add-apt-repository -y ppa:nilarimogard/webupd8 >>"$PEGS_LOGFILE" 2>&1
#noobslab apps
add-apt-repository -y ppa:noobslab/apps >>"$PEGS_LOGFILE" 2>&1

######################################################
echo "######################## Updating apt cache #################################"
echo "######################## Updating apt cache #################################" >>"$PEGS_LOGFILE" 2>&1
apt-get -qqy update >>"$PEGS_LOGFILE" 2>&1
######################################################
echo "######################## Updating installed packages ########################"
echo "######################## Updating installed packages ########################" >>"$PEGS_LOGFILE" 2>&1
apt-get -qqy --allow-unauthenticated upgrade >>"$PEGS_LOGFILE" 2>&1
echo "######################## Installing extra packages ##########################"
echo "######################## Installing extra packages ##########################" >>"$PEGS_LOGFILE" 2>&1
apt-get -qqy --allow-unauthenticated install mc tilda lxd synaptic plank adb fastboot gmusicbrowser audacious adapt lxd-tools nova-compute-lxd forensics-all forensics-extra forensics-extra-gui forensics-full qemu juju python-novaclient python-keystoneclient python-glanceclient python-neutronclient chromium-browser gparted wine-stable playonlinux trash-cli winetricks gadmin-proftpd python3-crontab >>PEGS_LOGFILE  2>&1
echo "######################## Cleaning up obsolete packages ######################"
echo "######################## Cleaning up obsolete packages ######################" >>"$PEGS_LOGFILE" 2>&1
apt-get -qqy autoremove >>"$PEGS_LOGFILE" 2>&1
echo "######################## Installing extra software ##########################"
echo "######################## Installing extra software ##########################" >>"$PEGS_LOGFILE" 2>&1
wget -nv http://nl.archive.ubuntu.com/ubuntu/pool/main/libg/libgcrypt11/libgcrypt11_1.5.3-2ubuntu4.5_amd64.deb >>"$PEGS_LOGFILE" 2>&1
gdebi -n libgcrypt11_1.5.3-2ubuntu4.5_amd64.deb >>"$PEGS_LOGFILE" 2>&1
rm libgcrypt11_1.5.3-2ubuntu4.5_amd64.deb >>"$PEGS_LOGFILE" 2>&1
wget -nv http://staruml.io/download/release/v2.8.0/StarUML-v2.8.0-64-bit.deb >>"$PEGS_LOGFILE" 2>&1
gdebi -n StarUML-v2.8.0-64-bit.deb >>"$PEGS_LOGFILE" 2>&1
rm StarUML-v2.8.0-64-bit.deb >>"$PEGS_LOGFILE" 2>&1
wget -nv https://download.teamviewer.com/download/teamviewer_i386.deb >>"$PEGS_LOGFILE" 2>&1
gdebi -n teamviewer_i386.deb >>"$PEGS_LOGFILE" 2>&1
rm teamviewer_i386.deb >>"$PEGS_LOGFILE" 2>&1
echo "######################## Adding maintenance script to anacron ###############"
echo "######################## Adding maintenance script to anacron ###############" >>"$PEGS_LOGFILE" 2>&1
cp pegs_maintenance.sh /etc/pegs_maintenance.sh
chmod 555 /etc/pegs_maintenance.sh
chown root:root /etc/pegs_maintenance.sh
echo -e "\n###Added by Pegs Linux Administration Tools ###\n@weekly\t10\tpegs.maintenance\tbash /etc/pegs_maintenance.sh\n### /PLAT ###\n" >> /etc/anacrontab
echo "######################## Done ###############################################"
echo "######################## Done ###############################################" >>"$PEGS_LOGFILE" 2>&1
