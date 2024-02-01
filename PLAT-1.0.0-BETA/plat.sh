#!/bin/bash
set -o xtrace	# Trace the execution of the script
START_TIME=$(date +"%Y-%m-%d_%H.%M.%S.%3N")
set -o errexit	# Exit on most errors (see the manual)
set -o errtrace	# Make sure any error trap is inherited
set -o pipefail	# Use last non-zero exit code in a pipeline
set -o nounset	# Disallow expansion of unset variables

################################################################################
# Pegasus' Linux Administration Tools	#						  Bootstrapper #
# (C)2017-2018 Mattijs Snepvangers		#				 pegasus.ict@gmail.com #
# License: MIT							#	Please keep my name in the credits #
################################################################################

unset CDPATH				# prevent mishaps using cd with relative paths
declare -gr COMMAND="$0"	# Making the command that called this script portable
declare -gr ARGS="$@"		# Making ARGS portable
declare -gr SCRIPT_FULL="${COMMAND##*/}"
declare -gr SCRIPT="${SCRIPT_FULL%.*}"

{ # Making sure this script is run by root/sudo, using bash to prevent mishaps
	if [ "$(ps -p "$$" -o comm=)" != "bash" ]
	then
		sudo bash "$COMMAND" "$ARGS"
		exit "$?"
	fi
	# Making sure this script is run by bash 4+
	if [ -z "$BASH_VERSION" ] || [ "${BASH_VERSION:0:1}" -lt 4 ]
	then
		echo "You need bash v4+ to run this script. Aborting..."
		exit 1
	fi
	# Make sure only root can run this script
	if [[ $EUID -ne 0 ]]
	then
		echo "This script must be run as root / with sudo"
		echo "restarting script with sudo..."
		sudo bash "$COMMAND" "$ARGS"
		exit "$?"
	fi
}

echo "$START_TIME ## Starting PostInstall Process #######################"

init() {
	################### PROGRAM INFO ###########################################
	declare -gr PROGRAM_SUITE="Pegasus' Linux Administration Tools"
	declare -gr SCRIPT_TITLE="Post Install Script"
	declare -gr MAINTAINER="Mattijs Snepvangers"
	declare -gr MAINTAINER_EMAIL="pegasus.ict@gmail.com"
	declare -gr VER_MAJOR=1
	declare -gr VER_MINOR=0
	declare -gr VER_PATCH=3
	declare -gr VER_STATE="BETA"
	declare -gr BUILD=20180709
	############################################################################
	declare -gr PROGRAM="$PROGRAM_SUITE - $SCRIPT"
	declare -gr SHORT_VER="$VER_MAJOR.$VER_MINOR.$VER_PATCH-$VER_STATE"
	declare -gr VER="Ver$SHORT_VER build $BUILD"
	############################################################################

	# setting constants
	declare -gr CURR_YEAR=$(date +"%Y")
	declare -gr TODAY=$(date +"%d-%m-%Y")
	declare -gr LOG_DIR="/var/log/plat"
	declare -gr TRGT_DIR="/etc/plat"
	declare -gr LOG_FILE="$LOG_DIR/$SCRIPT_$START_TIME.log"
	declare -gr MAINTENANCE_SCRIPT="$TRGT_DIR/maintenance.sh"
	declare -gr MAINTENANCE_SCRIPT_TITLE="Maintenance Script"
	declare -gr CONTAINER_SCRIPT="$TRGT_DIR/maintenance_container.sh"
	declare -gr CONTAINER_SCRIPT_TITLE="Container Maintenance Script"

	# setting defaults
	declare -g VERBOSITY=2
	declare -g TMP_AGE=2
	declare -g GARBAGE_AGE=7
	declare -g LOG_AGE=30
	declare -Ag SYSTEM_ROLE=(
							[BASIC]=false
							[WS]=false
							[SERVER]=false
							[NAS]=false
							[WEB]=false
							[PXE]=false
							[X11]=false
							[HONEY]=false
							[ROUTER]=false
							[FIREWALL]=false
							[ZEUS)=false
							[LXC_HOST]=false
							[MAIN_SERVER]=false
							[CONTAINER]=false
							)
}

###### FUNCTIONS ###############################################################
add_to_script() { #adds line or blob to script
	local _TARGET="$1"
	local _LINE_OR_BLOB="$2"
	local _MESSAGE="$3"
	if [ "$LINE_OR_BLOB" == line ] || [ "$LINE_OR_BLOB" == true ]
	then
		echo "$MESSAGE" >> "$TARGET"
	elif [ "$LINE_OR_BLOB" == blob ]
	then
		cat "$MESSAGE" >> "$TARGET"
	else
		err_line "unknown value: $_LINE_OR_BLOB"
	fi
}

# fun: add_line_to_cron
# txt: adds a line to (ana)crontab unless it's already there
# use: add_line_to_cron LINE TARGET
# opt: var LINE: line to be added
# opt: var CRON: either /etc/
# opt: KEY: code needed when using the apt-key method
# env: LOG_FILE: In case of wget method writes directly to LOG_FILE
# api: pbfl::apt
add_line_to_cron() { ### Inserts line into file if it's not there yet
	_LINE_TO_ADD="$1"
	_TARGET="$2"
	_line_exists() {
		grep -qsFx "$LINE_TO_ADD" "$TARGET_FILE"
	}
	dbg_line "LINE_TO_ADD: $_LINE_TO_ADD"
	dbg_line "TARGET: $_TARGET"
	if [ $(_line_exists) ]
	then
		info_line "line already exists, leaving it undisturbed"
	else
		if [ -w "$_TARGET" ]
		then
			printf "%s\n" "$_LINE_TO_ADD" >> "$_TARGET"
			info_line "$_TARGET has been updated"
		else
			crit_line "CRITICAL: $_TARGET not writeable: Line could not be added"
		fi
	fi
}

# fun: add_ppa_key
# txt: installs ppa certificate
# use: add_ppa_key METHOD URL [KEY]
# opt: METHOD: <wget|apt-key|aar>
# opt: URL: the URL of the PPA key
# opt: KEY: code needed when using the apt-key method
# env: LOG_FILE: In case of wget method writes directly to LOG_FILE
# api: pbfl::apt
add_ppa_key() {
	local _METHOD	;	_METHOD=$1
	local _URL		;	_URL=$2
	local _KEY		;	_KEY=$3
	case $_METHOD in
		"wget"		)	wget -q -a "$LOG_FILE" $_URL -O- | apt-key add - ;;
		"apt-key"	)	apt-key adv --keyserver $_URL --recv-keys $_KEY 2>&1 | verb_line ;;
		"aar"		)	add-apt-repository $_URL 2>&1 | verb_line ;;
	esac
}

# fun: apt_inst
# txt: updates all installed packages
# use: apt_inst PACKAGES
# opt: PACKAGES: space separated list of packages to be installed
# api: pbfl::apt
apt_inst() {
	local _PACKAGES	;	_PACKAGES="$@"
	apt-get install --force-yes -y --no-install-recommends -qq --allow-unauthenticated ${_PACKAGES} 2>&1 | verb_line
}

build_maintenance_script() {
	_SCRIPT=$1
	if [[ $_SCRIPT == $MAINTENANCE_SCRIPT ]]
		then _SCRIPT_TITLE="$MAINTENANCE_SCRIPT_TITLE"
		else _SCRIPT_TITLE="$CONTAINER_SCRIPT_TITLE"
	fi
	if [ -f "$_SCRIPT" ] ; then rm "$_SCRIPT" 2>&1 | dbg_line; dbg_line "Removed old maintenance script."; fi
	add_to_script "$_SCRIPT" false <<EOT
#!/usr/bin/bash
################################################################################
# $PROGRAM_SUITE - $_SCRIPT_TITLE   Ver$SHORT_VER #
# (c)2017-$CURR_YEAR $MAINTAINER    build $BUILD     $MAINTAINER_EMAIL #
# This maintenance script is dynamically built          Last build: $TODAY #
# License: GPL v3                           Please keep my name in the credits #
################################################################################
EOT
	sed -e 1d maintenance/maintenance-subheader1.sh >> "$_SCRIPT"
	add_to_script "$_SCRIPT" true "SCRIPT_TITLE=\"$_SCRIPT_TITLE\""
	sed -e 1d maintenance/maintenance-subheader2.sh >> "$_SCRIPT"
	sed -e 1d maintenance/maintenance-functions.sh >> "$_SCRIPT"
	add_to_script "$_SCRIPT" false <<EOT
to_log <<EOH
################################################################################
# $PROGRAM_SUITE - $_SCRIPT_TITLE     Ver$SHORT_VER #
# (c)2017-$CURR_YEAR $MAINTAINER    build $BUILD     $MAINTAINER_EMAIL #
# This maintenance script is dynamically built          Last build: $TODAY #
################################################################################
EOH
EOT
	add_to_script "$_SCRIPT" true "GARBAGE_AGE=$GARBAGE_AGE"
	add_to_script "$_SCRIPT" true "LOG_AGE=$LOG_AGE"
	add_to_script "$_SCRIPT" true "TMP_AGE=$TMP_AGE"
	if [[ $SYSTEM_ROLE[CONTAINER == false ]] ; then if [[ $_SCRIPT == $MAINTENANCE_SCRIPT ]]
	then
		if [[ $SYSTEM_ROLE[LXCHOST == true ]] ; then
			sed -e 1d maintenance/body-lxchost0.sh >> "$_SCRIPT"
			if [[ $SYSTEM_ROLE[BACKUPSERVER == true ]] ; then sed -e 1d maintenance/backup2tape.sh >> "$_SCRIPT" ; fi
			sed -e 1d maintenance/body-lxchost1.sh >> "$_SCRIPT"
		fi
	fi; fi
	sed -e 1d maintenance/body-basic.sh >> "$_SCRIPT"
}
check_container() {
	_CONTAINER=$1
	case "$_CONTAINER" in
		"nas"	)	SYSTEM_ROLE[NAS=true
					verb_line "container=nas";;
		"web" 	)	SYSTEM_ROLE[NAS=true
					SYSTEM_ROLE[WEB=true
					verb_line "container=web";;
		"x11"	)	SYSTEM_ROLE[WS=true
					verb_line "container=x11";;
		"pxe"	)	SYSTEM_ROLE[NAS=true
					SYSTEM_ROLE[PXE=true
					verb_line "container=pxe";;
		"basic"	)	SYSTEM_ROLE[BASIC=true;
					verb_line "container=basic";;
		"router")	verb_line "container=router"
					SYSTEM_ROLE[ROUTER=true;;
		*		)	crit_line "ERROR: Unknown containertype $CONTAINER, exiting...";;
	esac;
}
check_role() {
	_ROLE=$1
	case "$_ROLE" in
		"ws"			)	SYSTEM_ROLE[WS=true
							verb_line "role=ws";;
		"zeus" 		)	SYSTEM_ROLE[WS=true
							SYSTEM_ROLE[SERVER=true
							SYSTEM_ROLE[LXCHOST=true
							SYSTEM_ROLE[ZEUS=true
							SYSTEM_ROLE[NAS=true
							verb_line "role=zeus";;
		"mainserver"	)	verb_line "role=mainserver"
							SYSTEM_ROLE[SERVER=true
							SYSTEM_ROLE[BACKUPSERVER=true
							SYSTEM_ROLE[LXCHOST=true;;
		"container"		)	verb_line "role=container"
							SYSTEM_ROLE[SERVER=true
							SYSTEM_ROLE[CONTAINER=true;;
		*				)	crit_line "CRITICAL: Unknown systemrole $ROLE, exiting...";;
	esac
}
create_dir() {
	local _TARGET_DIR	;	_TARGET_DIR="$1"
	if [ ! -d "$_TARGET_DIR" ]
	then
		mkdir "$_TARGET_DIR"
	fi
}
cr_log_line() { ### INFO MESSAGES with timestamp
    _SUBJECT="$1" ; _LOG_LINE="$(get_timestamp) ## $_SUBJECT #" ; MAX_WIDTH=80
    for (( i=${#_LOG_LINE}; i<MAX_WIDTH; i++ )) ; do _LOG_LINE+="#" ; done
    info_line "$_LOG_LINE"
}
cr_sec_line() { ### VERBOSE MESSAGES
    _SUBJECT=$1 ; _SEC_LINE="# $_SUBJECT #" ; MAXWIDTH=78 ; IMAX=$MAXWIDTH-1
    for (( i=${#_SEC_LINE}; i<IMAX; i+=2 )) ; do _SEC_LINE="#$_SEC_LINE#" ; done
	for (( i=${#_SEC_LINE}; i<MAXWIDTH; i++ )) ; do _SEC_LINE="$_SEC_LINE#" ; done
	verb_line " $_SEC_LINE"
}
download() {
	wget -q -a "$LOG_FILE" -nv $1
}
getargs() {
	#echo hoi 1
	#getopt --test > /dev/null
	#echo hoi 2
    #if [[ $! -ne 4 ]]
    #then
		#echo "I’m sorry, `getopt --test` failed in this environment."
		#exit 1
	#else echo hoi
	#fi
	OPTIONS="hv:r:c:g:l:t:"
	LONG_OPTIONS="help,verbosity:,role:,containertype:,garbageage:,logage:,tmpage:"
    PARSED=$(getopt -o $OPTIONS --long $LONG_OPTIONS -n "$0" -- "$@")
    if [ $? -ne 0 ] ; then usage ; fi
    eval set -- "$PARSED"
    while true; do
        case "$1" in
			-h|--help 			) usage ; shift ;;
            -v|--verbosity		) setverbosity $2 ; shift 2 ;;
            -r|--role 			) check_role $2; shift 2 ;;
            -c|--containertype	) check_container $2; shift 2 ;;
            -g|--garbageage		) GABAGE_AGE=$2; shift 2 ;;
            -l|--logage			) LOG_AGE=$2; shift 2 ;;
            -t|--tmpage			) TMP_AGE=$2; shift 2 ;;
            -- ) shift; break ;;
            * ) break ;;
        esac
    done
}

# fun: get_timestamp
# txt: returns something like 2018-03-23_13.37.59.123
# use: get_timestamp
# api: pbfl::datetime
get_timestamp() {
	echo $(date +"%Y-%m-%d_%H.%M.%S.%3N")
}

go_home(){
	dbg_line  "Where are we being called from?"
	declare -gr SCRIPT_PATH="$(readlink -fn $COMMAND)"
	declare -gr SCRIPT_DIR=$(dirname "$SCRIPT_PATH")
	declare -g CURRENT_DIR=$(pwd)
	if [[ $SCRIPT_DIR != $CURRENT_DIR ]]
	then
		dbg_line "We're being called outside our basedir, going home to \"$SCRIPT_DIR\"..."
		cd "$SCRIPT_DIR"
	else
		dbg_line "We're right at home. :-) "
	fi
}
install() {
	dpkg -i $1 2>&1 | dbg_line
}
opr() {
    ### OutPutRouter ###
    # decides what to print on screen based on $VERBOSITY level
    # usage: opr <verbosity level> <message>
    IMPORTANCE=$1 ; MESSAGE=$2
    if ! [[ -f "$LOG_FILE" ]] ; then create_dir "$LOG_DIR"; touch "$LOG_FILE"; fi
    if (( $IMPORTANCE <= $VERBOSITY ))
	then
		echo "$MESSAGE" | tee -a $LOG_FILE
	else
		echo "$MESSAGE" >> $LOG_FILE
	fi
}
crit_line() { ### CRITICAL MESSAGES
	local _MESSAGE="$1"
	log_line 1 "$_MESSAGE"
	exit 1
}
err_line() { ### ERROR MESSAGES
	local _MESSAGE="$1"
	log_line 2 "$_MESSAGE"
}
warn_line() { ### WARNING MESSAGES
	local _MESSAGE="$1"
	log_line 3 "$_MESSAGE"
}
info_line() { ### VERBOSE MESSAGES
	local _MESSAGE="$1"
	log_line 4 "$_MESSAGE"
}
dbg_line() { ### DEBUG MESSAGES
	if [[ "$VERBOSITY" -ge 5 ]]
	then
		local _MESSAGE="$1"
		log_line 5 "$_MESSAGE"
	else # If debugging is off disable function; saves on cycles
		dbg_line() { :; }
	fi
}
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
			  Valid options: ws, zeus, mainserver, container << REQUIRED >>
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
version() { echo -e "\n$PROGRAM $VER - (c)$CURR_YEAR $MAINTAINER"; }

 # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
main() {

}
################################################################################
#### BOILERPLATE ###############################################################

go_home
create_dir "$TRGT_DIR"
getargs "$@"
main

# check whether systemrole_container has been checked and if yes,
#+ whether nas,web,ws,pxe,basic or router have been checked
if [[ $SYSTEM_ROLE[CONTAINER] == true ]] ; then
	if [[ $SYSTEM_ROLE[NAS] == true ]] || [[ $SYSTEM_ROLE[WEB] == true ]] || [[ $SYSTEM_ROLE[WS] == true ]] || [[ $SYSTEM_ROLE[NAS] == true ]] || [[ $SYSTEM_ROLE[PXE] == true ]] || [[ $SYSTEM_ROLE[BASIC] == true ]] || [[ $SYSTEM_ROLE[ROUTER] == true ]]
	then
		echo '' # we're good :-)
	else # somebody SNAFU'd
		crit_line "CRITICAL: no container role has been designated"
	fi
fi
info_line <<EOT
################################################################################
## $PROGRAM_SUITE - $SCRIPT_TITLE  Ver$SHORT_VER ##
## (c)2017-$CURR_YEAR $MAINTAINER  build $BUILD     $MAINTAINER_EMAIL ##
################################################################################

EOT
################################################################################
if [[ $SYSTEM_ROLE[BACKUPSERVER] == true ]]
then
	cr_log_line "Injecting interfaces file"
	cat lxchost_interfaces.txt > /etc/network/interfaces
fi
################################################################################
cr_log_line "Installing extra PPA's"
cr_sec_line "Copying Ubuntu sources and some extras"; cp apt/base.list /etc/apt/sources.list.d/ 2>&1 | dbg_line
cr_sec_line "Adding GetDeb PPA key";				add_ppa "wget" "http://archive.getdeb.net/getdeb-archive.key"
cr_sec_line "Adding VirtualBox PPA key";			add_ppa "wget" "http://download.virtualbox.org/virtualbox/debian/oracle_vbox_2016.asc"
cr_sec_line "Adding Webmin PPA key";				add_ppa "wget" "http://www.webmin.com/jcameron-key.asc"
cr_sec_line "Adding WebUpd8 PPA key";			add_ppa "apt-key" "keyserver.ubuntu.com" "4C9D234C"
if [[ $SYSTEM_ROLE[WS == true ]] ; then
   cr_sec_line "Adding FreeCad PPA";				add_ppa "aar" "ppa:freecad-maintainers/freecad-stable"
   cr_sec_line "Adding GIMP PPA key";			add_ppa "apt-key" "keyserver.ubuntu.com" "614C4B38"
   cr_sec_line "Adding Gnome3 Extras PPA";		add_ppa "apt-key" "keyserver.ubuntu.com" "3B1510FD"
   cr_sec_line "Adding Google Chrome PPA";		add_ppa "wget" "https://dl.google.com/linux/linux_signing_key.pub"
   cr_sec_line "Adding Highly Explosive PPA";	add_ppa "apt-key" "keyserver.ubuntu.com" "93330B78"
   cr_sec_line "Adding MKVToolnix PPA"; 			add_ppa "wget" "http://www.bunkus.org/gpg-pub-moritzbunkus.txt"
   cr_sec_line "Adding Opera (Beta) PPA"; 		add_ppa "wget" "http://deb.opera.com/archive.key"
   cr_sec_line "Adding OwnCloud Desktop PPA";	add_ppa "wget" "http://download.opensuse.org/repositories/isv:ownCloud:community/xUbuntu_16.04/Release.key"
   cr_sec_line "Adding Wine PPA"; 				add_ppa "apt-key" "keyserver.ubuntu.com" "883E8688397576B6C509DF495A9A06AEF9CB8DB0"
fi
if [[ $SYSTEM_ROLE[NAS] == true ]] ; then cr_sec_line "Adding Syncthing PPA" ; add_ppa "wget" "https://syncthing.net/release-key.txt" ; fi
################################################################################
cr_log_line "removing duplicate lines from source lists"; perl -i -ne 'print if ! $a{$_}++' "/etc/apt/sources.list /etc/apt/sources.list.d/*" 2>&1 | dbg_line
cr_log_line "Updating apt cache"; apt-get update -q 2>&1 | dbg_line
cr_log_line "Installing updates"; apt-get --allow-unauthenticated upgrade -qy 2>&1 | dbg_line
######
cr_log_line "Installing extra packages";  apt-inst mc trash-cli snapd git
if [[ $SYSTEM_ROLE[WS == true ]] ; 		then apt-inst synaptic tilda audacious samba wine-stable playonlinux winetricks; fi
if [[ $SYSTEM_ROLE[ZEUS == true ]] ; then apt-inst picard audacity calibre fastboot adb fslint gadmin-proftpd geany* gprename lame masscan forensics-all forensics-extra forensics-extra-gui forensics-full chromium-browser gparted ; fi
if [[ $SYSTEM_ROLE[WEB == true ]] ;		then apt-inst apache2 phpmyadmin mysql-server mytop proftpd webmin ; fi
if [[ $SYSTEM_ROLE[NAS == true ]] ;		then apt-inst samba nfsd proftpd ; fi
if [[ $SYSTEM_ROLE[PXE == true ]] ;		then apt-inst atftpd ; fi
if [[ $SYSTEM_ROLE[LXCHOST == true ]] ;	then apt-inst python3-crontab lxc lxcfs lxd lxd-tools bridge-utils xfsutils-linux criu apt-cacher-ng; fi
if [[ $SYSTEM_ROLE[SERVER == true ]] ;	then apt-inst ssh-server screen; fi
if [[ $SYSTEM_ROLE[BASIC == true ]] ;	then echo "" ; fi
if [[ $SYSTEM_ROLE[ROUTER == true ]];	then apt-inst bridge-utils webmin ufw; fi
################################################################################
cr_log_line "Installing extra software"
cr_sec_line "Installing TeamViewer"
download "https://download.teamviewer.com/download/teamviewer_i386.deb"
install teamviewer_i386.deb
apt-get install -fy 2>&1 | dbg_line
if [[ $SYSTEM_ROLE[ZEUS == true ]]
then
  cr_sec_line "Installing StarUML"
  download "http://nl.archive.ubuntu.com/ubuntu/pool/main/libg/libgcrypt11/libgcrypt11_1.5.3-2ubuntu4.5_amd64.deb"
  install libgcrypt11_1.5.3-2ubuntu4.5_amd64.deb
  download "http://staruml.io/download/release/v2.8.1/StarUML-v2.8.1-64-bit.deb"
  install StarUML-v2.8.0-64-bit.deb
  cr_sec_line "Installing GitKraken"
  download "https://release.gitkraken.com/linux/gitkraken-amd64.deb"
  install gitkraken-amd64.deb
fi
rm *.deb 2>&1 | dbg_line
################################################################################
cr_log_line "Building maintenance script"
build_maintenance_script "$MAINTENANCE_SCRIPT"
if [[ $SYSTEM_ROLE[LXCHOST == true ]] ; then build_maintenance_script "$CONTAINER_SCRIPT" ; fi
################################################################################
if [[ $SYSTEM_ROLE[CONTAINER == true ]] ; then cr_sec_line "NOT adding $MAINTENANCE_SCRIPT to sheduler"
else
	cr_sec_line "adding $MAINTENANCE_SCRIPT to sheduler"
	if [[ $SYSTEM_ROLE[BACKUPSERVER == true ]]
		then CRON_FILE="/etc/crontab" ; LINE_TO_ADD="\n0 * * 4 0 bash $MAINTENANCE_SCRIPT" ; dbg_line "using cron"
		else CRON_FILE="/etc/anacrontab" ; LINE_TO_ADD="\n@weekly\t10\tplat_maintenance\tbash $MAINTENANCE_SCRIPT" ; dbg_line "using anacron"
	fi
	add_line_to_cron "$LINE_TO_ADD" "$CRON_FILE"
fi
################################################################################
cr_log_line "checking for reboot requirement"
if [ -f /var/run/reboot-required ]; then cr_log_line "REBOOT REQUIRED" ; shutdown -r 23:30  2>&1 | info_line ; else info_line "No reboot required" ; fi
