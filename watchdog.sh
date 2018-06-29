#!/bin/bash
############################################################################
# Pegasus' Linux Administration Tools #					 Internet Watchdog #
# (C)2017-2018 Mattijs Snepvangers	  #				 pegasus.ict@gmail.com #
# License: MIT						  # Please keep my name in the credits #
############################################################################
START_TIME=$(date +"%Y-%m-%d_%H.%M.%S.%3N")
declare -g VERBOSITY=3
declare -g DO_INSTALL=false
declare -g LOG_FILE_CREATED=false
# Making sure this script is run by bash to prevent mishaps
if [ "$(ps -p "$$" -o comm=)" != "bash" ]; then bash "$0" "$@" ; exit "$?" ; fi
# Make sure only root can run this script
if [[ $EUID -ne 0 ]]; then echo "This script must be run as root" ; exit 1 ; fi
declare -gr LIB_INDEX="default.inc.bash"
declare -gr LOCAL_LIB="../PBFL/"
declare -gr SYS_LIB_DIR="/var/lib/plat/"
if [[ -f "$LOCAL_LIB$LIB_INDEX" ]]
then
	source "$LOCAL_LIB$LIB_INDEX"
elif [[ -f "$SYS_LIB_DIR$LIB_INDEX" ]]
then
	source "$SYS_LIB_DIR$LIB_INDEX"
else
	crit_line "File $LIB_INDEX not found!"
	exit 1
fi

echo "$START_TIME # START:    Starting Watchdog Process ######################################"
### DECLARING FUNCTIONS #######################################################

### INIT ###
init() {
	dbg_line "INIT start"
	################### PROGRAM INFO ##############################################
	declare -gr PROGRAM_SUITE="Pegasus' Linux Administration Tools"
	declare -gr SCRIPT="${0##*/}"
	declare -gr SCRIPT_DIR="$(pwd -P)"
	declare -gr SCRIPT_TITLE="Internet Watchdog"
	declare -gr MAINTAINER="Mattijs Snepvangers"
	declare -gr MAINTAINER_EMAIL="pegasus.ict@gmail.com"
	declare -gr COPYRIGHT="(c)2017-$(date +"%Y")"
	declare -gr VERSION_MAJOR=1
	declare -gr VERSION_MINOR=0
	declare -gr VERSION_PATCH=0
	declare -gr VERSION_STATE="RC-5"
	declare -gr VERSION_BUILD=20180507
	declare -gr LICENSE="MIT"
	###############################################################################
	declare -gr PROGRAM="$PROGRAM_SUITE - $SCRIPT_TITLE"
	declare -gr SHORT_VERSION="$VERSION_MAJOR.$VERSION_MINOR.$VERSION_PATCH-$VERSION_STATE"
	declare -gr VERSION="Ver$SHORT_VERSION build $VERSION_BUILD"
	declare -gr DEFAULT_TEST_SERVER="www.google.com"

	###
	create_constants
	create_logfile
	dbg_line "INIT end"
}

get_args() { ### parses commandline arguments
	dbg_line "parsing args"
	getopt --test > /dev/null
	if [[ $? -ne 4 ]]
	then
		err_line "I’m sorry, \"getopt --test\" failed in this environment."
		exit 1
	fi
	OPTIONS="ihv:s:"
	LONG_OPTIONS="install,help,verbosity:,server:"
	PARSED=$(getopt -o $OPTIONS --long $LONG_OPTIONS -n "$0" -- "$@")
	dbg_line "Parsed args: $PARSED"
	if [ $? -ne 0 ]
		then usage
	fi
	eval set -- "$PARSED"
	while true; do
		case "$1" in
			-i|--install	)	dbg_line "installation requested"	;	declare -gr DO_INSTALL=true	;	shift	;;
			-h|--help		)	dbg_line "help asked"				;	usage						;	shift	;;
			-v|--verbosity	)	dbg_line "set verbosity to $2"		;	set_verbosity $2			;	shift 2	;;
			-s|--server		)	dbg_line "set testserver to $2"		;	declare -gr TEST_SERVER=$2	;	shift 2	;;
			--				)	shift; break ;;
			*				)	break ;;
		esac
	done
	dbg_line "done parsing args"
}

usage() { ### returns usage information
	version
	cat <<-EOT
		USAGE: sudo bash $SCRIPT -h
				or
			   sudo bash $SCRIPT [ -v INT ] [ -s <uri> ]

		OPTIONS

		   -i or --install		tells the script to install/update itself into init.d
		   -v or --verbosity	defines the amount of chatter. 1=CRITICAL, 2=ERROR, 3=WARNING, 4=INFO, 5=DEBUG. default=4
		   -s or --server		defines which server, instead of the default server, is to be used to test our DNS
		   -h or --help			prints this message

		  The options can be used in any order

		  WARNING!!! There is no error checking on the URI you give to check against!!!
		  If you want to screw up your server, that's on you!
		EOT
	exit 3
}

### END OF FUNCTION DEFINITIONS ###############################################

##### MAIN #####
get_screen_size
init
get_args "$@"
if [ "$DO_INSTALL" == true ]
then
	info_line "starting the installation of $SCRIPT_TITLE"
	insert_into_initd
else
	if [ -z ${TEST_SERVER+x} ]
	then
		declare -gr TEST_SERVER="$DEFAULT_TEST_SERVER"
		info_line "test server is set to default"
	fi
	watch_dog $TEST_SERVER
fi
