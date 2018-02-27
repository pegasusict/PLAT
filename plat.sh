#!/bin/bash
################################################################################
## Pegasus' Linux Administration Tools        build20171215        VER1.0BETA ##
## (C)2017 Mattijs Snepvangers                          pegasus.ict@gmail.com ##
## plat.sh                postinstall script                       VER1.0BETA ##
## License: GPL v3                         Please keep my name in the credits ##
################################################################################

# When was this script called
_now=$(date +"%Y-%m-%d_%H.%M.%S.%3N")
# Making sure this script is run by bash to prevent mishaps
if [ "$(ps -p "$$" -o comm=)" != "bash" ]; then bash "$0" "$@" ; exit "$?" ; fi
# Make sure only root can run this script
if [[ $EUID -ne 0  ]]; then echo "This script must be run as root" ; exit 1 ; fi
# DEBUG is off by default
DEBUG = false
# define logfile name & creating log path
logdir = "/var/log/plat"
if [ ! -d "$logdir" ] ; then mkdir "$logdir" ; fi
PLAT_LOGFILE="$logdir/PostInstall_$_now.log"
# defining functions
getargs() {
   TEMP=`getopt -o hdr:c: --long help,debug,role:,containertype: -n "$FUNCNAME" -- "$@"`
   if [ $? != 0 ] ; then return 1 ; fi
   eval set -- "$TEMP"
   local format='%s\n' escape='-E' line='-n' script clear='tput sgr0'
   while true; do
		case "$1" in
			-h|--help) cat <<-EOF
         USAGE:

         OPTIONS

           -r or --role tells the script what kind of system we are dealing with.
              Valid options: basic, ws, zeus, mainserver, container
           -c or --containertype tells the script what kind of container we are working on.
              Valid options are: basic, nas, web, x11, pxe
           -d or --debug prints all messages
           -h or --help prints this message
EOF
         return
		shift; break;
			-d|--debug) DEBUG=true; shift;;
			-r|--role)
				case "${2}" in
					"ws" )
					  systemrole[ws] = true
					  ;;
					"zeus" )
					  systemrole[ws] = true
					  systemrole[lxdhost] = true
					  systemrole[zeus] = true
					  systemrole[nas] = true
					  ;;
					"mainserver" )
					  role = "mainserver"
					  systemrole[lxdhost] = true
					  ;;
					"container" )
					  systemrole[container] = true
					  ;;
				esac; shift 2;;
			-c|--containertype) 
				case "${2}" in
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
				esac; shift 2;;
		esac
   done
   tput -S <<<"$script"
   $clear
   echo "DEBUG: $DEBUG"
}
sof() {
	### ScreenOrFile
	### if DEBUG = TRUE, output is to screen and file, else only to file
	if [ "$DEBUG" = true ]
	then
	  echo $1 2>&1 | tee -a $PLAT_LOGFILE      
	else
	  echo $1 2>&1 >> $PLAT_LOGFILE
	fi
}
create_logline() {
	_subject="$1"
    _timestamp=$(date +"%Y-%m-%d_%H.%M.%S,%3N")
    _log_line="$_timestamp ## $_subject #"
    imax=80
    for (( i=${#_log_line}; i<imax; i++ )) ; do _log_line+="#" ; done
    sof $_log_line
}
create_secline() {
	_log_line="# $1 #"
	imax=78
	for (( i=${#_log_line}; i<imax; i+=2 )) ; do _log_line="#$_log_line#" ; done
	sof $_log_line
}
add_line_to_file() {
	LINE_TO_ADD = $1
	TARGET_FILE = $2
	if [ grep -qsFx "$LINE_TO_ADD" "$TARGET_FILE" ] ; then
		sof "line already exists, leaving it undisturbed"
	else
		if [ -w "$TARGET_FILE" ] ; then
			printf "%s\n" "$LINE_TO_ADD" >> "$TARGET_FILE"
			sof "$TARGET_FILE has been updated"
		else
			sof "$TARGET_FILE not writeable"
			exit 1
		fi
	fi
}

getargs

sof "################################################################################"
sof "## Pegasus' Linux Administration Tools - Post Install Script         V1.0Beta ##"
sof "## (c) 2017 Mattijs Snepvangers    build 20171215       pegasus.ict@gmail.com ##"
sof "################################################################################"
sof ""
########################################################################
create_logline "Injecting interfaces file into mainserver config"
if [ $role = "mainserver" ]
then
   cat lxdhost_interfaces.txt > /etc/network/interfaces
fi
########################################################################
create_logline "Installing extra PPA's"
create_secline "Copying Ubuntu sources and some extras"
cp apt/base.list /etc/apt/sources.list.d/ 2>&1 | sof
create_secline "Adding GetDeb PPA key"
wget -O- http://archive.getdeb.net/getdeb-archive.key | apt-key add - 2>&1 | sof
create_secline "Adding VirtualBox PPA key"
wget http://download.virtualbox.org/virtualbox/debian/oracle_vbox_2016.asc -O- | apt-key add - 2>&1 | sof
create_secline "Adding Webmin PPA key"
wget http://www.webmin.com/jcameron-key.asc -O- | apt-key add - 2>&1 | sof
create_secline "Adding WebUpd8 PPA key"
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 4C9D234C 2>&1 | sof
if [ "$systemrole[ws]" = true ] ; then
   create_secline "Adding FreeCad PPA"
   add-apt-repository ppa:freecad-maintainers/freecad-stable | sof
   create_secline "Adding GIMP PPA key"
   apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 614C4B38 2>&1 | sof
   create_secline "Adding Gnome3 Extras PPA"
   apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 3B1510FD 2>&1 | sof
   create_secline "Adding Google Chrome PPA"
   wget https://dl.google.com/linux/linux_signing_key.pub -O- | apt-key add - 2>&1 | sof
   create_secline "Adding Highly Explosive (Tools for Photographers) PPA"
   apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 93330B78 2>&1 | sof
   create_secline "Adding MKVToolnix PPA"
   wget http://www.bunkus.org/gpg-pub-moritzbunkus.txt -O- | apt-key add - 2>&1 | sof
   create_secline "Adding Opera (Beta) PPA"
   wget -O - http://deb.opera.com/archive.key | apt-key add - 2>&1 | sof
   create_secline "Adding OwnCloud Desktop PPA"
   wget http://download.opensuse.org/repositories/isv:ownCloud:community/xUbuntu_16.04/Release.key -O- | apt-key add - 2>&1 | sof
   create_secline "Adding Wine PPA"
   apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 883E8688397576B6C509DF495A9A06AEF9CB8DB0 2>&1 | sof
fi
if [ "$systemrole[nas]" = true ] ; then
   create_secline "Adding Syncthing PPA"
   curl -s https://syncthing.net/release-key.txt | apt-key add - 2>&1 | sof
fi
########################################################################
create_logline "removing duplicate lines from source lists"
perl -i -ne 'print if ! $a{$_}++' "/etc/apt/sources.list /etc/apt/sources.list.d/*" 2>&1 | sof
########################################################################
create_logline "Updating apt cache"
apt-get update -q 2>&1 | sof
########################################################################
create_logline "Installing updates"
apt-get --allow-unauthenticated upgrade -qy 2>&1 | sof
########################################################################
create_logline "Installing extra packages"
apt-get -qqy --allow-unauthenticated install mc trash-cli 2>&1 | sof
if [ "$systemrole[ws]" = true ] ; then
   apt-get -qqy --allow-unauthenticated install synaptic tilda/
   audacious samba wine-stable playonlinux winetricks 2>&1 | sof
fi
if [ "$systemrole[zeus]" = true ] ; then
   apt-get -qqy --allow-unauthenticated install plank picard audacity/
   calibre fastboot adb fslint gadmin-proftpd geany* gprename lame/
   masscan forensics-all forensics-extra forensics-extra-gui/
   forensics-full chromium-browser gparted 2>&1 | sof
fi
if [ "$systemrole[web]" = true ] ; then
   apt-get -qqy --allow-unauthenticated install apache2 phpmyadmin/
   mysql-server mytop proftpd 2>&1 | sof
fi
if [ "$systemrole[nas]" = true ] ; then
   apt-get -qqy --allow-unauthenticated install samba 2>&1 | sof
fi
if [ "$systemrole[pxe]" = true ] ; then
   apt-get -qqy --allow-unauthenticated install atftpd 2>&1 | sof
###CHECK### what about: cobbler
fi
################################################################################
create_logline "Installing extra software"
create_secline "Installing TeamViewer"
wget -nv https://download.teamviewer.com/download/teamviewer_i386.deb 2>&1 | sof
dpkg -i teamviewer_i386.deb 2>&1 | sof
rm teamviewer_i386.deb 2>&1 | sof
apt-get install -fy 2>&1 | sof
if [ $systemrole = "zeus" ]
then
  create_secline "Installing StarUML"
  wget -nv http://nl.archive.ubuntu.com/ubuntu/pool/main/libg/libgcrypt11/libgcrypt11_1.5.3-2ubuntu4.5_amd64.deb 2>&1 | sof
  dpkg -i libgcrypt11_1.5.3-2ubuntu4.5_amd64.deb 2>&1 | sof
  rm libgcrypt11_1.5.3-2ubuntu4.5_amd64.deb 2>&1 | sof
  wget -nv http://staruml.io/download/release/v2.8.0/StarUML-v2.8.0-64-bit.deb 2>&1 | sof
  dpkg -i StarUML-v2.8.0-64-bit.deb 2>&1 | sof
  rm StarUML-v2.8.0-64-bit.deb 2>&1 | sof
  create_secline "Installing GitKraken"
  wget https://release.gitkraken.com/linux/gitkraken-amd64.deb 2>&1 | sof
  dpkg -i gitkraken-amd64.deb 2>&1 | sof
  rm gitkraken-amd64.deb 2>&1 | sof
fi
################################################################################
create_logline "Building maintenance script"
mkdir /etc/plat 2>&1 | sof
maintenancescript="/etc/plat/maintenance.sh"
if [ -f "$maintenancescript" ] ; then
	rm $maintenancescript 2>&1 | sof
	create_secline "Removed old maintenance script."
cat maintenance/maintenance-header1.sh >> "$maintenancescript"
echo "##                     built at $_timestamp                     ##" >> "$maintenancescript"
sed -e 1d maintenance/maintenance-header2.sh >> "$maintenancescript"
echo "##                     built at $_timestamp                     ##" >> "$maintenancescript"
sed -e 1d maintenance/maintenance-header3.sh >> "$maintenancescript"
if [ $systemrole = "lxdhost" ] ; then
   sed -e 1d maintenance/body-lxdhost0.sh >> "$maintenancescript"
   if [ $role == "mainserver" ] ; then
     sed -e 1d maintenance/backup2tape.sh >> "$maintenancescript"
   fi
   sed -e 1d maintenance/body-lxdhost1.sh >> "$maintenancescript"
fi
sed -e 1d maintenance/body-basic.sh >> "$maintenancescript"
chmod 555 /etc/plat/maintenance.sh 2>&1 | sof
chown root:root /etc/plat/maintenance.sh 2>&1 | sof
######
create_secline "adding maintenancescript to sheduler"
if [ $role = "mainserver" ] ; then
	LINE_TO_ADD="\n### Added by Pegs Linux Administration Tools ###\n0 * * 4 0 bash /etc/plat/maintenance.sh\n\n"
	TARGET_FILE="/etc/crontab"
else
	LINE_TO_ADD="\n### Added by Pegs Linux Administration Tools ###\n@weekly\t10\tplat_maintenance\tbash /etc/plat/maintenance.sh\n### /PLAT ###\n"
	TARGET_FILE="/etc/anacrontab"
fi
add_line_to_file $LINE_TO_ADD $TARGET_FILE
################################################################################
create_logline "Building mail script"
mailscript="/etc/plat/mail.sh"
mkdir /etc/plat
rm $mailscript 2>&1 | sof
cat mail/mail0.sh >> "$mailscript"
echo "Which gmail account will I use to send the reports?"
read sender
echo "From_Mail=\"$sender\"" >> "$mailscript"
sed -e 1d mail/mail1.sh >> "$mailscript"
echo "Which password goes with that account?"
read PassWord
echo "Sndr_Passwd=\"$PassWord\"" >> "$mailscript"
sed -e 1d mail/mail2.sh >> "$mailscript"
echo "To whom will the reports be sent?"
read Recipient
echo "To_Mail=\"$Recipient\"" >> "$mailscript"
sed -e 1d mail/mail3.sh >> "$mailscript"
################################################################################
create_logline "sheduling reboot if required"
if [ -f /var/run/reboot-required ]; then
	create_logline "REBOOT REQUIRED"
    shutdown -r 23:30  2>&1 | sof
fi
################################################################################
create_logline "DONE, emailing log(s)"
bash /etc/plat/mail.sh
