#!/bin/bash
################################################################################
# Pegasus' Linux Administration Tools	#						  rsync script #
# (C)2017-2018 Mattijs Snepvangers		#				 pegasus.ict@gmail.com #
# License: MIT							#	Please keep my name in the credits #
################################################################################

for DAY in 6 5 4 3 2 1
do
	DATE_LOCAL=$(date --date="$DAY day ago" +"%Y%m%d")
	DATE_REMOTE=$(date --date="$DAY day ago" +"daily-%Y-%m-%d")
	rsync -avrt --delete --rsh='ssh -p 22' ictlab-info@ssh.pcextreme.nl:/home/vhosting/z/.zfs/snapshot/$DATE_REMOTE/vhost0032837/ /media/pegasus/storage/\[\ SPOOR\ 11\ \]/ictlab.info\ backups/$DATE_LOCAL
done
