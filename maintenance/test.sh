#!/bin/bash

_timestamp=$(date +"%Y-%m-%d_%H.%M.%S,%3N")
_logline="########## $_timestamp-1/10 ###### Scanning for containers #####################"
echo $_logline 2>&1 | tee -a $PLAT_LOGFILE
active_containers=$(lxc list -c ns | grep -i running)
inactive_containers=$(lxc list -c ns | grep -i stopped)
active_containers=$(echo "$active_containers" | grep -Po "\b[a-zA-Z][-a-zA-Z]{0,61}[a-zA-Z0-9](?=\s*\| RUNNING)")
inactive_containers=$(echo "$inactive_containers" | grep -Po "\b[a-zA-Z][-a-zA-Z]{0,61}[a-zA-Z0-9](?=\s*\| STOPPED)")

echo "test result:"
echo "$active_containers"
#####################################################################
active_containers=readarray -t y <<<"$active_containers"
echo "$active_containers[0]"
echo "====================="
echo "$active_containers[1]"
echo "====================="
