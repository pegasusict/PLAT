#!/usr/bin/bash
#echo "script is not yet complete" ; exit 1
declare -gr START_TIME=$(date +"%Y-%m-%d_%H.%M.%S.%3N")


{ # if run interactive, debugging is switched on
echo $- | grep i
if [[ $? -ne 0 ]]
then
    echo "Running interactive, switching to debug mode"
    declare -gr DEBUGGER=true
    set -o xtrace	# Trace the execution of the script
#    set -o errexit	# Exit on most errors (see the manual)
    set -o errtrace	# Make sure any error trap is inherited
    set -o pipefail	# Use last non-zero exit code in a pipeline
fi
}
{ # Making sure this script is run by bash to prevent mishaps
if [ "$(ps -p "$$" -o comm=)" != "bash" ]
then
    bash "$COMMAND" "$ARGS"
    exit "$?"
fi
# Making sure this script is run by bash 4+
if [ -z "$BASH_VERSION" ] || [ "${BASH_VERSION:0:1}" -lt 4 ]
then
    echo "You need bash v4+ to run this script. Aborting..."
    exit $?
fi
}
{ # Make sure only root can run this script
if [[ $EUID -ne 0 ]]
then
    echo "This script must be run as root / with sudo"
    echo "restarting script with sudo..."
    sudo bash "$COMMAND" "$ARGS"
    exit "$?"
fi
}
unset CDPATH
init() {
    declare -g HEADER="################################################################################\n# Pegasus' Linux Administration Tools - Maintenance Script      Ver1.2.30-BETA #\n# (c)2017-2018 Mattijs Snepvangers    build 20180714     pegasus.ict@gmail.com #\n# This maintenance script is dynamically built          Last build: 15-07-2018 #\n# License: MIT                              Please keep my name in the credits #\n################################################################################\n"
    declare -gr COMMAND="$@"
    declare -gr SCRIPT_FULL=${COMMAND##*/}
    declare -gr CURR_YEAR=$(date +"%Y")
    declare -gr SUITE="Pegasus' Linux Administration Tools"
    declare -gr SCRIPT=$("SCRIPT_FULL%.*")
    declare -gr VER_MAJ=1
    declare -gr VER_MIN=2
    declare -gr VER_PAT=59
    declare -gr VER_ST="BETA"
    declare -gr BLD=20180715
    declare -gr MAINT="Mattijs Snepvangers"
    declare -gr EMAIL="pegasus.ict@gmail.com"
    declare -gr SHORT_VER="$VER_MAJ.$VER_MIN.$VER_PAT-$VER_ST"
    ###
    declare -gr LOG_FILE="/var/log/plat/maintenance_${START_TIME}.log"
    declare -gr SCRIPT_TITLE="Maintenance Script"
    ###
    declare -gr SYS_BIN_DIR="/etc/plat/"
    declare -gr M_SCRIPT="maintenance.sh"
    declare -gr C_SCRIPT="maintenance_container.sh"
    ###
    declare -gr TRASH_AGE=7 ; declare -gr LOG_AGE=30 ; declare -gr TMP_AGE=2
    declare -g ACT_CONT ; ACT_CONT=""
}
#################################################################################
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
##### FUNCTIONS #################################################################
apt_cycle() {
    cr_log_line "Starting Update Process"
    cr_sec_line "Updating apt cache"				; apt-get -qqy update
    cr_sec_line "Fixing any broken dependencies if needed"	; apt-get -qqy --fix-broken install
    cr_sec_line "checking for distribution upgrade"		; apt-get -qqy dist-upgrade
    cr_sec_line "Updating installed packages"			; apt-get -qqy --allow-unauthenticated upgrade
    cr_sec_line "Cleaning up obsolete packages"			; apt-get -qqy auto-remove
    cr_sec_line "Clearing old/obsolete package cache"		; apt-get -qqy autoclean
}
chk_result() { if [[ $1 -gt 0 ]] ; then cr_sec_line "$2" ; fi ; }
cleanup() {
    local _RESULT ; _RESULT=""
    ### GARBAGE ####################################################################
    cr_log_line "Removing files from trash older than $TRASH_AGE days"
    _RESULT=$(trash-empty "$TRASH_AGE")
    chk_result $? "$_RESULT"`
    ###
    cr_log_line "Clearing user cache"
    _RESULT=$(find /home/* -type f \( -name '*.tmp' -o -name '*.temp' -o -name '*.swp' -o -name '*~' -o -name '*.bak' -o -name '..netrwhist' \) -delete)
    chk_result $? "$_RESULT"
    ###
    cr_log_line "Deleting logs older than $LOG_AGE"
    _RESULT=$(find /var/log -name "*.log" -mtime +"$LOG_AGE" -a ! -name "SQLUpdate.log" -a ! -name "updated_days*" -a ! -name "qadirectsvcd*" -exec rm -f {})
    chk_result $? "$_RESULT"
    ###
    cr_log_line "Purging TMP dirs of files unchanged for at least $TRASH_AGE days"
    TMP_DIRS="/tmp /var/tmp" # List of directories to search
    _RESULT=$(find $TMP_DIRS -depth -type f -a -ctime $TRASH_AGE -print -delete)
    chk_result $? "$_RESULT"
    _RESULT=$(find $TMP_DIRS -depth -type l -a -ctime $TRASH_AGE -print -delete)
    chk_result $? "$_RESULT"
    _RESULT=$(find $TMP_DIRS -depth -type f -a -empty -print -delete)
    chk_result $? "$_RESULT"
    _RESULT=$(find $TMP_DIRS -depth -type s -a -ctime $TRASH_AGE -a -size 0 -print -delete)
    chk_result $? "$_RESULT"
    _RESULT=$(find $TMP_DIRS -depth -mindepth 1 -type d -a -empty -a ! -name 'lost+found' -print -delete)
    chk_result $? "$_RESULT"
}
cont_list() {
    cr_log_line "Scanning for containers"
    declare -g ACT_CONT		; declare -g ACT_CONT_CNT
    declare -g INACT_CONT	; declare -g INACT__CONT	; declare -g INACT_CONT_CNT
    #
    local _GREP1	;	local _GREP2
    _GREP1=" | grep -Po \"\b[a-zA-Z][-a-zA-Z0-9]{0,61}[a-zA-Z0-9](?=\s*\| " ; _GREP2=")\"" ; IFS=$'\n'
    #
    ACT_CONT="$(lxc list -c ns | grep -i running)"
    INACT_CONT="$(lxc list -c ns | grep -i stopped)" ; INACT_CONT+="$(lxc list -c ns | grep -i frozen)"
    ACT_CONT=$(echo "${ACT_CONT}${GREP1}RUNNING${_GREP2}")
    INACT__CONT=$(echo "${INACT_CONT}${GREP1}STOPPED${_GREP2}") ; INACT__CONT+=$(echo "${INACT_CONT}${GREP1}FROZEN${_GREP2}")
    INACT_CONT="$_INACT__CONT"		;	unset INACT__CONT
    ACT_CONT_CNT=${#ACT_CONT[@]}	;	INACT_CONT_CNT=${#INACT_CONT[@]}
    #
    if [ $ACT_CONT_CNT -gt 0 ] ; then
        create_sec_line "$ACT_CONT_CNT active containers found:"
        for (( i=0; i<ACT_CONT_CNT; i++ )) ; do create_sec_line "-> ${ACT_CONT[$i]}" ; done
    else create_sec_line "No active containers found" ; fi
    if [ $INACT_CONT_CNT -gt 0 ] ; then
        create_sec_line "$INACT_CONT_CNT inactive containers found:"
        for (( i=0; i<INACT_CONT_CNT; i++ )) ; do create_sec_line "-> ${INACT_CONT[$i]}" ; done
    else create_sec_line "No inactive containers found" ; fi
}
cont_maintenance() {
    cr_log_line "Starting Maintenance on active containers"
    for (( i=0; i<ACT_CONT_CNT; i++ )) ; do
        lxc file push "${SYS_BIN_DIR}${C_SCRIPT}" "${ACT_CONT[$i]}${SYS_BIN_DIR}${M_SCRIPT}"
        lxc exec "${ACT_CONT[$i]}${SYS_BIN_DIR}${M_SCRIPT}"
    done
}
cr_line() {
    local _LEN ; _LEN=$1 ; local _LINE ; _LINE="$2"
    #
    for (( i=${#_LINE}; i<$((_LEN-51));	i+=50 )) ; do _LINE+="############################################################"	; done
    for (( i=${#_LINE}; i<$((_LEN-21));	i+=20 )) ; do _LINE+="####################"						; done
    for (( i=${#_LINE}; i<$((_LEN-11));	i+=10 )) ; do _LINE+="##########"							; done
    for (( i=${#_LINE}; i<$((_LEN-6));	i+=5 ))  ; do _LINE+="#####"								; done
    for (( i=${#_LINE}; i<$((_LEN-1));	i+=2 ))  ; do _LINE+="##"								; done
    for (( i=${#_LINE}; i<$((_LEN-0));	i+1 ))   ; do _LINE+="#"								; done
    echo "$_LINE"
}
cr_log_line() { local _MSG ; _MSG="$1" ; local _LINE ; _LINE="$(get_time) ## $_MSG #" ; _LINE=$(cr_line 80 "$_LINE") ; to_log "$_LINE" ; }
cr_sec_line() { local _MSG ; _MSG="$1" ; local _LINE ; _LINE="# $_MSG #" ; _LINE=$(cr_line 78 "$_LINE") ; to_log "$_LINE" ; }
cr_snapshots() {
    cr_log_line "Creating Snapshots"
    for (( i=0; i<ACT_CONT_CNT; i++ )) ; do
        lxc pause ${ACT_CONT[$i]} ; lxc snapshot "${ACT_CONT[$i]}" "${ACT_CONT[$i]}_$(get_time)" ; lxc start ${ACT_CONT[$i]}
    done
    for (( i=0; i<INACT_CONT_CNT; i++ )) ; do lxc snapshot "${INACT_CONT[$i]}" "${INACT_CONT[$i]}_$(get_time)" ; done
}
get_time(){ echo $(date +"%Y-%m-%d_%H.%M.%S.%3N") ; }
shed_reboot() {
    cr_log_line "sheduling reboot if required"
    if [ -f /var/run/reboot-required ]; then shutdown -r 23:30 ; fi
}
sys_bak() {
    local _OLD_PWD ; _OLD_PWD=$(pwd) ; local _RESULT
    #
    cr_log_line "Perform full system backup to tape"
    _RESULT=$(mt -f /dev/st0 rewind 2>&1) ; check_output $? "$_RESULT" ; _RESULT=""
    cd /
    check_output $(tar -cpzf /dev/st0 -v –exclude=cache –exclude=/dev/ –exclude=/lost+found/ \
    –exclude=/media/ –exclude=/mnt/ –exclude=/proc/ –exclude=/sys/ –exclude=/tmp/ \
    –exclude=/var/cache/apt/ –exclude="$LOG_FILE" 2>&1) ; check_output $? "$_RESULT" ; _RESULT=""
    #mt -f /dev/st0 offline
    cd $_OLD_PWD
}
to_log() { if [[ "$debug" == true ]] ; then echo "$1" | tee -a "$LOG_FILE" ; else echo "$1" >> "$LOG_FILE" ; fi; }

#################################################################################
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#################################################################################
init
to_log $HEADER
cont_list
cr_snapshots
sys_bak
cont_maintenance
cleanup
sh_reboot
cr_log_line "Maintenance Complete"
