#!/bin/bash
### APT ########################################################################
create_logline "Updating apt cache" ;						apt-get -qqy update 2>&1 | tee -a $PLAT_LOGFILE
create_logline "Updating installed packages" ;				apt-get -qqy --allow-unauthenticated upgrade 2>&1 | tee -a $PLAT_LOGFILE
create_logline "Cleaning up obsolete packages" ;			apt-get -qqy autoremove 2>&1 | tee -a $PLAT_LOGFILE
create_logline "Removing old/obsolete apt package cache" ;	apt-get -qqy clean 2>&1 | tee -a $PLAT_LOGFILE
### GARBAGE ####################################################################
create_logline "Removing files from trash older than $garbageage days"
trash-empty "$garbageage" 2>&1 | tee -a $PLAT_LOGFILE
###
create_logline "Clearing user cache"
echo $_logline 2>&1 | tee -a $PLAT_LOGFILE
find /home/* -type f \( -name '*.tmp' -o -name '*.temp' -o -name '*.swp' -o -name '*~' -o -name '*.bak' -o -name '..netrwhist' \) -delete 2>&1 | tee -a $PLAT_LOGFILE
###
create_logline "Deleting logs older than $logage"
find /var/log -name "*.log" -mtime +"$logage" -a ! -name "SQLUpdate.log" -a ! -name "updated_days*" -a ! -name "qadirectsvcd*" -exec rm -f {} \;  2>&1 | tee -a $PLAT_LOGFILE
###
create_logline "Purging TMP dirs of files unchanged for at least $garbageage days"
CRUNCHIFY_TMP_DIRS="/tmp /var/tmp"	# List of directories to search
find $CRUNCHIFY_TMP_DIRS -depth -type f -a -ctime $garbageage -print -delete 2>&1 | tee -a $PLAT_LOGFILE
find $CRUNCHIFY_TMP_DIRS -depth -type l -a -ctime $garbageage -print -delete 2>&1 | tee -a $PLAT_LOGFILE
find $CRUNCHIFY_TMP_DIRS -depth -type f -a -empty -print -delete 2>&1 | tee -a $PLAT_LOGFILE
find $CRUNCHIFY_TMP_DIRS -depth -type s -a -ctime $garbageage -a -size 0 -print -delete 2>&1 | tee -a $PLAT_LOGFILE
find $CRUNCHIFY_TMP_DIRS -depth -mindepth 1 -type d -a -empty -a ! -name 'lost+found' -print -delete 2>&1 | tee -a $PLAT_LOGFILE
################################################################################
create_logline "sheduling reboot if required"
if [ -f /var/run/reboot-required ]; then shutdown -r 23:30 ; fi
###
create_logline "Maintenance Complete"
### send email with log attached
bash /etc/plat/mail.sh
