#!/bin/bash
# if run in shell, debug is switched on
echo $- | grep i
if [[ $? -ge 1 ]] ; then
	declare -gr DEBUGMODE=true
	set -o xtrace	# Trace execution
	set -o errexit	# Exits on most errors




START_TIME=$(date +"%Y-%m-%d_%H.%M.%S.%3N")
CURR_YEAR=$(date +"%Y")
SCRIPT="${${basename "${BASH_SOURCE[0]}"}%.*}"
INI_FILE="$SCRIPT.ini"
