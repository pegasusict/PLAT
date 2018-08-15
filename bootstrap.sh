#!/bin/bash
START_TIME=$(date +"%Y-%m-%d_%H.%M.%S.%3N")
DEBUG=true
############################################################################
# Pegasus' Linux Administration Tools #							 Bootstrap #
# (C)2017-2018 Mattijs Snepvangers	  #				 pegasus.ict@gmail.com #
# License: MIT						  # Please keep my name in the credits #
############################################################################
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
	declare -gr SCRIPT_TITLE="Bootstrap Core"
	declare -gir VER_MAJOR=0
	declare -gir VER_MINOR=0
	declare -gir VER_PATCH=0
	declare -gr VER_STATE="PRE-ALPHA"
	declare -gir BUILD=20180813
	declare -gr PROGRAM="$PROGRAM_SUITE - $SCRIPT_TITLE"
	declare -gr SHORT_VER="$VER_MAJOR.$VER_MINOR.$VER_PATCH-$VER_STATE"
	declare -gr VER="Ver$SHORT_VER build $BUILD"
	###
	declare -Ag CFG=(
		[SYSTEM_ROLE__BASIC]=false
		[SYSTEM_ROLE__WS]=false
		[SYSTEM_ROLE__SERVER]=false
		[SYSTEM_ROLE__LXCHOST]=false

		[SYSTEM_ROLE__POSEIDON]=false
		[SYSTEM_ROLE__HOOFDSERVER]=false

		[SYSTEM_ROLE__CONTAINER]=false
		[SYSTEM_ROLE__FIREWALL]=false
		[SYSTEM_ROLE__HONEY]=false
		[SYSTEM_ROLE__NAS]=false
		[SYSTEM_ROLE__PXE]=false
		[SYSTEM_ROLE__ROUTER]=false
		[SYSTEM_ROLE__WEB]=false
		[SYSTEM_ROLE__X11]=false
	)
}

# fun: prep
# txt: prep initializes default settings, imports the PBFL index and makes
#      other preparations needed by the script
# use: prep
# api: prerun
prep() {
	import "$LIB" "$LOCAL_LIB_DIR" true
	import "$FUNC_FILE" "lib/" true
	create_dir "$LOG_DIR"
	header
}

# fun: main
# txt: main bootstrap thread
# use: main
# api: bootstrap
main() {
	import "bootstrap_cfg.sh"




	create_dir "$SYS_BIN_DIR"
	if [[ ${SYSTEM_ROLE[CONTAINER]} == true ]]
	then
		dbg_line "SYSTEM_ROLE CONTAINER was chosen, see if there's a containerrole as well"
		declare -g CONTAINER_ROLE_CHOSEN=false
		for ROLE in BASIC WS SERVER NAS PXE ROUTER WEB X11 FIREWALL
		do
			if [[ ${SYSTEM_ROLE["$ROLE"]} == true ]]
			then
				CONTAINER_ROLE_CHOSEN=true
			fi
		done
		if [[ $CONTAINER_ROLE_CHOSEN != true ]]
		then
			crit_line "NO CONTAINER ROLE was chosen"
		fi
	fi
	############################################################################
	if [[ ${SYSTEM_ROLE[MAINSERVER]} == true ]]
	then
		info_line "Injecting interfaces file into network config"
		cat templates/lxchost_interfaces.txt > /etc/network/interfaces ### TODO(pegasusict): convert to sed insert/replace
	fi
	############################################################################
	############################################################################
	info_line "Copying Ubuntu sources and some extras"
	exeqt "cp apt/base.list /etc/apt/sources.list.d/"
	############################################################################
	info_line "Installing extra PPA's"
	for ROLE in ${SYSTEM_ROLE[@]}
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
	if [[ ${SYSTEM_ROLE[BASIC]} == true ]]
	then
		info_line "Installing packages for SYSTEM_ROLE POSEIDON"
		apt-inst mc
	fi
	if [[ ${SYSTEM_ROLE[WS]} == true ]]
	then
		info_line "Installing packages for SYSTEM_ROLE POSEIDON"
		apt-inst mc
	fi
	if [[ ${SYSTEM_ROLE[SERVER]} == true ]]		;	then apt-inst ssh-server screen webmin; fi
	if [[ ${SYSTEM_ROLE[LXC_HOST]} == true ]]	;	then apt-inst python3-crontab lxc lxcfs lxd lxd-tools bridge-utils xfsutils-linux criu apt-cacher-ng; fi

	if [[ ${SYSTEM_ROLE[POSEIDON]} == true ]]
	then
		info_line "Installing packages for SYSTEM_ROLE POSEIDON"
		apt-inst audacity calibre fastboot adb fslint gadmin-proftpd geany* gprename lame masscan forensics-all forensics-extra forensics-extra-gui forensics-full gparted picard
	fi
	if [[ ${SYSTEM_ROLE[CONTAINER]} == true ]]
	then
		info_line "Installing packages for SYSTEM_ROLE POSEIDON"
		apt-inst mc
	fi

	if [[ ${SYSTEM_ROLE[WEB]} == true ]]
	then
		info_line "Installing packages for SYSTEM_ROLE WEB"
		apt-inst apache2 phpmyadmin mysql-server mytop proftpd webmin
	fi
	if [[ ${SYSTEM_ROLE[NAS]} == true ]]
	then
		info_line "Installing packages for SYSTEM_ROLE NAS"
		apt-inst samba nfsd proftpd
	fi
	if [[ ${SYSTEM_ROLE[PXE]} == true ]]
	then
		info_line "Installing packages for SYSTEM_ROLE PXE"
		apt-inst atftpd ; fi


	if [[ ${SYSTEM_ROLE[ROUTER]} == true ]]		;	then apt-inst bridge-utils ufw; fi
	############################################################################
	info_line "Cleaning up obsolete packages"
	apt-get -qqy autoremove 2>&1 | dbg_line
	info_line "Clearing old/obsolete package cache"
	apt-get -qqy autoclean 2>&1 | dbg_line
	### GARBAGE ################################################################
	info_line "Taking out the trash."
	dbg_line "Removing files from trash older than $GARBAGE_AGE days"
	apt_inst trash-cli
	trash-empty "$GARBAGE_AGE" 2>&1 dbg_line
	###
	dbg_line "Clearing user cache"
	find /home/* -type f \( -name '*.tmp' -o -name '*.temp' -o -name '*.swp' -o -name '*~' -o -name '*.bak' -o -name '..netrwhist' \) -delete 2>&1 | dbg_line
	###
	dbg_line "Deleting logs older than $LOG_AGE"
	find /var/log -name "*.log" -mtime +"$LOG_AGE" -a ! -name "SQLUpdate.log" -a ! -name "updated_days*" -a ! -name "qadirectsvcd*" -exec rm -f {} \ 2>&1 dbg_line
	###
	dbg_line "Purging TMP dirs of files unchanged for at least $TMP_AGE days"
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
	if [[ ${SYSTEM_ROLE[LXC_HOST]} == true ]]
	then
		build_maintenance_script "$CONTAINER_SCRIPT"
	fi
	cp "$LIB_DIR$LIB" "$SYS_LIB_DIR"
	############################################################################
	############################################################################
	if [[ ${SYSTEM_ROLE[CONTAINER]} == true ]]
	then
		dbg_line "This is a container; NOT adding $MAINTENANCE_SCRIPT to a sheduler"
	else
		dbg_line "adding $MAINTENANCE_SCRIPT to sheduler"
		if [[ ${SYSTEM_ROLE[MAIN_SERVER]} == true ]]
		then
			CRON_FILE="/etc/crontab"
			LINE_TO_ADD="\n0 6 * * 0 root bash $SYS_BIN_DIR$MAINTENANCE_SCRIPT #PLAT maintenance"
			dbg_line "using cron"
		else
			CRON_FILE="/etc/anacrontab"
			LINE_TO_ADD="\n@weekly\t10\tplat_maintenance\tbash $SYS_BIN_DIR$MAINTENANCE_SCRIPT"
			dbg_line "using anacron"
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
go_home
init
prep
main
