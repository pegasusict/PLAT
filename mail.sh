create_logline "Building mail script"
mailscript="/etc/plat/mail.sh"
mkdir /etc/plat
touch $mailscript
cat mail/mail0.sh >> "$mailscript"
echo "Which gmail account will I use to send the reports?"
read sender
echo "From_Mail=\"$sender\"" >> "$mailscript"
sed -e 1d mail/mail1.sh >> "$mailscript"
echo "Which password goes with that account?"
read PassWord
echo "Sndr_Passwd=\"$PassWord\"" >> "$mailscript"
sed -e 1d mail/mail2.sh >> "$mailscript"
echo "To whom will the reports be sent?"
read Recipient
echo "To_Mail=\"$Recipient\"" >> mailscript
sed -e 1d mail/mail3.sh >> "$mailscript"
################################################################################
create_logline "DONE"
### email with log attached
bash /etc/plat/mail.sh
