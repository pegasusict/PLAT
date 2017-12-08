#!/bin/bash
################################################################################
## Pegasus' Linux Administration Tools                             VER1.0BETA ##
## (C)2017 Mattijs Snepvangers                          pegasus.ict@gmail.com ##
## pegs_postinstall_srv.sh    postinstall script                   VER1.0BETA ##
## License: GPL v3                         Please keep my name in the credits ##
################################################################################

# Make sure only root can run this script
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

_now=$(date +"%Y-%m-%d_%H.%M.%S.%3N")
PLAT_LOGFILE="/var/log/platPostInstall_$_now.log"
echo "################################################################################" 2>&1 | tee -a $PLAT_LOGFILE
echo "## Pegasus' Linux Administration Tools - Post Install Script         V1.0Beta ##" 2>&1 | tee -a $PLAT_LOGFILE
echo "## (c) 2017 Mattijs Snepvangers                         pegasus.ict@gmail.com ##" 2>&1 | tee -a $PLAT_LOGFILE
echo "################################################################################" 2>&1 | tee -a $PLAT_LOGFILE
echo "" 2>&1 | tee -a $PLAT_LOGFILE

getargs() {
   TEMP=`getopt -o hr:c: --long help,role:,containertype: -n "$FUNCNAME" -- "$@"`
   if [ $? != 0 ] ; then return 1 ; fi
   eval set -- "$TEMP";
   local format='%s\n' escape='-E' line='-n' script clear='tput sgr0';
   while [[ ${1:0:1} == - ]]; do
      [[ $1 =~ ^-h|--help ]] && {
         cat <<-EOF
         USAGE:

         OPTIONS

           -r or --role tells the script what kind of system we're dealing with.
              Valid options: basic, ws, zeus, lxdhost, container
           -c or --containertype tells the script what kind of container we're working on.
              Valid options are: basic, nas, web, x11, pxe
EOF
###TODO### re indent EOF when done
         return;
      };
      [[ $1 == -- ]] && { shift; break; };
      [[ $1 =~ ^-r|--role$ ]] && { role="${2}"; shift 2; continue; };
      [[ $1 =~ ^-c|--containertype$ ]] && { containertype="${2}"; shift 2; continue; };
      break;
   done
   tput -S <<<"$script";
   $clear;
}

case "$role" in
   "ws" )
      systemrole[basic] = true
      systemrole[ws] = true
      ;;
   "zeus" )
      systemrole[basic] = true
      systemrole[ws] = true
      systemrole[lxdhost] = true
      systemrole[zeus] = true
      systemrole[nas] = true
      ;;
   "lxdhost" )
      systemrole[basic] = true
      systemrole[lxdhost] = true
      ;;
   "container" )
      systemrole[container] = true
      case "$containertype" in
         "nas" )
            systemrole[basic] = true
            systemrole[nas] = true
            ;;
         "web" )
            systemrole[basic] = true
            systemrole[nas] = true
            systemrole[web] = true
            ;;
         "x11" )
            systemrole[basic] = true
            systemrole[ws] = true
            ;;
         "pxe" )
            systemrole[basic] = true
            systemrole[nas] = true
            systemrole[pxe] = true
            ;;
         * )
            systemrole[basic] = true
            ;;
      esac
   * )
      systemrole[basic] = true
      ;;
esac

_timestamp=$(date +"%Y-%m-%d_%H.%M.%S,%3N")
_logline="$_timestamp-1/7 ###### installing extra PPA's #############################"
echo $_logline 2>&1 | tee -a $PLAT_LOGFILE





if [ "$systemrole[basic]" = true ];
then
   echo "########## copying ubuntu main sources and some extras #########################" 2>&1 | tee -a $PLAT_LOGFILE
   cp apt/base.lst /etc/apt/sources.list.d/ 2>&1 | tee -a $PLAT_LOGFILE
   echo "########## adding GetDeb PPA key ###############################################" 2>&1 | tee -a $PLAT_LOGFILE
   wget -q -O- http://archive.getdeb.net/getdeb-archive.key | apt-key add - 2>&1 | tee -a $PLAT_LOGFILE
   echo "########## adding VirtualBox PPA key ###########################################" 2>&1 | tee -a $PLAT_LOGFILE
   wget -q http://download.virtualbox.org/virtualbox/debian/oracle_vbox_2016.asc -O- | apt-key add - 2>&1 | tee -a $PLAT_LOGFILE
   echo "########## adding Webmin PPA key ###############################################" 2>&1 | tee -a $PLAT_LOGFILE
   wget http://www.webmin.com/jcameron-key.asc -O- | apt-key add - 2>&1 | tee -a $PLAT_LOGFILE
   echo "########## adding WebUpd8 PPA key ##############################################" 2>&1 | tee -a $PLAT_LOGFILE
   apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 4C9D234C 2>&1 | tee -a $PLAT_LOGFILE
fi

if [ "$systemrole[ws]" = true ];
then
   echo "########## copying extra PPA's #################################################" 2>&1 | tee -a $PLAT_LOGFILE
   cp apt/base.lst /etc/apt/sources.list.d/ 2>&1 | tee -a $PLAT_LOGFILE
   echo "########## adding GIMP PPA key #################################################" 2>&1 | tee -a $PLAT_LOGFILE
   add-apt-repository ppa:freecad-maintainers/freecad-stable
   echo "########## adding GIMP PPA key #################################################" 2>&1 | tee -a $PLAT_LOGFILE
   apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 614C4B38 2>&1 | tee -a $PLAT_LOGFILE
   echo "########## adding Gnome3 Extras PPA ############################################" 2>&1 | tee -a $PLAT_LOGFILE
   apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 3B1510FD 2>&1 | tee -a $PLAT_LOGFILE
   echo "########## adding Google Chrome PPA ############################################" 2>&1 | tee -a $PLAT_LOGFILE
   wget -q https://dl.google.com/linux/linux_signing_key.pub -O- | apt-key add - 2>&1 | tee -a $PLAT_LOGFILE
   echo "########## adding Highly Explosive (Tools for Photographers) PPA ###############" 2>&1 | tee -a $PLAT_LOGFILE
   apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 93330B78 2>&1 | tee -a $PLAT_LOGFILE
   echo "########## adding MKVToolnix PPA ###############################################" 2>&1 | tee -a $PLAT_LOGFILE
   wget -q http://www.bunkus.org/gpg-pub-moritzbunkus.txt -O- | apt-key add - 2>&1 | tee -a $PLAT_LOGFILE
   echo "########## adding Opera (Beta) PPA #############################################" 2>&1 | tee -a $PLAT_LOGFILE
   wget -O - http://deb.opera.com/archive.key | apt-key add - 2>&1 | tee -a $PLAT_LOGFILE
   echo "########## adding OwnCloud Desktop Client PPA ##################################" 2>&1 | tee -a $PLAT_LOGFILE
   wget -q http://download.opensuse.org/repositories/isv:ownCloud:community/xUbuntu_16.04/Release.key -O- | apt-key add - 2>&1 | tee -a $PLAT_LOGFILE
   echo "########## adding Wine PPA #####################################################" 2>&1 | tee -a $PLAT_LOGFILE
   apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 883E8688397576B6C509DF495A9A06AEF9CB8DB0 2>&1 | tee -a $PLAT_LOGFILE
fi

if [ "$systemrole[nas]" = true ];
then
   echo "########## adding Syncthing PPA ################################################" 2>&1 | tee -a $PLAT_LOGFILE
   curl -s https://syncthing.net/release-key.txt | apt-key add - 2>&1 | tee -a $PLAT_LOGFILE
fi

######################################################
_timestamp=$(date +"%Y-%m-%d_%H.%M.%S,%3N")
_logline="$_timestamp-2/7 ###### Updating apt cache #################################"
echo $_logline 2>&1 | tee -a $PLAT_LOGFILE
apt-get -qqy update 2>&1 | tee -a $PLAT_LOGFILE

######################################################
_timestamp=$(date +"%Y-%m-%d_%H.%M.%S,%3N")
_logline="$_timestamp-3/7 ###### installing updates #################################"
echo $_logline 2>&1 | tee -a $PLAT_LOGFILE
apt-get -qqy --allow-unauthenticated upgrade 2>&1 | tee -a $PLAT_LOGFILE

######################################################
_timestamp=$(date +"%Y-%m-%d_%H.%M.%S,%3N")
_logline="$_timestamp-4/7 ###### installing extra packages ##########################"
echo $_logline 2>&1 | tee -a $PLAT_LOGFILE
if [ "$systemrole[basic]" = true ];
then
   apt-get -qqy --allow-unauthenticated install mc trash-cli 2>&1 | tee -a $PLAT_LOGFILE  2>&1
fi
if [ "$systemrole[ws]" = true ];
then
   apt-get -qqy --allow-unauthenticated install synaptic tilda audacious samba wine-stable playonlinux winetricks 2>&1 | tee -a $PLAT_LOGFILE  2>&1
fi
if [ "$systemrole[zeus]" = true ];
then
   apt-get -qqy --allow-unauthenticated install plank picard audacity calibre fastboot adb fslint gadmin-proftpd geany* gprename lame masscan forensics-all forensics-extra forensics-extra-gui forensics-full chromium-browser gparted 2>&1 | tee -a $PLAT_LOGFILE
fi
######################################################################
if [ "$systemrole[web]" = true ];
then
   apt-get -qqy --allow-unauthenticated install apache2, phpmyadmin mysql-server mytop proftpd 2>&1 | tee -a $PLAT_LOGFILE  2>&1
fi
if [ "$systemrole[nas]" = true ];
then
   apt-get -qqy --allow-unauthenticated install samba 2>&1 | tee -a $PLAT_LOGFILE  2>&1
fi
if [ "$systemrole[pxe]" = true ];
then
   apt-get -qqy --allow-unauthenticated install atftpd 2>&1 | tee -a $PLAT_LOGFILE  2>&1
###check### what about: cobbler
fi






######################################################
_timestamp=$(date +"%Y-%m-%d_%H.%M.%S,%3N")
_logline="$_timestamp-5/7 ###### cleaning up obsolete packages ######################"
echo $_logline 2>&1 | tee -a $PLAT_LOGFILE
apt-get -qqy autoremove 2>&1 | tee -a $PLAT_LOGFILE

######################################################
_timestamp=$(date +"%Y-%m-%d_%H.%M.%S,%3N")
_logline="$_timestamp-6/7 ###### installing extra software ##########################"
echo $_logline 2>&1 | tee -a $PLAT_LOGFILE
### teamviewer
 wget -nv https://download.teamviewer.com/download/teamviewer_i386.deb 2>&1 | tee -a $PLAT_LOGFILE
gdebi -n teamviewer_i386.deb 2>&1 | tee -a $PLAT_LOGFILE
rm teamviewer_i386.deb 2>&1 | tee -a $PLAT_LOGFILE
apt-get install -f 2>&1 | tee -a $PLAT_LOGFILE

######################################################
_timestamp=$(date +"%Y-%m-%d_%H.%M.%S,%3N")
_logline="$_timestamp-7/7 ###### Adding maintenance script to crontab ###############"
echo $_logline 2>&1 | tee -a $PLAT_LOGFILE
cp pegs_maintenance.sh /etc/pegs_maintenance.sh
chmod 555 /etc/pegs_maintenance.sh
chown root:root /etc/pegs_maintenance.sh
echo -e "\n### Added by Pegs Linux Administration Tools ###\n0 * * 4 0 bash /etc/pegs_maintenance.sh\n\n" >> /etc/crontab

######################################################
_timestamp=$(date +"%Y-%m-%d_%H.%M.%S,%3N")
_logline="$_timestamp ###### DONE ###################################################"
echo $_logline 2>&1 | tee -a $PLAT_LOGFILE
