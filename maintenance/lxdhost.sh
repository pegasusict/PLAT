#!/bin/bash
################################################################################
## Pegasus' Linux Administration Tools                             VER0.6BETA ##
## (C)2017 Mattijs Snepvangers                          pegasus.ict@gmail.com ##
## pegs_postinstall_srv.sh    postinstall script server edition    VER0.6BETA ##
## License: GPL v3                         Please keep my name in the credits ##
################################################################################

# Make sure only root can run this script
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

_now=$(date +"%Y-%m-%d_%H.%M.%S.%3N")
PEGS_LOGFILE="/var/log/pegsPostInstall_$_now.log"

printf "################################################################################\n" 2>&1 | tee -a $PEGS_LOGFILE
printf "## Pegasus' Linux Administration Tools - LXDhost Maintenance Script  V0.1Beta ##\n" 2>&1 | tee -a $PEGS_LOGFILE
printf "## (c) 2017 Mattijs Snepvangers                         pegasus.ict@gmail.com ##\n" 2>&1 | tee -a $PEGS_LOGFILE
printf "################################################################################\n" 2>&1 | tee -a $PEGS_LOGFILE
printf "\n" 2>&1 | tee -a $PEGS_LOGFILE

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
                    working on
                    valid options are: basic, nas, web, x11, pxe
            EOF
            return;
        };
        [[ $1 == -- ]] && { shift; break; };
        [[ $1 =~ ^-r|--role$ ]] && { role="${2}"; shift 2; continue; };
        [[ $1 =~ ^-c|--containertype$ ]] && { container="${2}"; shift 2; continue; };
        break
    done
    tput -S <<<"$script";
    $clear;
}
