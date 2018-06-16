#!/bin/bash

# DEBUG SWITCHES
set -o xtrace	# Trace the execution of the script
set -o errexit	# Exit on most errors (see the manual)
set -o errtrace	# Make sure any error trap is inherited
#set -o nounset	# Disallow expansion of unset variables
set -o pipefail	# Use last non-zero exit code in a pipeline

############################################################################
# Pegasus' Linux Administration Tools #					  <<script title>> #
# (C)2017-<<yr>> Mattijs Snepvangers  #				 pegasus.ict@gmail.com #
# License: MIT						  # Please keep my name in the credits #
############################################################################

# !!! first replace (ctrl-h)
# <<yr>> with the current year
# "<<date>>" with todays date
# <<script title>> with the title of the script and adjust the number of tabs if needed for proper alignment

# to prevent mishaps when using cd with relative paths
unset CDPATH

START_TIME=$(date +"%Y-%m-%d_%H.%M.%S.%3N")
# Making sure this script is run by bash to prevent mishaps
if [ "$(ps -p "$$" -o comm=)" != "bash" ]; then bash "$0" "$@" ; exit "$?" ; fi
# Make sure only root can run this script
if [[ $EUID -ne 0 ]]; then echo "This script must be run as root" ; exit 1 ; fi
echo "$START_TIME ## Starting PostInstall Process #######################"
### FUNCTIONS ###

init() {
	################### PROGRAM INFO ##########################################
	declare -gr PROGRAM_SUITE="Pegasus' Linux Administration Tools"
	declare -gr SCRIPT="${0##*/}"
	declare -gr SCRIPT_DIR="${0%/*}"
	declare -gr SCRIPT_TITLE="<<script title>>"
	declare -gr MAINTAINER="Mattijs Snepvangers"
	declare -gr MAINTAINER_EMAIL="pegasus.ict@gmail.com"
	declare -gr COPYRIGHT="(c)2017-$(date +"%Y")"
	declare -gr VERSION_MAJOR=0
	declare -gr VERSION_MINOR=0
	declare -gr VERSION_PATCH=0
	declare -gr VERSION_STATE="PRE-ALPHA"
	declare -gr VERSION_BUILD="<<date>>"
	declare -gr LICENSE="MIT"
	###########################################################################
	declare -gr PROGRAM="$PROGRAM_SUITE - $SCRIPT_TITLE"
	declare -gr SHORT_VERSION="$VERSION_MAJOR.$VERSION_MINOR.$VERSION_PATCH-$VERSION_STATE"
	declare -gr VERSION="Ver$SHORT_VERSION build $VERSION_BUILD"
}

prep() {
	import "PBFL/default.inc.bash"
	create_dir "$LOG_DIR"
	import "$LIB"
	header
	goto_base_dir
	parse_ini $INI_FILE
	get_args $@
}

import() {
	local _FILE="$1"
	if [[ -f "$_FILE" ]]
	then
		source "$_FILE"
	else
		crit_line "File $_FILE not found!"
		exit 1
	fi
}

main() {





}

###############################################################################
init
prep $@

main
