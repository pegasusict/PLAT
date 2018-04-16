#!/bin/bash
###############################################################################
# Pegasus' Linux Administration Tools                      postinstall script #
# (C)2017-2018 Mattijs Snepvangers                      pegasus.ict@gmail.com #
# License: GPL v3                          Please keep my name in the credits #
###############################################################################
START_TIME=$(date +"%Y-%m-%d_%H.%M.%S.%3N")
# Making sure this script is run by bash to prevent mishaps
if [ "$(ps -p "$$" -o comm=)" != "bash" ]; then bash "$0" "$@" ; exit "$?" ; fi
# Make sure only root can run this script
if [[ $EUID -ne 0  ]]; then echo "This script must be run as root" ; exit 1 ; fi
echo "$START_TIME ## Starting PostInstall Process #######################"
### FUNCTIONS ###
init() {
	################### PROGRAM INFO ##############################################
	declare -gr PROGRAM_SUITE="Pegasus' Linux Administration Tools"
	declare -gr SCRIPT="${0##*/}" ###CHECK###
	declare -gr SCRIPT_TITLE="Post Install Script"
	declare -gr MAINTAINER="Mattijs Snepvangers"
	declare -gr MAINTAINER_EMAIL="pegasus.ict@gmail.com"
	declare -gr COPYRIGHT="(c)2017-$(date +"%Y")"
	declare -gr VERSION_MAJOR=1
	declare -gr VERSION_MINOR=4
	declare -gr VERSION_PATCH=16
	declare -gr VERSION_STATE="BETA"
	declare -gr VERSION_BUILD=20180413
	declare -gr LICENSE="GPL v3"
	###############################################################################
	declare -gr PROGRAM="$PROGRAM_SUITE - $SCRIPT_TITLE"
	declare -gr SHORT_VERSION="$VERSION_MAJOR.$VERSION_MINOR.$VERSION_PATCH-$VERSION_STATE"
	declare -gr VERSION="Ver$SHORT_VERSION build $VERSION_BUILD"
	### set default values ########################################################
	VERBOSITY=2 ; TMP_AGE=2 ; GARBAGE_AGE=7 ; LOG_AGE=30
	LOG_DIR="/var/log/plat" ; LOG_FILE="$LOGDIR/PostInstall_$START_TIME.log"
}

main() {
	# check whether systemrole_container has been checked and if yes,
	#+ nas,web,ws,pxe,basic or router have been checked
	if [[ $SYSTEMROLE_CONTAINER == true ]]
	then
		dbg_line "SYSTEMROLE_CONTAINER was chosen, see if there's a containerrole as well"
		if [[ $SYSTEMROLE_NAS == true ]] || [[ $SYSTEMROLE_WEB == true ]] || [[ $SYSTEMROLE_WS == true ]] || [[ $SYSTEMROLE_PXE == true ]] || [[ $SYSTEMROLE_BASIC == true ]] || [[ $SYSTEMROLE_ROUTER == true ]]
			then
				dbg_line  "a CONTAINER_ROLE has been chosen; we're good :-) "
			else
				crit_line "No container role has been designated"
				exit 1
		fi
	fi
	################################################################################
	if [[ $SYSTEMROLE_MAINSERVER == true ]]
	then
		info_line "Injecting interfaces file into network config"
		cat lxchost_interfaces.txt > /etc/network/interfaces
	fi
	################################################################################
	info_line "Installing extra PPA's"
	verb_line "Copying Ubuntu sources and some extras"  ;   cp apt/base.list /etc/apt/sources.list.d/ 2>&1 | err_line
	verb_line "Adding GetDeb PPA key"           ;   add_ppa "wget" "http://archive.getdeb.net/getdeb-archive.key"
	verb_line "Adding VirtualBox PPA key"       ;   add_ppa "wget" "http://download.virtualbox.org/virtualbox/debian/oracle_vbox_2016.asc"
	verb_line "Adding Webmin PPA key"           ;   add_ppa "wget" "http://www.webmin.com/jcameron-key.asc"
	verb_line "Adding WebUpd8 PPA key"          ;   add_ppa "apt-key" "keyserver.ubuntu.com" "4C9D234C"
	if [[ $SYSTEMROLE_WS == true ]]
	then
	   verb_line "Adding FreeCad PPA"           ;   add_ppa "aar" "ppa:freecad-maintainers/freecad-stable"
	   verb_line "Adding GIMP PPA key"          ;   add_ppa "apt-key" "keyserver.ubuntu.com" "614C4B38"
	   verb_line "Adding Gnome3 Extras PPA"     ;   add_ppa "apt-key" "keyserver.ubuntu.com" "3B1510FD"
	   verb_line "Adding Google Chrome PPA"     ;   add_ppa "wget" "https://dl.google.com/linux/linux_signing_key.pub"
	   verb_line "Adding Highly Explosive PPA"  ;   add_ppa "apt-key" "keyserver.ubuntu.com" "93330B78"
	   verb_line "Adding MKVToolnix PPA"        ;   add_ppa "wget" "http://www.bunkus.org/gpg-pub-moritzbunkus.txt"
	   verb_line "Adding Opera (Beta) PPA"      ;   add_ppa "wget" "http://deb.opera.com/archive.key"
	   verb_line "Adding OwnCloud Desktop PPA"  ;   add_ppa "wget" "http://download.opensuse.org/repositories/isv:ownCloud:community/xUbuntu_16.04/Release.key"
	   verb_line "Adding Wine PPA"              ;   add_ppa "apt-key" "keyserver.ubuntu.com" "883E8688397576B6C509DF495A9A06AEF9CB8DB0"
	fi
	if  [[ $SYSTEMROLE_NAS == true ]]
	then
		verb_line "Adding Syncthing PPA"        ;   add_ppa "wget" "https://syncthing.net/release-key.txt"
	fi
	################################################################################
	info_line "removing duplicate lines from source lists"
	perl -i -ne 'print if ! $a{$_}++' "/etc/apt/sources.list /etc/apt/sources.list.d/*" 2>&1 | dbg_line
	info_line "Updating apt cache"
	apt-get update -q 2>&1 | dbg_line
	info_line "Installing updates"
	apt-get --allow-unauthenticated upgrade -qy 2>&1 | dbg_line
	######
	info_line "Installing extra packages"   ;   apt-inst mc trash-cli snapd git
	if [[ $SYSTEMROLE_WS == true ]]         ;   then apt-inst synaptic tilda audacious samba wine-stable playonlinux winetricks; fi
	if [[ $SYSTEMROLE_POSEIDON == true ]]   ;   then apt-inst picard audacity calibre fastboot adb fslint gadmin-proftpd geany* gprename lame masscan forensics-all forensics-extra forensics-extra-gui forensics-full chromium-browser gparted ; fi
	if [[ $SYSTEMROLE_WEB == true ]]        ;   then apt-inst apache2 phpmyadmin mysql-server mytop proftpd webmin ; fi
	if [[ $SYSTEMROLE_NAS == true ]]        ;   then apt-inst samba nfsd proftpd ; fi
	if [[ $SYSTEMROLE_PXE == true ]]        ;   then apt-inst atftpd ; fi
	if [[ $SYSTEMROLE_LXCHOST == true ]]    ;   then apt-inst python3-crontab lxc lxcfs lxd lxd-tools bridge-utils xfsutils-linux criu apt-cacher-ng; fi
	if [[ $SYSTEMROLE_SERVER == true ]]     ;   then apt-inst ssh-server screen webmin; fi
	if [[ $SYSTEMROLE_BASIC == true ]]      ;   then echo "" ; fi
	if [[ $SYSTEMROLE_ROUTER == true ]]     ;   then apt-inst bridge-utils ufw; fi
	################################################################################
	info_line "Installing extra software"
	verb_line "Installing TeamViewer"
	OLD_PWD=$(pwd)
	create_tmp
	cd $TMP_DIR
	download "https://download.teamviewer.com/download/teamviewer_i386.deb"
	install teamviewer_i386.deb
	apt-get install -fy 2>&1 | verb_line
	if [[ $SYSTEMROLE_POSEIDON == true ]]
	then
	  verb_line "Installing StarUML"
	  download "http://nl.archive.ubuntu.com/ubuntu/pool/main/libg/libgcrypt11/libgcrypt11_1.5.3-2ubuntu4.5_amd64.deb"
	  install libgcrypt11_1.5.3-2ubuntu4.5_amd64.deb
	  download "http://staruml.io/download/release/v2.8.1/StarUML-v2.8.1-64-bit.deb"
	  install StarUML-v2.8.0-64-bit.deb
	  verb_line "Installing GitKraken"
	  download "https://release.gitkraken.com/linux/gitkraken-amd64.deb"
	  install gitkraken-amd64.deb
	fi
	cd $OLD_PWD
	unset $OLD_PWD
	####
	info_line "Building maintenance script"
	build_maintenance_script "$MAINTENANCE_SCRIPT$MAINTENANCE_SCRIPT"
	if [[ $SYSTEMROLE_LXCHOST == true ]]
	then
		build_maintenance_script "$MAINTENANCE_SCRIPT$CONTAINER_SCRIPT"
	fi
	cp "$LIB_DIR$LIB" "$TARGET_SCRIPT_DIR$LIB_DIR"
	####
	if [[ $SYSTEMROLE_CONTAINER == true ]]
	then dbg_line "NOT adding $MAINTENANCE_SCRIPT to sheduler"
	else
		verb_line "adding $MAINTENANCE_SCRIPT to sheduler"
		if [[ $SYSTEMROLE_MAINSERVER == true ]]
		then
			CRON_FILE="/etc/crontab"
			LINE_TO_ADD="\n0 6 * * 0 root bash $TARGET_SCRIPT_DIR$MAINTENANCE_SCRIPT #PLAT maintenance"
			verb_line "using cron"
		else
			CRON_FILE="/etc/anacrontab"
			LINE_TO_ADD="\n@weekly\t10\tplat_maintenance\tbash $MAINTENANCE_SCRIPT"
			verb_line "using anacron"
		fi
		add_line_to_file "$LINE_TO_ADD" "$CRON_FILE"
		unset $LINE_TO_ADD
		unset $CRON_FILE
	fi
	###
	info_line "checking for reboot requirement"
	if [ -f /var/run/reboot-required ]
	then
		info_line "REBOOT REQUIRED, sheduled for $REBOOT_TIME"
		shutdown -r $REBOOT_TIME  2>&1 | info_line
	else
		info_line "No reboot required"
	fi
}

###########
init
source "lib/default.inc.bash"
create_dir "$LOG_DIR"
#PI_LIB="$LIB_DIRpostinstall-$LIB_FILE"
PI_LIB="lib/postinstall-functions.inc.bash"
source "$PI_LIB"
header
goto_base_dir
parse_ini $INI_FILE
get_args "$@"
create_dir $TARGET_SCRIPT_DIR

main
