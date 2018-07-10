#!/bin/bash
################################################################################
create_logline "Starting Maintenance on containers"
for (( i=0; i<active_containers_found; i++ ))
do
    lxc file push maintenance/maintenance-container.sh ${activecontainers[$i]}/etc/plat/
    lxc file push mail.sh ${activecontainers[$i]}/etc/plat/
    lxc exec ${activecontainers[$i]} /etc/plat/maintenance.sh
done
