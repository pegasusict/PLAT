#!/bin/bash
################################################################################
# Pegasus' Linux Administration Tools	#			apt-get maintenance script #
# (C)2017-2018 Mattijs Snepvangers		#				 pegasus.ict@gmail.com #
# License: MIT							#	Please keep my name in the credits #
################################################################################
# Ver 0.1.0-BETA
# Build	20180713
START_TIME=$(date +"%Y-%m-%d_%H.%M.%S.%3N")

# fun: bash_check
# txt: Checks if the script is being run using Bash v4+
# use: bash_check
# api: internal

# Making sure this script is run by bash to prevent mishaps
if [ "$(ps -p "$$" -o comm=)" != "bash" ]
then
	bash "$COMMAND" "$ARGS"
	exit "$?"
fi
# Making sure this script is run by bash 4+
if [ -z "$BASH_VERSION" ] || [ "${BASH_VERSION:0:1}" -lt 4 ]
then
	echo "You need bash v4+ to run this script. Aborting..."
	exit 1
fi

# fun: su_check
# txt: Checks if the script is being run by root or sudo. If not, issues warning and reruns command using sudo
# use: su_check
# api: internal
if [[ $EUID -ne 0 ]]
then
	echo "This script must be run as root / with sudo"
	echo "restarting script with sudo..."
	sudo bash "$COMMAND" "$ARGS"
	exit "$?"
fi
echo "$START_TIME ## Starting Update Process #######################"
echo "Updating apt cache"					;	apt-get -qqy update
echo "Fixing any broken dependencies if needed"	;	apt -qqy --fix-broken install
echo "checking for distribution upgrade"	;	apt-get -qqy dist-upgrade
echo "Updating installed packages"			;	apt-get -qqy --allow-unauthenticated upgrade
echo "Cleaning up obsolete packages"		;	apt-get -qqy auto-remove
echo "Clearing old/obsolete package cache"	;	apt-get -qqy autoclean
###
echo "checking for reboot requirement"
if [ -f /var/run/reboot-required ]
then
	echo "REBOOT REQUIRED, sheduled for 23:59"
	shutdown -r 23:59 2>&1
else
	echo "No reboot required"
fi
###
END_TIME=$(date +"%Y-%m-%d_%H.%M.%S.%3N")
echo "$END_TIME ## Update Process Finished ########################"
