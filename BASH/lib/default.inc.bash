#!/bin/bash
###############################################################################
# Pegasus' Linux Administration Tools                           Library Index #
# (C)2017-2018 Mattijs Snepvangers                      pegasus.ict@gmail.com #
# License: GPL v3                          Please keep my name in the credits #
###############################################################################

#######################################################
# PROGRAM_SUITE="Pegasus' Linux Administration Tools" #
# SCRIPT_TITLE="Library Index"                        #
# MAINTAINER="Mattijs Snepvangers"                    #
# MAINTAINER_EMAIL="pegasus.ict@gmail.com"            #
# VERSION_MAJOR=0                                     #
# VERSION_MINOR=0                                     #
# VERSION_PATCH=11                                    #
# VERSION_STATE="PRE-ALPHA"                           #
# VERSION_BUILD=20180409                              #
#######################################################

### FUNCTIONS ###
create_constants() {
	# declare extensions & dirs
	declare -gr INI_EXT=".ini"
	declare -gr LIB_EXT=".inc.bash"
	declare -gr LIB_DIR="lib/"
	# declare ini & dedicated function lib
	declare -gr INI_FILE="$SCRIPT$INI_EXT"
	declare -gr LIB_FILE="functions$LIB_EXT"
	declare -gr LIB="$LIB_DIR$LIB_FILE"
	# blib coupling
	declare -gr BLIB_VER="1.2"
	declare -gr BLIB_DIR="$LIB_DIRblib_$BLIB_VER/"
	# ini parser
	declare -gr INI_PRSR_FILE="ini_parser$LIB_EXT"
	# today's date
	declare -gr TODAY=$(date +"%d-%m-%Y")
}
### MAIN ###
create_constants
source "$LIB"
source "$LIB_DIR$INI_PRSR_FILE"
