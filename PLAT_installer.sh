#!/bin/bash
############################################################################
# Pegasus' Linux Administration Tools #				   PLAT install script #
# pegasus.ict@gmail.com				  #	https://pegasusict.github.io/PLAT/ #
# (C)2017-2018 Mattijs Snepvangers	  #				 pegasus.ict@gmail.com #
# License: MIT						  #	Please keep my name in the credits #
############################################################################
START_TIME=$(date +"%Y-%m-%d_%H.%M.%S.%3N")
source lib/subheader.sh
echo "$START_TIME ## Starting PLAT Install Process #######################"

# mod: PLAT::Installer
# txt: This script installs the entire PLAT suite on your system.

# fun: init
# txt: declares global constants with program/suite information
# use: init
# api: prerun
init() {
	declare -gr SCRIPT_TITLE="PLAT Install Script"
	declare -gr VERSION_MAJOR=0
	declare -gr VERSION_MINOR=0
	declare -gr VERSION_PATCH=5
	declare -gr VERSION_STATE="PRE-ALPHA"
	declare -gr VERSION_BUILD=20180622
	###
	declare -gr PROGRAM="$PROGRAM_SUITE - $SCRIPT_TITLE"
	declare -gr SHORT_VERSION="$VERSION_MAJOR.$VERSION_MINOR.$VERSION_PATCH-$VERSION_STATE"
	declare -gr VERSION="Ver$SHORT_VERSION build $VERSION_BUILD"
}

# fun: prep
# txt: prep initializes default settings, imports the PBFL index and makes
#      other preparations needed by the script
# use: prep
# api: prerun
prep() {
	declare -g VERBOSITY=5
	import "PBFL/default.inc.bash"
	create_dir "$LOG_DIR"
	header
	read_ini ${SCRIPT_DIR}${INI_FILE}
	get_args
}

# fun: main
# txt: main bootstrap thread
# use: main
# api: PLAT::install
main(){
	import "PBFL/default.inc.bash"
	create_tmp "plat_inst"
	cd "$TMP_DIR"
	#download all repositories
	for _REP in ("PLAT" "PBFL" "PLAT_WordPressTools" "PLAT_container_toolset")
	do
		git clone "${_BASE_URL}${_REP}${_EXT}"
		mv templates/* "${SYS_LIB_DIR}templates/"
		mv *.inc.bash "$SYS_LIB_DIR"
		mv *.bash "$SYS_BIN_DIR"
		mv *.ini "$SYS_CFG_DIR"
	done
	###TODO(pegasusict): Continue developing this script
}

##### BOILERPLATE #####
init
prep
main
