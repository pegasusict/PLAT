#!/bin/bash
################################################################################
# Pegasus' Linux Administration Tools	#		 PostInstall Functions Library #
# (C)2017-2018 Mattijs Snepvangers		#				 pegasus.ict@gmail.com #
# License: MIT							#	Please keep my name in the credits #
################################################################################

#######################################################
# PROGRAM_SUITE="Pegasus' Linux Administration Tools" #
# SCRIPT_TITLE="PostInstall Functions Library"        #
# MAINTAINER="Mattijs Snepvangers"                    #
# MAINTAINER_EMAIL="pegasus.ict@gmail.com"            #
# VERSION_MAJOR=0                                     #
# VERSION_MINOR=1                                     #
# VERSION_PATCH=33                                    #
# VERSION_STATE="ALPHA"                               #
# VERSION_BUILD=20180419                              #
# LICENSE="MIT"										  #
#######################################################

### Basic program ##############################################################
get_args() {
	getopt --test > /dev/null
	if [[ $? -ne 4 ]]
	then
		err_line "I’m sorry, \"getopt --test\" failed in this environment."
		exit 1
	fi
	OPTIONS="hv:r:c:g:l:t:S:P:R:"
	LONG_OPTIONS="help,verbosity:,role:,containertype:garbageage:logage:tmpage:"
	PARSED=$(getopt -o $OPTIONS --long $LONG_OPTIONS -n "$0" -- "$@")
	if [ $? -ne 0 ]
		then usage
	fi
	eval set -- "$PARSED"
	while true; do
		case "$1" in
			-h|--help			) usage ; shift ;;
			-v|--verbosity		) setverbosity $2 ; shift 2 ;;
			-r|--role			) checkrole $2; shift 2 ;;
			-c|--containertype	) checkcontainer $2; shift 2 ;;
			-g|--garbageage		) GABAGE_AGE=$2; shift 2 ;;
			-l|--logage			) LOG_AGE=$2; shift 2 ;;
			-t|--tmpage			) TMP_AGE=$2; shift 2 ;;
			--					) shift; break ;;
			*					) break ;;
		esac
	done
}

build_maintenance_script() { ###TODO### Convert to template
	local _SCRIPT=$1
	local _SCRIPT_INI="${_SCRIPT%.*}.ini"
	if [[ "$_SCRIPT" == "$MAINTENANCE_SCRIPT" ]]
	then
		local _SCRIPT_TITLE="$MAINTENANCE_SCRIPT_TITLE"
	else
		local _SCRIPT_TITLE="$CONTAINER_SCRIPT_TITLE"
	fi
	### removing old script if it exists
	if [ -f "$_SCRIPT" ]
	then
		rm "$_SCRIPT" 2>&1 | dbg_line
		info_line "Removed old maintenance script."
	fi
	### generating script header
	add_to_script "$_SCRIPT" line "#!/usr/bin/bash"
	make_line >> "$_SCRIPT"
	header_line "$PROGRAM_SUITE - $_SCRIPT_TITLE" "Ver$SHORT_VERSION" >> "$_SCRIPT"
	header_line "$COPYRIGHT $MAINTAINER" "build $VERSION_BUILD  $MAINTAINER_EMAIL" >> "$_SCRIPT"
	header_line "This maintenance script is dynamically built" "Last build: $TODAY" >> "$_SCRIPT"
	header_line "License: $LICENSE" "Please keep my name in the credits" >> "$_SCRIPT"
	make_line >> "$_SCRIPT"
	sed -e 1d maintenance/maintenance-subheader1.sh >> "$_SCRIPT"
	add_to_script "$_SCRIPT" line "PROGRAM_SUITE=\"$PROGRAM_SUITE\""
	add_to_script "$_SCRIPT" line "SCRIPT_TITLE=\"$_SCRIPT_TITLE\""
	add_to_script "$_SCRIPT" line "VERSION_MAJOR=$VERSION_MAJOR"
	add_to_script "$_SCRIPT" line "VERSION_MINOR=$VERSION_MINOR"
	add_to_script "$_SCRIPT" line "VERSION_PATCH=$VERSION_PATCH"
	add_to_script "$_SCRIPT" line "VERSION_STATE=$VERSION_STATE"
	add_to_script "$_SCRIPT" line "VERSION_BUILD=$VERSION_BUILD"
	add_to_script "$_SCRIPT" line "MAINTAINER=\"$MAINTAINER\""
	add_to_script "$_SCRIPT" line "MAINTAINER_EMAIL=\"$MAINTAINER_EMAIL\""
	make_line >> "$_SCRIPT"
	make_line "#" 80 "### define CONSTANTS #"
	add_to_script "$_SCRIPT" line "declare -r LIB_DIR=\"$LIB_DIR\""
	add_to_script "$_SCRIPT" line "declare -r LIB=\"$LIB\""
	add_to_script "$_SCRIPT" line "declare -r INI_PRSR=\"$INI_PRSR\""
	make_line "#" 80 "### set default values #"
	add_to_script "$_SCRIPT" line "VERBOSITY=$VERBOSITY"
	add_to_script "$_SCRIPT" line "TMP_AGE=$TMP_AGE"
	add_to_script "$_SCRIPT" line "GARBAGE_AGE=$GARBAGE_AGE"
	add_to_script "$_SCRIPT" line "LOG_AGE=$LOG_AGE"
	add_to_script "$_SCRIPT" line "LOG_DIR=\"$LOG_DIR\""
	sed -e 1d maintenance/maintenance-subheader2.sh >> "$_SCRIPT"
	### adding header to be printed by maintenance file
	add_to_script "$_SCRIPT" line "verb_line <<EOH"
	make_line >> "$_SCRIPT"
	header_line "$PROGRAM_SUITE - $_SCRIPT_TITLE" "Ver$SHORT_VERSION" >> "$_SCRIPT"
	header_line "$COPYRIGHT $MAINTAINER" "build $VERSION_BUILD  $MAINTAINER_EMAIL" >> "$_SCRIPT"
	header_line "This maintenance script is dynamically built" "Last build: $TODAY" >> "$_SCRIPT"
	header_line "License: $LICENSE" "Please keep my name in the credits" >> "$_SCRIPT"
	make_line >> "$_SCRIPT"
	add_to_script "$_SCRIPT" line "EOH"
	### generating maintenance ini file
	info_line "generating ini file"
	add_to_script "$_SCRIPT_INI" line "GARBAGE_AGE=$GARBAGE_AGE"
	add_to_script "$_SCRIPT_INI" line "LOG_AGE=$LOG_AGE"
	add_to_script "$_SCRIPT_INI" line "TMP_AGE=$TMP_AGE"
	if [[ $SYSTEMROLE_CONTAINER == false ]]
	then
		if [[ $_SCRIPT == $MAINTENANCE_SCRIPT ]]
		then
			if [[ $SYSTEMROLE_LXCHOST == true ]]
			then
				sed -e 1d maintenance/body-lxchost0.sh >> "$_SCRIPT"
				if [[ $SYSTEMROLE_MAINSERVER == true ]]
				then
					sed -e 1d maintenance/backup2tape.sh >> "$_SCRIPT"
				fi
				sed -e 1d maintenance/body-lxchost1.sh >> "$_SCRIPT"
			fi
		fi
	fi
	sed -e 1d maintenance/body-basic.sh >> "$_SCRIPT"
}

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
