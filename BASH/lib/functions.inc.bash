#!/bin/bash
############################################################################
# Pegasus' Linux Administration Tools #                  Functions Library #
# (C)2017-2018 Mattijs Snepvangers    #              pegasus.ict@gmail.com #
# License: GPL v3                     # Please keep my name in the credits #
############################################################################

#######################################################
# PROGRAM_SUITE="Pegasus' Linux Administration Tools" #
# SCRIPT_TITLE="Functions Library"                    #
# MAINTAINER="Mattijs Snepvangers"                    #
# MAINTAINER_EMAIL="pegasus.ict@gmail.com"            #
# VERSION_MAJOR=0                                     #
# VERSION_MINOR=5                                     #
# VERSION_PATCH=11                                    #
# VERSION_STATE="ALPHA"                               #
# VERSION_BUILD=20180409                              #
#######################################################

### Basic program ##############################################################
create_var() { ### sets $VAR to $VALUE
    # varname is automatically changed to uppercase
    _VAR=$1
    _VALUE=$2
    declare -gu $_VAR=$_VALUE
}
create_indexed_array() { ### sets $ARRAY to $VALUE1 --- $VALUEn
    # usage create_indexed_array $ARRAY $VALUE1 [$VALUE2 ...]
    _ARRAY=$1
    _ARGS=$@
    for (( i=1 ; i<=_ARGS ; i++ ))
    do
        declare -ga $_ARRAY$[$i]=( ${_ARGS[$i]} ) ###CHECK###
    done
}
create_associative_array() { ### fills $ARRAY with $KEY=$VALUE pair(s)
    # usage create_associative_array $ARRAY $KEY1 $VALUE1 [KEY2 $VALUE2 ...]
    _ARRAY=$1
    _ARGS=$@
    for (( i=1 ; i<=_ARGS ; i+2 ))
    do
        declare -gA $_ARRAY$=( [${_ARGS[$i]}]=${_ARGS[$i+1]} )
    done
}
get_screen_size() { ### gets terminal size and sets global vars
					#+  SCREEN_HEIGHT and SCREEN_WIDTH
	shopt -s checkwinsize
	(:)
	dbg_line "Found $LINES lines and $COLUMNS columns."
	declare -g SCREEN_HEIGHT=${$LINES:-25 }
	declare -g SCREEN_WIDTH=${$COLUMNS:-80 }
}
get_timestamp() { ### returns something like 2018-03-23_13.37.59.123
    echo $(date +"%Y-%m-%d_%H.%M.%S.%3N")
}

### Program Info ###############################################################
version() {
    echo -e "\n$PROGRAM $VERSION - $COPYRIGHT $MAINTAINER"
}

### User Interaction ###########################################################
header() { ### generates a header
    # usage: header $CHAR $LEN
    # $CHAR defaults to # and $LEN defaults to 80
    _CHAR=${$1:-#}
    _LEN=${$2:-80}
    _HEADER=$(make_line $_CHAR $_LEN)
    _HEADER+=header_line $PROGRAM_SUITE $SCRIPT_TITLE $_CHAR $_LEN
    _HEADER+=header_line $COPYRIGHT $MAINTAINER_EMAIL $_CHAR $_LEN
    _HEADER+=header_line $SHORT_VERSION "Build $VERSION_BUILD" $_CHAR $_LEN
    _HEADER+=header_line "License: $LICENSE" "Please keep my name in the credits" $_CHAR $_LEN
    _HEADER+="\n$(make_line $_CHAR $_LEN)\n"
    cat "$_HEADER"
}
header_line() { ### generates a header-line
    # usage: header_line $PART1 $PART2 $CHAR $LEN $SPACER
    # $CHAR defaults to "#", $LEN to 80 and spacer to " "
    _PART1="$1"
    _PART2="$2"
    _CHAR=${$3:-#}
    _LEN=${$4:-}
    _SPACER=${$5:- }
    _HEADER_LINE="# $_PART1$_SPACER$_PART2 #"
    for (( i=${#_HEADER_LINE}; i<MAX_WIDTH; i++ ))
        do _SPACER+=" "
    done
    _HEADER_LINE="# $_PART1$_SPACER$_PART2 #"
    printf "%s\n" $_HEADER_LINE
}
make_line() { ### generates a line
    # usage: make_line [$CHAR [$LEN [$LINE]]]
    # $CHAR defaults to "#" and $LEN defaults to 80
    _CHAR=${$1:-#}
    _LEN=${$2:-80}
    _LINE=${$3:-#}
    for (( i=${#_LINE}; i<_LEN; i++ ))
        do _LINE+=$CHAR
    done
    printf "%s\n" $_LINE
}

### LOGGING ####################################################################
set_verbosity() { ### Set verbosity level
    case $1 in
        0   )   VERBOSITY=0;;   ### Be vewy, vewy quiet... /
								#+ Will only show Critical errors which result in an untimely exiting of the script
        1   )   VERBOSITY=1;;   # Will show errors that don't endanger the basic functioning of the program
        2   )   VERBOSITY=2;;   # Will show warnings
        3   )   VERBOSITY=3;;   # Just give us the highlights, please - will tell what phase is taking place
        4   )   VERBOSITY=4;;   # Let me know what youre doing, every step of the way
        5   )   VERBOSITY=5;;   # I want it all, your thoughts and dreams too!!!
        *   )   VERBOSITY=2;;   ## DEFAULT
    esac
}
###
crit_line() { ### CRITICAL MESSAGES with timestamp
    local _LOG_LINE="CRITICAL: $1"
    logline 1 "$_LOGLINE"
}
err_line() { ### ERROR MESSAGES with timestamp
    local _LOG_LINE="ERROR: $1"
    logline 2 "$_LOGLINE"
}
info_line() { ### INFO MESSAGES with timestamp
    local _LOG_LINE="INFO: $1"
    logline 3 "$_LOGLINE"
}
verb_line() { ### VERBOSE MESSAGES with timestamp
    local _LOG_LINE="VERBOSE: $1"
    logline 4 "$_LOGLINE"
}
dbg_line() { ### DEBUG MESSAGES with timestamp
	if [[ $VERBOSITY -ge 5 ]]
	then
		_LOG_LINE="DEBUG: $1"
		log_line 5 "$_LOG_LINE"
		unset _LOG_LINE
	fi
}
###
log_line() { # creates a nice logline and decides what to print on screen and 
				#+ what to send to logfile based on VERBOSITY and IMPORTANCE levels
    # messages up to level 4 are sent to log
    # if verbosity = 5, all messages are printed on screen and sent to log incl debug
    # usage: opr <importance> <message>
    local _IMPORTANCE=$1
    local _MESSAGE="$(get_timestamp) # $2 #"
    local _WIDTH=$SCREEN_WIDTH
    source $LIB_DIR/terminaloutput.sh
    for (( i=${#_MESSAGE} ; i<_WIDTH ; i++ ))
        do _LOG_LINE+="#"
    done
        if [ "$VERBOSITY" < 5 ]
        then
			case $IMPORTANCE in
				
        if [ $IMPORTANCE -le $VERBOSITY ]
        then
            echo "$MESSAGE" | tee -a $LOGFILE
        else
            echo "$MESSAGE" >> $LOGFILE
        fi
    else
        echo "$MESSAGE" | tee -a $LOGFILE
    fi
}

### File(System) operations ####################################################
add_line_to_file() { ### Inserts line into file if it's not there yet
    _LINE_TO_ADD=$1
    _TARGET=$2
    _line_exists() {
        grep -qsFx "$LINE_TO_ADD" "$TARGET_FILE"
    }
    dbg_line "LINE_TO_ADD: $_LINE_TO_ADD"
    dbg_line "TARGET: $_TARGET"
    if [ $(_line_exists) ]
        then
            info_line "line already exists, leaving it undisturbed"
        else
            if [ -w "$_TARGET" ]
                then
                    printf "%s\n" "$_LINE_TO_ADD" >> "$_TARGET"
                    info_line "$_TARGET has been updated"
                else
                    crit_line "CRITICAL: $_TARGET not writeable: Line could not be added"
                    exit 1
            fi
    fi
}
add_to_script() { #adds line or blob to script
	local _TARGET_SCRIPT=$1
	local _LINE_OR_BLOB=$2
	local _MESSAGE=$3
	if [ "$LINE_OR_BLOB" == line ]
	then
	    echo "$MESSAGE" >> "$TARGET_SCRIPT"
	elif [ "$LINE_OR_BLOB" == blob ]
	    cat "$MESSAGE" >> "$TARGET_SCRIPT"
	else
	    err_line "unknown value: $_LINE_OR_BLOB"
	    exit 1
	fi
}
create_dir() { ### Creates directory if it doesn't exist
    _TARGET_DIR=$1
    if [ ! -d "$_TARGET_DIR" ]
        then mkdir "$_TARGET_DIR"
    fi
}
create_file() { ### Creates file if it doesn't exist
    _TARGET_FILE=$1
    if [ ! -f "$_TARGET_FILE" ]
        then touch "$_TARGET_FILE"
    fi
}
create_file_from_template() { ### render a template file
    # expand variables + preserve formatting
    #usage: create_file_from_template $TARGET_FILE $TEMPLATE
    _TARGET_FILE=$1
    _TEMPLATE=$2
    eval "echo \"$(cat $_TEMPLATE)\"" > $_TARGET_FILE
}
file_exists() { ### Checks if file exists
    # usage: file_exists $FILE
    $_FILE=$1
    if [ -f "$1" ]
    then
        echo true
    else
        echo false
    fi
}
goto_base_dir() { # If we're not in the base directory of the script,
	#+ let's go there to prevent stuff from going haywire
    dbg_line "Let's find out where we're at..."
    EXEC_PATH="${BASH_SOURCE[0]}"
    while [ -h "$EXEC_PATH" ]
    do # resolve $EXEC_PATH until the file is no longer a symlink
        local TARGET="$(readlink "$EXEC_PATH")"
        if [[ $TARGET == /* ]]
        then
            dbg_line "EXEC_PATH '$EXEC_PATH' is an absolute symlink to '$TARGET'"
            EXEC_PATH="$TARGET"
        else
            DIR="$(dirname "$EXEC_PATH")"
            dbg_line "EXEC_PATH '$EXEC_PATH' is a relative symlink to '$TARGET' (relative to '$DIR')"
            EXEC_PATH="$DIR/$TARGET"
        fi
    done
    dbg_line "EXEC_PATH is $EXEC_PATH"
    THIS_SCRIPT="$(basename $EXEC_PATH)"
    BASE_DIR=$(dirname "$EXEC_PATH")
    RDIR="$( dirname "$EXEC_PATH" )"
    DIR="$( cd -P "$( dirname "$EXEC_PATH" )" && pwd )"
    if [ "$DIR" != "$RDIR" ]
    then
        dbg_line "DIR '$RDIR' resolves to '$DIR'"
    fi
    dbg_line "DIR is '$DIR'"
    THIS_SCRIPT=$(basename $EXEC_PATH)
    BASE_DIR=$(dirname "$EXEC_PATH")
    if [[ $(pwd) != "$BASE_DIR" ]]
    then
        cd "$BASE_DIR"
    fi
    dbg_line "Now we're in the base directory\"$BASE_DIR\""
}
purge_dir() {
    _DIR="$1"
    rm -rf "$_DIR"
    create_dir "$_DIR"
}

### TMP OPS ###
create_tmp() { ### usage: create_tmp $PREFIX
    local _PREFIX=$1
    TMP_DIR=""
    TMP_FILE=""
    until [ -n "$TMP_DIR" -a ! -d "$TMP_DIR" ]
    do
        TMP_DIR="/tmp/$_PREFIX.${RANDOM}${RANDOM}${RANDOM}" 
    done 
    mkdir -p -m 0700 $TMP_DIR || { 
        echo "FATAL: Failed to create temp dir '$TMP_DIR': $?"
        exit 100
    } 
    TMP_FILE="$TMP_DIR/$_PREFIX.${RANDOM}${RANDOM}${RANDOM}" 
    touch $TMP_FILE && chmod 0600 $TMP_FILE || { 
        echo "FATAL: Failed to create temp file '$TMP_FILE': $?"
        exit 101
    }
    # Do our best to clean up temp files no matter what 
    # Note $temp_dir must be set before this, and must not change! 
    declare -g CLEANUP="rm -rf $TMP_DIR" 
    trap "$CLEANUP" ABRT EXIT HUP INT QUIT 
}

### apt & friends ##############################################################
add_ppa(){
    METHOD=$1; URL=$2; KEY=$3
    case $METHOD in
        "wget"      )   wget -q -a "$LOGFILE" $URL -O- | apt-key add - ;;
        "apt-key"   )   apt-key adv --keyserver $URL --recv-keys $KEY 2>&1 | opr3 ;;
        "aar"       )   add-apt-repository $URL | opr3 ;;
    esac
}
apt_inst() { ### Installs packages (space seperated arguments)
    apt-get -qqy --allow-unauthenticated install "$@" 2>&1 | opr4
}
install() {
    dpkg -i $1 2>&1 | opr4
}

### (Inter)net(work) Operations ################################################
download() { ### downloads quietly, output to $LOGFILE
    wget -q -a "$LOGFILE" -nv $1
}
