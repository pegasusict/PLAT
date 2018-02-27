#!/usr/bin/bash
################################################################################
## Pegasus' Linux Administration Tools                             VER1.0BETA ##
## (C)2017 Mattijs Snepvangers                          pegasus.ict@gmail.com ##
## plat_mail.sh                            mail script             VER1.0BETA ##
##                This mail script is dynamically built by plat.sh            ##
## License: GPL v3                         Please keep my name in the credits ##
################################################################################

# Making sure this script is run by bash to prevent mishaps
if [ "$(ps -p "$$" -o comm=)" != "bash" ]; then
    bash "$0" "$@"
    exit "$?"
fi

# Define sender's detail  email ID
