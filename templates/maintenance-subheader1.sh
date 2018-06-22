#!/bin/bash
START_TIME=$(date +"%Y-%m-%d_%H.%M.%S.%3N")
CURR_YEAR=$(date +"%Y")
SCRIPT="${${basename "${BASH_SOURCE[0]}"}%.*}"
INI_FILE="$SCRIPT.ini"

