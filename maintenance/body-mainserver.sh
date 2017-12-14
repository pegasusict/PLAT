################################################################################
_timestamp=$(date +"%Y-%m-%d_%H.%M.%S,%3N")
_logline="########## $_timestamp-1/10 ###### Scanning for containers #####################"
echo $_logline 2>&1 | tee -a $PLAT_LOGFILE
active_containers=$(lxc list -c ns | grep -i running)
inactive_containers=$(lxc list -c ns | grep -i stopped)
active_containers=$(echo "$active_containers" | grep -Po "\b[a-zA-Z][-a-zA-Z0-9]{0,61}[a-zA-Z0-9](?=\s*\| RUNNING)")
inactive_containers=$(echo "$inactive_containers" | grep -Po "\b[a-zA-Z][-a-zA-Z]{0,61}[a-zA-Z0-9](?=\s*\| STOPPED)")
IFS=$'\n'
activecontainers=($active_containers)
inactivecontainers=($inactive_containers)
active_containers_found=${#activecontainers[@]}
inactive_containers_found=${#inactivecontainers[@]}
################################################################################
_timestamp=$(date +"%Y-%m-%d_%H.%M.%S,%3N")
_logline="########## $_timestamp-2/10 ###### Containers found: ###########################"
echo $_logline 2>&1 | tee -a $PLAT_LOGFILE
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
################################################################################
_timestamp=$(date +"%Y-%m-%d_%H.%M.%S,%3N")
_logline="########## $_timestamp-1/10 ###### creating snapshots ##########################"
echo $_logline 2>&1 | tee -a $PLAT_LOGFILE
#lxc  2>&1 | tee -a $PLAT_LOGFILE
for (( i=0; i<active_containers_found; i++ ));
do
    lxc pause ${activecontainers[$i]}
    lxc snapshot "${activecontainers[$i]}" "${activecontainers[$i]}_$_timestamp"
    lxc start ${activecontainers[$i]}
done
for (( i=0; i<inactive_containers_found; i++ ))
do
    lxc snapshot "${inactivecontainers[$i]}" "${inactivecontainers[$i]}_$_timestamp"
done
################################################################################
_timestamp=$(date +"%Y-%m-%d_%H.%M.%S,%3N")
_logline="########## $_timestamp-2/10 ###### full system backup ##########################"
echo $_logline 2>&1 | tee -a $PLAT_LOGFILE
mt -f /dev/st0 rewind 2>&1 | tee -a $PLAT_LOGFILE
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
 2>&1 | tee -a $PLAT_LOGFILE
 mt -f /dev/st0 offline
 cd $oldpwd
################################################################################
_timestamp=$(date +"%Y-%m-%d_%H.%M.%S,%3N")
_logline="########## $_timestamp-3/10 ###### Starting Maintenance scripts on containers ##"
echo $_logline 2>&1 | tee -a $PLAT_LOGFILE
for (( i=0; i<${active_containers_found}; i++ ));
do
    lxc file push maintenance/plat_maintenance_container.sh ${activecontainers[$i]}/etc/plat_maintenance.sh
    lxc exec ${activecontainers[$i]} /etc/plat_maintenance.sh
done
################################################################################
_timestamp=$(date +"%Y-%m-%d_%H.%M.%S,%3N")
_logline="########## $_timestamp-4/10 ###### Updating apt cache ##########################"
echo $_logline 2>&1 | tee -a $PLAT_LOGFILE
apt-get -qqy update 2>&1 | tee -a $PLAT_LOGFILE
################################################################################
_timestamp=$(date +"%Y-%m-%d_%H.%M.%S,%3N")
_logline="########## $_timestamp-5/10 ###### Updating installed packages #################"
echo $_logline 2>&1 | tee -a $PLAT_LOGFILE
apt-get -qqy --allow-unauthenticated upgrade 2>&1 | tee -a $PLAT_LOGFILE
################################################################################
_timestamp=$(date +"%Y-%m-%d_%H.%M.%S,%3N")
_logline="########## $_timestamp-6/10 ###### Cleaning up obsolete packages ###############"
echo $_logline 2>&1 | tee -a $PLAT_LOGFILE
apt-get -qqy autoremove 2>&1 | tee -a $PLAT_LOGFILE
################################################################################
_timestamp=$(date +"%Y-%m-%d_%H.%M.%S,%3N")
_logline="########## $_timestamp-7/10 ###### Purging apt package cache ###################"
echo $_logline 2>&1 | tee -a $PLAT_LOGFILE
apt-get -qqy clean 2>&1 | tee -a $PLAT_LOGFILE
################################################################################
_timestamp=$(date +"%Y-%m-%d_%H.%M.%S,%3N")
_logline="########## $_timestamp-8/10 ###### Emptying the trash ##########################"
echo $_logline 2>&1 | tee -a $PLAT_LOGFILE
trash-empty 2>&1 | tee -a $PLAT_LOGFILE
################################################################################
_timestamp=$(date +"%Y-%m-%d_%H.%M.%S,%3N")
_logline="########## $_timestamp-9/10 ###### Clearing user cache #########################"
echo $_logline 2>&1 | tee -a $PLAT_LOGFILE
find /home/* -type f \( -name '*.tmp' -o -name '*.temp' -o -name '*.swp' -o -name '*~' -o -name '*.bak' -o -name '..netrwhist' \) -delete 2>&1 | tee -a $PLAT_LOGFILE
################################################################################
_timestamp=$(date +"%Y-%m-%d_%H.%M.%S,%3N")
_logline="########## $_timestamp 10/10 ##### Deleting old logs ###########################"
echo $_logline 2>&1 | tee -a $PLAT_LOGFILE
find /var/log -name "*.log" -mtime +30 -a ! -name "SQLUpdate.log" -a ! -name "updated_days*" -a ! -name "qadirectsvcd*" -exec rm -f {} \;  2>&1 | tee -a $PLAT_LOGFILE
################################################################################
_timestamp=$(date +"%Y-%m-%d_%H.%M.%S,%3N")
_logline="########## $_timestamp-11/12 ##### Purging TMP directories #####################"
echo $_logline 2>&1 | tee -a $PLAT_LOGFILE
# CRUNCHIFY_TMP_DIRS - List of directories to search
CRUNCHIFY_TMP_DIRS="/tmp /var/tmp"
# DEFAULT_FILE_AGE - # days ago (rounded up) that file was last accessed
DEFAULT_FILE_AGE=+2
# DEFAULT_LINK_AGE - # days ago (rounded up) that symlink was last accessed
DEFAULT_LINK_AGE=+2
# DEFAULT_SOCK_AGE - # days ago (rounded up) that socket was last accessed
DEFAULT_SOCK_AGE=+2
find $CRUNCHIFY_TMP_DIRS -depth -type f -a -ctime $DEFAULT_FILE_AGE -print -delete 2>&1 | tee -a $PLAT_LOGFILE
find $CRUNCHIFY_TMP_DIRS -depth -type l -a -ctime $DEFAULT_LINK_AGE -print -delete 2>&1 | tee -a $PLAT_LOGFILE
find $CRUNCHIFY_TMP_DIRS -depth -type f -a -empty -print -delete 2>&1 | tee -a $PLAT_LOGFILE
find $CRUNCHIFY_TMP_DIRS -depth -type s -a -ctime $DEFAULT_SOCK_AGE -a -size 0 -print -delete 2>&1 | tee -a $PLAT_LOGFILE
find $CRUNCHIFY_TMP_DIRS -depth -mindepth 1 -type d -a -empty -a ! -name 'lost+found' -print -delete 2>&1 | tee -a $PLAT_LOGFILE
################################################################################
_timestamp=$(date +"%Y-%m-%d_%H.%M.%S,%3N")
_logline="########## $_timestamp 12/12 ##### Retrieving logs from containers #############"
echo $_logline 2>&1 | tee -a $PLAT_LOGFILE
for (( i=0; i<${active_containers_found}; i++ ));
do
    lxc file pull ${activecontainers[$i]}/var/log/plat/* maintenance/logs/
done
_timestamp=$(date +"%Y-%m-%d_%H.%M.%S,%3N")
_logline="########## $_timestamp ###### Maintenance complete #############################"
echo $_logline 2>&1 | tee -a $PLAT_LOGFILE
###TODO### send email with logs attached
