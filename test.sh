#!/bin/bash
create_logline() {
   _timestamp=$(date +"%Y-%m-%d_%H.%M.%S,%3N")
   _log_line="$_timestamp ## $1 #"
   imax=80
   for (( i=${#_log_line}; i<imax; i++ ))
   do
       _log_line+="#"
   done
   echo $_log_line 2>&1 | tee -a $PLAT_LOGFILE
}
create_secline() {
   _log_line="# $1 #"
   imax=78
   for (( i=${#_log_line}; i<imax; i+=2 ))
   do
       _log_line="#$_log_line#"
   done
   echo $_log_line 2>&1 | tee -a $PLAT_LOGFILE
}
create_logline "testing"
create_secline "Once Upon a Time"
