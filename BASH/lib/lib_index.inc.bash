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
# VERSION_PATCH=0                                     #
# VERSION_STATE="PRE-ALPHA"                           #
# VERSION_BUILD=20180405                              #
#######################################################

### FUNCTIONS ###
create_constants() {
	declare -r INI_EXT=".ini"
	declare -r LIB_EXT=".inc.bash"
	declare -r LIB_DIR="lib/"
	#
	declare -r INI_FILE="$SCRIPT$INI_EXT"
	declare -r LIB_FILE="functions$LIB_EXT"


	
	declare -r BLIB_VER="1.2"
	declare -r BLIB_DIR="$LIB_DIRblib_$BLIB_VER/"

	
	declare -r INI_PRSR_FILE="ini_parser$LIB_EXT"
	#
	declare -r TODAY=$(date +"%d-%m-%Y")


}

main() {
	create_constants

}
### MAIN ###
main
