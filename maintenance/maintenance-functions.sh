#!/bin/bash
#### DEFINING FUNCTIONS ########################################################
create_logline() {
	_loglinetitle=$1
	_log_line="$(getthetime) ## $_loglinetitle #"
	imax=80
	for (( i=${#_log_line}; i<imax; i++ ))
	do _log_line+="#" ; done
	tolog $_log_line
}
create_secline() {
	_seclinetitle=$1
	_sec_line="# $_seclinetitle #"
	maxwidth=78
	imax=$maxwidth-1
	for (( i=${#_sec_line}; i<imax; i+=2 ))
	do _sec_line="#$_sec_line#" ; done
	if [ ${#_sec_line}<maxwidth ]; then $_sec_line="$_sec_line#"; fi
	tolog $_sec_line
}
getthetime(){ echo $(date +"%Y-%m-%d_%H.%M.%S.%3N") ; }
tolog() { echo $1 >> "$PLAT_LOGFILE" ; }
