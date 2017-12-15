#!/usr/bin/bash
# Define sender's detail  email ID
From_Mail="pegasus.ict@gmail.com"

# Sender's Username and password account for sending mail
Sndr_Uname="${From_Mail}"
Sndr_Passwd="Peg_1r3i5y6q3"

# Define recepient's email ID
To_Mail="mattijs@ictlab.info"

# Define CC to (Note: for multiple CC use ,(comma) as seperator )
# CC_TO="loginrahul90@gmail.com"

# Define mail server for sending mail [ IP:PORT or HOSTNAME:PORT ]
RELAY_SERVER="smtp.gmail.com:587"

# Subject
Subject="Test Mail using SendEmail"

# Mail Body

MSG() {

cat <<_EOF
L.S.,

    Logfile(s) attached

_EOF

today=$(date +"%Y-%m-%d_")
Attachment="/var/log/plat/$today*.*"

# store logging information in below log file
Log_File="/var/log/sendmail.log"

# check sendmail dir exists or not if not check create it
Log_dir="$(dirname ${Log_File})"


if [ ! -d "${Log_dir}" ]; then

    mkdir "${Log_dir}"

fi



check_sendmail() {

    if [ ! -x "/usr/bin/sendEmail" ]; then
        echo "sendEmail not installed"
        echo "Installing sendEmail..."
        sleep 1s
        apt install sendemail libnet-smtp-tls-perl -y
    fi
}

check_sendmail

/usr/bin/sendEmail -v -f ${From_Mail} \
                     -t ${To_Mail} -u "${Subject}" \
                     -m `MSG` \
                     -a "${Attachment}"
                     -xu "${Sndr_Uname}" \
                     -xp "${Sndr_Passwd}" \
                     -o tls=auto \
                     -s "${RELAY_SERVER}" \
                     -cc "${CC_TO}" \
                     -l "${Log_File}"
