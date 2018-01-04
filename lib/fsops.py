#!/usr/bin/env python3
"""
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
* Pegasus' Linux Administration Tools        Build 20180104     VER 2.0 ALPHA *
* (C)2017 Mattijs Snepvangers                           pegasus.ict@gmail.com *
* fsops.py                         Filesystem Operations        VER 0.0 ALPHA *
* License: GPL v3                          Please keep my name in the credits *
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
"""
import os

def verify_dir_exists(path):
    """verify whether a directory exists

    """
    return os.path.isdir(path)

def verify_file_exists(path):
    """verify file existence at "path"

    """
    result = os.path.isfile(path)
    return result

def delete_file(file_to_be_deleted):
    """delete file_to_be_deleted

    """
    os.unlink(file_to_be_deleted)
    return True

def main():
    """testfunction for this module"""
    pass

# standard boilerplate
if __name__ == '__main__':
    main()
