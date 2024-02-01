#!/bin/bash
################################################################################
# Pegasus' Linux Administration Tools	#		PLAT Manager Functions Library #
# (C)2017-2018 Mattijs Snepvangers		#				 pegasus.ict@gmail.com #
# License: MIT							#	Please keep my name in the credits #
################################################################################

################################################################################
# PROGRAM_SUITE="Pegasus' Linux Administration Tools"
# SCRIPT_TITLE="Plat Manager Functions"
# MAINTAINER="Mattijs Snepvangers"
# MAINTAINER_EMAIL="pegasus.ict@gmail.com"
# VER_MAJOR=0
# VER_MINOR=0
# VER_PATCH=5
# VER_STATE="ALPHA"
# BUILD=20180620
# LICENSE="MIT"
################################################################################

# mod: PLAT_manager functions
# txt: This script is contains functions made specific for the script with the
#      same name.

# fun: getargs
# txt: parses commandline arguments
# use: init
# api: prerun
get_args() {
	getopt --test > /dev/null
	if [[ $? -ne 4 ]]
	then
		err_line "I’m sorry, \"getopt --test\" failed in this environment."
		exit 1
	fi
	OPTIONS="hv:r:c:g:l:t:S:P:R:"
	LONG_OPTIONS="help,verbosity:,role:,containertype:garbageage:logage:tmpage:"
	PARSED=$(getopt -o $OPTIONS --long $LONG_OPTIONS -n "$0" -- "$@")
	if [ $? -ne 0 ]
		then usage
	fi
	eval set -- "$PARSED"
	while true; do
		case "$1" in
			-h|--help			) usage ; shift ;;
			-v|--verbosity		) setverbosity $2 ; shift 2 ;;
			-r|--role			) checkrole $2; shift 2 ;;
			-c|--containertype	) checkcontainer $2; shift 2 ;;
			-g|--garbageage		) GABAGE_AGE=$2; shift 2 ;;
			-l|--logage			) LOG_AGE=$2; shift 2 ;;
			-t|--tmpage			) TMP_AGE=$2; shift 2 ;;
			--					) shift; break ;;
			*					) break ;;
		esac
	done
}

# fun: usage
# txt: outputs usage information
# use: usage
# api: prerun
usage() {
	version
	cat <<-EOT
		USAGE: sudo bash $SCRIPT -h
		        or
		       sudo bash $SCRIPT -r <SYSTEM_ROLE> [ -c <containertype> ] [ -v INT ] [ -g <garbageage> ] [ -l <logage> ] [ -t <tmpage> ]

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
