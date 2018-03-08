#!/usr/bin/bash
# store logging information in below log file
LOG_FILE="/var/log/plat/sendemail_$today.log"

# check sendmail dir exists. else create it
LOG_DIR="$(dirname ${LOG_FILE})"
if [ ! -d "${LOG_DIR}" ]; then mkdir "${LOG_DIR}"; fi

if [ ! -x "/usr/bin/sendEmail" ]; then
	echo "sendEmail not installed, installing..."
	sleep 1s
	apt install sendemail libnet-smtp-tls-perl -y
fi
#sending the email
/usr/bin/sendEmail -v -f ${FROM_MAIL} -t ${TO_MAIL} -cc "${CC_TO}" \
					-u "${SUBJECT}" -m ${MSG} -a "${ATTACHMENT}" \
                    -xu ${FROM_MAIL} -xp "${SENDER_PASSWORD}" \
                    -o tls=auto -s "$MAIL_SERVER" -l "${LOG_FILE}"
