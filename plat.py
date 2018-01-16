#!/usr/bin/env python3
"""
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
* Pegasus' Linux Administration Tools      Build 20180115       VER 2.0 ALPHA *
* (C)2017 Mattijs Snepvangers                           pegasus.ict@gmail.com *
* plat.py                                  Main Script          VER 0.0 ALPHA *
* License: GPL v3                          Please keep my name in the credits *
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
"""

# Make sure only root can run this script
if os.geteuid() != 0:
    exit("You need to have root privileges to run this script.\nExiting.")

### defining constants
PKGVERSION = "2.0 ALPHA"
PKGACCRONYM = "PLAT"
PKGNAME = "Pegasus' Linux Administration Tools"
MYNAME = "Main Script"
MYFNAME = "plat.py"
MYVERSION = "2.0 ALPHA"
MYBUILD = "20180104"
AUTHORNAME = "Mattijs Snepvangers"
AUTHOREMAIL = "pegasus.ict@gmail.com"
LICENSE = "GPL v3"

### enable logging
#import lib.logger

### start logfile, place header in logfile & on screen

### parse arguments

def argparser():
    """-r or --role tells the script what kind of system we are dealing with.
    Valid options: basic, ws, zeus, mainserver, container
    -c or --containertype tells the script what kind of container we are working on.
    Valid options are: basic, nas, web, x11, pxe"""
    pass

### update interfaces file if systemrole is mainserver

### determine which elements are required for each systemrole

### install/update Ubuntu sources & PPA's as needed per systemrole

### apt update

### apt upgrade

### install extre packages  as needed per systemrole

### download & install extre software as needed per systemrole

### Build maintenance script based on systemrole
###TODO### include mail trigger

### move maintenance script to /usr/bin/plat and set owner/rights

### add maintenance to crontab/anacrontab

### Build mail script
def build_mail_script():
    """Which gmail account will I use to send the reports?
    Which password goes with that account?
    To whom will the reports be sent?
    """
    pass

### place mailscript in /usr/bin/plat

### run maintenance script and exit
