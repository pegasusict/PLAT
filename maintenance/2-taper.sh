#!/bin/bash
################################################################################
## Pegasus' Linux Administration Tools                             VER0.6BETA ##
## (C)2017 Mattijs Snepvangers                          pegasus.ict@gmail.com ##
## plat_maintenance_taper.sh     tape backup script                VER0.1BETA ##
## License: GPL v3                         Please keep my name in the credits ##
################################################################################

# Make sure only root can run this script
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

_now=$(date +"%Y-%m-%d_%H.%M.%S.%3N")
PLAT_LOGFILE="/var/log/plat_backup_$_now.log"

echo "################################################################################" 2>&1 | tee -a $PLAT_LOGFILE
echo "## Pegasus' Linux Administration Tools -         Tape Backup Script  V0.8Beta ##" 2>&1 | tee -a $PLAT_LOGFILE
echo "## (c) 2017 Mattijs Snepvangers                         pegasus.ict@gmail.com ##" 2>&1 | tee -a $PLAT_LOGFILE
echo "################################################################################" 2>&1 | tee -a $PLAT_LOGFILE
echo "" 2>&1 | tee -a $PLAT_LOGFILE

## backup data to tape
#   1st sunday of the month complete backup, rest incremental
