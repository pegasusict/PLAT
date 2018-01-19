#!/usr/bin/env python3
"""
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
* Pegasus' Linux Administration Tools      Build 20180104       VER 2.0 ALPHA *
* (C)2017 Mattijs Snepvangers                           pegasus.ict@gmail.com *
* fsops.py                                 Logging Class        VER 0.0 ALPHA *
* License: GPL v3                          Please keep my name in the credits *
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
"""

class MyLogger :
    """logging system

    """
    def __init__(self):
        import logging
        logging.basicConfig(filename='/var/log/PLAT/%(asctime)s.log',
                            format='%(asctime)s %(levelname)s:%(message)s',
                            level=logging.DEBUG)

    @classmethod
    def logentry(self, message, loglevel):
        """Method to create the correct logging message

        """
        #loglevels = ("debug", "info", "warning", "error", "critical")
        if loglevel == "debug":
            logging.debug(message)
        elif loglevel == "info":
            logging.info(message)
        elif loglevel == "warning":
            logging.warning(message)
        elif loglevel == "error":
            logging.error(message)
        elif loglevel == "critical":
            logging.critical(message)
            #exit(message)
        else:
            raise Error(TypeError, "loglevel incorrect")

    @classmethod
    def __get_the_time(self):
        """get timestamp inc milliseconds

        """
        ###TODO### add option for timestamp stripped of special chars if needed (filename)
        self.the_time = asctime()

    @classmethod
    def dummy_method(self):
        """dummy method to fool pylint

        """
        pass
def main():
    """testfunction for this module"""
    pass

# standard boilerplate
if __name__ == '__main__':
    main()
