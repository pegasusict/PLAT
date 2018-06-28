#!/bin/bash
############################################################################
# Pegasus' Linux Administration Tools #					   basic subheader #
# (C)2017-2018 Mattijs Snepvangers	  #				 pegasus.ict@gmail.com #
# License: MIT						  # Please keep my name in the credits #
############################################################################
# Version: 0.1.2-ALPHA
# Build: 20180622

# mod: PLAT::subheader
# txt: subheader to all major scripts in the suite

# DEBUG OPTIONS
if [ "$DEBUG" = true ]
then
	set -o xtrace	# Trace the execution of the script
	set -o errexit	# Exit on most errors (see the manual)
	set -o errtrace	# Make sure any error trap is inherited
	set -o pipefail	# Use last non-zero exit code in a pipeline
	#set -o nounset	# Disallow expansion of unset variables
fi

# Making sure this script is run by bash to prevent mishaps
if [ "$(ps -p "$$" -o comm=)" != "bash" ]; then bash "$0" "$@" ; exit "$?" ; fi

# Making sure this script is run by bash 4+
if [ -z "$BASH_VERSION" ] || [ "${BASH_VERSION:0:1}" -lt 4 ]
then echo "You need bash v4+ to run this script. Aborting..." ; exit 1 ; fi

# Making sure only root/sudo can run this script
if [[ $EUID -ne 0 ]]; then echo "This script must be run as root / with sudo" ; exit 1 ; fi

# to prevent mishaps when using cd with relative paths
unset CDPATH

# Making Commandline portable
declare -gr SCRIPT_FULL="${0##*/}"

# Making ARGS portable
declare -g ARGS=$@

# fun: preinit
# txt: declares global constants with script/suite information
# use: preinit
# api: prerun
preinit() {
	##### SUITE INFO #####
	declare -gr PROGRAM_SUITE="Pegasus' Linux Administration Tools"
	declare -gr MAINTAINER="Mattijs Snepvangers"
	declare -gr MAINTAINER_EMAIL="pegasus.ict@gmail.com"
	declare -gr COPYRIGHT="(c)2017-$(date +"%Y")"
	declare -gr LICENSE="MIT"
	###
	declare -gr SCRIPT_EXT="${SCRIPT_FULL##*.}"
	declare -gr SCRIPT="${SCRIPT_FULL%.*}"
	_SCRIPT_PATH="$(readlink -fn -- "$SCRIPT_FULL")"
	declare -gr SCRIPT_DIR=(dirname "$_SCRIPT_PATH")
	unset _SCRIPT_PATH
	###
	declare -gr MAINTENANCE_SCRIPT="maintenance.sh"
	declare -gr MAINTENANCE_SCRIPT_TITLE="Maintenance Script"
	declare -gr CONTAINER_SCRIPT="maintenance_container.sh"
	declare -gr CONTAINER_SCRIPT_TITLE="Container Maintenance Script"
	###
}
preinit



import() {
	local _FILE="$1"
	if [[ -f "$_FILE" ]]
	then
		source "$_FILE"
	else
		echo "File $_FILE not found!" >&2
		exit 1
	fi
}
