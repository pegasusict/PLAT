#!/bin/bash
SCRIPT=$(basename "$0")
VERSION_MAJOR=0
VERSION_MINOR=2
VERSION_PATCH=57
VERSION_STATE="ALPHA " # needs to be 6 chars for alignment <ALPHA |BETA  |RC    |STABLE>
VERSION_BUILD=20180306
MAINTAINER="Mattijs Snepvangers"
EMAIL="pegasus.ict@gmail.com"
###
SHORT_VERSION="$VERSION_MAJOR.$VERSION_MINOR.$VERSION_PATCH-$VERSION_STATE"
###
# Making sure this script is run by bash to prevent mishaps
if [ "$(ps -p "$$" -o comm=)" != "bash" ]; then bash "$0" "$@" ; exit "$?" ; fi
# Make sure only root can run this script
if [[ $EUID -ne 0  ]]; then echo "This script must be run as root" ; exit 1 ; fi
###### DEFINE LOGFILE ##########################################################
LOGFILE="/var/log/plat/maintenance_$START_TIME.log"
