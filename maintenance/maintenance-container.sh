#!/bin/bash
#############################################################################
# Pegasus' Linux Administration Tools                    maintenance script #
# (C)2017-2018 Mattijs Snepvangers                    pegasus.ict@gmail.com #
# License: GPL v3                        Please keep my name in the credits #
#############################################################################
PROGRAM_SUITE="Pegasus' Linux Administration Tools"
SCRIPT_TITLE="CONTAINER MAINTENANCE"
SCRIPT=$(basename "$0")
VERSION_MAJOR=0
VERSION_MINOR=2
VERSION_PATCH=42
VERSION_STATE="BETA"
VERSION_BUILD=20180305
###############################################################################
PROGRAM="$PROGRAM_SUITE - $SCRIPT"
SHORTVERSION="$VERSION_MAJOR.$VERSION_MINOR.$VERSION_PATCH-$VERSION_STATE"
VERSION="Ver$SHORTVERSION build $VERSION_BUILD"
###############################################################################
# When was this script called
_now=$(date +"%Y-%m-%d_%H.%M.%S.%3N")
# Making sure this script is run by bash to prevent mishaps
if [ "$(ps -p "$$" -o comm=)" != "bash" ]; then bash "$0" "$@" ; exit "$?" ; fi
# Make sure only root can run this script
if [[ $EUID -ne 0  ]]; then echo "This script must be run as root" ; exit 1 ; fi
###### DEFINE LOGFILE ##########################################################
PLAT_LOGFILE="/var/log/plat/maintenance_$_now.log"
#### DEFINING FUNCTIONS ########################################################
getthetime(){ echo $(date +"%Y-%m-%d_%H.%M.%S.%3N") ; }
tolog() { echo $1 >> "$PLAT_LOGFILE" ; }
create_logline() {
	_loglinetitle=$1
	_log_line="$(getthetime) ## $loglinetitle #"
	imax=80
	for (( i=${#_log_line}; i<$imax; i++ ))
	do
	   _log_line+="#"
	done
	tolog $_log_line
}
create_secline() {
	_loglinetitle=$1
	_log_line="# $loglinetitle #"
	imax=78
	for (( i=${#_log_line}; i<$imax; i+=2 ))
	do
	   _log_line="#$_log_line#"
	done
	tolog $_log_line
}
################################################################################
tolog <<EOT
##############################################################################
# Pegasus' Linux Administration Tools - Post Install Script  Ver$SHORTVERSION #
# (c)2017-2018 Mattijs Snepvangers  build $VERSION_BUILD     pegasus.ict@gmail.com #
##############################################################################

EOT
################################################################################
create_logline "Updating apt cache"
apt-get -qqy update 2>&1 | tolog
################################################################################
create_logline "Updating installed packages"
apt-get -qqy --allow-unauthenticated upgrade 2>&1 | tolog
################################################################################
create_logline "Cleaning up obsolete packages"
apt-get -qqy autoremove 2>&1 | tolog
################################################################################
create_logline "Purging apt package cache"
apt-get -qqy clean 2>&1 | tolog
################################################################################
create_logline "Emptying the trash"
trash-empty $garbageage 2>&1 | tolog
################################################################################
create_logline "Clearing user cache"
find /home/* -type f \( -name '*.tmp' -o -name '*.temp' -o -name '*.swp' -o -name '*~' -o -name '*.bak' -o -name '..netrwhist' \) -delete 2>&1 | tolog
################################################################################
create_logline "Deleting old logs"
find /var/log -name "*.log" -mtime +30 -a ! -name "SQLUpdate.log" -a ! -name "updated_days*" -a ! -name "qadirectsvcd*" -exec rm -f {} \;  2>&1 | tolog
################################################################################
create_logline "Purging TMP directories"
# CRUNCHIFY_TMP_DIRS - List of directories to search
CRUNCHIFY_TMP_DIRS="/tmp /var/tmp"
find $CRUNCHIFY_TMP_DIRS -depth -type f -a -ctime $garbageage -print -delete 2>&1 | tolog
find $CRUNCHIFY_TMP_DIRS -depth -type l -a -ctime $garbageage -print -delete 2>&1 | tolog
find $CRUNCHIFY_TMP_DIRS -depth -type f -a -empty -print -delete 2>&1 | tolog
find $CRUNCHIFY_TMP_DIRS -depth -type s -a -ctime $garbageage -a -size 0 -print -delete 2>&1 | tolog
find $CRUNCHIFY_TMP_DIRS -depth -mindepth 1 -type d -a -empty -a ! -name 'lost+found' -print -delete 2>&1 | tolog
################################################################################
create_logline "Maintenance Complete"
################################################################################
### sending log by email
bash /etc/plat/mail.sh
