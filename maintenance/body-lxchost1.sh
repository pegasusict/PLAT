#!/bin/bash
################################################################################
info_line "Starting maintenance on containers"
for (( i=0; i<active_containers_found; i++ ))
do
    lxc file push maintenance/maintenance-container.sh ${active_containers[$i]}/etc/plat/
#    lxc file push mail.sh ${active_containers[$i]}/etc/plat/
    lxc exec ${active_containers[$i]} /etc/plat/maintenance.sh
done
