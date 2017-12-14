#!/bin/bash

create_logline(title) {
   _timestamp=$(date +"%Y-%m-%d_%H.%M.%S,%3N")
   _log_line = "$_timestamp ## $title #"
   chrlen=${#_log_line}
   imax = 80
   for (( i=${#_log_line}; i<imax; i++ ))
   do
       _log_line = _log_line + "#"
   done
   echo $_log_line 2>&1 | tee -a $PLAT_LOGFILE
   }

logline"Testing..."
create_logline($logline)
