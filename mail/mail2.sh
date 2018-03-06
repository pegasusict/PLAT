#!/usr/bin/bash
# Attachment
today=$(date +"%Y-%m-%d")
Attachment="/var/log/plat/$today*.*"

# store logging information in below log file
Log_File="/var/log/plat/sendemail_$today.log"

# check sendmail dir exists. else create it
Log_dir="$(dirname ${Log_File})"
if [ ! -d "${Log_dir}" ]; then mkdir "${Log_dir}"; fi

if [ ! -x "/usr/bin/sendEmail" ]; then
	echo "sendEmail not installed, installing..."
	sleep 1s
	apt install sendemail libnet-smtp-tls-perl -y
fi

/usr/bin/sendEmail -v -f ${From_Mail} \
                     -t ${To_Mail} -u "${Subject}" \
                     -m ${MSG} \
                     -a "${Attachment}"
                     -xu "${Sndr_Uname}" \
                     -xp "${Sndr_Passwd}" \
                     -o tls=auto \
                     -s "${RELAY_SERVER}" \
                     -cc "${CC_TO}" \
                     -l "${Log_File}"
