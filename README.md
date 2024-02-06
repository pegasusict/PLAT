[![Codacy Badge](https://api.codacy.com/project/badge/Grade/6975700247d543379109da35892a2e73)](https://www.codacy.com/app/pegasus.ict/PLAT?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=pegasusict/PLAT&amp;utm_campaign=Badge_Grade)

```
                             .:/- `:+shdddhys+-             
                          .+yy: :sdddddhyoooosyh+`          
                        -sdd/ -yddddh+-         ./-         
                       +ddd- +dddddy.                       
                    ` oddd/ /dddddh`                        
                   :o.dddh `dddddd+                         
                  :d./ddds /dddddd/     ....`  ./-          
                  hy +ddds /dddddds   `+hhhyyyysdhy+.       
      --         `dy /dddd``ddddddd-/yhhyso/```-//.+y+      
     +y          `dd``dddds /ddddddy-sdd+`         ssyo     
    +d:           ydo +dddds`/hdddddyodd/`     `-:.-//d`    
   .dd            /dd/ oddddy/-ohddddy+hy-    ohohhs..d:    
   +dh             ydho./hddddho:+ydddh+oh+`  dh `-+y-sh.   
/: sdh             .hddh+:ohddddhs//ydddy+yy- +d-   /yyo-`  
h/ sdd-             :hdddhs/+shddddy/:sddhssh+`oh.   `-/ys+`
yy`+dds             /-hdddddyo/+shdddy//yddhohs.+h:-/ss+-`hs
+dy/ddd/            /o-ohdddddhy+::ohdds:oddh/yh.:o+/.-+y ho
oydhdddh/            sy::shddddddhs:-/ydh/:hdh-yh`   -hyd.ys
sshdddddds.        ```sdy/:oydddddddy/.:hd+-hdy.hs  .yy:dood
.yddddddddho-`    .yys.+hdyo:/+syhddddy/-hd-/dd-od/+hs`hhoy/
 `+hddddddddhyo++ohyohy::ydddys+/:/+yddd:+do dd++ddhs+.://` 
   .:oyyhhhhhhyddd/` -yds:/yddddddys//yd:-d/ hd:ydd/hhy+-.  
       `.----.`hds    `:yhy+/shddddddy:+ -o`/ho+dd//hh+:hh` 
               yd/       -ohhs.:oyhddds  ` ./:sdh/ `ho-ydy` 
               od+         /dd-   .:/:.   `:ohhs. `sy-hh+`  
               -dh`        .ddy+:-....-/+shhy+.  +ys+hy-    
                +ds`        sddhhhhhhhhys+:.    .hhy+-      
                 :yy:`      .hdy-...:/:         `.-.        
                   :ss/.     -hds` :hh-                     
                     .ydo     :ddo:dd+-----::`              
                      /dh    -hdo`++oooo++//oy-`            
                      /dd` .sdd/.ooooooooooysydy/           
                      -hd/..:oys+:`         //-`            
                        .:osso/::+ss+:`                     
                             .:+syo/:/hs                    
                                  ./dy:do`                  
                                    /osyho                  

```
# PLAT
Pegasus' Linux Administration Tools is a set of bash scripts that make life 
easier for the Admin/new user on Ubuntu Server/Desktop derivatives.
It's main purpose is to help with bootstrapping systems and tedious repetitive
 tasks which make up a large portion of Linux administration.
Currently there's a Bootstrap script which, as the name suggests, is run right
 after installing Linux on a computer.
This script also generates a maintenance & backup script tailor made to the
 system's characteristics and roles it will preform.

More information can be found under the news messages.
<<updated: 22nd of march 2018>>
---
# NEWS

 ## 20180313 UPDATE: The BASH version is now V1.0.0-beta

### 20180312 update:
* Issue #2 & commit e468f7d22e550d860deda08dc2c4d0def20d797a.
* Email functionality broken, has been removed for now, will be added again
 with a later release.
* All references to the email functionality have been commented out or moved
 to a temporary file.
---
* 20180305 Update:
* Most of the issues should be gone now.
* I've added tonnes of features based on and/or inspired by feedback I received
 through various channels.
* Constructive criticism and suggestions are very welcome!
---

**Post-Install script:**

     Pegasus' Linux Administration Tools - plat.sh Ver1.0.0-BETA build 20180313 - (c) 2018 Mattijs Snepvangers
        USAGE:	sudo bash plat.sh -h
                    or
            sudo bash plat.sh -r <systemrole> [ -c <containertype> ] [ -v INT ]
                [ -g <garbageage> ] [ -l <logage> ] [ -t <tmpage> ]

         OPTIONS

           -r or --role tells the script what kind of system we are dealing with.
              Valid options: ws, zeus, backupserver, container << REQUIRED >>
           -c or --containertype tells the script what kind of container we are working on.
              Valid options are: basic, nas, web, x11, pxe << REQUIRED if -r=container >>
           -v or --verbosity defines the amount of chatter. 0=CRITICAL, 1=WARNING, 2=INFO, 3=VERBOSE,
                    4=DEBUG. default=2
           -g or --garbageage defines the age (in days) of garbage (trashbins & temp files) being
                    cleaned, default=7
           -l or --logage defines the age (in days) of logs to be purged, default=30
           -t or --tmpage define how long temp files should be untouched before they are deleted,
                    default=2
           -h or --help prints this message

            The options can be used in any order

---

        All versions:	Edit/add repos & ppas appropriate to systemrole, remove duplicate lines
                Install trash-cli, mc, teamviewer, git, snapd
                apt-get update, upgrade, auto-remove, autoclean

        ws:		Adds maintenance script to anacrontab weekly
                Installs synaptic, tilda, audacious, samba, wine-stable, playonlinux, winetricks

        zeus:
                Adds maintenance script to anacrontab weekly
                Installs staruml, gitkraken, picard, audacity, calibre, fastboot, adb, fslint,
                gadmin-proftpd, geany, gprename, lame, masscan, forensics-all, forensics-extra,
                forensics-extra-gui, forensics-full, chromium-browser, gparted, ssh-server, screen,
                synaptic, tilda, audacious, samba, wine-stable, playonlinux, winetricks

        lxchost:	Installs python3-crontab, lxc, lxcfs, lxd, lxd-tools, bridge-utils, xfsutils-linux,
                criu, apt-cacher-ng, ssh-server, screen
                replaces /etc/network/interfaces with lxcinterfaces file included in this package,
                restarts network to incorporate bridge,
                adds maintenance,
                places container_maintenance file on server

        containers:
            web:	Installs apache2, phpmyadmin, mysqld, mytop, samba, proftpd, webmin, ssh-server,
                        screen
            nas:	Installs samba, nfs, proftpd, ssh-server, screen
            pxe:	Installs atftpd, ssh-server, screen
            X11:	Installs ldm, ssh-server, screen
            Basic:	Installs ssh-server, screen

---
**Maintenance scripts:**

    Maintenance scripts are purpose built by post-install script
    All versions:	apt-get update, upgrade, auto-remove, autoclean
            remove 7+ day old trash files, remove temp-files which haven't been accessed in the
            past 2+ days, remove 30+ days old logs
    Poseidon/lxdhost: also handles maintenance of containers, first creates snapshots, then maintenance
    Backupserver: also handles maintenance of containers, first creates snapshots, then tape backup, then
            maintenance
