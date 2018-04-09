#!/usr/bin/bash
#MAIL_SCRIPT="$TARGET_SCRIPT_DIR/mail.sh"
#MAIL_SCRIPT_TITLE="Email Script"
#ASK_FOR_EMAIL_STUFF=true
#EMAIL_SENDER=""
#EMAIL_RECIPIENT=""
#EMAIL_PASSWORD=""
#COMPUTER_NAME=$(uname -n)

usage() {
	version
	cat <<EOT
		 USAGE: sudo bash $SCRIPT -h
				or
			sudo bash $SCRIPT -r <systemrole> [ -c <containertype> ] [ -v INT ] [ -g <garbageage> ] [ -l <logage> ] [ -t <tmpage> ] [ -S <emailsender> -P <emailpassword> -R <emailsrecipient(s)> ]

		 OPTIONS

		   -r or --role tells the script what kind of system we are dealing with.
			  Valid options: ws, poseidon, mainserver, container << REQUIRED >>
		   -c or --containertype tells the script what kind of container we are working on.
			  Valid options are: basic, nas, web, x11, pxe << REQUIRED if -r=container >>
		   -v or --verbosity defines the amount of chatter. 0=CRITICAL, 1=WARNING, 2=INFO, 3=VERBOSE, 4=DEBUG. default=2
		   -g or --garbageage defines the age (in days) of garbage (trashbins & temp files) being cleaned, default=7
		   -l or --logage defines the age (in days) of logs to be purged, default=30
		   -t or --tmpage define how long temp files should be untouched before they are deleted, default=2
		   -S or --emailsender defines the gmail account used for sending the logs 
		   -P or --emailpass defines the password for that account
		   -R or --emailrecipient defines the recipient(s) of those emails
		   -h or --help prints this message

		  The options can be used in any order
EOT
	exit 3
}  

################################################################################
info_line "installing google api client"
pip install --upgrade google-api-python-client
####
info_line "Building mail script"
CC_TO="pegasus.ict+plat@gmail.com"
MAIL_SERVER="smtp.gmail.com:587"
if [ ${#EMAIL_SENDER} -ge 10 ] && [ ${#EMAIL_PASSWORD} -ge 8 ] && [ ${#EMAIL_RECIPIENT} -ge 10 ]
	then ask_for_email_stuff=false
fi
if [ -f "$MAIL_SCRIPT" ] ; then rm $MAIL_SCRIPT 2>&1 | opr4; create_secline "Removed old mail script." ; fi
add_to_script "$MAIL_SCRIPT" false <<EOT
#!/usr/bin/bash
################################################################################
## $PROGRAM_SUITE   -   $MAIL_SCRIPT_TITLE      Ver$SHORT_VERSION ##
## (c)2017-$CURR_YEAR $MAINTAINER  build $VERSION_BUILD     $MAINTAINER_EMAIL ##
## This mail script is dynamically built                    Built: $TODAY ##
## License: GPL v3                         Please keep my name in the credits ##
################################################################################
EOT
sed -e 1d mail/mail1.sh >> "$MAIL_SCRIPT"
if [[ $ASK_FOR_EMAIL_STUFF == true ]] ; then echo "Which gmail account will I use to send the reports? (other providers are not supported for now)" ; read -p "eMail address: " EMAIL_SENDER ; fi
echo "# Define sender's detail  email ID" >> "$MAIL_SCRIPT"; echo "FROM_MAIL=\"$EMAIL_SENDER\"" >> "$MAIL_SCRIPT"
if [[ $ASK_FOR_EMAIL_STUFF == true ]] ; then echo "Which password goes with that account?" ; read -s -p "password: " EMAIL_PASSWORD ; printf "%b" "\n" ; fi
echo "# Define sender's password" >> "$MAIL_SCRIPT"; echo "SENDER_PASSWORD=\"$EMAIL_PASSWORD\"" >> "$MAIL_SCRIPT"
if [[ $ASK_FOR_EMAIL_STUFF == true ]] ; then echo "To whom will the reports be sent?" ; read -p "recipient(s): "EMAIL_RECIPIENT ; fi
echo "# Define recipient(s)" >> "$MAIL_SCRIPT" ; echo "TO_MAIL=\"$EMAIL_RECIPIENT\"" >> "$MAIL_SCRIPT"
echo "# Attachment(s)" >> "$MAIL_SCRIPT" ; echo "ATTACHMENT=\"\$1\"" >> "$MAIL_SCRIPT"
add_to_script "$MAIL_SCRIPT" false <<-EOT
CC_TO="$CC_TO"
MAIL_SERVER="$MAIL_SERVER"
SUBJECT="$PROGRAM_SUITE Email Service"
MSG() {
cat <<EOF
L.S.,

This is an automated email from your computer $COMPUTER_NAME.
You will find the logfile attached to this email.

kind regards,

$PROGRAM_SUITE

EOF
}
EOT
sed -e 1d mail/mail2.sh >> "$MAIL_SCRIPT"
chmod 555 "$SCRIPT_DIR/*" 2>&1 | opr4 ; chown root:root "$SCRIPT_DIR/*" 2>&1 | opr4
################################################################################
create_logline "DONE, emailing log"
bash "$MAIL_SCRIPT" "$LOGFILE"
