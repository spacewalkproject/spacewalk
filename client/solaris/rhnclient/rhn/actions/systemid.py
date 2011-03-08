#!/usr/bin/python
#
# Copyright (c) 1999-2002 Red Hat, Inc.  Distributed under GPL.
#
# Author: Adrian Likins <alikins@redhat.com>

import os
import time

from rhn.client import config


# mark this module as acceptable
__rhnexport__ = [
    'disable',
]


DISABLE_FILE = os.path.normpath(config.PREFIX + "/etc/sysconfig/rhn/disable")

def disable(messageText):
    """We have been told that we should disable the systemid"""

    # open and shut off
    fd = open(DISABLE_FILE, "w")
    fd.write("Disable lock created on %s. RHN Server Message:\n\n%s\n" % (
        time.ctime(time.time()), messageText))
    fd.close()
    
    # done if we survived this long
    return(0, "systemId disable lock file has been writen", {})

