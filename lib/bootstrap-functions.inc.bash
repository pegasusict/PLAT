#!/bin/bash
################################################################################
# Pegasus' Linux Administration Tools	#		   Bootstrap Functions Library #
# (C)2017-2018 Mattijs Snepvangers		#				 pegasus.ict@gmail.com #
# License: MIT							#	Please keep my name in the credits #
################################################################################

#######################################################
# PROGRAM_SUITE="Pegasus' Linux Administration Tools" #
# SCRIPT_TITLE="BootStrap Functions"				  #
# MAINTAINER="Mattijs Snepvangers"					  #
# MAINTAINER_EMAIL="pegasus.ict@gmail.com"			  #
# VER_MAJOR=0										  #
# VER_MINOR=1										  #
# VER_PATCH=46										  #
# VER_STATE="ALPHA"									  #
# VER_BUILD=20180807								  #
# LICENSE="MIT"										  #
#######################################################

# mod: bootstrap_functions
# txt: This script is contains functions made specific for the script
#      with the same name.

# fun: build_maintenance_script
# txt: Generates maintenance script for workstations, servers and containers.
# use: build_maintenance_script filename
# api: bootstrap
build_maintenance_script() { ### TODO(pegasusict): convert to template
	local _SCRIPT		;	_SCRIPT=$1
	#local _SCRIPT_INI	;	_SCRIPT_INI="${_SCRIPT%.*}.ini"
	local _SCRIPT_TITLE
	if [[ "$_SCRIPT" == "$MAINTENANCE_SCRIPT" ]]
	then _SCRIPT_TITLE="$MAINTENANCE_SCRIPT_TITLE"
	else _SCRIPT_TITLE="$CONTAINER_SCRIPT_TITLE"
	fi
	### removing old script if it exists
	if [ -f "$_SCRIPT" ] ; then
		rm "$_SCRIPT" 2>&1 | dbg_line
		info_line "Removed old maintenance script."
	fi
	### generating script header ##############################################
	add_to_script "$_SCRIPT" line "#!/usr/bin/bash"
	make_line >> "$_SCRIPT"
	header_line "$PROGRAM_SUITE - $_SCRIPT_TITLE" "Ver$SHORT_VER" >> "$_SCRIPT"
	header_line "$COPYRIGHT $MAINTAINER" "build $VER_BUILD  $MAINTAINER_EMAIL" >> "$_SCRIPT"
	header_line "This maintenance script is dynamically built" "Last build: $TODAY" >> "$_SCRIPT"
	header_line "License: $LICENSE" "Please keep my name in the credits" >> "$_SCRIPT"
	make_line >> "$_SCRIPT"
	###########################################################################
	sed -e 1d "${TPL_DIR}${MAINT_PRFX}"subheader1.sh >> "$_SCRIPT"
	add_to_script "$_SCRIPT" line "PROGRAM_SUITE=\"$PROGRAM_SUITE\""
	add_to_script "$_SCRIPT" line "SCRIPT_TITLE=\"$_SCRIPT_TITLE\""
	add_to_script "$_SCRIPT" line "VER_MAJOR=$VER_MAJOR"
	add_to_script "$_SCRIPT" line "VER_MINOR=$VER_MINOR"
	add_to_script "$_SCRIPT" line "VER_PATCH=$VER_PATCH"
	add_to_script "$_SCRIPT" line "VER_STATE=$VER_STATE"
	add_to_script "$_SCRIPT" line "VER_BUILD=$VER_BUILD"
	add_to_script "$_SCRIPT" line "MAINTAINER=\"$MAINTAINER\""
	add_to_script "$_SCRIPT" line "MAINTAINER_EMAIL=\"$MAINTAINER_EMAIL\""
	make_line >> "$_SCRIPT"
	###########################################################################
	make_line "#" 80 "### define CONSTANTS #"
	add_to_script "$_SCRIPT" line "declare -r LIB_DIR=\"$LIB_DIR\""
	add_to_script "$_SCRIPT" line "declare -r LIB=\"$LIB\""
	add_to_script "$_SCRIPT" line "declare -r INI_PRSR=\"$INI_PRSR\""
	###########################################################################
	make_line "#" 80 "### set default values #"
	add_to_script "$_SCRIPT" line "VERBOSITY=$VERBOSITY"
	add_to_script "$_SCRIPT" line "TMP_AGE=$TMP_AGE"
	add_to_script "$_SCRIPT" line "GARBAGE_AGE=$GARBAGE_AGE"
	add_to_script "$_SCRIPT" line "LOG_AGE=$LOG_AGE"
	add_to_script "$_SCRIPT" line "LOG_DIR=\"$LOG_DIR\""
	sed -e 1d "${TPL_DIR}${MAINT_PRFX}"subheader2.sh >> "$_SCRIPT"
	### adding header to be printed by maintenance file #######################
	add_to_script "$_SCRIPT" line "dbg_line <<EOH"
	make_line >> "$_SCRIPT"
	header_line "$PROGRAM_SUITE - $_SCRIPT_TITLE" "Ver$SHORT_VER" >> "$_SCRIPT"
	header_line "$COPYRIGHT $MAINTAINER" "build $VER_BUILD  $MAINTAINER_EMAIL" >> "$_SCRIPT"
	header_line "This maintenance script is dynamically built" "Last build: $TODAY" >> "$_SCRIPT"
	header_line "License: $LICENSE" "Please keep my name in the credits" >> "$_SCRIPT"
	make_line >> "$_SCRIPT"
	add_to_script "$_SCRIPT" line "EOH"
	### generating maintenance ini file #######################################
	info_line "generating ini file"

	add_to_script "$_SCRIPT_INI" line "GARBAGE_AGE=$GARBAGE_AGE"
	add_to_script "$_SCRIPT_INI" line "LOG_AGE=$LOG_AGE"
	add_to_script "$_SCRIPT_INI" line "TMP_AGE=$TMP_AGE"
	if [[ $SYSTEMROLE_CONTAINER == false ]] ; then
		if [[ $_SCRIPT == $MAINTENANCE_SCRIPT ]] ; then
			if [[ $SYSTEMROLE_LXCHOST == true ]] ; then
				sed -e 1d "${TPL_DIR}${MAINT_PRFX}"body-lxchost0.sh >> "$_SCRIPT"
				if [[ $SYSTEMROLE_MAINSERVER == true ]] ; then
					sed -e 1d "${TPL_DIR}${MAINT_PRFX}"backup2tape.sh >> "$_SCRIPT"
				fi
				sed -e 1d "${TPL_DIR}${MAINT_PRFX}"body-lxchost1.sh >> "$_SCRIPT"
			fi
		fi
	fi
	sed -e 1d "${TPL_DIR}${MAINT_PRFX}"body-basic.sh >> "$_SCRIPT"
}
