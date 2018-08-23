#!/bin/bash
################################################################################
# Pegasus' Linux Administration Tools	#						  rsync script #
# (C)2017-2018 Mattijs Snepvangers		#				 pegasus.ict@gmail.com #
# License: MIT							#	Please keep my name in the credits #
################################################################################

init() {
	declare -gr VER_MAJOR=0
	declare -gr VER_MINOR=3
	declare -gr VER_PATCH=3
	declare -gr BUILD=20180823
	######################################
	declare -gr	SCRIPT_TITLE="RSync Script"
}

config() {
	### How far back do you want to go?
	declare -gr DAYS_BACK=6
	### REMOTE
	declare -gr SERVER="ssh.pcextreme.nl"
	declare -gr PROTOCOL="ssh"
	declare -gr PORT=22
	declare -gr PATH_REMOTE_1="/home/vhosting/z/.zfs/snapshot/"
	declare -gr PATH_REMOTE_2="/vhost0032837/"
	declare -gr PATH_SUBDIR="domains/ictlab.info/htdocs/"
	declare -gr USER="ictlab-info"
	### LOCAL
	declare -gr PATH_LOCAL="/media/pegasus/storage/storage/\[\ SPOOR\ 11\ \]/ictlab.info\ backups/"
	### rsync switches
	declare -gr RSYNC_VERBOSE=true
	declare -gr RSYNC_CONVERT_SYMLINKS=true
	### LOG format
	declare -gr LOG_DATE=$(date +"%Y%m%d")
	declare -gr LOG_PATH="/media/pegasus/storage/[ SPOOR 11 ]/ictlab.info backups/"
	declare -gr LOG="${LOG_PATH}rsync_${LOG_DATE}.log"
}

main() {
	ls "$LOG_PATH"
	touch "$LOG"
	local RSYNC_OPTS	;	RSYNC_OPTS=""
	if [[ "$RSYNC_VERBOSE" = true ]]
	then
		RSYNC_OPTS+="v"
	fi
	if [[ "$RSYNC_CONVERT_SYMLINKS" = true ]]
	then
		RSYNC_OPTS+="L"
	fi
	for (( DAY=${DAYS_BACK}; DAY>=0 ; DAY-- ))
	do
		DATE_LOCAL=$(date --date="${DAY} day ago" +"%Y%m%d")
		DATE_REMOTE=$(date --date="${DAY} day ago" +"daily-%Y-%m-%d")
		rsync -a"${RSYNC_OPTS}" --rsh="${PROTOCOL} -p ${PORT}" \
		"${USER}@${SERVER}:${PATH_REMOTE_1}${DATE_REMOTE}${PATH_REMOTE_2}${PATH_SUBDIR} \
		${PATH_LOCAL}${DATE_LOCAL}/${PATH_SUBDIR}" >> "$LOG"
	done
}

##### BOILERPLATE
config
main
