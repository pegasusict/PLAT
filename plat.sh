#!/bin/bash
###############################################################################
## Pegasus' Linux Administration Tools                    postinstall script ##
## (C)2017-2018 Mattijs Snepvangers                    pegasus.ict@gmail.com ##
## License: GPL v3                        Please keep my name in the credits ##
###############################################################################
START_TIME=$(date +"%Y-%m-%d_%H.%M.%S.%3N")
echo "$START_TIME ## Starting PostInstall Process #######################"
################### PROGRAM INFO ##############################################
PROGRAM_SUITE="Pegasus' Linux Administration Tools"
SCRIPT_TITLE="Post Install Script"
MAINTENANCE_SCRIPT_TITLE="Maintenance Script"
CONTAINER_SCRIPT_TITLE="Container Maintenance Script"
#MAIL_SCRIPT_TITLE="Email Script"
MAINTAINER="Mattijs Snepvangers"
MAINTAINER_EMAIL="pegasus.ict@gmail.com"
VERSION_MAJOR=1
VERSION_MINOR=0
VERSION_PATCH=0
VERSION_STATE="BETA"
VERSION_BUILD=201803013
###############################################################################
PROGRAM="$PROGRAM_SUITE - $SCRIPT"
SHORT_VERSION="$VERSION_MAJOR.$VERSION_MINOR.$VERSION_PATCH-$VERSION_STATE"
VERSION="Ver$SHORT_VERSION build $VERSION_BUILD"
###############################################################################
# Making sure this script is run by bash to prevent mishaps
if [ "$(ps -p "$$" -o comm=)" != "bash" ]; then bash "$0" "$@" ; exit "$?" ; fi
# Make sure only root can run this script
if [[ $EUID -ne 0  ]]; then echo "This script must be run as root" ; exit 1 ; fi
# set default values
CURR_YEAR=$(date +"%Y")			;		TODAY=$(date +"%d-%m-%Y")	;	VERBOSITY=2
#COMPUTER_NAME=$(uname -n)
TMP_AGE=2						;		GARBAGE_AGE=7				;	LOG_AGE=30
#ASK_FOR_EMAIL_STUFF=true		;		
SYSTEMROLE_BASIC=false			;		SYSTEMROLE_WS=false
SYSTEMROLE_POSEIDON=false		;		SYSTEMROLE_SERVER=false
SYSTEMROLE_LXCHOST=false		;		SYSTEMROLE_NAS=false
SYSTEMROLE_MAINSERVER=false 	;		SYSTEMROLE_CONTAINER=false
SYSTEMROLE_WEB=false			;		SYSTEMROLE_PXE=false
LOGDIR="/var/log/plat"			;		SCRIPT_DIR="/etc/plat"
LOGFILE="$LOGDIR/PostInstall_$START_TIME.log"
MAINTENANCE_SCRIPT="$SCRIPT_DIR/maintenance.sh"
CONTAINER_SCRIPT="$SCRIPT_DIR/maintenance_container.sh"
#MAIL_SCRIPT="$SCRIPT_DIR/mail.sh"
#EMAIL_SENDER=false;	EMAIL_RECIPIENT=false;	EMAIL_PASSWORD=false
###################### defining functions #####################################
add_to_script() {
	TARGET_SCRIPT=$1 ; IS_LINE=$2 ; MESSAGE=$3
	if [[ $IS_LINE == true ]]
	then echo $MESSAGE >> $TARGET_SCRIPT
	else cat $MESSAGE >> $TARGET_SCRIPT
	fi
}
add_line_to_cron() {
	CRONTAB=$2
	LINE_TO_ADD=$1
	opr4 "LINE_TO_ADD: $LINE_TO_ADD" ; opr4 "CRONTAB: $CRONTAB"
    line_exists() { grep -qsFx "$LINE_TO_ADD" "$TARGET_FILE" ; }
    add_line() {
		if [ -w "$CRONTAB" ]
		then printf "%s\n" "$LINE_TO_ADD" >> "$CRONTAB" ; opr3 "$CRONTAB has been updated"
		else opr1 "CRITICAL: $CRONTAB not writeable: Line could not be added" ; exit 1
		fi
	}
	if [ $(line_exists) ]
	then opr4 "line already exists, leaving it undisturbed"
	else add_line
	fi
}
add_ppa(){
	METHOD=$1; URL=$2; KEY=$3
	case $METHOD in
		"wget"		)	wget -q -a "$LOGFILE" $URL -O- | apt-key add - ;;
		"apt-key"	)	apt-key adv --keyserver $URL --recv-keys $KEY 2>&1 | opr3 ;;
		"aar"		)	add-apt-repository $URL | opr3 ;;
	esac
}
apt-inst() { apt-get -qqy --allow-unauthenticated install "$@" 2>&1 | opr4; }
build_maintenance_script() {
	_SCRIPT=$1
	if [[ $_SCRIPT == $MAINTENANCE_SCRIPT ]]
		then _SCRIPT_TITLE="$MAINTENANCE_SCRIPT_TITLE"
		else _SCRIPT_TITLE="$CONTAINER_SCRIPT_TITLE"
	fi
	if [ -f "$_SCRIPT" ] ; then rm "$_SCRIPT" 2>&1 | opr4; opr4 "Removed old maintenance script."; fi
	add_to_script "$_SCRIPT" false <<EOT
#!/usr/bin/bash
################################################################################
# $PROGRAM_SUITE - $_SCRIPT_TITLE   Ver$SHORT_VERSION #
# (c)2017-$CURR_YEAR $MAINTAINER    build $VERSION_BUILD     $MAINTAINER_EMAIL #
# This maintenance script is dynamically built          Last build: $TODAY #
# License: GPL v3                           Please keep my name in the credits #
################################################################################
EOT
	sed -e 1d maintenance/maintenance-subheader1.sh >> "$_SCRIPT"
	add_to_script "$_SCRIPT" true "SCRIPT_TITLE=\"$_SCRIPT_TITLE\""
	sed -e 1d maintenance/maintenance-subheader2.sh >> "$_SCRIPT"
	sed -e 1d maintenance/maintenance-functions.sh >> "$_SCRIPT"
	add_to_script "$_SCRIPT" false <<EOT
tolog <<EOH
################################################################################
# $PROGRAM_SUITE - $_SCRIPT_TITLE     Ver$SHORT_VERSION #
# (c)2017-$CURR_YEAR $MAINTAINER    build $VERSION_BUILD     $MAINTAINER_EMAIL #
# This maintenance script is dynamically built          Last build: $TODAY #
################################################################################
EOH
EOT
	add_to_script "$_SCRIPT" true "GARBAGE_AGE=$GARBAGE_AGE"
	add_to_script "$_SCRIPT" true "LOG_AGE=$LOG_AGE"
	add_to_script "$_SCRIPT" true "TMP_AGE=$TMP_AGE"
	if [[ $SYSTEMROLE_CONTAINER == false ]] ; then if [[ $_SCRIPT == $MAINTENANCE_SCRIPT ]]
	then
		if [[ $SYSTEMROLE_LXCHOST == true ]] ; then
			sed -e 1d maintenance/body-lxchost0.sh >> "$_SCRIPT"
			if [[ $SYSTEMROLE_MAINSERVER == true ]] ; then sed -e 1d maintenance/backup2tape.sh >> "$_SCRIPT" ; fi
			sed -e 1d maintenance/body-lxchost1.sh >> "$_SCRIPT"
		fi
	fi; fi
	sed -e 1d maintenance/body-basic.sh >> "$_SCRIPT"
}
checkcontainer() {
	_CONTAINER=$1
	case "$_CONTAINER" in
		"nas"	)	SYSTEMROLE_NAS=true
					opr3 "container=nas";;
		"web" 	)	SYSTEMROLE_NAS=true
					SYSTEMROLE_WEB=true
					opr3 "container=web";;
		"x11"	)	SYSTEMROLE_WS=true
					opr3 "container=x11";;
		"pxe"	)	SYSTEMROLE_NAS=true
					SYSTEMROLE_PXE=true
					opr3 "container=pxe";;
		"basic"	)	SYSTEMROLE_BASIC=true;
					opr3 "container=basic";;
		"router")	opr3 "container=router"
					SYSTEMROLE_ROUTER=true;;
		*		)	opr0 "ERROR: Unknown containertype $CONTAINER, exiting...";
					exit 1;;
	esac;
}
checkrole() {
	_ROLE=$1
	case "$_ROLE" in
		"ws"			)	SYSTEMROLE_WS=true
							opr3 "role=ws";;
		"poseidon" 		)	SYSTEMROLE_WS=true
							SYSTEMROLE_SERVER=true
							SYSTEMROLE_LXCHOST=true
							SYSTEMROLE_POSEIDON=true
							SYSTEMROLE_NAS=true
							opr3 "role=poseidon";;
		"mainserver"	)	opr3 "role=mainserver"
							SYSTEMROLE_SERVER=true
							SYSTEMROLE_MAINSERVER=true
							SYSTEMROLE_LXCHOST=true;;
		"container"		)	opr3 "role=container"
							SYSTEMROLE_SERVER=true
							SYSTEMROLE_CONTAINER=true;;
		*				)	opr0 "CRITICAL: Unknown systemrole $ROLE, exiting..."
							exit 1;;
	esac
}
cr_dir() { TARGET_DIR=$1; if [ ! -d "$TARGET_DIR" ] ; then mkdir "$TARGET_DIR" ; fi ; }
create_logline() { ### INFO MESSAGES with timestamp
    _SUBJECT="$1" ; _LOG_LINE="$(get_timestamp) ## $_SUBJECT #" ; MAX_WIDTH=80
    for (( i=${#_LOG_LINE}; i<MAX_WIDTH; i++ )) ; do _LOG_LINE+="#" ; done
    opr2 "$_LOG_LINE"
}
create_secline() { ### VERBOSE MESSAGES
    _SUBJECT=$1 ; _SEC_LINE="# $_SUBJECT #" ; MAXWIDTH=78 ; IMAX=$MAXWIDTH-1
    for (( i=${#_SEC_LINE}; i<IMAX; i+=2 )) ; do _SEC_LINE="#$_SEC_LINE#" ; done
	for (( i=${#_SEC_LINE}; i<MAXWIDTH; i++ )) ; do _SEC_LINE="$_SEC_LINE#" ; done
	opr3 " $_SEC_LINE"
}
download() { wget -q -a "$LOGFILE" -nv $1; }
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
            -g|--garbageage		) GABAGE_AGE=$2; shift 2 ;;
            -l|--logage			) LOG_AGE=$2; shift 2 ;;
            -t|--tmpage			) TMP_AGE=$2; shift 2 ;;
            #-S|--emailsender	) EMAIL_SENDER=$2; shift 2 ;;
            #-P|--emailpass		) EMAIL_PASSWORD=$2; shift 2 ;;
            #-R|--emailrecipient ) EMAIL_RECIPIENT=$2; shift 2 ;;
            -- ) shift; break ;;
            * ) break ;;
        esac
    done
}
get_timestamp(){ echo $(date +"%Y-%m-%d_%H.%M.%S.%3N") ; }
install() { dpkg -i $1 2>&1 | opr4; }
opr() {
    ### OutPutRouter ###
    # decides what to print on screen based on $VERBOSITY level
    # usage: opr <verbosity level> <message>
    IMPORTANCE=$1 ; MESSAGE=$2
    if [ $IMPORTANCE -le $VERBOSITY ]
		then echo "$MESSAGE" | tee -a $LOGFILE
		else echo "$MESSAGE" >> $LOGFILE
	fi
}
opr0() { opr 0 "$1"; } ### CRITICAL
opr1() { opr 1 "$1"; } ### WARNING
opr2() { opr 2 "$1"; } ### INFO
opr3() { opr 3 "$1"; } ### VERBOSE
opr4() { opr 4 "$1"; } ### DEBUG
setverbosity() {
	case $1 in
		0	)	VERBOSITY=0;;	### Be vewy, vewy quiet... Will only show Critical errors which result in untimely exiting of the script
		1	)	VERBOSITY=1;;	# Will only show warnings that don't endanger the basic functioning of the program
		2	)	VERBOSITY=2;;	# Just give us the highlights, please - will tell what phase is taking place
		3	)	VERBOSITY=3;;	# Let me know what youre doing, every step of the way
		4	)	VERBOSITY=4;;	# I want it all, your thoughts and dreams too!!!
	esac
}
usage() {
	version
	cat <<EOT
		 USAGE: sudo bash $SCRIPT -h
				or
			sudo bash $SCRIPT -r <systemrole> [ -c <containertype> ] [ -v INT ] [ -g <garbageage> ] [ -l <logage> ] [ -t <tmpage> ]

		 OPTIONS

		   -r or --role tells the script what kind of system we are dealing with.
			  Valid options: ws, poseidon, mainserver, container << REQUIRED >>
		   -c or --containertype tells the script what kind of container we are working on.
			  Valid options are: basic, nas, web, x11, pxe, router << REQUIRED if -r=container >>
		   -v or --verbosity defines the amount of chatter. 0=CRITICAL, 1=WARNING, 2=INFO, 3=VERBOSE, 4=DEBUG. default=2
		   -g or --garbageage defines the age (in days) of garbage (trashbins & temp files) being cleaned, default=7
		   -l or --logage defines the age (in days) of logs to be purged, default=30
		   -t or --tmpage define how long temp files should be untouched before they are deleted, default=2
		   -h or --help prints this message

		  The options can be used in any order
EOT
	exit 3
}  
version() { echo -e "\n$PROGRAM $VERSION - (c)$CURR_YEAR $MAINTAINER"; }   
# If we're not in the base directory of the script, let's go there to prevent stuff from going haywire
opr4 "Let's find out where we're at..."
EXEC_PATH="${BASH_SOURCE[0]}"
while [ -h "$EXEC_PATH" ]; do # resolve $EXEC_PATH until the file is no longer a symlink
  TARGET="$(readlink "$EXEC_PATH")"
  if [[ $TARGET == /* ]]; then
    opr4 "EXEC_PATH '$EXEC_PATH' is an absolute symlink to '$TARGET'"
    EXEC_PATH="$TARGET"
  else
    DIR="$(dirname "$EXEC_PATH")"
    opr4 "EXEC_PATH '$EXEC_PATH' is a relative symlink to '$TARGET' (relative to '$DIR')"
    EXEC_PATH="$DIR/$TARGET" # if $EXEC_PATH was a relative symlink, we need to resolve it relative to the path where the symlink file was located
  fi
done
opr4 "THIS_SCRIPT=$(basename $EXEC_PATH)
BASE_DIR=$(dirname "$EXEC_PATH")
 is '$EXEC_PATH'"
RDIR="$(dirname "$EXEC_PATH" )"
DIR="$(cd -P "$( dirname "$EXEC_PATH" )" && pwd )"
if [ "$DIR" != "$RDIR" ]; then opr4 "DIR '$RDIR' resolves to '$DIR'" ; fi
opr4 "DIR is '$DIR'"
THIS_SCRIPT=$(basename $EXEC_PATH) ; BASE_DIR=$(dirname "$EXEC_PATH")
if [[ $(pwd) != "$BASE_DIR" ]] ; then cd "$BASE_DIR" ; fi
### create directories if needed
cr_dir $LOGDIR ; cr_dir $SCRIPT_DIR
###
getargs "$@"
###
# check whether systemrole_container has been checked and if yes,
#+ nas,web,ws,pxe,basic or router have been checked
if [[ $SYSTEMROLE_CONTAINER == true ]] ; then
	if [[ $SYSTEMROLE_NAS == true ]] || [[ $SYSTEMROLE_WEB == true ]] || [[ $SYSTEMROLE_WS == true ]] || [[ $SYSTEMROLE_NAS == true ]] || [[ $SYSTEMROLE_PXE == true ]] || [[ $SYSTEMROLE_BASIC == true ]] || [[ $SYSTEMROLE_ROUTER == true ]]
		then echo '' # we're good :-)
		else # somebody SNAFU'd
			opr0 "CRITICAL: no container role has been designated"
			exit 1
	fi
fi
opr2 <<EOT
################################################################################
## $PROGRAM_SUITE - $SCRIPT_TITLE  Ver$SHORTVERSION ##
## (c)2017-$CURR_YEAR $MAINTAINER  build $VERSION_BUILD     $MAINTAINER_EMAIL ##
################################################################################

EOT
################################################################################
if [[ $SYSTEMROLE_MAINSERVER == true ]] ; then create_logline "Injecting interfaces file into network config" ; cat lxchost_interfaces.txt > /etc/network/interfaces ; fi
################################################################################
create_logline "Installing extra PPA's"
create_secline "Copying Ubuntu sources and some extras"; cp apt/base.list /etc/apt/sources.list.d/ 2>&1 | opr4
create_secline "Adding GetDeb PPA key";				add_ppa "wget" "http://archive.getdeb.net/getdeb-archive.key"
create_secline "Adding VirtualBox PPA key";			add_ppa "wget" "http://download.virtualbox.org/virtualbox/debian/oracle_vbox_2016.asc"
create_secline "Adding Webmin PPA key";				add_ppa "wget" "http://www.webmin.com/jcameron-key.asc"
create_secline "Adding WebUpd8 PPA key";			add_ppa "apt-key" "keyserver.ubuntu.com" "4C9D234C"
if [[ $SYSTEMROLE_WS == true ]] ; then
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
if [[ $SYSTEMROLE_NAS == true ]] ; then create_secline "Adding Syncthing PPA" ; add_ppa "wget" "https://syncthing.net/release-key.txt" ; fi
################################################################################
create_logline "removing duplicate lines from source lists"; perl -i -ne 'print if ! $a{$_}++' "/etc/apt/sources.list /etc/apt/sources.list.d/*" 2>&1 | opr4
create_logline "Updating apt cache"; apt-get update -q 2>&1 | opr4
create_logline "Installing updates"; apt-get --allow-unauthenticated upgrade -qy 2>&1 | opr4
######
create_logline "Installing extra packages";  apt-inst mc trash-cli snapd git
if [[ $SYSTEMROLE_WS == true ]] ; 		then apt-inst synaptic tilda audacious samba wine-stable playonlinux winetricks; fi
if [[ $SYSTEMROLE_POSEIDON == true ]] ; then apt-inst picard audacity calibre fastboot adb fslint gadmin-proftpd geany* gprename lame masscan forensics-all forensics-extra forensics-extra-gui forensics-full chromium-browser gparted ; fi
if [[ $SYSTEMROLE_WEB == true ]] ;		then apt-inst apache2 phpmyadmin mysql-server mytop proftpd webmin ; fi
if [[ $SYSTEMROLE_NAS == true ]] ;		then apt-inst samba nfsd proftpd ; fi
if [[ $SYSTEMROLE_PXE == true ]] ;		then apt-inst atftpd ; fi
if [[ $SYSTEMROLE_LXCHOST == true ]] ;	then apt-inst python3-crontab lxc lxcfs lxd lxd-tools bridge-utils xfsutils-linux criu apt-cacher-ng; fi
if [[ $SYSTEMROLE_SERVER == true ]] ;	then apt-inst ssh-server screen; fi
if [[ $SYSTEMROLE_BASIC == true ]] ;	then echo "" ; fi
if [[ $SYSTEMROLE_ROUTER == true ]];	then apt-inst bridge-utils webmin ufw; fi
################################################################################
create_logline "Installing extra software"
create_secline "Installing TeamViewer"
download "https://download.teamviewer.com/download/teamviewer_i386.deb"
install teamviewer_i386.deb
apt-get install -fy 2>&1 | opr4
if [[ $SYSTEMROLE_POSEIDON == true ]]
then
  create_secline "Installing StarUML"
  download "http://nl.archive.ubuntu.com/ubuntu/pool/main/libg/libgcrypt11/libgcrypt11_1.5.3-2ubuntu4.5_amd64.deb"
  install libgcrypt11_1.5.3-2ubuntu4.5_amd64.deb
  download "http://staruml.io/download/release/v2.8.1/StarUML-v2.8.1-64-bit.deb"
  install StarUML-v2.8.0-64-bit.deb
  create_secline "Installing GitKraken"
  download "https://release.gitkraken.com/linux/gitkraken-amd64.deb"
  install gitkraken-amd64.deb
fi
rm *.deb 2>&1 | opr4
################################################################################
create_logline "Building maintenance script"
build_maintenance_script "$MAINTENANCE_SCRIPT"
if [[ $SYSTEMROLE_LXCHOST == true ]] ; then build_maintenance_script "$CONTAINER_SCRIPT" ; fi
################################################################################
if [[ $SYSTEMROLE_CONTAINER == true ]] ; then create_secline "NOT adding $MAINTENANCE_SCRIPT to sheduler"
else
	create_secline "adding $MAINTENANCE_SCRIPT to sheduler"
	if [[ $SYSTEMROLE_MAINSERVER == true ]]
		then CRON_FILE="/etc/crontab" ; LINE_TO_ADD="\n0 * * 4 0 bash $MAINTENANCE_SCRIPT" ; opr4 "using cron"
		else CRON_FILE="/etc/anacrontab" ; LINE_TO_ADD="\n@weekly\t10\tplat_maintenance\tbash $MAINTENANCE_SCRIPT" ; opr4 "using anacron"
	fi
	add_line_to_cron "$LINE_TO_ADD" "$CRON_FILE"
fi
################################################################################
create_logline "checking for reboot requirement"
if [ -f /var/run/reboot-required ]; then create_logline "REBOOT REQUIRED" ; shutdown -r 23:30  2>&1 | opr2 ; else opr2 "No reboot required" ; fi
################################################################################
###TODO### make update mechanism using git for maintenance files?
