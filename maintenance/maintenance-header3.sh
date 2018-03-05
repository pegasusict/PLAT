#!/bin/bash
echo "################################################################################" 2>&1 | tee -a $PLAT_LOGFILE
echo "" 2>&1 | tee -a $PLAT_LOGFILE
getthetime(){ echo $(date +"%Y-%m-%d_%H.%M.%S.%3N") ; }
create_logline() {
   _log_line="$(getthetime) ## $loglinetitle #"
   imax=80
   for (( i=${#_log_line}; i<$imax; i++ ))
   do _log_line+="#" ; done
   echo $_log_line 2>&1 >> $PLAT_LOGFILE
}
create_secline() {
   _log_line="# $loglinetitle #"
   imax=78
   for (( i=${#_log_line}; i<$imax; i+=2 ))
   do _log_line="#$_log_line#" ; done
   echo $_log_line 2>&1 >> $PLAT_LOGFILE
}
