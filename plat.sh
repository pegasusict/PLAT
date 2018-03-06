#!/bin/bash
###############################################################################
## Pegasus' Linux Administration Tools                    postinstall script ##
## (C)2017-2018 Mattijs Snepvangers                    pegasus.ict@gmail.com ##
## License: GPL v3                        Please keep my name in the credits ##
###############################################################################
START_TIME=$(date +"%Y-%m-%d_%H.%M.%S.%3N")
PROGRAM_SUITE="Pegasus' Linux Administration Tools"
SCRIPT_TITLE="Post Install Script"
$MAINTENANCE_SCRIPT_TITLE="Maintenance Script"
$EMAIl_SCRIPT_TITLE="Email Script"
SCRIPT=$(basename "$0")
MAINTAINER="Mattijs Snepvangers"
EMAIL="pegasus.ict@gmail.com"
VERSION_MAJOR=0
VERSION_MINOR=10
VERSION_PATCH=3
VERSION_STATE="ALPHA " # needs to be 6 chars for alignment <ALPHA |BETA  |STABLE>
VERSION_BUILD=20180306
CURR_YEAR=$(date +"%Y")
TODAY=$(date +"%d-%m-%Y")
###############################################################################
PROGRAM="$PROGRAM_SUITE - $SCRIPT"
SHORTVERSION="$VERSION_MAJOR.$VERSION_MINOR.$VERSION_PATCH-$VERSION_STATE"
VERSION="Ver$SHORTVERSION build $VERSION_BUILD"
###############################################################################
# Making sure this script is run by bash to prevent mishaps
if [ "$(ps -p "$$" -o comm=)" != "bash" ]; then bash "$0" "$@" ; exit "$?" ; fi
# Make sure only root can run this script
if [[ $EUID -ne 0  ]]; then echo "This script must be run as root" ; exit 1 ; fi
# set default values
Verbosity=2
tmpage=2
garbageage=7
logage=30
ask_for_email_stuff="yes"
###################### defining functions #####################################
apt-inst() { apt-get -qqy --allow-unauthenticated install "$@" 2>&1 | opr4; }
add_line_to_file() {
    LINE_TO_ADD = $1
    TARGET_FILE = $2
    if [ grep -qsFx "$LINE_TO_ADD" "$TARGET_FILE" ] ; then opr4 "line already exists, leaving it undisturbed"
    else
        if [ -w "$TARGET_FILE" ] ; then printf "%s\n" "$LINE_TO_ADD" >> "$TARGET_FILE"; opr3 "$TARGET_FILE has been updated"
        else opr1 "WARNING: $TARGET_FILE not writeable: Line '$LINE_TO_ADD' could not be added"
        fi
    fi
}
add_to_maintenance() { add_to_script "$maintenancescript" $1 ; }
add_to_mail() { add_to_script "$mailscript" $1 ; }
add_ppa(){
	method=$1; url=$2; key=$3
	case method in
		"wget"		)	wget -q -a "$PLAT_LOGFILE" $url -O- | apt-key add - ;;
		"apt-key"	)	apt-key adv --keyserver $url --recv-keys $key 2>&1 | opr3 ;;
		"aar"		)	add-apt-repository $url | opr3 ;;
	esac
}
add_to_script() {
	targetscript=$1
	line=$2
	cat "$line" >> $targetscript
}
checkcontainer() {
	_container=$1
	case "$_container" in
		"nas"	)	systemrole[nas] = true
					opr3 "container=nas";;
		"web" 	)	systemrole[nas] = true
					systemrole[web] = true
					opr3 "container=web";;
		"x11"	)	systemrole[ws] = true
					opr3 "container=x11";;
		"pxe"	)	systemrole[nas] = true
					systemrole[pxe] = true
					opr3 "container=pxe";;
		"basic"	)	systemrole[basic]=true;
					opr3 "container=basic";;
		*		)	opr0 "ERROR: Unknown containertype $container, exiting...";
					exit 1;;
	esac;
}
checkrole() {
	_role=$1
	case "$_role" in
		"ws"			)	systemrole[ws]=true
							opr3 "role=ws";;
		"poseidon" 		)	systemrole[ws]=true
							systemrole[server]=true
							systemrole[lxdhost]=true
							systemrole[poseidon]=true
							systemrole[nas]=true
							opr3 "role=poseidon";;
		"mainserver"	)	opr3 "role=mainserver"
							systemrole[server]=true
							systemrole[mainserver]=true
							systemrole[lxdhost]=true;;
		"container"		)	opr3 "role=container"
							systemrole[server]=true
							systemrole[container]=true;;
		*				)	opr0 "CRITICAL: Unknown systemrole $role, exiting..."
							exit 1;;
	esac
}
cr_dir() { targetdir=$1; if [ ! -d "$targetdir" ] ; then mkdir "$targetdir" ; fi ; }
create_logline() { ### INFO MESSAGES with timestamp
    _subject="$1"
    _log_line="$(getthetime) ## $_subject #"
    imax=80
    for (( i=${#_log_line}; i<$imax; i++ )) ; do _log_line+="#" ; done
    opr2 "$_log_line"
}
create_secline() { ### VERBOSE MESSAGES
    _subject="$1 - line $LINENO"
    _sec_line="# $_subject #"
    imax=78
    for (( i=${#_sec_line}; i<$imax; i+=2 )) ; do _sec_line="#$_sec_line#" ; done
    opr3 "$_sec_line"
}
download() { wget -q -a "$PLAT_LOGFILE" -nv $1; }
getargs() {
    getopt --test > /dev/null
	if [[ $? -ne 4 ]]; then
		echo "I’m sorry, `getopt --test` failed in this environment."
		exit 1
	fi
	OPTIONS="hv:r:c:g:l:t:S:P:R:"
	LONG_OPTIONS="help,verbosity:,role:,containertype:garbageage:logage:tmpage:emailsender:emailpass:emailreciever:"
    PARSED=$(getopt -o $OPTIONS --long $LONG_OPTIONS -n "$0" -- "$@")
    if [ $? -ne 0 ] ; then usage ; fi
    eval set -- "$PARSED"
    while true; do
        case "$1" in
			-h|--help 			) usage ; shift ;;
            -v|--verbosity		) setverbosity $2 ; shift 2 ;;
            -r|--role 			) checkrole $2; shift 2 ;; 
            -c|--containertype	) checkcontainer $2; shift 2 ;;
            -g|--garbageage		) gabageage=$2; shift 2 ;;
            -l|--logage			) logage=$2; shift 2 ;;
            -t|--tmpage			) tmpage=$2; shift 2 ;;
            -S|--emailsender	) EmailSender=$2; shift 2 ;;
            -P|--emailpass		) EmailPassword=$2; shift 2 ;;
            -R|--emailrecipient ) EmailRecipient=$2; shift 2 ;;
            -- ) shift; break ;;
            * ) break ;;
        esac
    done
}
getthetime(){ echo $(date +"%Y-%m-%d_%H.%M.%S.%3N") ; }
insert_timestamp() {
	targetfile=$1
	echo "##                     built at $(getthetime)                     ##" >> "$targetfile"
}
install() { dpkg -i $1 2>&1 | opr4; }
opr() {
    ### OutPutRouter ###
    # decides what to print on screen based on $Verbosity level
    # usage: opr <verbosity level> <message>
    importance=$1
    message=$2
    if [ $importance -le $Verbosity ]
		then echo "$message" | tee -a $PLAT_LOGFILE
		else echo "$message" >> $PLAT_LOGFILE
	fi
}
opr0() { opr 0 "$1"; } ### CRITICAL
opr1() { opr 1 "$1"; } ### WARNING
opr2() { opr 2 "$1"; } ### INFO
opr3() { opr 3 "$1"; } ### VERBOSE
opr4() { opr 4 "$1"; } ### DEBUG
setverbosity() {
	case $1 in
		0	)	Verbosity=0;;	### Be vewy, vewy quiet... Will only show Critical errors which result in untimely exiting of the script
		1	)	Verbosity=1;;	# Will only show warnings that don't endanger the basic functioning of the program
		2	)	Verbosity=2;;	# Just give us the highlights, please - will tell what phase is taking place
		3	)	Verbosity=3;;	# Let me know what youre doing, every step of the way
		4	)	Verbosity=4;;	# I want it all, your thoughts and dreams too!!!
	esac
}
usage() {
	version
	cat <<EOT
		 USAGE: sudo bash $SCRIPT -h
				or
			sudo bash $SCRIPT -r <systemrole> [ -c <containertype> ] [ -v INT ] [ -g <garbageage> ] [ -l <logage> ] [ -t <tmpage> ] [ -S <emailsender> -P <emailpassword> -R <emailsrecipient(s)> ]

		 OPTIONS

		   -r or --role tells the script what kind of system we are dealing with.
			  Valid options: ws, poseidon, mainserver, container << REQUIRED >>
		   -c or --containertype tells the script what kind of container we are working on.
			  Valid options are: basic, nas, web, x11, pxe << REQUIRED if -r=container >>
		   -v or --verbosity defines the amount of chatter. 0=CRITICAL, 1=WARNING, 2=INFO, 3=VERBOSE, 4=DEBUG. default=2
		   -g or --garbageage defines the age (in days) of garbage (trashbins & temp files) being cleaned, default=7
		   -l or --logage defines the age (in days) of logs to be purged, default=30
		   -t or --tmpage define how long temp files should be untouched before they are deleted, default=2
		   -S or --emailsender defines the gmail account used for sending the logs 
		   -P or --emailpass defines the password for that account
		   -R or --emailrecipient defines the recipient(s) of those emails
		   -h or --help prints this message

		  The options can be used in any order
EOT
	exit 3
}  
version() { echo -e "\n$PROGRAM $VERSION - (c)$CURR_YEAR $MAINTAINER"; }   
### "define logfile name & create log path"
logdir="/var/log/plat"
cr_dir $logdir
PLAT_LOGFILE="$logdir/PostInstall_$START_TIME.log"
###
getargs "$@"
###
opr2 <<EOT
################################################################################
## $PROGRAM_SUITE - $SCRIPT_TITLE  Ver$SHORTVERSION ##
## (c)2017-$CURR_YEAR $MAINTAINER  build $VERSION_BUILD     $EMAIL ##
################################################################################

EOT
if [ ${#systemrole} -le 1 ]; then opr0 "CRITICAL: no systemrole defined, exiting..."; exit 1 ; fi
########################################################################
if [ $systemrole[mainserver] = true ]
then
	create_logline "Injecting interfaces file into mainserver network config"
	cat lxdhost_interfaces.txt > /etc/network/interfaces
fi
########################################################################
create_logline "Installing extra PPA's"
create_secline "Copying Ubuntu sources and some extras"; cp apt/base.list /etc/apt/sources.list.d/ 2>&1 | opr4
create_secline "Adding GetDeb PPA key";				add_ppa "wget" "http://archive.getdeb.net/getdeb-archive.key"
create_secline "Adding VirtualBox PPA key";			add_ppa "wget" "http://download.virtualbox.org/virtualbox/debian/oracle_vbox_2016.asc"
create_secline "Adding Webmin PPA key";				add_ppa "wget" "http://www.webmin.com/jcameron-key.asc"
create_secline "Adding WebUpd8 PPA key";			add_ppa "apt-key" "keyserver.ubuntu.com" "4C9D234C"
if [ "$systemrole[ws]" = true ] ; then
   create_secline "Adding FreeCad PPA";				add_ppa "aar" "ppa:freecad-maintainers/freecad-stable"
   create_secline "Adding GIMP PPA key";			add_ppa "apt-key" "keyserver.ubuntu.com" "614C4B38"
   create_secline "Adding Gnome3 Extras PPA";		add_ppa "apt-key" "keyserver.ubuntu.com" "3B1510FD"
   create_secline "Adding Google Chrome PPA";		add_ppa "wget" "https://dl.google.com/linux/linux_signing_key.pub"
   create_secline "Adding Highly Explosive PPA";	add_ppa "apt-key" "keyserver.ubuntu.com" "93330B78"
   create_secline "Adding MKVToolnix PPA"; 			add_ppa "wget" "http://www.bunkus.org/gpg-pub-moritzbunkus.txt"
   create_secline "Adding Opera (Beta) PPA"; 		add_ppa "wget" "http://deb.opera.com/archive.key"
   create_secline "Adding OwnCloud Desktop PPA";	add_ppa "wget" "http://download.opensuse.org/repositories/isv:ownCloud:community/xUbuntu_16.04/Release.key"
   create_secline "Adding Wine PPA"; 				add_ppa "apt-key" "keyserver.ubuntu.com" "883E8688397576B6C509DF495A9A06AEF9CB8DB0"
fi
if [ "$systemrole[nas]" = true ] ; then
   create_secline "Adding Syncthing PPA"; 			add_ppa "wget" "https://syncthing.net/release-key.txt"
fi
########################################################################
create_logline "removing duplicate lines from source lists"; perl -i -ne 'print if ! $a{$_}++' "/etc/apt/sources.list /etc/apt/sources.list.d/*" 2>&1 | opr4
create_logline "Updating apt cache"; apt-get update -q 2>&1 | opr4
create_logline "Installing updates"; apt-get --allow-unauthenticated upgrade -qy 2>&1 | opr4
######
create_logline "Installing extra packages";  apt-inst mc trash-cli snapd git
if [ "$systemrole[ws]" = true ] ; 		then apt-inst synaptic tilda audacious samba wine-stable playonlinux winetricks; fi
if [ "$systemrole[poseidon]" = true ] ; then apt-inst picard audacity calibre fastboot adb fslint gadmin-proftpd geany* gprename lame masscan forensics-all forensics-extra forensics-extra-gui forensics-full chromium-browser gparted ; fi
if [ "$systemrole[web]" = true ] ;		then apt-inst apache2 phpmyadmin mysql-server mytop proftpd webmin ; fi
if [ "$systemrole[nas]" = true ] ;		then apt-inst samba nfsd proftpd ; fi
if [ "$systemrole[pxe]" = true ] ;		then apt-inst atftpd ; fi
if [ "$systemrole[lxdhost]" = true ] ;	then apt-inst python3-crontab lxc lxcfs lxd lxd-tools bridge-utils xfsutils-linux criu apt-cacher-ng; fi
if [ "$systemrole[server]" = true ] ;	then apt-inst ssh-server screen; fi
################################################################################
create_logline "Installing extra software"
create_secline "Installing TeamViewer"
download "https://download.teamviewer.com/download/teamviewer_i386.deb"
install teamviewer_i386.deb
apt-get install -fy 2>&1 | opr4
if [ $systemrole = "poseidon" ]
then
  create_secline "Installing StarUML"
  download "http://nl.archive.ubuntu.com/ubuntu/pool/main/libg/libgcrypt11/libgcrypt11_1.5.3-2ubuntu4.5_amd64.deb"
  install libgcrypt11_1.5.3-2ubuntu4.5_amd64.deb
  download "http://staruml.io/download/release/v2.8.0/StarUML-v2.8.0-64-bit.deb"
  install StarUML-v2.8.0-64-bit.deb
  create_secline "Installing GitKraken"
  download "https://release.gitkraken.com/linux/gitkraken-amd64.deb"
  install gitkraken-amd64.deb
fi
rm *.deb 2>&1 | opr4
################################################################################
create_logline "Building maintenance script"
cr_dir "/etc/plat"
maintenancescript="/etc/plat/maintenance.sh"
if [ -f "$maintenancescript" ] ; then rm $maintenancescript 2>&1 | opr4; opr4 "Removed old maintenance script."; fi
add_to_maintenance <<EOT
#!/usr/bin/bash
################################################################################
## $PROGRAM_SUITE - $MAINTENANCE_SCRIPT_TITLE   Ver$SHORTVERSION ##
## (c)2017-$CURR_YEAR $MAINTAINER  build $VERSION_BUILD     $EMAIL ##
## This maintenance script is dynamically built        Last build: $TODAY ##
## License: GPL v3                         Please keep my name in the credits ##
################################################################################

EOT
sed -e 1d maintenance/maintenance-header2.sh >> "$maintenancescript"
sed -e 1d maintenance/maintenance-header3.sh >> "$maintenancescript"
add_to_maintenance <<EOT
tolog <<EOH
################################################################################
## $PROGRAM_SUITE - $MAINTENANCE_SCRIPT_TITLE   Ver$SHORTVERSION ##
## (c)2017-$CURR_YEAR $MAINTAINER  build $VERSION_BUILD     $EMAIL ##
## This maintenance script is dynamically built        Last build: $TODAY ##
## License: GPL v3                         Please keep my name in the credits ##
################################################################################

EOH
EOT
add_to_maintenance "garbageage=$garbageage"
add_to_maintenance "logage=$logage"
if [ $systemrole[lxdhost] = true ]
	then sed -e 1d maintenance/body-lxdhost0.sh >> "$maintenancescript"
	if [ $systemrole[mainserver] = true ]; then sed -e 1d maintenance/backup2tape.sh >> "$maintenancescript"; fi
	sed -e 1d maintenance/body-lxdhost1.sh >> "$maintenancescript"
fi
sed -e 1d maintenance/body-basic.sh >> "$maintenancescript"
chmod 555 "$maintenancescript" 2>&1 | opr4 ; chown root:root "$maintenancescript" 2>&1 | opr4
###
create_secline "adding maintenancescript to sheduler"
if [ $systemrole[mainserver] = true ]
then
    LINE_TO_ADD="\n### Added by $PROGRAM_SUITE ###\n0 * * 4 0 bash /etc/plat/maintenance.sh\n\n"
    TARGET_FILE="/etc/crontab"
else
    LINE_TO_ADD="\n### Added by $PROGRAM_SUITE ###\n@weekly\t10\tplat_maintenance\tbash /etc/plat/maintenance.sh\n"
    TARGET_FILE="/etc/anacrontab"
fi
add_line_to_file "$LINE_TO_ADD" "$TARGET_FILE"
################################################################################
create_logline "Building mail script"
if [[ ${#EmailSender} -ge 10 ] && [ ${#EmailPassword} -ge 8 ] && [ ${#EmailRecipient} -ge 10 ]]; then ask_for_email_stuff="no"; fi
mailscript="/etc/plat/mail.sh"
cr_dir "/etc/plat"
if [ -f "$mail" ] ; then rm $mail 2>&1 | opr4; create_secline "Removed old mail script.";fi
add_to_mail <<EOT
#!/usr/bin/bash
################################################################################
## $PROGRAM_SUITE   -   $MAIL_SCRIPT_TITLE      Ver$SHORTVERSION ##
## (c)2017-$CURR_YEAR $MAINTAINER  build $VERSION_BUILD     $EMAIL ##
## This mail script is dynamically built               Last build: $TODAY ##
## License: GPL v3                         Please keep my name in the credits ##
################################################################################

EOT
sed -e 1d mail/mail1.sh >> "$mailscript"
if [ "$ask_for_email_stuff" = "yes" ];then echo "Which gmail account will I use to send the reports? (other providers are not supported for now)";read EmailSender;fi
echo "# Define sender's detail  email ID" >> "$mailscript"; echo "From_Mail=\"$EmailSender\"" >> "$mailscript"
if [ "$ask_for_email_stuff" = "yes" ];then echo "Which password goes with that account?"; read EmailPassword; fi
echo "# Define sender's password" >> "$mailscript"; echo "Sndr_Passwd=\"$EmailPassword\"" >> "$mailscript"
if [ "$ask_for_email_stuff" = "yes" ];then echo "To whom will the reports be sent?"; read EmailRecipient;fi
echo "# Define recipient(s)" >> "$mailscript"; echo "To_Mail=\"Email$Recipient\"" >> "$mailscript"
add_to_mail <<EOT
CC_TO="$EMAIL"
RELAY_SERVER="smtp.gmail.com:587"
SUBJECT="$PROGRAM_SUITE mailservice"
MSG() {
cat <<EOF
L.S.,

This is an automated email from your server/workstation $(HOST).
You will find the logfile(s) attached to this email.

kind regards,

$PROGRAM_SUITE

EOF
}
EOT
sed -e 1d mail/mail2.sh >> "$mailscript"
################################################################################
create_logline "checking for reboot requirement"
if [ -f /var/run/reboot-required ]; then create_logline "REBOOT REQUIRED"; shutdown -r 23:30  2>&1 | opr2; fi
################################################################################
create_logline "DONE, emailing log"
bash /etc/plat/mail.sh
###TODO### make update mechanism using git for maintenancefiles?
