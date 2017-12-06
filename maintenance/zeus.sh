#!/bin/bash
################################################################################
## Pegasus' Linux Administration Tools                             VER0.6BETA ##
## (C)2017 Mattijs Snepvangers                          pegasus.ict@gmail.com ##
## plat_maintenance_zeus.sh   maintenance script zeus edition      VER0.6BETA ##
## License: GPL v3                         Please keep my name in the credits ##
################################################################################

# Make sure only root can run this script
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

_now=$(date +"%Y-%m-%d_%H.%M.%S.%3N")
PLAT_LOGFILE="/var/log/platMaintenance_$_now.log"

printf "################################################################################\n" 2>&1 | tee -a $PLAT_LOGFILE
printf "## Pegasus' Linux Administration Tools -  Zeus Maintenance Script    V0.8Beta ##\n" 2>&1 | tee -a $PLAT_LOGFILE
printf "## (c) 2017 Mattijs Snepvangers                         pegasus.ict@gmail.com ##\n" 2>&1 | tee -a $PLAT_LOGFILE
printf "################################################################################\n" 2>&1 | tee -a $PLAT_LOGFILE
printf "\n" 2>&1 | tee -a $PLAT_LOGFILE
