#!/bin/bash
################################################################################
# Pegasus' Linux Administration Tools	#						PLAT subheader #
# (C)2017-2018 Mattijs Snepvangers		#				 pegasus.ict@gmail.com #
# License: MIT							#	Please keep my name in the credits #
################################################################################
# Version: 0.2.40-ALPHA
# Build: 20180808

unset CDPATH				# prevent mishaps using cd with relative paths
declare -gr COMMAND="$0"	# Making the command that called this script portable
declare -gr SCRIPT_FULL="${COMMAND##*/}"	# Making Commandline "portable"
declare -agr ARGS=$@		# Making ARGS portable

# mod: PLAT::subheader
# txt: subheader to all major scripts in the suite

# fun: preinit
# txt: declares global constants with script/suite information.
# use: preinit
# api: internal
preinit() {
	dbg_pause
	##### SUITE INFO #####
	declare -gr PROGRAM_SUITE="Pegasus' Linux Administration Tools"
	declare -gr MAINTAINER="Mattijs Snepvangers"
	declare -gr MAINTAINER_EMAIL="pegasus.ict@gmail.com"
	declare -gr COPYRIGHT="(c)2017-$(date +"%Y")"
	declare -gr LICENSE="MIT"
	###
	declare -gr SCRIPT="${SCRIPT_FULL%.*}"
	declare -gr SCRIPT_PATH="$(readlink -fn $COMMAND)"
	declare -gr SCRIPT_DIR="$(dirname "$SCRIPT_PATH")"
	###
	declare -gr MAINTENANCE_SCRIPT="maintenance.sh"
	declare -gr MAINTENANCE_SCRIPT_TITLE="Maintenance Script"
	declare -gr CONTAINER_SCRIPT="maintenance_container.sh"
	declare -gr CONTAINER_SCRIPT_TITLE="Container Maintenance Script"
	##################################################################
	declare -gr LIB="default.inc.bash"
	declare -gr LOCAL_LIB_DIR="PBFL/"
	declare -gr BASE="plat/"
	declare -gr SYS_BIN_DIR="/bin/$BASE"
	declare -gr SYS_CFG_DIR="/etc/$BASE"
	declare -gr SYS_LIB_DIR="/var/lib/$BASE"
	declare -gr SYS_LOG_DIR="/var/log/$BASE"
	declare -gr SYS_DOC_DIR="/usr/share/doc/$BASE"
	##################################################################
	declare -g SCREEN_WIDTH	;	SCREEN_WIDTH=80
	dbg_restore
}

### LOGGING FUNCTIONS
get_timestamp() {
	echo $(date +"%Y-%m-%d_%H.%M.%S.%3N")
}

# fun: log_line IMPORTANCE MESSAGE
# txt: Creates a nice logline and decides what to print on screen and what to
#      send to logfile by comparing VERBOSITY and IMPORTANCE.
# use: log_line <INT> IMPORTANCE <VAR> MESSAGE
# api: logging_internal
log_line() {
	local _IMPORTANCE=$1
	local _LABEL=""
	local _LOG_OUTPUT=""
	local _MESSAGE="$2"
	case $_IMPORTANCE in
		1	)	_LABEL="CRITICAL:"	;;
		2	)	_LABEL="ERROR:   "	;;
		3	)	_LABEL="WARNING: "	;;
		4	)	_LABEL="INFO:    "	;;
		5	)	_LABEL="DEBUG:   "	;;

		*	)	_LABEL="INFO:    "	;;
	esac
	_LOG_OUTPUT="$(get_timestamp) # $_LABEL $_MESSAGE"
	### screen output
	if (( "$_IMPORTANCE" <= "$VERBOSITY" ))
	then
		if $(( _IMPORTANCE >= 1 )) && $(( _IMPORTANCE <= 2 ))
		then
			echo -e "$_MESSAGE" >&2
		else
			echo -e "$_MESSAGE"
		fi
	fi
	### file output
	to_log "$_LOG_OUTPUT"
}

# fun: exeqt
# txt: Executes COMMAND.
#      If COMMAND returns an error code, the output is sent to the error log.
# use: exeqt COMMAND
# api: logging internal
exeqt() {
	local _CMD		; _CMD="$1"
	local _RESULT	; _RESULT=$($_CMD) 2>&1
	if [[ $? > 0 ]]
	then
		err_line $_RESULT
	fi
}

# fun: to_log
# txt: Checks whether the log file has been created yet and whether the log
#      buffer exists. The log entry will be added to the logfile if exist,
#      otherwise it will be added to the buffer which will be created if needed.
# use: log_line IMPORTANCE LOG_ENTRY
# api: logging_internal
to_log() {
	local _LOG_ENTRY	;	_LOG_ENTRY="$1"
	if [ "$LOG_FILE_CREATED" != true ]
	then
		if [ -z ${LOG_BUFFER+x} ]
		then
			declare -g LOG_BUFFER
			LOG_BUFFER="$START_TIME - $COMMAND Process started\n"
		fi
		LOG_BUFFER+="$_LOG_ENTRY\n"
	else
		to_log() {
			if [ -n "$LOG_BUFFER" ]
			then
				cat "$LOG_BUFFER" > "$LOG_FILE"
				unset $LOG_BUFFER
			else
				to_log() {
					echo "$_LOG_ENTRY" >> "$LOG_FILE"
				}
			fi
			echo "$_LOG_ENTRY" >> "$LOG_FILE"
		}
		to_log "$_LOG_ENTRY"
	fi
}

# fun: crit_line MESSAGE
# txt: Passes MESSAGE on to 'log_line 1'
# use: crit_line <var> MESSAGE
# api: logging
crit_line() {
	dbg_pause
	local _MESSAGE="$1"
	log_line 1 "$_MESSAGE"
	exit 1
	dbg_restore
}

# fun: err_line MESSAGE
# txt: Passes MESSAGE on to 'log_line 2'
# use: err_line <var> MESSAGE
# api: logging
err_line() {
	dbg_pause
	if [[ -n "$1" ]]
	then
		local _MESSAGE="$1"
		log_line 2 "$_MESSAGE"
	fi
	dbg_restore
}

# fun: warn_line MESSAGE
# txt: Passes MESSAGE on to 'log_line 3'
# use: warn_line <var> MESSAGE
# api: logging
warn_line() {
	dbg_pause
	local _MESSAGE="$1"
	log_line 3 "$_MESSAGE"
	dbg_restore
}

# fun: info_line MESSAGE
# txt: Passes MESSAGE on to 'log_line 4'
# use: info_line <var> MESSAGE
# api: logging
info_line() {
	dbg_pause
	local _MESSAGE="$1"
	log_line 4 "$_MESSAGE"
	dbg_restore
}

# fun: dbg_line MESSAGE
# txt: Passes MESSAGE on to 'log_line 5' if VERBOSITY is 5+
# use: dbg_line <var> MESSAGE
# api: logging
dbg_line() {
	:
}

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# fun: bash_check
# txt: Checks if the script is being run using Bash v4+
# use: bash_check
# api: internal
bash_check() {
	dbg_pause
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
	dbg_restore
}

# fun: dbg_check
# txt: Enables debugging options if $DEBUG = true
# use: dbg_check
# api: internal
dbg_check() {
	if [ "$DEBUG" = true ]
	then
		dbg_line() {
			dbg_pause
			log_line 5 "$1"
			dbg_restore
		}
		set -x # -o xtrace	# Trace the execution of the script
		set -e # -o errexit	# Exit on most errors (see the manual)
		set -E # -o errtrace	# Make sure any error trap is inherited
		set -o pipefail	# Use last non-zero exit code in a pipeline
		#set -u # -o nounset	# Disallow expansion of unset variables
		declare -g DEBUG_PAUSE	;	DEBUG_PAUSE=0
	fi
}

# fun: su_check
# txt: Checks if the script is being run by root or sudo.
#      If not, issues warning and reruns command using sudo
# use: su_check
# api: internal
su_check() {
	dbg_pause
	if [[ $EUID -ne 0 ]]
	then
		echo "This script must be run as root / with sudo"
		echo "restarting script with sudo..."
		sudo bash "$COMMAND" "$ARGS"
		exit "$?"
	fi
	dbg_restore
}

# stop exiting on most errors ( can be a nusance with (getopt) tests)
# Disable tracing execution of the script
dbg_pause() {
	set +ex
	DEBUG_PAUSE=$(( DEBUG_PAUSE + 1 ))
	echo "dbg_pause: DEBUG_PAUSE=$DEBUG_PAUSE"
}

# Exit on most errors (see the manual)
# Disable tracing execution of the script
dbg_restore() {
	if [ "$DEBUG" = true ]
	then
		if [ $DEBUG_PAUSE > 1 ]
		then
			DEBUG_PAUSE=$(( DEBUG_PAUSE - 1 ))
			echo "dbg_restore: DEBUG_PAUSE=$DEBUG_PAUSE"
		else
			set -ex
		fi
	fi
}

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# fun: go_home
# txt: determins where the script is called from and if this is the same
#      location the script resides. If not, moves to that directory.
# use: go_home
# api: internal
go_home(){
	#info_line "go_home: Where are we being called from?"
	#declare -g CURRENT_DIR=$(pwd)
	##CURRENT_DIR+="/"
	#if [[ "$SCRIPT_DIR" != "$CURRENT_DIR" ]]
	#then
		#info_line "go_home: We're being called outside our basedir, going home to \"$SCRIPT_DIR\"..."
		cd "$SCRIPT_DIR"
	#else
		#info_line "go_home: We're right at home. :-) "
	#fi
}

# fun: import
# txt: tries to import the file from given location and some standard locations
#      of this suite. If REQUIRED is set to true, script will exit with a
#      CRITICAL ERROR message
# use: import $FILE $DIR [ $REQUIRED ]
# opt: str FILE: filename
# opt: str DIR: directory ( MUST end with slash! )
# opt: bool REQUIRED ( true/false ) if omitted, REQUIRED is set to false
# api: internal
import() {
	dbg_pause
	local _FILE	;	_FILE="$1"
	local _DIR	;	_DIR="$2"
	local _REQUIRED	;	_REQUIRED="$3"
	local _SUCCESS	;	_SUCCESS=false
	if [[ "x$_REQUIRED" = x ]]
	then
		_REQUIRED=false
	fi
	for LOC in "$_DIR$_FILE" "../$_DIR$_FILE" "$LOCAL_LIB_DIR$_FILE" "../$LOCAL_LIB_DIR$_FILE" "$SYS_LIB_DIR$_FILE"
	do
		if [[ -f "$LOC" ]]
		then
			source "$LOC"
			SUCCESS=true
			break
		fi
	done
	if [[ "$SUCCESS" = false ]]
	then
		if [[ "$_REQUIRED" = true ]]
		then
			crit_line "Required file $_FILE not found, aborting!"
		else
			err_line "File $_FILE not found!"
		fi
	fi
	dbg_restore
}

##### BOILERPLATE ##############################################################
su_check
dbg_check
bash_check
preinit
