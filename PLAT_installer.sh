#!/bin/bash
cat <<EOT
#############################################################################
# Pegasus' Linux Administration Tools #					PLAT install script #
# https://github.com/pegasusict/PLAT/ #	 https://pegasusict.github.io/PLAT/ #
# (C)2017-2018 Mattijs Snepvangers	  #				  pegasus.ict@gmail.com #
# License: GPL v3					  #	 Please keep my name in the credits #
#############################################################################
EOT
START_TIME=$(date +"%Y-%m-%d_%H.%M.%S.%3N")
# Making sure this script is run by bash to prevent mishaps
if [ "$(ps -p "$$" -o comm=)" != "bash" ]; then bash "$0" "$@" ; exit "$?" ; fi
# Make sure only root can run this script
if [[ $EUID -ne 0 ]]; then echo "This script must be run as root" ; exit 1 ; fi
echo "$START_TIME ## Starting PLAT Install Process #######################"
### SETTINGS ###
defaults(){
	declare -gr INSTALL_BIN="/usr/bin/plat/"
	declare -gr INSTALL_LIB="/usr/lib/plat/"
	declare -gr INSTALL_INI="/etc/plat/"
	declare -gr BASE_URL="https://github.com/pegasusict/"
	declare -gr EXT=".git"
}
### PROGRAM INFO ###
init() {
	################### PROGRAM INFO ##############################################
	declare -gr PROGRAM_SUITE="Pegasus' Linux Administration Tools"
	declare -gr SCRIPT="${0##*/}" ###CHECK###
	declare -gr SCRIPT_TITLE="PLAT Install Script"
	declare -gr MAINTAINER="Mattijs Snepvangers"
	declare -gr MAINTAINER_EMAIL="pegasus.ict@gmail.com"
	declare -gr COPYRIGHT="(c)2017-$(date +"%Y")"
	declare -gr VERSION_MAJOR=0
	declare -gr VERSION_MINOR=0
	declare -gr VERSION_PATCH=0
	declare -gr VERSION_STATE="PRE-ALPHA"
	declare -gr VERSION_BUILD=20180426
	declare -gr LICENSE="GPL v3"
	###############################################################################
	declare -gr PROGRAM="$PROGRAM_SUITE - $SCRIPT_TITLE"
	declare -gr SHORT_VERSION="$VERSION_MAJOR.$VERSION_MINOR.$VERSION_PATCH-$VERSION_STATE"
	declare -gr VERSION="Ver$SHORT_VERSION build $VERSION_BUILD"
}

gen_ini(){

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
main(){
	import "BASH_FUNC_LIB/default.inc.bash"
	#move to tmp dir
	create_tmp "plat_inst"
	cd "$TMP_DIR"
	#download all repositories
	for _REP in ("PLAT" "BASH_FUNC_LIB" "PLAT_WordPressTools" "PLAT_container_toolset")
		git clone "$_BASE_URL$_REP$_EXT"
	done
	
}
