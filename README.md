# plat
Pegasus' Linux Administration Tools is a set of bash and python scripts that make life easier for the lazy/newbie user on Ubuntu

20171201 update:

the scripts have evolved!!!

planned functionality (very soon)

**keyword arguments:** 
  postinstall:
     --role <zeus|ws|lxdhost|container> [--containertype <nas|web|X11>]
     
        ws: edits/adds repos & ppas, adds maintenance_ws script to anacrontab, installs teamviewer, samba
            
        zeus (my ws): same as ws, install staruml, lxd stuff, proftpd, opensshd etc
        
        lxdhost: adds /etc/apt/sources.list.d/plat_lxd_host.lst, 
                 installs lxd stuff, mc, bridge_utils, ...
                 replaces /etc/network/interfaces with lxdinterfaces included in this package,
                 restarts network to incorporate bridge,
                 adds maintenance_lxdhost script to crontab
                 
        container: adds /etc/apt/sources.list.d/plat_lxd_container.lst
                   installs mc, trash-cli
        
        containertype web: installs apache2, phpmyadmin, mysqld, samba, proftpd
        containertype nas: installs samba, nfs, proftpd
        containertype X11: installs ldm, teamviewer
 
 **maintenance scripts:**
 zeus
 ws
 lxdhost => tape backup,also handles maintenance of containers 
