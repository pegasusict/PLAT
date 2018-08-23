#!/bin/bash
################################################################################
# Pegasus' Linux Administration Tools	#			apt-get maintenance script #
# (C)2017-2018 Mattijs Snepvangers		#				 pegasus.ict@gmail.com #
# License: MIT							#	Please keep my name in the credits #
################################################################################
START_TIME=$(date +"%Y-%m-%d_%H.%M.%S.%3N")

# fun: init
# txt: declares global constants with program/suite information
# use: init
# api: prerun
init() {
	##### PROGRAM INFO #####
	declare -gr SCRIPT_TITLE="Apt Cycle Script"
	declare -gr PROGRAM_SUITE="Pegasus' Linux Administration Tools"
	declare -gr MAINTAINER="Mattijs Snepvangers"
	declare -gr MAINTAINER_EMAIL="pegasus.ict@gmail.com"
	declare -gr COPYRIGHT="(c)2017-$(date +"%Y")"
	declare -gr LICENSE="MIT"
	###
	declare -gir VER_MAJOR=1
	declare -gir VER_MINOR=0
	declare -gir VER_PATCH=0
	declare -gr VER_STATE="ALPHA"
	declare -gir BUILD=20180823
	declare -gr PROGRAM="$PROGRAM_SUITE - $SCRIPT_TITLE"
	declare -gr SHORT_VER="$VER_MAJOR.$VER_MINOR.$VER_PATCH-$VER_STATE"
	declare -gr VER="Ver$SHORT_VER build $BUILD"
}

dbg_line() {	echo $1	; }
info_line() {	echo $1	; }
warn_line() {	echo $1	; }
err_line() {	echo $1	; }
crit_line() {	echo $1	;	exit 1;	}

# fun: bash_check
# txt: Checks if the script is being run using Bash v4+
# use: bash_check
# api: internal
bash_check() {
	# Making sure this script is run by bash to prevent mishaps
	if [ "$(ps -p "$$" -o comm=)" != "bash" ]
	then
		bash "$COMMAND" "$ARGS"
		exit "$?"
	fi
	# Making sure this script is run by bash 4+
	if [ -z "$BASH_VERSION" ] || [ "${BASH_VERSION:0:1}" -lt 4 ]
	then
		echo "You need bash v4+ to run this script. Aborting..."
		exit 1
	fi
}

# fun: su_check
# txt: Checks if the script is being run by root or sudo. If not, issues warning and reruns command using sudo
# use: su_check
# api: internal
su_check() {
	if [[ $EUID -ne 0 ]]
	then
		echo "This script must be run as root / with sudo"
		echo "restarting script with sudo..."
		sudo bash "$COMMAND" "$ARGS"
		exit "$?"
	fi
}

# fun: reboot_check
# txt: Checks if the system needs to reboot to complete installation of a new kernel. If so, tells the system to reboot at 23:59
# use: reboot_check
# api: internal
reboot_check() {
	info_line "checking for reboot requirement"
	if [ -f /var/run/reboot-required ]
	then
		info_line "REBOOT REQUIRED, sheduled for 23:59"
		shutdown -r 23:59 2>&1
	else
		info_line "No reboot required"
	fi
}

# fun: prep
# txt: prep makes preparations needed by the script
# use: prep
# api: prerun
prep() {
	bash_check
	su_check
}

# fun: header
# txt: generates a complete header
# use: header [$CHAR [$LEN [$SPACER]]]
# opt: $CHAR: defaults to "#"
# opt: $LEN: defaults to 80
# opt: $SPACER: defaults to " "
# api: pbfl::header
header() {
	dbg_pause
	local _CHAR		;	_CHAR=${1:-#}
	local _LEN		;	_LEN=${2:-80}
	local _SPACER	;	_SPACER=${2:-" "}
	local _HEADER	;	_HEADER="$(make_line "$_CHAR" "$_LEN")\n"
	_HEADER+="$(header_line "$PROGRAM_SUITE" "$SCRIPT_TITLE" "$_CHAR" "$_LEN" "$_SPACER")\n"
	_HEADER+="$(header_line "$COPYRIGHT" "$MAINTAINER_EMAIL" "$_CHAR" "$_LEN" "$_SPACER")\n"
	_HEADER+="$(header_line "$SHORT_VER" "Build $BUILD" "$_CHAR" "$_LEN" "$_SPACER")\n"
	_HEADER+="$(header_line "License: $LICENSE" "Please keep my name in the credits" "$_CHAR" "$_LEN" "$_SPACER")\n"
	_HEADER+="$(make_line $_CHAR $_LEN)\n"
	echo -e "${_HEADER}"
	dbg_restore
}

# fun: header_line
# txt: generates a headerline, eg: # <MAINTAINER>             <MAINTAINEREMAIL> #
# use: header_line  $PART1 $PART2 [$CHAR [$LEN [$SPACER]]]
# opt: $CHAR: defaults to "#"
# opt: $LEN: defaults to 80
# opt: $SPACER: defaults to " "
# api: pbfl::header::internal
header_line() {
	local _PART1		;	_PART1="$1"
	local _PART2		;	_PART2="$2"
	local _CHAR			;	_CHAR=${3:-#}
	local _LEN			;	_LEN=${4:-80}
	local _SPACER		;	_SPACER=${5:-" "}
	local _SPACERS		;	_SPACERS=""
	local _HEADER_LINE	;	_HEADER_LINE="${_CHAR} ${_PART1}${_SPACERS}${_PART2} ${_CHAR}"
	local _HEADER_LINE_LEN	;	_HEADER_LINE_LEN=${#_HEADER_LINE}
	local _SPACERS_LEN	;	_SPACERS_LEN=$((_LEN-_HEADER_LINE_LEN))
	_SPACERS=$( printf "%0.s$_SPACER" $( seq 1 $_SPACERS_LEN ) )
	_HEADER_LINE="${_CHAR} ${_PART1}${_SPACERS}${_PART2} ${_CHAR}"
	echo -e "${_HEADER_LINE}"
}

# fun: make_line
# txt: generates a line
# use: make_line [$CHAR [$LEN]]
# opt: $CHAR: defaults to "#"
# opt: $LEN: defaults to 80
# api: pbfl::header
make_line() {
	local _CHAR		;	_CHAR=${1:-#}
	local _LEN		;	_LEN=${2:-80}
	local _LINE		;	_LINE=$( printf "%0.s$_CHAR" $( seq 1 $_LEN ) )
	echo -e "${_LINE}"
}

# fun: apt_cmd
# txt: performs apt-get ACTION
# use: apt_cmd $ACTION
# api: pbfl::apt-internal
apt_cmd() {
	apt-get -qqy $@ | dbg_line
}

# fun: apt_update
# txt: reloads the apt database
# use: apt_update
# api: pbfl::apt
apt_update() {
	info_line "Updating apt cache"
	apt_cmd update
}

# fun: apt_upgrade
# txt: updates all installed packages
# use: apt_upgrade
# api: pbfl::apt
apt_upgrade() {
	info_line "Updating installed packages"
	apt_cmd --allow-unauthenticated upgrade
}

# fun: apt_remove
# txt: uninstalls & purges all obsolete packages
# use: apt_remove
# api: pbfl::apt
apt_remove() {
	info_line "apt_remove: Cleaning up obsolete packages"
	apt-get -qqy auto-remove --purge 2>&1 | dbg_line
}

# fun: apt_clean
# txt: cleans up apt cache
# use: apt_clean
# api: pbfl::apt
apt_clean() {
	info_line "apt_clean: Clearing old/obsolete package cache"
	apt_cmd autoclean
}

# fun: apt_fix_deps
# txt: fixes broken dependencies
# use: apt_fix_deps
# api: pbfl::apt
apt_fix_deps() {
	info_line "apt_fix_deps:  Fixing any broken dependencies if needed"
	apt_cmd --fix-broken install
}

# fun: clean_sources
# txt: cleans up /etc/apt/sources.list and /etc/apt/sources.list.d/*
# use: clean_sources
# api: pbfl::apt
clean_sources() {
	info_line "removing duplicate lines from source lists"
	#perl -i -ne 'print if ! $a{$_}++' /etc/apt/sources.list /etc/apt/sources.list.d/* | dbg_line
	local TEMP; TEMP=$(mktemp)
	local -a FILES=($(echo /etc/apt/*.list /etc/apt/sources.list.d/*.list | sort))
	local LENGTH; LENGTH=$(echo ${#FILES[@]})
	for ((i=0;i<LENGTH;i++))
	do
		for ((j=0;j<=3;j++))
		do
			[ "${FILES[i]}" == "${FILES[i+j]}" ] && continue
			[ "$((i+j))" -ge "$LENGTH" ] && continue
			#echo ${FILES[i]} ${FILES[i+j]}
			grep -w -Ff ${FILES[i]} -v ${FILES[i+j]} > ${TEMP}
			mv ${TEMP} ${FILES[i+j]}
		done
	done
}

# fun: apt_cycle
# txt: does a complete update/upgrade/autoremove/clean cycle
# use: apt_cycle
# api: pbfl::apt
apt_cycle() {
	clean_sources
	apt_update
	apt_fix_deps

	apt_upgrade

	apt_remove
	apt_clean
	reboot_check
}

# fun: main
# txt: main thread
# use: main
# api: plat
main() {
	info_line "$START_TIME ## Starting Update Process #######################"
	apt_cycle
	END_TIME=$(date +"%Y-%m-%d_%H.%M.%S.%3N")
	info_line "$END_TIME ## Update Process Finished ########################"
}
#############################################################
prep
init
header
main
