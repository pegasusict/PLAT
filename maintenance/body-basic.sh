#!/bin/bash
### APT ########################################################################
info_line "Updating apt cache"                  ;	apt-get -qqy update 2>&1 | dbg_line
info_line "Updating installed packages"         ;	apt-get -qqy --allow-unauthenticated upgrade 2>&1 | dbg_line
info_line "Cleaning up obsolete packages"       ;	apt-get -qqy autoremove 2>&1 | dbg_line
info_line "Clearing old/obsolete package cache" ;	apt-get -qqy autoclean 2>&1 | dbg_line
### GARBAGE ####################################################################
info_line "Taking out the trash."
verb_line "Removing files from trash older than $GARBAGE_AGE days"
trash-empty "$GARBAGE_AGE" 2>&1 dbg_line
###
verb_line "Clearing user cache"
find /home/* -type f \( -name '*.tmp' -o -name '*.temp' -o -name '*.swp' -o -name '*~' -o -name '*.bak' -o -name '..netrwhist' \) -delete 2>&1 | dbg_line
###
verb_line "Deleting logs older than $LOG_AGE"
find /var/log -name "*.log" -mtime +"$LOG_AGE" -a ! -name "SQLUpdate.log" -a ! -name "updated_days*" -a ! -name "qadirectsvcd*" -exec rm -f {} \;  dbg_line
###
verb_line "Purging TMP dirs of files unchanged for at least $TMP_AGE days"
CRUNCHIFY_TMP_DIRS="/tmp /var/tmp"	# List of directories to search
find $CRUNCHIFY_TMP_DIRS -depth -type f -a -ctime $TMP_AGE -print -delete 2>&1 dbg_line
find $CRUNCHIFY_TMP_DIRS -depth -type l -a -ctime $TMP_AGE -print -delete 2>&1 dbg_line
find $CRUNCHIFY_TMP_DIRS -depth -type f -a -empty -print -delete 2>&1 dbg_line
find $CRUNCHIFY_TMP_DIRS -depth -type s -a -ctime $TMP_AGE -a -size 0 -print -delete 2>&1 dbg_line
find $CRUNCHIFY_TMP_DIRS -depth -mindepth 1 -type d -a -empty -a ! -name 'lost+found' -print -delete 2>&1 dbg_line
################################################################################
info_line "checking for reboot requirement"
if [ -f /var/run/reboot-required ]
then
	info_line "REBOOT REQUIRED, sheduled for $REBOOT_TIME"
	shutdown -r $REBOOT_TIME  2>&1 | info_line
else
	info_line "No reboot required"
fi
###
info_line "Maintenance Complete"
### send email with log attached
#bash /etc/plat/mail.sh
