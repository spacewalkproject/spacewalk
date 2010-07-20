#!/usr/bin/python
#
# Copyright (c) 1999-2002 Red Hat, Inc.  Distributed under GPL.
#
# Author: Adrian Likins <alikins@redhat.com>

import time


# mark this module as acceptable
__rhnexport__ = [
    'disable',
]

def disable(messageText, cache_only=None):
    """We have been told that we should disable the systemid"""
    if cache_only:
        return (0, "no-ops for caching", {})

    disableFilePath = "/etc/sysconfig/rhn/disable"
    # open and shut off
    fd = open(disableFilePath, "w")
    fd.write("Disable lock created on %s. RHN Server Message:\n\n%s\n" % (
        time.ctime(time.time()), messageText))
    fd.close()
    
    # done if we survived this long
    return(0, "systemId disable lock file has been writen", {})

