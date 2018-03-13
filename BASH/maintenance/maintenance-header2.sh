#!/bin/bash
create_logline() {
	_loglinetitle=$1
	_log_line="$(getthetime) ## $loglinetitle #"
	imax=80
	for (( i=${#_log_line}; i<imax; i++ ))
	do _log_line+="#" ; done
	tolog $_log_line
}
create_secline() {
	_sec_line="# $seclinetitle #"
	imax=78
	for (( i=${#_log_line}; i<imax; i+=2 ))
	do _log_line="#$_log_line#" ; done
	tolog $_log_line
}
getthetime(){ echo $(date +"%Y-%m-%d_%H.%M.%S.%3N") ; }
tolog() { echo $1 >> "$LOGFILE" ; }
