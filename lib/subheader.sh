#!/bin/bash
############################################################################
# Pegasus' Linux Administration Tools #						PLAT subheader #
# (C)2017-2018 Mattijs Snepvangers	  #				 pegasus.ict@gmail.com #
# License: MIT						  # Please keep my name in the credits #
############################################################################
# Version: 0.2.0-ALPHA
# Build: 20180710

# mod: PLAT::subheader
# txt: subheader to all major scripts in the suite

### TEMPORARY LOGGING FUNCTIONS
get_timestamp() {
	 $(date +"%Y-%m-%d_%H.%M.%S.%3N")
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
		if (( IMPORTANCE >= 1 && IMPORTANCE <= 2 ))
		then
			echo -e "$_MESSAGE" >&2
		else
			echo -e "$_MESSAGE"
		fi
	fi
	### file output
	to_log "$_LOG_OUTPUT"
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
		LOG_BUFFER+="$_LOG_ENTRY"
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

dbg_line() {
	:
}
info_line() {
	log_line "Info:: $1"
}
warn_line() {
	log_line "WARNING: $1"
}
err_line() {
	log_line "ERROR: $1"
}
crit_line() {
	log_line "CRITICAL ERROR: $1" 1>&2
	exit 1
}

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

# fun: dbg_check
# txt: Enables debugging options if $DEBUG = true
# use: dbg_check
# api: internal
dbg_check() {
	if [ "$DEBUG" = true ]
	then
		dbg_line() {
			log_line "Debug: $1"
		}
		set -o xtrace	# Trace the execution of the script
		set -o errexit	# Exit on most errors (see the manual)
		set -o errtrace	# Make sure any error trap is inherited
		set -o pipefail	# Use last non-zero exit code in a pipeline
		set -o nounset	# Disallow expansion of unset variables
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

unset CDPATH				# prevent mishaps using cd with relative paths
declare -gr COMMAND="$0"	# Making the command that called this script portable
declare -gr SCRIPT_FULL="${COMMAND##*/}"	# Making Commandline "portable"
declare -gr ARGS="$@"				# Making ARGS portable

# fun: preinit
# txt: declares global constants with script/suite information.
# use: preinit
# api: internal
preinit() {
	##### SUITE INFO #####
	declare -gr PROGRAM_SUITE="Pegasus' Linux Administration Tools"
	declare -gr MAINTAINER="Mattijs Snepvangers"
	declare -gr MAINTAINER_EMAIL="pegasus.ict@gmail.com"
	declare -gr COPYRIGHT="(c)2017-$(date +"%Y")"
	declare -gr LICENSE="MIT"
	###
	declare -gr SCRIPT="${SCRIPT_FULL%.*}"
	declare -gr SCRIPT_FULL="${COMMAND##*/}"
	declare -gr SCRIPT="${SCRIPT_FULL%.*}"
	declare -gr SCRIPT_PATH="$(readlink -fn $COMMAND)"
	declare -gr SCRIPT_DIR=$(dirname "$SCRIPT_PATH")
	###
	declare -gr MAINTENANCE_SCRIPT="maintenance.sh"
	declare -gr MAINTENANCE_SCRIPT_TITLE="Maintenance Script"
	declare -gr CONTAINER_SCRIPT="maintenance_container.sh"
	declare -gr CONTAINER_SCRIPT_TITLE="Container Maintenance Script"
	##################################################################
	declare -gr LIB="default.inc.bash"
	declare -gr LOCAL_LIB_DIR="PBFL/"
	declare -gr SYS_LIB_DIR="/var/lib/plat/"
}

go_home(){
	info_line "go_home: Where are we being called from?"
	declare -gr SCRIPT_FULL="${COMMAND##*/}"
	declare -gr SCRIPT="${SCRIPT_FULL%.*}"
	declare -gr SCRIPT_PATH="$(readlink -fn $COMMAND)"
	declare -gr SCRIPT_DIR=$(dirname "$SCRIPT_PATH")
	declare -g CURRENT_DIR=$(pwd)
	if [[ $SCRIPT_DIR != $CURRENT_DIR ]]
	then
		info_line "go_home: We're being called outside our basedir, going home to \"$SCRIPT_DIR\"..."
		cd "$SCRIPT_DIR"
	else
		info_line "go_home: We're right at home. :-) "
	fi
}

# fun: import
# txt: tries to import the file from given location and some standard locations
#      of this suite. If REQUIRED is set to true, script will exit with a
#      CRITICAL ERROR message
# use: import $FILE $DIR $REQUIRED
# opt: var FILE: filename
# opt: var DIR: directory ( MUST end with slash! )
# opt: bool REQUIRED ( true/false ) if omitted, REQUIRED is set to false
# api: internal
import() {
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
}

su_check
dbg_check
bash_check
preinit
