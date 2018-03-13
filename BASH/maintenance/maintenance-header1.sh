#!/bin/bash
# Making sure this script is run by bash to prevent mishaps
if [ "$(ps -p "$$" -o comm=)" != "bash" ] ; then bash "$0" "$@" ; exit "$?" ; fi
# Make sure only root can run this script
if [[ $EUID -ne 0 ]]; then echo "This script must be run as root" 1>&2; exit 1 ; fi
###
_now=$(date +"%Y-%m-%d_%H.%M.%S.%3N")
LOGFILE="/var/log/plat/maintenance_$_now.log"
