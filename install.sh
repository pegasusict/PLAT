#!/bin/bash
################################################################################
# Pegasus' Linux Administration Tools	#						PLAT Installer #
# pegasus.ict@gmail.com					#	https://pegasusict.github.io/PLAT/ #
# (C)2017-2024 Mattijs Snepvangers		#				 pegasus.ict@gmail.com #
# License: MIT							#	Please keep my name in the credits #
################################################################################
START_TIME=$(date +"%Y-%m-%d_%H.%M.%S.%3N")
declare -g VERBOSITY=5

source lib/subheader.sh
echo "$START_TIME ## Starting PLAT Install Process #######################"

# mod: PLAT::Install
# txt: This script installs the entire PLAT suite on your system.

# fun: init
# txt: declares global constants with program/suite information
# use: init
# api: prerun
init() {
	declare -gr SCRIPT_TITLE="PLAT Installer"
	declare -gr VER_MAJOR=0
	declare -gr VER_MINOR=0
	declare -gr VER_PATCH=10
	declare -gr VER_STATE="PRE-ALPHA"
	declare -gr BUILD=20240124
	###
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
	header
	read_ini "${SCRIPT_DIR}${INI_FILE}"
	get_args
}

# fun: main
# txt: main install thread
# use: main
# api: PLAT::install
main() {
	# ask user install complete suite or just some bits?
	# default install: PLAT & PBFL
	# optional: WordPress, Container, apt_cacher, Internet_Watchdog,
	###TODO(pegasusict): Continue developing this script
	:
}

##### BOILERPLATE #####
init
prep
main
