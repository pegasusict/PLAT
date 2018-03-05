#!/bin/bash
################################################################################
create_logline "Full System Backup to tape"
mt -f /dev/st0 rewind 2>&1 >> $PLAT_LOGFILE
oldpwd=$(pwd)
cd /
sudo tar -cpzf /dev/st0
-v
–exclude=cache
–exclude=/dev/*
–exclude=/lost+found/*
–exclude=/media/*
–exclude=/mnt/*
–exclude=/proc/*
–exclude=/sys/*
–exclude=/tmp/*
–exclude=/var/cache/apt/*
–exclude="$PLAT_LOGFILE" /
2>&1 >> $PLAT_LOGFILE
mt -f /dev/st0 offline
cd $oldpwd
