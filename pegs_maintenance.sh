#!/bin/bash
################################################################################
## Pegasus' Linux Administration Tools                             VER0.5BETA ##
## (C)2017 Mattijs Snepvangers                          pegasus.ict@gmail.com ##
## pegs_maintenance.sh        maintenance script                   VER0.5 BETA ##
## License: GPL v3                         Please keep my name in the credits ##
################################################################################

# Make sure only root can run this script
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi
###TODO### Create auto update script
_now=$(date +"%Y%m%d.%H%M%S%3N")
PEGS_LOGFILE="/var/log/pegsMaintenance_$_now.log"

_timestamp=$(date +"%Y%m%d.%H%M%S%3N")
_logline="###### $_timestamp-1/8 ###### Updating apt cache #####################"
echo $_logline 2>&1
echo $_logline >> $PEGS_LOGFILE 2>&1
apt-get -qqy update >> $PEGS_LOGFILE 2>&1

_timestamp=$(date +"%Y%m%d.%H%M%S%3N")
_logline="###### $_timestamp-2/8 ###### Updating installed packages ############"
echo $_logline 2>&1
echo $_logline >> $PEGS_LOGFILE 2>&1
apt-get -qqy --allow-unauthenticated upgrade >> $PEGS_LOGFILE 2>&1

_timestamp=$(date +"%Y%m%d.%H%M%S%3N")
_logline="###### $_timestamp-3/8 ###### Cleaning up obsolete packages ######################"
echo $_logline 2>&1
echo $_logline >> $PEGS_LOGFILE 2>&1
apt-get -qqy autoremove >> $PEGS_LOGFILE 2>&1

_timestamp=$(date +"%Y%m%d.%H%M%S%3N")
_logline="###### $_timestamp-4/8 ###### Purging apt package cache ##########################"
echo $_logline 2>&1
echo $_logline >> $PEGS_LOGFILE 2>&1
apt-get -qqy clean >> $PEGS_LOGFILE 2>&1

_timestamp=$(date +"%Y%m%d.%H%M%S%3N")
_logline="###### $_timestamp-5/8 ###### Emptying the trash #################################"
echo $_logline 2>&1
echo $_logline >> $PEGS_LOGFILE 2>&1
trash-empty >> $PEGS_LOGFILE 2>&1

_timestamp=$(date +"%Y%m%d.%H%M%S%3N")
_logline="###### $_timestamp-6/8 ###### Clearing user cache ################################"
echo $_logline 2>&1
echo $_logline >> $PEGS_LOGFILE 2>&1
find /home/* -type f \( -name '*.tmp' -o -name '*.temp' -o -name '*.swp' -o -name '*~' -o -name '*.bak' -o -name '..netrwhist' \) -delete >> $PEGS_LOGFILE 2>&1

_timestamp=$(date +"%Y%m%d.%H%M%S%3N")
_logline="###### $_timestamp-7/8 ###### Deleting old logs ############################"
echo $_logline 2>&1
echo $_logline >> $PEGS_LOGFILE 2>&1
find /var/log -name "*.log" -mtime +30 -a ! -name "SQLUpdate.log" -a ! -name "updated_days*" -a ! -name "qadirectsvcd*" -exec rm -f {} \;  >> $PEGS_LOGFILE 2>&1

_timestamp=$(date +"%Y%m%d.%H%M%S%3N")
_logline="###### $_timestamp-8/8 ##### Purging TMP directories ##################"
echo $_logline 2>&1
echo $_logline >> $PEGS_LOGFILE 2>&1
# CRUNCHIFY_TMP_DIRS - List of directories to search
CRUNCHIFY_TMP_DIRS="/tmp /var/tmp"
# DEFAULT_FILE_AGE - # days ago (rounded up) that file was last accessed
DEFAULT_FILE_AGE=+2
# DEFAULT_LINK_AGE - # days ago (rounded up) that symlink was last accessed
DEFAULT_LINK_AGE=+2
# DEFAULT_SOCK_AGE - # days ago (rounded up) that socket was last accessed
DEFAULT_SOCK_AGE=+2
find $CRUNCHIFY_TMP_DIRS -depth -type f -a -ctime $DEFAULT_FILE_AGE -print -delete >> $PEGS_LOGFILE 2>&1
find $CRUNCHIFY_TMP_DIRS -depth -type l -a -ctime $DEFAULT_LINK_AGE -print -delete >> $PEGS_LOGFILE 2>&1
find $CRUNCHIFY_TMP_DIRS -depth -type f -a -empty -print -delete >> $PEGS_LOGFILE 2>&1
find $CRUNCHIFY_TMP_DIRS -depth -type s -a -ctime $DEFAULT_SOCK_AGE -a -size 0 -print -delete >> $PEGS_LOGFILE 2>&1
find $CRUNCHIFY_TMP_DIRS -depth -mindepth 1 -type d -a -empty -a ! -name 'lost+found' -print -delete >> $PEGS_LOGFILE 2>&1

_timestamp=$(date +"%Y%m%d.%H%M%S%3N")
_logline="$_timestamp-###### Maintenance complete ###############################"
echo $_logline 2>&1
echo $_logline >> $PEGS_LOGFILE 2>&1
