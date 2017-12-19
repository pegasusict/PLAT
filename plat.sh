#!/bin/bash
################################################################################
## Pegasus' Linux Administration Tools        build20171215        VER1.0BETA ##
## (C)2017 Mattijs Snepvangers                          pegasus.ict@gmail.com ##
## plat.sh                postinstall script                       VER1.0BETA ##
## License: GPL v3                         Please keep my name in the credits ##
################################################################################
# Make sure only root can run this script
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

_now=$(date +"%Y-%m-%d_%H.%M.%S.%3N")
PLAT_LOGFILE="/var/log/plat/PostInstall_$_now.log"
echo "################################################################################" 2>&1 | tee -a $PLAT_LOGFILE
echo "## Pegasus' Linux Administration Tools - Post Install Script         V1.0Beta ##" 2>&1 | tee -a $PLAT_LOGFILE
echo "## (c) 2017 Mattijs Snepvangers    build 20171215       pegasus.ict@gmail.com ##" 2>&1 | tee -a $PLAT_LOGFILE
echo "################################################################################" 2>&1 | tee -a $PLAT_LOGFILE
echo "" 2>&1 | tee -a $PLAT_LOGFILE
######## defining functions
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

           -r or --role tells the script what kind of system we are dealing with.
              Valid options: basic, ws, zeus, mainserver, container
           -c or --containertype tells the script what kind of container we are working on.
              Valid options are: basic, nas, web, x11, pxe
EOF
###TODO### re indent EOF when done if needed
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
create_logline() {
   _timestamp=$(date +"%Y-%m-%d_%H.%M.%S,%3N")
   _log_line="$_timestamp ## $loglinetitle #"
   imax=80
   for (( i=${#_log_line}; i<imax; i++ ))
   do
       _log_line+="#"
   done
   echo $_log_line 2>&1 | tee -a $PLAT_LOGFILE
}
create_secline() {
   _log_line="# $loglinetitle #"
   imax=78
   for (( i=${#_log_line}; i<imax; i+=2 ))
   do
       _log_line="#$_log_line#"
   done
   echo $_log_line 2>&1 | tee -a $PLAT_LOGFILE
}

getargs()
###TODO### what to do with interfaces file?
if [ $role = "mainserver" ];
then
   cat lxdhost_interfaces.txt > /etc/network/interfaces
fi

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
   "mainserver" )
      systemrole[basic] = true
      systemrole[lxdhost] = true
      ;;
   "container" )
      systemrole[container] = true
      systemrole[basic] = true
      case "$containertype" in
         "nas" )
            systemrole[nas] = true
            ;;
         "web" )
            systemrole[nas] = true
            systemrole[web] = true
            ;;
         "x11" )
            systemrole[ws] = true
            ;;
         "pxe" )
            systemrole[nas] = true
            systemrole[pxe] = true
            ;;
      esac
   * )
      systemrole[basic] = true
      ;;
esac
################################################################################
create_logline "Installing extra PPA's"
if [ "$systemrole[basic]" = true ];
then
   create_secline "Copying Ubuntu sources and some extras"
   cp apt/base.lst /etc/apt/sources.list.d/ 2>&1 | tee -a $PLAT_LOGFILE
   create_secline "Adding GetDeb PPA key"
   wget -q -O- http://archive.getdeb.net/getdeb-archive.key | apt-key add - 2>&1 | tee -a $PLAT_LOGFILE
   create_secline "Adding VirtualBox PPA key"
   wget -q http://download.virtualbox.org/virtualbox/debian/oracle_vbox_2016.asc -O- | apt-key add - 2>&1 | tee -a $PLAT_LOGFILE
   create_secline "Adding Webmin PPA key"
   wget http://www.webmin.com/jcameron-key.asc -O- | apt-key add - 2>&1 | tee -a $PLAT_LOGFILE
   create_secline "Adding WebUpd8 PPA key"
   apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 4C9D234C 2>&1 | tee -a $PLAT_LOGFILE
fi
if [ "$systemrole[ws]" = true ];
then
   create_secline "Copying extra PPA's"
   cp apt/base.lst /etc/apt/sources.list.d/ 2>&1 | tee -a $PLAT_LOGFILE
   create_secline "Adding FreeCad PPA"
   add-apt-repository ppa:freecad-maintainers/freecad-stable
   create_secline "Adding GIMP PPA key"
   apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 614C4B38 2>&1 | tee -a $PLAT_LOGFILE
   create_secline "Adding Gnome3 Extras PPA"
   apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 3B1510FD 2>&1 | tee -a $PLAT_LOGFILE
   create_secline "Adding Google Chrome PPA"
   wget -q https://dl.google.com/linux/linux_signing_key.pub -O- | apt-key add - 2>&1 | tee -a $PLAT_LOGFILE
   create_secline "Adding Highly Explosive (Tools for Photographers) PPA"
   apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 93330B78 2>&1 | tee -a $PLAT_LOGFILE
   create_secline "Adding MKVToolnix PPA"
   wget -q http://www.bunkus.org/gpg-pub-moritzbunkus.txt -O- | apt-key add - 2>&1 | tee -a $PLAT_LOGFILE
   create_secline "Adding Opera (Beta) PPA"
   wget -O - http://deb.opera.com/archive.key | apt-key add - 2>&1 | tee -a $PLAT_LOGFILE
   create_secline "Adding OwnCloud Desktop PPA"
   wget -q http://download.opensuse.org/repositories/isv:ownCloud:community/xUbuntu_16.04/Release.key -O- | apt-key add - 2>&1 | tee -a $PLAT_LOGFILE
   create_secline "Adding Wine PPA"
   apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 883E8688397576B6C509DF495A9A06AEF9CB8DB0 2>&1 | tee -a $PLAT_LOGFILE
fi

if [ "$systemrole[nas]" = true ];
then
   create_secline "Adding Syncthing PPA"
   curl -s https://syncthing.net/release-key.txt | apt-key add - 2>&1 | tee -a $PLAT_LOGFILE
fi
################################################################################
create_logline "Updating apt cache"
apt-get -qqy update 2>&1 | tee -a $PLAT_LOGFILE
################################################################################
create_logline "Installing updates"
apt-get -qqy --allow-unauthenticated upgrade 2>&1 | tee -a $PLAT_LOGFILE
################################################################################
create_logline "Installing extra packages"
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
if [ "$systemrole[web]" = true ];
then
   apt-get -qqy --allow-unauthenticated install apache2 phpmyadmin mysql-server mytop proftpd 2>&1 | tee -a $PLAT_LOGFILE  2>&1
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
################################################################################
create_logline "Installing extra software"
create_secline "Installing TeamViewer"
wget -nv https://download.teamviewer.com/download/teamviewer_i386.deb 2>&1 | tee -a $PLAT_LOGFILE
gdebi -n teamviewer_i386.deb 2>&1 | tee -a $PLAT_LOGFILE
rm teamviewer_i386.deb 2>&1 | tee -a $PLAT_LOGFILE
apt-get install -f 2>&1 | tee -a $PLAT_LOGFILE

if $systemrole = "zeus";
then
  create_secline "Installing StarUML & GitKraken"
  wget -nv http://nl.archive.ubuntu.com/ubuntu/pool/main/libg/libgcrypt11/libgcrypt11_1.5.3-2ubuntu4.5_amd64.deb 2>&1 | tee -a $PEGS_LOGFILE
  gdebi -n libgcrypt11_1.5.3-2ubuntu4.5_amd64.deb 2>&1 | tee -a $PEGS_LOGFILE
  rm libgcrypt11_1.5.3-2ubuntu4.5_amd64.deb 2>&1 | tee -a $PEGS_LOGFILE
  wget -nv http://staruml.io/download/release/v2.8.0/StarUML-v2.8.0-64-bit.deb 2>&1 | tee -a $PEGS_LOGFILE
  gdebi -n StarUML-v2.8.0-64-bit.deb 2>&1 | tee -a $PEGS_LOGFILE
  rm StarUML-v2.8.0-64-bit.deb 2>&1 | tee -a $PEGS_LOGFILE
  wget https://release.gitkraken.com/linux/gitkraken-amd64.deb 2>&1 | tee -a $PEGS_LOGFILE
  gdebi -n gitkraken-amd64.deb 2>&1 | tee -a $PEGS_LOGFILE
  rm gitkraken-amd64.deb 2>&1 | tee -a $PEGS_LOGFILE
fi
################################################################################
create_logline "Building maintenance script"
maintenancescript = "maintenance.sh"
cat maintenance/maintenance-header1.sh >> "$maintenancescript"
echo "##                     built at $_timestamp                     ##" >> "$maintenancescript"
sed -e 1d maintenance/maintenance-header2.sh >> "$maintenancescript"
echo "##                     built at $_timestamp                     ##" >> "$maintenancescript"
sed -e 1d maintenance/maintenance-header3.sh >> "$maintenancescript"
if $systemrole = "lxdhost";
then
   sed -e 1d maintenance/body-lxdhost0.sh >> "$maintenancescript"
   if $role = "mainserver";
   then
     sed -e 1d maintenance/backup2tape.sh >> "$maintenancescript"
   fi
   sed -e 1d maintenance/body-lxdhost1.sh >> "$maintenancescript"
fi
sed -e 1d maintenance/basic-body.sh >> "$maintenancescript"
create_secline "Moving maintenance script to /etc/"
mv "$maintenancescript" /etc/plat/maintenance.sh
chmod 555 /etc/plat/maintenance.sh
chown root:root /etc/plat/maintenance.sh
if $role = "mainserver";
then
  echo -e "\n### Added by Pegs Linux Administration Tools ###\n0 * * 4 0 bash /etc/plat/maintenance.sh\n\n" >> /etc/crontab
elif
  echo -e "\n### Added by Pegs Linux Administration Tools ###\n@weekly\t10\tplat_maintenance\tbash /etc/plat/maintenance.sh\n### /PLAT ###\n" >> /etc/anacrontab
fi
################################################################################
create_logline "Building mail script"
mailscript = "/etc/plat/mail.sh"
cat mail/mail0.sh >> "$mailscript"
echo "Which gmail account will I use to send the reports?"
read sender
echo "From_Mail=\"$sender\"" >> mailscript
cat mail/mail1.sh >> "$mailscript"
echo "Which password goes with that account?"
read PassWord
echo "Sndr_Passwd=\"$PassWord\"" >> mailscript
cat mail/mail2.sh >> "$mailscript"
echo "To whom will the reports be sent?"
read Recipient
echo "To_Mail=\"$Recipient\"" >> mailscript
cat mail/mail3.sh >> "$mailscript"
################################################################################
create_logline "DONE"
### email with log attached
bash /etc/plat/mail.sh
