#!/bin/bash
################################################################################
# Pegasus' Linux Administration Tools	#			         PLAT preinstaller #
# pegasus.ict@gmail.com					#	https://pegasusict.github.io/PLAT/ #
# (C)2017-2024 Mattijs Snepvangers		#				 pegasus.ict@gmail.com #
# License: MIT							#	Please keep my name in the credits #
################################################################################
START_TIME=$(date +"%Y-%m-%d_%H.%M.%S.%3N")
declare -g VERBOSITY=5

source lib/subheader.sh
echo "$START_TIME ## Starting PLAT Pre-Install Process #######################"

# mod: PLAT::Preinstall
# txt: This script cleans up the system and performs backups before reinstalling

# fun: init
# txt: declares global constants with program/suite information
# use: init
# api: prerun
init() {
	declare -gr SCRIPT_TITLE="PLAT Pre-Installer"
	declare -gr VER_MAJOR=0
	declare -gr VER_MINOR=0
	declare -gr VER_PATCH=1
	declare -gr VER_STATE="ALPHA"
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
	read_ini ${SCRIPT_DIR}${INI_FILE}
	get_args
}

# fun: main
# txt: main preinstall thread
# use: main
# api: PLAT::preinstall
main(){
    # clear cache dirs
    rm -rf /home/*/.cache/*
    rm -rf /home/*/.*/cache/*
    rm -rf /home/*/.*/log/*
    rm -rf /home/*/.*/logs/*

    local BACKUPDATE ; BACKUPDATE=$(date +"%Y%m%d")
    local TARGETDIR; TARGETDIR="/alpha/data3/BACKUP/zeus/${BACKUPDATE}/"
    mkdir -p $TARGETDIR

    cp /etc/fstab $TARGETDIR
    cp /etc/apt/sources.list $TARGETDIR

    # backup homedir(s)
    cp -bfrPx /home/ $TARGETDIR
}

##### BOILERPLATE #####
init
prep
main
