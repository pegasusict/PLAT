#!/bin/bash

# scan for active & inactive containers
###CHECK###
containers = "${ lxc list | grep active }"


# for each active container:
    ### apt update
    ### apt upgrade
    ### apt auto-remove
    ### apt purge
    ### apt auto clean
    ### purge cache/tmp/logs/trash

# for each container: create snapshot
