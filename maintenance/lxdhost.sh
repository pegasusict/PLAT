#!/bin/bash
################################################################################
## Pegasus' Linux Administration Tools                             VER0.6BETA ##
## (C)2017 Mattijs Snepvangers                          pegasus.ict@gmail.com ##
## plat_maintenance_lxdhost.sh     maintenance script lxdhost      VER0.1BETA ##
## License: GPL v3                         Please keep my name in the credits ##
################################################################################

# Make sure only root can run this script
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

_now=$(date +"%Y-%m-%d_%H.%M.%S.%3N")
PLAT_LOGFILE="/var/log/platMaintenance_$_now.log"

# find ip addresses in use
# arp-scan 192.168.1.0/24

printf "################################################################################\n" 2>&1 | tee -a $PLAT_LOGFILE
printf "## Pegasus' Linux Administration Tools - LXDhost Maintenance Script  V0.8Beta ##\n" 2>&1 | tee -a $PLAT_LOGFILE
printf "## (c) 2017 Mattijs Snepvangers                         pegasus.ict@gmail.com ##\n" 2>&1 | tee -a $PLAT_LOGFILE
printf "################################################################################\n" 2>&1 | tee -a $PLAT_LOGFILE
printf "\n" 2>&1 | tee -a $PLAT_LOGFILE
