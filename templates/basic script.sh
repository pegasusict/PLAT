#!/bin/bash
################################################################################
# Pegasus' Linux Administration Tools	#					  <<script title>> #
# (C)2017-<<yr>> Mattijs Snepvangers	#				 pegasus.ict@gmail.com #
# License: MIT							# Please keep my name in the credits #
################################################################################
# tpl version: 0.1.0-ALPHA
# tpl build: 20180622
START_TIME=$(date +"%Y-%m-%d_%H.%M.%S.%3N")

# !!! first replace (ctrl-h)
# <<yr>> with the current year
# "<<date>>" with todays date
# <<script title>> with the title of the script and adjust the number of tabs if needed for proper alignment

source ./lib/subheader.sh

# mod: bootstrap
# txt: This script is meant to run as bootstrap on a freshly installed system
#      to add tweaks, software sources, install extra packages and external
#      software which isn't available via PPA and generates a suitable
#      maintenance script which will be set in cron or anacron

# fun: init
# txt: declares global constants with program/suite information
# env: $0 is used to determine basepath and scriptname
# use: init
# api: prerun
init() {
	################### PROGRAM INFO ##########################################
	declare -gr PROGRAM_SUITE="Pegasus' Linux Administration Tools"
	declare -gr SCRIPT="${0##*/}"
	declare -gr SCRIPT_DIR="${0%/*}"
	declare -gr SCRIPT_TITLE="<<script title>>"
	declare -gr MAINTAINER="Mattijs Snepvangers"
	declare -gr MAINTAINER_EMAIL="pegasus.ict@gmail.com"
	declare -gr COPYRIGHT="(c)2017-$(date +"%Y")"
	declare -gr VER_MAJOR=0
	declare -gr VER_MINOR=0
	declare -gr VER_PATCH=0
	declare -gr VER_STATE="PRE-ALPHA"
	declare -gr BUILD="<<date>>"
	declare -gr LICENSE="MIT"
	##################################################################################################
	declare -gr PROGRAM="$PROGRAM_SUITE - $SCRIPT_TITLE"
	declare -gr SHORT_VER="$VER_MAJOR.$VER_MINOR.$VER_PATCH-$VER_STATE"
	declare -gr VER="Ver$SHORT_VER build $BUILD"
}


# fun: prep
# txt: prep initializes default settings, imports the PBFL index and makes
#      other preparations needed by the script
# use: prep
# api: prerun
prep() {
	import "PBFL/default.inc.bash"
	create_dir "$LOG_DIR"
	import "$LIB"
	header
	parse_ini
	get_args
}

# fun: main
# txt: main thread
# use: main
# api: <<script title>>
main() {

}

##### BOILERPLATE #####
init
prep
main
