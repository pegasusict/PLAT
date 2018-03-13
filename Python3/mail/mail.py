#!/usr/bin/python3
"""Send an email message from the user's account.
"""

import smtplib
from datetime import date
from email.MIMEMultipart import MIMEMultipart
from email.MIMEText import MIMEText
from email.MIMEBase import MIMEBase
from email import encoders

# Send The Log File Before Erasing #
ATTACHEDFILE="/var/log/plat/PostInstall*.log"
MSG = MIMEMultipart()
MSG['From'] = 'mattijs@ictlab.info'
RECIPIENTS = 'mattijs@ictlab.info'
MSG['Subject'] = 'PostInstall Log'
MESSAGE = 'Hi! \n Please find the logs for {}-{}-{}.'.format(date.today().day, date.today().month, date.today().year)

FILENAME = "PostInstall"
ATTACHMENT = open(ATTACHEDFILE, "rb")
PART = MIMEBase('application', 'octet-stream')
PART.set_payload((ATTACHMENT).read())
encoders.encode_base64(PART)
PART.add_header('Content-Disposition', "attachment; filename= {}".format(FILENAME))
MSG.attach(PART)

MSG.attach(MIMEText(MESSAGE))
MAILSERVER = smtplib.SMTP('smtp.gmail.com', 587) # using gmail SMTP server
MAILSERVER.ehlo()
MAILSERVER.starttls()
MAILSERVER.ehlo()
MAILSERVER.login('login', 'password')
MAILSERVER.sendmail(MSG['From'], RECIPIENTS, MSG.as_string())
MAILSERVER.quit()

# Erase File logs #
with open('/home/ubuntu/login_activity.txt', 'w') as file:
    file.write('')
file.close()
