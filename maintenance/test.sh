#!/bin/bash

_timestamp=$(date +"%Y-%m-%d_%H.%M.%S,%3N")
_logline="########## $_timestamp-1/10 ###### Scanning for containers #####################"
echo $_logline 2>&1 | tee -a $PLAT_LOGFILE
active_containers=$(lxc list -c ns | grep -i running)
inactive_containers=$(lxc list -c ns | grep -i stopped)
active_containers=$(echo "$active_containers" | grep -Po "\b[a-zA-Z][-a-zA-Z]{0,61}[a-zA-Z0-9](?=\s*\| RUNNING)")
inactive_containers=$(echo "$inactive_containers" | grep -Po "\b[a-zA-Z][-a-zA-Z]{0,61}[a-zA-Z0-9](?=\s*\| STOPPED)")
IFS=$'\n'
activecontainers=($active_containers)
inactivecontainers=($inactive_containers)
active_containers_found=${#activecontainers[@]}
inactive_containers_found=${#inactivecontainers[@]}
if [ $active_containers_found -gt 0 ];
then
   echo "$active_containers_found active containers found:"
   for (( i=0; i<${active_containers_found}; i++ ));
   do
      echo "-> ${activecontainers[$i]}"
   done
else
   echo "No active containers found"
fi
if [ $inactive_containers_found -gt 0 ];
then
   echo "$inactive_containers_found inactive containers found:"
   for (( i=0; i<${inactive_containers_found}; i++ ));
   do
      echo "-> ${inactivecontainers[$i]}"
   done
else
   echo "No inactive containers found"
fi
