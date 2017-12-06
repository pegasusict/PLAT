#!/bin/bash
################################################################################
## Pegasus' Linux Administration Tools                             VER1.0BETA ##
## (C)2017 Mattijs Snepvangers                          pegasus.ict@gmail.com ##
## pegs_postinstall_srv.sh    postinstall script                   VER1.0BETA ##
## License: GPL v3                         Please keep my name in the credits ##
################################################################################

# Make sure only root can run this script
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

_now=$(date +"%Y-%m-%d_%H.%M.%S.%3N")
PLAT_LOGFILE="/var/log/pegsPostInstall_$_now.log"
printf "################################################################################\n" 2>&1 | tee -a $PLAT_LOGFILE
printf "## Pegasus' Linux Administration Tools - Post Install Script         V1.0Beta ##\n" 2>&1 | tee -a $PLAT_LOGFILE
printf "## (c) 2017 Mattijs Snepvangers                         pegasus.ict@gmail.com ##\n" 2>&1 | tee -a $PLAT_LOGFILE
printf "################################################################################\n" 2>&1 | tee -a $PLAT_LOGFILE
printf "\n" 2>&1 | tee -a $PLAT_LOGFILE

getargs() {
    TEMP=`getopt -o hr:c: --long help,role:,containertype: -n "$FUNCNAME" -- "$@"`
    if [ $? != 0 ] ; then return 1 ; fi
    eval set -- "$TEMP";
    local format='%s\n' escape='-E' line='-n' script clear='tput sgr0';
    while [[ ${1:0:1} == - ]]; do
        [[ $1 =~ ^-h|--help ]] && {
            cat <<-EOF
            USAGE:

            OPTIONS

              -r or --role tells the script what kind of system we're dealing with
                    valid options: basic, ws, zeus, lxdhost, container
              -c or --containertype tells the script what kind of container we're
                    working on.
                    valid options are: basic, nas, web, x11, pxe
EOF
###TODO### re indent EOF when done
            return;
        };
        [[ $1 == -- ]] && { shift; break; };
        [[ $1 =~ ^-r|--role$ ]] && { role="${2}"; shift 2; continue; };
        [[ $1 =~ ^-c|--containertype$ ]] && { container="${2}"; shift 2; continue; };
        break;
    done
    tput -S <<<"$script";
    $clear;
}


# Install extra ppa's
_timestamp=$(date +"%Y-%m-%d_%H.%M.%S,%3N")
_logline="$_timestamp-1/7 ###### installing extra PPA's #############################"
echo $_logline 2>&1 | tee -a $PLAT_LOGFILE
echo "copying PPA list."
cp apt/plat.list /etc/apt/sources.list.d/
bash apt/plat_ppa_keys_importer.sh 2>&1 | tee -a $PLAT_LOGFILE

######################################################
_timestamp=$(date +"%Y-%m-%d_%H.%M.%S,%3N")
_logline="$_timestamp-2/7 ###### Updating apt cache #################################"
echo $_logline 2>&1 | tee -a $PLAT_LOGFILE
apt-get -qqy update 2>&1 | tee -a $PLAT_LOGFILE

######################################################
_timestamp=$(date +"%Y-%m-%d_%H.%M.%S,%3N")
_logline="$_timestamp-3/7 ###### installing updates #################################"
echo $_logline 2>&1 | tee -a $PLAT_LOGFILE
apt-get -qqy --allow-unauthenticated upgrade 2>&1 | tee -a $PLAT_LOGFILE

######################################################
_timestamp=$(date +"%Y-%m-%d_%H.%M.%S,%3N")
_logline="$_timestamp-4/7 ###### installing extra packages ##########################"
echo $_logline 2>&1 | tee -a $PLAT_LOGFILE
apt-get -qqy --allow-unauthenticated install mc trash-cli python3-crontab lxc lxd lxd-tools bridge-utils xfsutils-linux criu 2>&1 | tee -a $PLAT_LOGFILE  2>&1

######################################################
_timestamp=$(date +"%Y-%m-%d_%H.%M.%S,%3N")
_logline="$_timestamp-5/7 ###### cleaning up obsolete packages ######################"
echo $_logline 2>&1 | tee -a $PLAT_LOGFILE
apt-get -qqy autoremove 2>&1 | tee -a $PLAT_LOGFILE

######################################################
_timestamp=$(date +"%Y-%m-%d_%H.%M.%S,%3N")
_logline="$_timestamp-6/7 ###### installing extra software ##########################"
echo $_logline 2>&1 | tee -a $PLAT_LOGFILE
### teamviewer
 wget -nv https://download.teamviewer.com/download/teamviewer_i386.deb 2>&1 | tee -a $PLAT_LOGFILE
gdebi -n teamviewer_i386.deb 2>&1 | tee -a $PLAT_LOGFILE
rm teamviewer_i386.deb 2>&1 | tee -a $PLAT_LOGFILE
apt-get install -f 2>&1 | tee -a $PLAT_LOGFILE

######################################################
_timestamp=$(date +"%Y-%m-%d_%H.%M.%S,%3N")
_logline="$_timestamp-7/7 ###### Adding maintenance script to crontab ###############"
echo $_logline 2>&1 | tee -a $PLAT_LOGFILE
cp pegs_maintenance.sh /etc/pegs_maintenance.sh
chmod 555 /etc/pegs_maintenance.sh
chown root:root /etc/pegs_maintenance.sh
echo -e "\n### Added by Pegs Linux Administration Tools ###\n0 * * 4 0 bash /etc/pegs_maintenance.sh\n\n" >> /etc/crontab

######################################################
_timestamp=$(date +"%Y-%m-%d_%H.%M.%S,%3N")
_logline="$_timestamp ###### DONE ###################################################"
echo $_logline 2>&1 | tee -a $PLAT_LOGFILE
