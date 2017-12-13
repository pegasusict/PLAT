#!/bin/bash
#active_containers="$(lxc list -c ns | grep -i running)"
#echo $active_containers
#findcontainers='\b(a-zA-Za-zA-Z0-9\-{,61}a-zA-Z0-9)\b'
#echo $active_containers | sed -e "$findcontainers"

#echo "$active_containers" | grep -Po "\b[a-zA-Z0-9][-a-zA-Z0-9]{1,61}[a-zA-Z0-9](?=\s*\| RUNNING)"

################################################################################
_timestamp=$(date +"%Y-%m-%d_%H.%M.%S,%3N")
_logline="########## $_timestamp-1/10 ###### Scanning for containers #####################"
echo $_logline 2>&1 | tee -a $PLAT_LOGFILE
active_containers=$(lxc list -c ns | grep -i running)
inactive_containers=$(lxc list -c ns | grep -i stopped)
active_containers=$(echo "$active_containers" | grep -Po "\b[a-zA-Z][-a-zA-Z]{0,61}[a-zA-Z0-9](?=\s*\| RUNNING)")
inactive_containers=$(echo "$inactive_containers" | grep -Po "\b[a-zA-Z][-a-zA-Z]{0,61}[a-zA-Z0-9](?=\s*\| STOPPED)")

echo "test result:"
echo "$active_containers"