#!/bin/bash
################################################################################
## Pegasus' Linux Administration Tools                             VER0.6BETA ##
## (C)2017 Mattijs Snepvangers                          pegasus.ict@gmail.com ##
## container_builder.sh        container builder                   VER0.6BETA ##
## License: GPL v3                         Please keep my name in the credits ##
################################################################################
# Make sure only root can run this script
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi
# define constants
declare -r TRUE=0
declare -r FALSE=1
################################################################################
_now=$(date +"%Y-%m-%d_%H.%M.%S.%3N")
PLAT_LOGFILE="/var/log/plat/ContainerBuilder_$_now.log"
echo "################################################################################" 2>&1 | tee -a $PLAT_LOGFILE
echo "## Pegasus' Linux Administration Tools - Container Builder           V1.0Beta ##" 2>&1 | tee -a $PLAT_LOGFILE
echo "## (c) 2017 Mattijs Snepvangers    build 20171214       pegasus.ict@gmail.com ##" 2>&1 | tee -a $PLAT_LOGFILE
echo "################################################################################" 2>&1 | tee -a $PLAT_LOGFILE
echo "" 2>&1 | tee -a $PLAT_LOGFILE

getargs() {
   TEMP=`getopt -o hn:c: --long help,name:,containertype: -n "$FUNCNAME" -- "$@"`
   if [ $? != 0 ] ; then return 1 ; fi
   eval set -- "$TEMP";
   local format='%s\n' escape='-E' line='-n' script clear='tput sgr0';
   while [[ ${1:0:1} == - ]]; do
      [[ $1 =~ ^-h|--help ]] && {
         cat <<-EOF
         USAGE:

         OPTIONS

           -n or --name tells the script what name the container needs to have.
              Valid options: max 63 chars: -, a-z, A-Z, 0-9
                             name may not start or end with a dash "-"
                             name may not start with a digit "0-9"
           -c or --containertype tells the script what kind of container we are working on.
              Valid options are: basic, nas, web, x11, pxe
EOF
         return;
      };
      [[ $1 == -- ]] && { shift; break; };
      [[ $1 =~ ^-n|--name$ ]] && { name="${2}"; shift 2; continue; };
      [[ $1 =~ ^-c|--containertype$ ]] && { containertype="${2}"; shift 2; continue; };
      break;
   done
   tput -S <<<"$script";
   $clear;
}
################################################################################
getargs()
checkname(contname) {
   filteredname=$(echo "$contname" | grep -Po "^[a-zA-Z][-a-zA-Z0-9]{0,61}[a-zA-Z0-9]$")
   if [$filteredname != $contname];
   then
      cat <<- EOF
I'm sorry, the name you proposed is invalid, please enter a valid name:
    > max 63 chars: -, a-z, A-Z, 0-9
    > name may not start or end with a dash "-"
    > name may not start with a digit "0-9""
EOF
###TODO### re indent EOF when done if needed
      return $FALSE
   else
      return $TRUE
   fi
}
#   read name
case "$containertype" in
   "nas" )
      systemrole[nas] = true
      ;;
   "web" )
      systemrole[nas] = true
      systemrole[web] = true
      ;;
   "x11" )
      systemrole[ws] = true
      ;;
   "pxe" )
      systemrole[nas] = true
      systemrole[pxe] = true
      ;;
   * )
      systemrole[basic] = true
      ;;
esac

print $systemrole
