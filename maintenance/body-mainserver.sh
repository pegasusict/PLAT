#!/bin/bash
################################################################################
_timestamp=$(date +"%Y-%m-%d_%H.%M.%S,%3N")
_logline="########## $_timestamp-1/10 ###### Scanning for containers #####################"
echo $_logline 2>&1 | tee -a $PLAT_LOGFILE
active_containers = ${lxc list | grep -i running}
inactive_containers = ${lxc list | grep -i stopped}
# Save current IFS
SAVEIFS=$IFS
# Change IFS to new line. 
IFS=$'\n'
active_containers = ($active_containers)
inactive_containers = ($inactive_containers)
# Restore IFS
IFS=$SAVEIFS
_timestamp=$(date +"%Y-%m-%d_%H.%M.%S,%3N")
_logline="########## $_timestamp-2/10 ###### Containers found: ###########################"
echo $_logline 2>&1 | tee -a $PLAT_LOGFILE
for (( i=0; i<${#active_containers[@]}; i++ ))
do
    echo "Active Container $i: ${active_containers[$i]}"
    active_containers_found++
done
echo "found $active_containers_found active containers."
for (( i=0; i<${#inactive_containers[@]}; i++ ))
do
    echo "Inactive Container $i: ${inactive_containers[$i]}"
    inactive_containers_found++
done
echo "found $inactive_containers_found inactive containers."
################################################################################
_timestamp=$(date +"%Y-%m-%d_%H.%M.%S,%3N")
_logline="########## $_timestamp-1/10 ###### creating snapshots ##########################"
echo $_logline 2>&1 | tee -a $PLAT_LOGFILE
#lxc  2>&1 | tee -a $PLAT_LOGFILE
for (( i=0; i<${#active_containers[@]}; i++ ))
do
    lxc pause ${active_containers[$i]}
    lxc snapshot "${active_containers[$i]}" "${active_containers[$i]}_$_timestamp"
    lxc start ${active_containers[$i]}    
done
for (( i=0; i<${#inactive_containers[@]}; i++ ))
do
    lxc snapshot "${inactive_containers[$i]}" "${inactive_containers[$i]}_$_timestamp"
done


















_timestamp=$(date +"%Y-%m-%d_%H.%M.%S,%3N")
_logline="########## $_timestamp-1/10 ####################################################"
echo $_logline 2>&1 | tee -a $PLAT_LOGFILE
#lxc  2>&1 | tee -a $PLAT_LOGFILE







################################################################################
################################################################################
_timestamp=$(date +"%Y-%m-%d_%H.%M.%S,%3N")
_logline="########## $_timestamp-2/10 ###### full system backup ##########################"
echo $_logline 2>&1 | tee -a $PLAT_LOGFILE
#tar 2>&1 | tee -a $PLAT_LOGFILE
################################################################################
_timestamp=$(date +"%Y-%m-%d_%H.%M.%S,%3N")
_logline="########## $_timestamp-3/10 ###### Updating apt cache ##########################"
echo $_logline 2>&1 | tee -a $PLAT_LOGFILE
apt-get -qqy update 2>&1 | tee -a $PLAT_LOGFILE
################################################################################
_timestamp=$(date +"%Y-%m-%d_%H.%M.%S,%3N")
_logline="########## $_timestamp-4/10 ###### Updating installed packages #################"
echo $_logline 2>&1 | tee -a $PLAT_LOGFILE
apt-get -qqy --allow-unauthenticated upgrade 2>&1 | tee -a $PLAT_LOGFILE
################################################################################
_timestamp=$(date +"%Y-%m-%d_%H.%M.%S,%3N")
_logline="########## $_timestamp-5/10 ###### Cleaning up obsolete packages ###############"
echo $_logline 2>&1 | tee -a $PLAT_LOGFILE
apt-get -qqy autoremove 2>&1 | tee -a $PLAT_LOGFILE
################################################################################
_timestamp=$(date +"%Y-%m-%d_%H.%M.%S,%3N")
_logline="########## $_timestamp-6/10 ###### Purging apt package cache ###################"
echo $_logline 2>&1 | tee -a $PLAT_LOGFILE
apt-get -qqy clean 2>&1 | tee -a $PLAT_LOGFILE
################################################################################
_timestamp=$(date +"%Y-%m-%d_%H.%M.%S,%3N")
_logline="########## $_timestamp-7/10 ###### Emptying the trash ##########################"
echo $_logline 2>&1 | tee -a $PLAT_LOGFILE
trash-empty 2>&1 | tee -a $PLAT_LOGFILE
################################################################################
_timestamp=$(date +"%Y-%m-%d_%H.%M.%S,%3N")
_logline="########## $_timestamp-8/10 ###### Clearing user cache #########################"
echo $_logline 2>&1 | tee -a $PLAT_LOGFILE
find /home/* -type f \( -name '*.tmp' -o -name '*.temp' -o -name '*.swp' -o -name '*~' -o -name '*.bak' -o -name '..netrwhist' \) -delete 2>&1 | tee -a $PLAT_LOGFILE
################################################################################
_timestamp=$(date +"%Y-%m-%d_%H.%M.%S,%3N")
_logline="########## $_timestamp-9/10 ###### Deleting old logs ###########################"
echo $_logline 2>&1 | tee -a $PLAT_LOGFILE
find /var/log -name "*.log" -mtime +30 -a ! -name "SQLUpdate.log" -a ! -name "updated_days*" -a ! -name "qadirectsvcd*" -exec rm -f {} \;  2>&1 | tee -a $PLAT_LOGFILE
################################################################################
_timestamp=$(date +"%Y-%m-%d_%H.%M.%S,%3N")
_logline="########## $_timestamp-10/10 ##### Purging TMP directories #####################"
echo $_logline 2>&1 | tee -a $PLAT_LOGFILE
# CRUNCHIFY_TMP_DIRS - List of directories to search
CRUNCHIFY_TMP_DIRS="/tmp /var/tmp"
# DEFAULT_FILE_AGE - # days ago (rounded up) that file was last accessed
DEFAULT_FILE_AGE=+2
# DEFAULT_LINK_AGE - # days ago (rounded up) that symlink was last accessed
DEFAULT_LINK_AGE=+2
# DEFAULT_SOCK_AGE - # days ago (rounded up) that socket was last accessed
DEFAULT_SOCK_AGE=+2
find $CRUNCHIFY_TMP_DIRS -depth -type f -a -ctime $DEFAULT_FILE_AGE -print -delete 2>&1 | tee -a $PLAT_LOGFILE
find $CRUNCHIFY_TMP_DIRS -depth -type l -a -ctime $DEFAULT_LINK_AGE -print -delete 2>&1 | tee -a $PLAT_LOGFILE
find $CRUNCHIFY_TMP_DIRS -depth -type f -a -empty -print -delete 2>&1 | tee -a $PLAT_LOGFILE
find $CRUNCHIFY_TMP_DIRS -depth -type s -a -ctime $DEFAULT_SOCK_AGE -a -size 0 -print -delete 2>&1 | tee -a $PLAT_LOGFILE
find $CRUNCHIFY_TMP_DIRS -depth -mindepth 1 -type d -a -empty -a ! -name 'lost+found' -print -delete 2>&1 | tee -a $PLAT_LOGFILE
################################################################################
_timestamp=$(date +"%Y-%m-%d_%H.%M.%S,%3N")
_logline="########## $_timestamp ###### Maintenance complete #############################"
echo $_logline 2>&1 | tee -a $PLAT_LOGFILE
