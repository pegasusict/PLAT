#!/bin/bash
################################################################################
create_logline "Starting Maintenance on containers"
for (( i=0; i<active_containers_found; i++ ));
do
    lxc file push maintenance/containers/* ${activecontainers[$i]}/etc/plat/
    lxc exec ${activecontainers[$i]} /etc/plat/maintenance.sh
done
