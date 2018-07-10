#!/bin/bash
###
SHORT_VER="$VER_MAJOR.$VER_MINOR.$VER_PATCH-$VER_STATE"
LOG_FILE="$LOG_DIR$SCRIPT_$START_TIME.log"
declare -r TODAY=$(date +"%d-%m-%Y")
# Making sure this script is run by bash to prevent mishaps
if [ "$(ps -p "$$" -o comm=)" != "bash" ]
then
    bash "$0" "$@"
    exit "$?"
fi
# Make sure only root can run this script
if [[ $EUID -ne 0  ]]
then
    echo "This script must be run as root"
    exit 1
fi
### Loading function Library ###################################################
source "$LIB_DIR$LIB"
### Loading prefs #####################################################################################
source "$INI_PRSR"
parse_ini "$INI_FILE"
