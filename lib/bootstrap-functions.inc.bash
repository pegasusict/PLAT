#!/bin/bash
############################################################################
# Pegasus' Linux Administration Tools #		   Bootstrap Functions Library #
# (C)2017-2018 Mattijs Snepvangers	  #				 pegasus.ict@gmail.com #
# License: MIT						  #	Please keep my name in the credits #
############################################################################

#######################################################
# PROGRAM_SUITE="Pegasus' Linux Administration Tools" #
# SCRIPT_TITLE="BootStrap Functions"				  #
# MAINTAINER="Mattijs Snepvangers"					  #
# MAINTAINER_EMAIL="pegasus.ict@gmail.com"			  #
# VER_MAJOR=0									  #
# VER_MINOR=1									  #
# VER_PATCH=40									  #
# VER_STATE="ALPHA"								  #
# VER_BUILD=20180620							  #
# LICENSE="MIT"										  #
#######################################################

# mod: bootstrap_functions
# txt: This script is contains functions made specific for the script with the
#      same name.

# fun: getargs
# txt: parses commandline arguments
# use: init
# api: prerun
get_args() {
	#getopt --test > /dev/null
	#if [[ $? -ne 4 ]]
	#then
		#err_line "I’m sorry, \"getopt --test\" failed in this environment."
		#exit 1
	#fi
	OPTIONS="hv:r:c:g:l:t:"
	LONG_OPTIONS="help,verbosity:,role:,containertype:garbageage:logage:tmpage:"
	PARSED=$(getopt -o $OPTIONS --long $LONG_OPTIONS -n "$COMMAND" -- "$ARGS")
	if [ $? -ne 0 ]
		then usage
	fi
	eval set -- "$PARSED"
	while true; do
		case "$1" in
			-h|--help			) usage ; shift ;;
			-v|--verbosity		) set_verbosity $2 ; shift 2 ;;
			-r|--role			) check_role $2; shift 2 ;;
			-c|--containertype	) check_container $2; shift 2 ;;
			-g|--garbageage		) GABAGE_AGE=$2; shift 2 ;;
			-l|--logage			) LOG_AGE=$2; shift 2 ;;
			-t|--tmpage			) TMP_AGE=$2; shift 2 ;;
			--					) shift; break ;;
			*					) break ;;
		esac
	done
}

# fun: build_maintenance_script
# txt: Generates maintenance script for workstations, servers and containers.
# use: build_maintenance_script filename
# api: bootstrap
build_maintenance_script() { ### TODO(pegasusict): convert to template
	local _SCRIPT		;	_SCRIPT=$1
	local _SCRIPT_INI	;	_SCRIPT_INI="${_SCRIPT%.*}.ini"
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
	add_to_script "$_SCRIPT" line "verb_line <<EOH"
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

# fun: check_container
# txt: parses containertype and sets systemroles accordingly
# use: check_container containertype
# api: bootstrap
check_container() {
	_CONTAINER=$1
	case "$_CONTAINER" in
		"nas"		)	SYSTEMROLE_NAS=true		;	dbg_line "container=nas"	;;
		"web"		)	SYSTEMROLE_NAS=true		;
						SYSTEMROLE_WEB=true		;	dbg_line "container=web"	;;
		"x11"		)	SYSTEMROLE_WS=true		;	dbg_line "container=x11"	;;
		"pxe"		)	SYSTEMROLE_NAS=true		;
						SYSTEMROLE_PXE=true		;	dbg_line "container=pxe"	;;
		"basic"		)	SYSTEMROLE_BASIC=true	;	dbg_line "container=basic"	;;
		"router"	)	SYSTEMROLE_ROUTER=true	;	dbg_line "container=router"	;;
		*			)	crit_line "CRITICAL: Unknown containertype $CONTAINER, exiting..."	;	exit 1	;;
	esac;
}

# fun: check_role
# txt: parses systemrole and sets additional systemroles accordingly
# use: check_container ROLE
# api: bootstrap
check_role() {
	local _ROLE=$1
	case "$_ROLE" in
		"ws"			)	SYSTEMROLE_WS=true			;	dbg_line "role=ws"			;;
		"poseidon"		)	SYSTEMROLE_WS=true			;
							SYSTEMROLE_SERVER=true		;
							SYSTEMROLE_LXCHOST=true		;
							SYSTEMROLE_POSEIDON=true	;
							SYSTEMROLE_NAS=true			;	dbg_line "role=poseidon"	;;
		"mainserver"	)	SYSTEMROLE_SERVER=true		;
							SYSTEMROLE_MAINSERVER=true	;
							SYSTEMROLE_LXCHOST=true		;	dbg_line "role=mainserver"	;;
		"container"		)	SYSTEMROLE_SERVER=true		;
							SYSTEMROLE_CONTAINER=true	;	dbg_line "role=container"	;;
		*				)	critline "CRITICAL: Unknown systemrole $ROLE, exiting..."	;	exit 1;;
	esac
}

# fun: usage
# txt: outputs usage information
# use: usage
# api: prerun
usage() {
	version
	cat <<-EOT
		USAGE: sudo bash $SCRIPT -h
		        or
		       sudo bash $SCRIPT -r <systemrole> [ -c <containertype> ] [ -v INT ] [ -g <garbageage> ] [ -l <logage> ] [ -t <tmpage> ]

		OPTIONS

		   -r or --role tells the script what kind of system we are dealing with.
		      Valid options: ws, poseidon, mainserver, container << REQUIRED >>
		   -c or --containertype tells the script what kind of container we are working on.
		      Valid options are: basic, nas, web, x11, pxe, router << REQUIRED if -r=container >>
		   -v or --verbosity defines the amount of chatter. 0=CRITICAL, 1=WARNING, 2=INFO, 3=VERBOSE, 4=DEBUG. default=2
		   -g or --garbageage defines the age (in days) of garbage (trashbins & temp files) being cleaned, default=7
		   -l or --logage defines the age (in days) of logs to be purged, default=30
		   -t or --tmpage define how long temp files should be untouched before they are deleted, default=2
		   -h or --help prints this message

		  The options can be used in any order
		EOT
	exit 3
}
