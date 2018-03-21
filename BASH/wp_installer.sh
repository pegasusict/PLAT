#!/bin/bash
###############################################################################
# Pegasus' Linux Administration Tools                     WP installer script #
# (C)2017-2018 Mattijs Snepvangers                      pegasus.ict@gmail.com #
# License: GPL v3                          Please keep my name in the credits #
###############################################################################
START_TIME=$(date +"%Y-%m-%d_%H.%M.%S.%3N")
echo "$START_TIME ## Starting PostInstall Process #######################"
################### PROGRAM INFO ##############################################
PROGRAM_SUITE="Pegasus' Linux Administration Tools"
SCRIPT_TITLE="WordPress site installer"
MAINTAINER="Mattijs Snepvangers"
MAINTAINER_EMAIL="pegasus.ict@gmail.com"
VERSION_MAJOR=0
VERSION_MINOR=0
VERSION_PATCH=0
VERSION_STATE="ALPHA"
VERSION_BUILD=201803021
###############################################################################
PROGRAM="$PROGRAM_SUITE - $SCRIPT"
SHORT_VERSION="$VERSION_MAJOR.$VERSION_MINOR.$VERSION_PATCH-$VERSION_STATE"
VERSION="Ver$SHORT_VERSION build $VERSION_BUILD"
###############################################################################
# Making sure this script is run by bash to prevent mishaps
if [ "$(ps -p "$$" -o comm=)" != "bash" ]; then bash "$0" "$@" ; exit "$?" ; fi
# Make sure only root can run this script
if [[ $EUID -ne 0  ]]; then echo "This script must be run as root" ; exit 1 ; fi
# set default values
CURR_YEAR=$(date +"%Y")			;		TODAY=$(date +"%d-%m-%Y")	;	VERBOSITY=2
LOGDIR="/var/log/plat"			;		SCRIPT_DIR="/etc/plat"
LOGFILE="$LOGDIR/WPinstall_$START_TIME.log"
#MAIL_SCRIPT="$SCRIPT_DIR/mail.sh"	;	MAIL_SCRIPT_TITLE="Email Script"
#ASK_FOR_EMAIL_STUFF=true
#EMAIL_SENDER=false;	EMAIL_RECIPIENT=false;	EMAIL_PASSWORD=false
#COMPUTER_NAME=$(uname -n)

###################### defining functions #####################################
download() { wget -q -a "$LOGFILE" -nv $1; }
install_wp(){
	download "https://wordpress.org/latest.tar.gz"
	###TODO### unpack and install in desired directory
}
