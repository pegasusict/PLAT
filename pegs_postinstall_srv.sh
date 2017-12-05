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
echo "################################################################################\n" 2>&1 | tee -a $PEGS_LOGFILE
echo "## Pegasus' Linux Administration Tools - Post Install Script         V0.6Beta ##\n" 2>&1 | tee -a $PEGS_LOGFILE
echo "## (c) 2017 Mattijs Snepvangers                         pegasus.ict@gmail.com ##\n" 2>&1 | tee -a $PEGS_LOGFILE
echo "################################################################################\n" 2>&1 | tee -a $PEGS_LOGFILE
echo "\n" 2>&1 | tee -a $PEGS_LOGFILE

printfx() {

    TEMP=`getopt -o hbrkwels:c:v:f:p: --long help,write,keep,reset,bold,format:,script:,color:,print: -n "$FUNCNAME" -- "$@"`

    if [ $? != 0 ] ; then return 1 ; fi

    eval set -- "$TEMP";

    local format='%s\n' escape='-E' line='-n' script clear='tput sgr0';

    while [[ ${1:0:1} == - ]]; do
        [[ $1 =~ ^-h|--help ]] && {
            cat <<-EOF
            USAGE: $FUNCNAME [OPTIONS] [TEXT]

            OPTIONS

              -s  Adds a line of text to tput script
              -c  Adds a line of text to tput script that sets the foreground
                  color
              -b  Adds a line of text to tput script that activates emboldened
                  text
              -f  Sets the final printf format
              -w  Forces an immediate write of tput script
              -p  Immediately prints data to standard out
              -e  Enabled backslash interpretation in immediate print operations
              -l  Enables line output in immediate print operations
              -k  disables terminal reset on return
              -r  Forces an immediate reset of terminal settings
              -v  Adds multiple lines of script from a shell variable label

              --script  Same as -s
              --color   Same as -c
              --bold    Same as -b
              --format  Same as -f
              --write   Same as -w
              --print   Same as -p
              --keep    Same as -k
              --reset   Same as -r

            EOF
            return;
        };

        [[ $1 == -- ]] && { shift; break; };
        [[ $1 == -l ]] && { line=''; shift 1; continue; };
        [[ $1 =~ ^-s|--script$ ]] && { script+="$2"$'\n'; shift 2; continue; };
        [[ $1 =~ ^-c|--color$ ]] && { script+="setf $2"$'\n'; shift 2; continue; };
        [[ $1 =~ ^-b|--bold$ ]] && { script+="bold"$'\n'; shift 1; continue; };
        [[ $1 =~ ^-f|--format$ ]] && { format="${2}"; shift 2; continue; };
        [[ $1 =~ ^-w|--write$ ]] && { tput -S <<<"$script"; script=''; shift 1; continue; };
        [[ $1 =~ ^-p|--print$ ]] && { echo $escape $line "${2}"; escape='-E' line='-n'; shift 2; continue; };
        [[ $1 =~ ^-k|--keep$ ]] && { clear='true'; shift 1; continue; };
        [[ $1 =~ ^-r|--reset$ ]] && { tput sgr0; shift 1; continue; };
        [[ $1 =~ ^-v ]] && { script+="${!2}"$'\n'; shift 2; continue; };
        [[ $1 =~ ^-e ]] && { escape=$1; shift 1; continue; };

        break;
    done

    echo $format;
    tput -S <<<"$script";
    (( $# )) && printf "$format" "$@";
    $clear;

}


# Install extra ppa's
_timestamp=$(date +"%Y-%m-%d_%H.%M.%S,%3N")
_logline="$_timestamp-1/7 ###### installing extra PPA's #############################"
echo $_logline 2>&1 | tee -a $PEGS_LOGFILE
echo 'deb http://archive.ubuntu.com/ubuntu main restricted universe multiverse proposed backports' >> /tmp/pegsaddition.list
sudo cp /tmp/pegsaddition.list /etc/apt/sources.list.d/
rm /tmp/pegsaddition.list
#add-apt-repository -y ppa:juju/stable >>"$PEGS_LOGFILE" 2>&1
#add-apt-repository -y ppa:landscape/17.03 >>"$PEGS_LOGFILE" 2>&1

######################################################
_timestamp=$(date +"%Y-%m-%d_%H.%M.%S,%3N")
_logline="$_timestamp-2/7 ###### Updating apt cache #################################"
echo $_logline 2>&1 | tee -a $PEGS_LOGFILE
apt-get -qqy update 2>&1 | tee -a $PEGS_LOGFILE

######################################################
_timestamp=$(date +"%Y-%m-%d_%H.%M.%S,%3N")
_logline="$_timestamp-3/7 ###### installing updates #################################"
echo $_logline 2>&1 | tee -a $PEGS_LOGFILE
apt-get -qqy --allow-unauthenticated upgrade 2>&1 | tee -a $PEGS_LOGFILE

######################################################
_timestamp=$(date +"%Y-%m-%d_%H.%M.%S,%3N")
_logline="$_timestamp-4/7 ###### installing extra packages ##########################"
echo $_logline 2>&1 | tee -a $PEGS_LOGFILE
apt-get -qqy --allow-unauthenticated install mc trash-cli python3-crontab lxc lxd lxd-tools bridge-utils xfsutils-linux criu 2>&1 | tee -a $PEGS_LOGFILE  2>&1

######################################################
_timestamp=$(date +"%Y-%m-%d_%H.%M.%S,%3N")
_logline="$_timestamp-5/7 ###### cleaning up obsolete packages ######################"
echo $_logline 2>&1 | tee -a $PEGS_LOGFILE
apt-get -qqy autoremove 2>&1 | tee -a $PEGS_LOGFILE

######################################################
_timestamp=$(date +"%Y-%m-%d_%H.%M.%S,%3N")
_logline="$_timestamp-6/7 ###### installing extra software ##########################"
echo $_logline 2>&1 | tee -a $PEGS_LOGFILE
### teamviewer
 wget -nv https://download.teamviewer.com/download/teamviewer_i386.deb 2>&1 | tee -a $PEGS_LOGFILE
gdebi -n teamviewer_i386.deb 2>&1 | tee -a $PEGS_LOGFILE
rm teamviewer_i386.deb 2>&1 | tee -a $PEGS_LOGFILE
apt-get install -f 2>&1 | tee -a $PEGS_LOGFILE

######################################################
_timestamp=$(date +"%Y-%m-%d_%H.%M.%S,%3N")
_logline="$_timestamp-7/7 ###### Adding maintenance script to crontab ###############"
echo $_logline 2>&1 | tee -a $PEGS_LOGFILE
cp pegs_maintenance.sh /etc/pegs_maintenance.sh
chmod 555 /etc/pegs_maintenance.sh
chown root:root /etc/pegs_maintenance.sh
echo -e "\n### Added by Pegs Linux Administration Tools ###\n0 * * 4 0 bash /etc/pegs_maintenance.sh\n\n" >> /etc/crontab

######################################################
_timestamp=$(date +"%Y-%m-%d_%H.%M.%S,%3N")
_logline="$_timestamp ###### DONE ###################################################"
echo $_logline 2>&1 | tee -a $PEGS_LOGFILE
