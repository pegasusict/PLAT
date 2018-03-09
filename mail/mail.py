
#!/usr/bin/env python
# -*- coding: utf-8 -*-
# Script performed to send login_activity.txt file to a user

import smtplib

from datetime import date
from email.MIMEMultipart import MIMEMultipart
from email.MIMEText import MIMEText
from email.MIMEBase import MIMEBase
from email import encoders

# Send The Log File Before Erasing #

msg = MIMEMultipart()
msg['From'] = 'someone@gmail.com'
recipients = 'bob.dupont@gmail.com'
msg['Subject'] = 'Login Activity' 
message = 'Hi! \n Please find the logs for the : {}/{}/{}.'.format(date.today().day, date.today().month, date.today().year)

filename = "login_activity.txt"
attachment = open("/home/ubuntu/login_activity.txt", "rb")
 
part = MIMEBase('application', 'octet-stream')
part.set_payload((attachment).read())
encoders.encode_base64(part)
part.add_header('Content-Disposition', "attachment; filename= {}".format(filename))
 
msg.attach(part)

msg.attach(MIMEText(message))
mailserver = smtplib.SMTP('smtp.gmail.com', 587) # using gmail SMTP server
mailserver.ehlo()
mailserver.starttls()
mailserver.ehlo()
mailserver.login('login', 'password')
mailserver.sendmail(msg['From'], recipients, msg.as_string())
mailserver.quit()


# Erase File logs #

with open('/home/ubuntu/login_activity.txt', 'w') as file:
	file.write('')
file.close()
