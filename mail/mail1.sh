#!/usr/bin/bash
##                This mail script is dynamically built by plat.sh            ##
## License: GPL v3                         Please keep my name in the credits ##
################################################################################

# Making sure this script is run by bash to prevent mishaps
if [ "$(ps -p "$$" -o comm=)" != "bash" ]; then bash "$0" "$@"; exit "$?"; fi
