#!/bin/bash
############################################################################
# Pegasus' Linux Administration Tools #					  bootstrap script #
# (C)2017-2018 Mattijs Snepvangers	  #				 pegasus.ict@gmail.com #
# License: MIT						  # Please keep my name in the credits #
############################################################################
START_TIME=$(date +"%Y-%m-%d_%H.%M.%S.%3N")
source lib/subheader.sh
echo "$START_TIME ## Starting Bootstrap Process #######################"

# mod: bootstrap
# txt: This script is meant to run as bootstrap on a freshly installed system
#      to add tweaks, software sources, install extra packages and external
#      software which isn't available via PPA and generates a suitable
#      maintenance script which will be set in cron or anacron

# fun: init
# txt: declares global constants with program/suite information
# use: init
# api: prerun
init() {
	##### PROGRAM INFO #####
	declare -gr SCRIPT_TITLE="Bootstrap Script"
	declare -gr VERSION_MAJOR=1
	declare -gr VERSION_MINOR=4
	declare -gr VERSION_PATCH=43
	declare -gr VERSION_STATE="ALPHA"
	declare -gr VERSION_BUILD=20180626
	###
	declare -gr PROGRAM="$PROGRAM_SUITE - $SCRIPT_TITLE"
	declare -gr SHORT_VERSION="$VERSION_MAJOR.$VERSION_MINOR.$VERSION_PATCH-$VERSION_STATE"
	declare -gr VERSION="Ver$SHORT_VERSION build $VERSION_BUILD"
	###
}

# fun: prep
# txt: prep initializes default settings, imports the PBFL index and makes
#      other preparations needed by the script
# use: prep
# api: prerun
prep() {
	declare -g VERBOSITY=5
	import "PBFL/default.inc.bash"
	import "lib/$LIB_FILE"
	create_dir "$LOG_DIR"
	header
	read_ini ${SCRIPT_PATH}${INI_FILE}
	get_args
}

# fun: main
# txt: main bootstrap thread
# use: main
# api: bootstrap
main() {
	# check whether SYSTEM_ROLE_container has been checked and if yes,
	#+ nas,web,ws,pxe,basic or router have been checked
	create_dir "$TARGET_SCRIPT_DIR"
	if [[ $SYSTEM_ROLE[CONTAINER] == true ]]
	then
		dbg_line "SYSTEM_ROLE CONTAINER was chosen, see if there's a containerrole as well"
		declare -g CONTAINER_ROLE_CHOSEN=false
		for ROLE in BASIC WS SERVER NAS PXE ROUTER WEB X11
		do
			if [[ $SYSTEM_ROLE["$ROLE"] == true ]]
			then
				CONTAINER_ROLE_CHOSEN=true
			fi
		done
		if [[ $CONTAINER_ROLE_CHOSEN == true ]]
		then
			dbg_line "CONTAINER ROLE(s) was/were chosen, we're good"
		else
			crit_line "NO CONTAINER ROLE was chosen"
			exit 1
		fi
	fi
	############################################################################
	if [[ $SYSTEM_ROLE[MAINSERVER] == true ]]
	then
		info_line "Injecting interfaces file into network config"
		cat lxchost_interfaces.txt > /etc/network/interfaces ### TODO(pegasusict): convert to sed insert/replace
	fi
	############################################################################
	############################################################################
	info_line "Copying Ubuntu sources and some extras"
	cp apt/base.list /etc/apt/sources.list.d/ >&2 | err_line
	############################################################################
	info_line "Installing extra PPA's"
	for ROLE in $SYSTEM_ROLE
	do
		if [[ "$ROLE"==true ]]
		then
			for PPA_KEY in $INI_PPA_KEYS
			do
				info_line "Adding $PPA_KEY PPA key"
				echo "add_ppa" "$PPA_KEYS[PPA_KEY][0]" "$PPA_KEYS[PPA_KEY][1]" "$PPA_KEYS[PPA_KEY][2]"
				add_ppa_key "$PPA_KEYS[PPA_KEY][0]" "$PPA_KEYS[PPA_KEY][1]" "$PPA_KEYS[PPA_KEY][2]"
			done
		fi
	done
	############################################################################
	info_line "removing duplicate lines from source lists"
	perl -i -ne 'print if ! $a{$_}++' "/etc/apt/sources.list /etc/apt/sources.list.d/*" 2>&1 | dbg_line
	info_line "Updating apt cache"
	apt-get update -q 2>&1 | dbg_line
	info_line "Installing updates"
	apt-get --allow-unauthenticated upgrade -qy 2>&1 | dbg_line
	############################################################################
	############################################################################
	info_line "Installing extra packages"
	### TODO(pegasusict): Rewrite to incorporate INI
	if [[ $SYSTEM_ROLE_POSEIDON == true ]]	;	then apt-inst audacity calibre fastboot adb fslint gadmin-proftpd geany* gprename lame masscan forensics-all forensics-extra forensics-extra-gui forensics-full gparted picard ; fi
	if [[ $SYSTEM_ROLE_WEB == true ]]		;	then apt-inst apache2 phpmyadmin mysql-server mytop proftpd webmin ; fi
	if [[ $SYSTEM_ROLE_NAS == true ]]		;	then apt-inst samba nfsd proftpd ; fi
	if [[ $SYSTEM_ROLE_PXE == true ]]		;	then apt-inst atftpd ; fi
	if [[ $SYSTEM_ROLE_LXCHOST == true ]]	;	then apt-inst python3-crontab lxc lxcfs lxd lxd-tools bridge-utils xfsutils-linux criu apt-cacher-ng; fi
	if [[ $SYSTEM_ROLE_SERVER == true ]]	;	then apt-inst ssh-server screen webmin; fi
	if [[ $SYSTEM_ROLE_BASIC == true ]]		;	then echo "" ; fi
	if [[ $SYSTEM_ROLE_ROUTER == true ]]	;	then apt-inst bridge-utils ufw; fi
	############################################################################
	info_line "Cleaning up obsolete packages"
	apt-get -qqy autoremove 2>&1 | dbg_line
	info_line "Clearing old/obsolete package cache"
	apt-get -qqy autoclean 2>&1 | dbg_line
	### GARBAGE ################################################################
	info_line "Taking out the trash."
	verb_line "Removing files from trash older than $GARBAGE_AGE days"
	trash-empty "$GARBAGE_AGE" 2>&1 dbg_line
	###
	verb_line "Clearing user cache"
	find /home/* -type f \( -name '*.tmp' -o -name '*.temp' -o -name '*.swp' -o -name '*~' -o -name '*.bak' -o -name '..netrwhist' \) -delete 2>&1 | dbg_line
	###
	verb_line "Deleting logs older than $LOG_AGE"
	find /var/log -name "*.log" -mtime +"$LOG_AGE" -a ! -name "SQLUpdate.log" -a ! -name "updated_days*" -a ! -name "qadirectsvcd*" -exec rm -f {} \ 2>&1 dbg_line
	###
	verb_line "Purging TMP dirs of files unchanged for at least $TMP_AGE days"
	CRUNCHIFY_TMP_DIRS="/tmp /var/tmp"	# List of directories to search
	find $CRUNCHIFY_TMP_DIRS -depth -type f -a -ctime $TMP_AGE -print -delete 2>&1 dbg_line
	find $CRUNCHIFY_TMP_DIRS -depth -type l -a -ctime $TMP_AGE -print -delete 2>&1 dbg_line
	find $CRUNCHIFY_TMP_DIRS -depth -type f -a -empty -print -delete 2>&1 dbg_line
	find $CRUNCHIFY_TMP_DIRS -depth -type s -a -ctime $TMP_AGE -a -size 0 -print -delete 2>&1 dbg_line
	find $CRUNCHIFY_TMP_DIRS -depth -mindepth 1 -type d -a -empty -a ! -name 'lost+found' -print -delete 2>&1 dbg_line
	############################################################################

	### TODO(pegasusict): download & install software from INI based on SYSTEM_ROLE

	############################################################################
	############################################################################
	info_line "Building maintenance script"
	build_maintenance_script "$MAINTENANCE_SCRIPT"
	if [[ $SYSTEM_ROLE_LXCHOST == true ]]
	then
		build_maintenance_script "$CONTAINER_SCRIPT"
	fi
	cp "$LIB_DIR$LIB" "$TARGET_SCRIPT_DIR$LIB_DIR"
	############################################################################
	############################################################################
	if [[ $SYSTEM_ROLE_CONTAINER == true ]]
	then
		dbg_line "This is a container; NOT adding $MAINTENANCE_SCRIPT to a sheduler"
	else
		verb_line "adding $MAINTENANCE_SCRIPT to sheduler"
		if [[ $SYSTEM_ROLE_MAINSERVER == true ]]
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
	############################################################################
	info_line "checking for reboot requirement"
	if [ -f /var/run/reboot-required ]
	then
		info_line "REBOOT REQUIRED, sheduled for $REBOOT_TIME"
		shutdown -r $REBOOT_TIME 2>&1 | info_line
	else
		info_line "No reboot required"
	fi
}

##### BOILERPLATE #####
init
prep
main
