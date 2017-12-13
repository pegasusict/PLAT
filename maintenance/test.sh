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
active_containers=$(echo "$active_containers" | grep -Po "\b[a-zA-Z0-9][-a-zA-Z]{0,61}[a-zA-Z0-9](?=\s*\| RUNNING)")
inactive_containers=$(echo $"inactive_containers" | grep -Po "\b[a-zA-Z0-9][-a-zA-Z]{0,61}[a-zA-Z0-9](?=\s*\| STOPPED)")
################################################################################
_timestamp=$(date +"%Y-%m-%d_%H.%M.%S,%3N")
_logline="########## $_timestamp-2/10 ###### Containers found: ###########################"
echo $_logline 2>&1 | tee -a $PLAT_LOGFILE
active_containers_found = 0
inactive_containers_found = 0
for (( i=0; i<${#active_containers[@]}; i++ ))
do
    echo "Active Container $i: ${active_containers[$i]}"
    active_containers_found++
done
echo "found $active_containers_found active containers."
for (( i=0; i<${#inactive_containers[@]}; i++ ))
do
    echo "Inactive Container $i: ${inactive_containers[$i]}"
    inactive_containers_found++
done
echo "found $inactive_containers_found inactive containers."
