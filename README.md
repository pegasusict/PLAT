[![Codacy Badge](https://api.codacy.com/project/badge/Grade/8c5640df6d7c480d8532efd5063c93e8)](https://www.codacy.com/app/pegasus.ict/plat?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=pegasusict/plat&amp;utm_campaign=Badge_Grade)

# PLAT
Pegasus' Linux Administration Tools is a set of bash scripts that make life easier for the lazy/newbie user
on Ubuntu
---
20180305 Update:
Most of the issues should be gone now, I've added tonnes of functionality based on and/or inspired by 
feedback I recieved through various channels.
Constructive criticism and suggestions are very welcome!

===============================================================================

**Post-Install script:**

       Pegasus' Linux Administration Tools - plat.sh Ver0.8.63-ALPHA build 20180305 - (c)2018 Mattijs Snepvangers
		 USAGE: sudo bash plat.sh -h
				or
			    sudo bash plat.sh -r <systemrole> [ -c <containertype> ] [ -v INT ]
			    	[ -g <garbageage> ] [ -l <logage> ] [ -t <tmpage> ] [ -S <emailsender>
				-P <emailpassword> -R <emailsrecipient(s)> ]

		 OPTIONS

		   -r or --role tells the script what kind of system we are dealing with.
			  Valid options: ws, poseidon, mainserver, container << REQUIRED >>
		   -c or --containertype tells the script what kind of container we are working on.
			  Valid options are: basic, nas, web, x11, pxe << REQUIRED if -r=container >>
		   -v or --verbosity defines the amount of chatter. 0=CRITICAL, 1=WARNING, 2=INFO, 3=VERBOSE,
		   			4=DEBUG. default=2
		   -g or --garbageage defines the age (in days) of garbage (trashbins & temp files) being 
		   			cleaned, default=7
		   -l or --logage defines the age (in days) of logs to be purged, default=30
		   -t or --tmpage define how long temp files should be untouched before they are deleted,
		   			default=2
		   -S or --emailsender defines the gmail account used for sending the logs 
		   -P or --emailpass defines the password for that account
		   -R or --emailrecipient defines the recipient(s) of those emails
		   -h or --help prints this message

		  The options can be used in any order

==============================================================================

        All versions: edit/add repos & ppas appropriate to systemrole, remove duplicate lines
                      Install trash-cli, mc, teamviewer, git, snapd
                      apt-get update, upgrade, auto-remove, autoclean
                      email report(s)

        ws: Adds maintenance script to anacrontab weekly
            installs synaptic, tilda, audacious, samba, wine-stable, playonlinux, winetricks

        poseidon:    Adds maintenance script to anacrontab weekly
                     Installs staruml, gitkraken, picard, audacity, calibre, fastboot, adb, fslint,
		      gadmin-proftpd, geany, gprename, lame, masscan, forensics-all, forensics-extra,
		      forensics-extra-gui, forensics-full, chromium-browser, gparted, ssh-server, screen,
		      synaptic, tilda, audacious, samba, wine-stable, playonlinux, winetricks

        lxdhost:     Installs python3-crontab, lxc, lxcfs, lxd, lxd-tools, bridge-utils, xfsutils-linux,
			criu, apt-cacher-ng, ssh-server, screen
                     replaces /etc/network/interfaces with lxdinterfaces file included in this package,
                     restarts network to incorporate bridge,
                     adds maintenance_lxdhost script to crontab,
                     places container_maintenance file on server

        containers:
              web:   Installs apache2, phpmyadmin, mysqld, mytop, samba, proftpd, webmin, ssh-server, screen
              nas:   Installs samba, nfs, proftpd, ssh-server, screen
              pxe:   Installs atftpd, ssh-server, screen
              X11:   Installs ldm, ssh-server, screen
              Basic: Installs ssh-server, screen


**Maintenance scripts:**

        Maintenance scripts are purpose built by post-install script
        All versions: apt-get update, upgrade, auto-remove, autoclean
                      remove 7+ day old trash files, remove temp-files which haven't been accessed in the
		      past 2+ days
                      remove 30+ days old logs
        Poseidon/lxdhost: also handles maintenance of containers, first creates snapshots, then maintenance
        Mainserver: also handles maintenance of containers, first creates snapshots, then tape backup, then
			maintenance


**Mail functionality**

        After running the Post Install script and after each run of the maintenance scripts,
        an email containing the logs is automatically sent to the given address(es) using the given
	credentials. For now the focus of the mail client lies on Gmail.
