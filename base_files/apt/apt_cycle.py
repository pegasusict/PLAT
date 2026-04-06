#!/bin/env python3
################################################################################
# Pegasus' Linux Administration Tools	#			apt-get maintenance script #
# (C)2017-2026 Mattijs Snepvangers		#				 pegasus.ict@gmail.com #
# License: MIT							#	Please keep my name in the credits #
################################################################################
import os
import sys
import subprocess
from datetime import datetime

__version__ = "1.0.0"
__build__ = "2026-03-12"
START_TIME = datetime.now().strftime("%Y-%m-%d_%H.%M.%S.%3N")

if os.geteuid() != 0:
    print("This script must be run as root / with sudo", flush=True)
    print("Restarting with sudo...", flush=True)
    os.execvp("sudo", ["sudo", sys.executable] + sys.argv)


APT = "apt-get"
YES_QUIET = "-qqy"
print(f"{START_TIME} ## Starting Update Process #######################")
print("Updating apt cache")	
subprocess.run([APT, YES_QUIET, "update"], check=True)
print("Fixing any broken dependencies if needed")
subprocess.run([APT, YES_QUIET, "--fix-broken", "install"], check=True)
print("checking for distribution upgrade")
subprocess.run([APT, YES_QUIET, "dist-upgrade"], check=True)
print("Updating installed packages")
subprocess.run([APT, YES_QUIET, "--allow-unauthenticated", "upgrade"], check=True)
print("Cleaning up obsolete packages")
subprocess.run([APT, YES_QUIET, "auto-remove"], check=True)
print("Clearing old/obsolete package cache")
subprocess.run([APT, YES_QUIET, "autoclean"], check=True)


print("checking for reboot requirement")
if os.path.isfile("/var/run/reboot-required"):
    print("REBOOT REQUIRED, sheduled for 23:59")
    subprocess.run(["shutdown", "-r", "23:59"], check=True)
else:
    print("No reboot required")


END_TIME = datetime.now().strftime("%Y-%m-%d_%H.%M.%S.%3N")
print(f"{END_TIME} ## Update Process Finished ########################")
