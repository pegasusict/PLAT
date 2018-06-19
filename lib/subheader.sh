#!/bin/bash
############################################################################
# Pegasus' Linux Administration Tools #					   basic subheader #
# (C)2017-2018 Mattijs Snepvangers	  #				 pegasus.ict@gmail.com #
# License: MIT						  # Please keep my name in the credits #
############################################################################

# DEBUG OPTIONS
set -o xtrace	# Trace the execution of the script
set -o errexit	# Exit on most errors (see the manual)
set -o errtrace	# Make sure any error trap is inherited
set -o pipefail	# Use last non-zero exit code in a pipeline
#set -o nounset	# Disallow expansion of unset variables

# Making sure this script is run by bash to prevent mishaps
if [ "$(ps -p "$$" -o comm=)" != "bash" ]; then bash "$0" "$@" ; exit "$?" ; fi
# Make sure only root can run this script
if [[ $EUID -ne 0 ]]; then echo "This script must be run as root" ; exit 1 ; fi
# to prevent mishaps when using cd with relative paths
unset CDPATH
# declare $@ as ARGS globally
declare -g ARGS=$@

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
