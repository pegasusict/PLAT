#!/bin/bash
################################################################################
create_logline "Scanning for containers"
active_containers=$(lxc list -c ns | grep -i running)
inactive_containers=$(lxc list -c ns | grep -i stopped)
active_containers=$(echo "$active_containers" | grep -Po "\b[a-zA-Z][-a-zA-Z0-9]{0,61}[a-zA-Z0-9](?=\s*\| RUNNING)")
inactive_containers=$(echo "$inactive_containers" | grep -Po "\b[a-zA-Z][-a-zA-Z]{0,61}[a-zA-Z0-9](?=\s*\| STOPPED)")
IFS=$'\n'
activecontainers=($active_containers)
inactivecontainers=($inactive_containers)
active_containers_found=${#activecontainers[@]}
inactive_containers_found=${#inactivecontainers[@]}
if [ $active_containers_found -gt 0 ];
then
	create_secline "$active_containers_found active containers found:"
	for (( i=0; i<active_containers_found; i++ )) ; do create_secline "-> ${activecontainers[$i]}" ; done
else create_secline "No active containers found"
fi
if [ $inactive_containers_found -gt 0 ];
then create_secline "$inactive_containers_found inactive containers found:"
   for (( i=0; i<inactive_containers_found; i++ )) ; do create_secline "-> ${inactivecontainers[$i]}" ; done
else
   create_secline "No inactive containers found"
fi
################################################################################
create_logline "Creating Snapshots"
for (( i=0; i<active_containers_found; i++ ))
do
	lxc pause ${activecontainers[$i]};
	lxc snapshot "${activecontainers[$i]}" "${activecontainers[$i]}_$(getthetime)"
    lxc start ${activecontainers[$i]}
done
for (( i=0; i<inactive_containers_found; i++ ))
do
	lxc snapshot "${inactivecontainers[$i]}" "${inactivecontainers[$i]}_$(getthetime)"
done
