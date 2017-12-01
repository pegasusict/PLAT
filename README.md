# plat
Pegasus' Linux Administration Tools is a set of bash and python scripts that make life easier for the lazy/newbie user on Ubuntu

20171201 update:

the scripts have evolved!!!

planned functionality (very soon)

**keyword arguments:** 
  postinstall:
     --role <zeus|ws|lxdhost|container> [--containertype <nas|web|X11>]
 
        All versions: edit/add repos & ppas
                      Install trash-cli, mc, teamviewer
                      apt-get up 
 
        ws: Adds maintenance_ws script to anacrontab weekly
            installs samba
            
        zeus (my ws): adds lxdhost_maintenance script to anacrontab,
                      installs staruml, lxd stuff, proftpd, opensshd, samba
                      
        lxdhost: installs lxd stuff, bridge_utils,
                 replaces /etc/network/interfaces with lxdinterfaces included in this package,
                 restarts network to incorporate bridge,
                 adds maintenance_lxdhost script to crontab
                 
        container: 
        
        containertype web: installs apache2, phpmyadmin, mysqld, samba, proftpd
        containertype nas: installs samba, nfs, proftpd
        containertype X11: installs ldm, teamviewer
 
**maintenance scripts:**
 
        ws:      apt-get update, upgrade, auto-remove, autoclean
                 Empty trash, remove tmp-files and old logs
        zeus: 
        lxdhost: tape backup,also handles maintenance of containers 
