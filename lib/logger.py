#!/usr/bin/env python3
"""
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
* Pegasus' Linux Administration Tools      Build 20180104       VER 2.0 ALPHA *
* (C)2017 Mattijs Snepvangers                           pegasus.ict@gmail.com *
* fsops.py                                 Logging Class        VER 0.0 ALPHA *
* License: GPL v3                          Please keep my name in the credits *
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
"""

class logger :
    """logging system

    """
    def __init__(self):
        import logging
        logging.basicConfig(filename='/var/log/PLAT/%(asctime)s.log',
                            format='%(asctime)s %(levelname)s:%(message)s',
                            level=logging.DEBUG)

    def newlogline(self, message, loglevel):
        loglevels = ("debug", "info", "warning", "error", "critical")
        if loglevel not in loglevels:
            raise Error("loglevel incorrect")

def main():
    """testfunction for this module"""
    pass

# standard boilerplate
if __name__ == '__main__':
    main()
