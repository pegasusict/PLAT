 From the app:
 ---
 Pegasus' Linux Administration Tools - postinstall.sh Ver1.0.0-BETA build 20180313 - (c) 2018 Mattijs Snepvangers
 
    USAGE:  sudo bash postinstall.sh -h
                or
        sudo bash postinstall.sh -r <systemrole> [ -c <containertype> ] [ -v INT ]
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

<updated: 26-04-2018>
