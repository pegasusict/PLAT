#!/bin/bash
################################################################################
## Pegasus' Linux Administration Tools                             VER0.6BETA ##
## (C)2017 Mattijs Snepvangers                          pegasus.ict@gmail.com ##
## pegs_maintenance.sh        maintenance script                   VER0.6BETA ##
## License: GPL v3                         Please keep my name in the credits ##
################################################################################

# Make sure only root can run this script
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

###
###TODO### Create auto update script
###

_now=$(date +"%Y-%m-%d_%H.%M.%S")
PEGS_LOGFILE="/var/log/plat_maintenance_$_now.log"

################################################################################
_timestamp=$(date +"%Y-%m-%d_%H.%M.%S,%3N")
_logline="########## $_timestamp-1/10 ###### creating snapshots ##########################"
echo $_logline 2>&1 | tee -a $PEGS_LOGFILE
#lxc  2>&1 | tee -a $PEGS_LOGFILE
################################################################################
_timestamp=$(date +"%Y-%m-%d_%H.%M.%S,%3N")
_logline="########## $_timestamp-2/10 ###### full system backup ##########################"
echo $_logline 2>&1 | tee -a $PEGS_LOGFILE
#tar 2>&1 | tee -a $PEGS_LOGFILE
################################################################################
_timestamp=$(date +"%Y-%m-%d_%H.%M.%S,%3N")
_logline="########## $_timestamp-3/10 ###### Updating apt cache ##########################"
echo $_logline 2>&1 | tee -a $PEGS_LOGFILE
apt-get -qqy update 2>&1 | tee -a $PEGS_LOGFILE
################################################################################
_timestamp=$(date +"%Y-%m-%d_%H.%M.%S,%3N")
_logline="########## $_timestamp-4/10 ###### Updating installed packages #################"
echo $_logline 2>&1 | tee -a $PEGS_LOGFILE
apt-get -qqy --allow-unauthenticated upgrade 2>&1 | tee -a $PEGS_LOGFILE
################################################################################
_timestamp=$(date +"%Y-%m-%d_%H.%M.%S,%3N")
_logline="########## $_timestamp-5/10 ###### Cleaning up obsolete packages ###############"
echo $_logline 2>&1 | tee -a $PEGS_LOGFILE
apt-get -qqy autoremove 2>&1 | tee -a $PEGS_LOGFILE
################################################################################
_timestamp=$(date +"%Y-%m-%d_%H.%M.%S,%3N")
_logline="########## $_timestamp-6/10 ###### Purging apt package cache ###################"
echo $_logline 2>&1 | tee -a $PEGS_LOGFILE
apt-get -qqy clean 2>&1 | tee -a $PEGS_LOGFILE
################################################################################
_timestamp=$(date +"%Y-%m-%d_%H.%M.%S,%3N")
_logline="########## $_timestamp-7/10 ###### Emptying the trash ##########################"
echo $_logline 2>&1 | tee -a $PEGS_LOGFILE
trash-empty 2>&1 | tee -a $PEGS_LOGFILE
################################################################################
_timestamp=$(date +"%Y-%m-%d_%H.%M.%S,%3N")
_logline="########## $_timestamp-8/10 ###### Clearing user cache #########################"
echo $_logline 2>&1 | tee -a $PEGS_LOGFILE
find /home/* -type f \( -name '*.tmp' -o -name '*.temp' -o -name '*.swp' -o -name '*~' -o -name '*.bak' -o -name '..netrwhist' \) -delete 2>&1 | tee -a $PEGS_LOGFILE
################################################################################
_timestamp=$(date +"%Y-%m-%d_%H.%M.%S,%3N")
_logline="########## $_timestamp-9/10 ###### Deleting old logs ###########################"
echo $_logline 2>&1 | tee -a $PEGS_LOGFILE
find /var/log -name "*.log" -mtime +30 -a ! -name "SQLUpdate.log" -a ! -name "updated_days*" -a ! -name "qadirectsvcd*" -exec rm -f {} \;  2>&1 | tee -a $PEGS_LOGFILE
################################################################################
_timestamp=$(date +"%Y-%m-%d_%H.%M.%S,%3N")
_logline="########## $_timestamp-10/10 ##### Purging TMP directories #####################"
echo $_logline 2>&1 | tee -a $PEGS_LOGFILE
# CRUNCHIFY_TMP_DIRS - List of directories to search
CRUNCHIFY_TMP_DIRS="/tmp /var/tmp"
# DEFAULT_FILE_AGE - # days ago (rounded up) that file was last accessed
DEFAULT_FILE_AGE=+2
# DEFAULT_LINK_AGE - # days ago (rounded up) that symlink was last accessed
DEFAULT_LINK_AGE=+2
# DEFAULT_SOCK_AGE - # days ago (rounded up) that socket was last accessed
DEFAULT_SOCK_AGE=+2
find $CRUNCHIFY_TMP_DIRS -depth -type f -a -ctime $DEFAULT_FILE_AGE -print -delete 2>&1 | tee -a $PEGS_LOGFILE
find $CRUNCHIFY_TMP_DIRS -depth -type l -a -ctime $DEFAULT_LINK_AGE -print -delete 2>&1 | tee -a $PEGS_LOGFILE
find $CRUNCHIFY_TMP_DIRS -depth -type f -a -empty -print -delete 2>&1 | tee -a $PEGS_LOGFILE
find $CRUNCHIFY_TMP_DIRS -depth -type s -a -ctime $DEFAULT_SOCK_AGE -a -size 0 -print -delete 2>&1 | tee -a $PEGS_LOGFILE
find $CRUNCHIFY_TMP_DIRS -depth -mindepth 1 -type d -a -empty -a ! -name 'lost+found' -print -delete 2>&1 | tee -a $PEGS_LOGFILE
################################################################################
_timestamp=$(date +"%Y-%m-%d_%H.%M.%S,%3N")
_logline="########## $_timestamp ###### Maintenance complete #############################"
echo $_logline 2>&1 | tee -a $PEGS_LOGFILE
