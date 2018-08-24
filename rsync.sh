#!/bin/bash
################################################################################
# Pegasus' Linux Administration Tools	#						  rsync script #
# (C)2017-2018 Mattijs Snepvangers		#				 pegasus.ict@gmail.com #
# License: MIT							#	Please keep my name in the credits #
################################################################################

declare -gr START_TIME=$(date +"%Y-%m-%d_%H.%M.%S.%3N")
declare -gr LOG_DATE=$(date +"%Y%m%d_%H%M%S")

init() {
	declare -gr VER_MAJOR=0
	declare -gr VER_MINOR=4
	declare -gr VER_PATCH=3
	declare -gr BUILD=20180824
	######################################
	declare -gr	SCRIPT_TITLE="RSync Script"
}

config() {
	### How far back do you want to go?
	declare -gr DAYS_BACK=6
	### Remote Server
	declare -gr SVR="ssh.pcextreme.nl"
	declare -gr PROT="ssh"
	declare -gr PORT=22
	declare -gr PATH_REM_1="/home/vhosting/z/.zfs/snapshot/"
	declare -gr PATH_REM_2="/vhost0032837/"
	declare -gr PATH_SUB="domains/ictlab.info/htdocs/"
	declare -gr USER="ictlab-info"
	### Local
	declare -gr PATH_LOC="/media/pegasus/storage/storage/\[\ SPOOR\ 11\ \]/ictlab.info\ backups/"
	### rsync switches
	declare -gr RSYNC_VERB=true
	declare -gr RSYNC_CNVRT_SLINKS=true
	### LOG format
	declare -gr LOG_PATH="/media/pegasus/storage/storage/[ SPOOR 11 ]/ictlab.info backups/"
	declare -gr LOG="${LOG_PATH}rsync_${LOG_DATE}.log"
}

main() {
	set -x
	ls "$LOG_PATH"
	touch "$LOG"
	local RSYNC_OPTS	;	RSYNC_OPTS=""
	if [[ "$RSYNC_VERB" = true ]] ; then RSYNC_OPTS+="v" ; fi
	if [[ "$RSYNC_CNVRT_SLINKS" = true ]] ; then RSYNC_OPTS+="L" ; fi
	for (( DAY=${DAYS_BACK}; DAY>=0 ; DAY-- )) ; do
		DATE_LOC=$(date --date="${DAY} day ago" +"%Y%m%d")
		DATE_REM=$(date --date="${DAY} day ago" +"daily-%Y-%m-%d")
		local SRV_PATH="${PATH_REM_1}${DATE_REM}${PATH_REM_2}${PATH_SUB}"
		local LOC_PATH="${PATH_LOC}${DATE_LOC}/${PATH_SUB}"
		mkdir -p "$LOG_PATH${DATE_LOC}/${PATH_SUB}"
		rsync -a"${RSYNC_OPTS}" --rsh="${PROT} -p ${PORT}" \
		"${USER}@${SVR}:${SRV_PATH} ${LOC_PATH}" >> "$LOG"
	done
}

##### BOILERPLATE
config
main
