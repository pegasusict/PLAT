#!/bin/bash
################################################################################
## Pegasus' Linux Administration Tools                             VER0.6BETA ##
## (C)2017 Mattijs Snepvangers                          pegasus.ict@gmail.com ##
## plat_maintenance_basic.sh    maintenance script basic           VER0.6BETA ##
## License: GPL v3                         Please keep my name in the credits ##
################################################################################

# Make sure only root can run this script
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

_now=$(date +"%Y-%m-%d_%H.%M.%S.%3N")
PEGS_LOGFILE="/var/log/plat_maintenance_$_now.log"

printf "################################################################################\n" 2>&1 | tee -a $PEGS_LOGFILE
printf "## Pegasus' Linux Administration Tools - Basic Maintenance Script    V0.8Beta ##\n" 2>&1 | tee -a $PEGS_LOGFILE
printf "## (c) 2017 Mattijs Snepvangers                         pegasus.ict@gmail.com ##\n" 2>&1 | tee -a $PEGS_LOGFILE
printf "################################################################################\n" 2>&1 | tee -a $PEGS_LOGFILE
printf "\n" 2>&1 | tee -a $PEGS_LOGFILE
