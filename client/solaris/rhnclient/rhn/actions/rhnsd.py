#!/usr/bin/python

# Copyright (c) 1999-2002 Red Hat, Inc.  Distributed under GPL.
#
# Author: Adrian Likins <alikins@redhat.com>
#

import string
import os

from rhn.client import config

RHNSD_CONFIG = os.path.normpath(config.PREFIX + "/etc/sysconfig/rhn/rhnsd")

# mark this module as acceptable
__rhnexport__ = [
    'configure'
]

def __configRhnsd(interval):
    fd = open(RHNSD_CONFIG, "r")
    lines = fd.readlines()
    count = 0
    index = None
    tmplines = []
    for line in lines:
        tmp = string.strip(line)
        tmplines.append(tmp)
        comps = string.split(tmp, "=", 1)
        if comps[0] == "INTERVAL":
            index = count
        count = count + 1
            
    if index != None:
        tmplines[index] = "INTERVAL=%s" % interval

    fd.close()
    fd = open(RHNSD_CONFIG, "w")
    contents = string.join(tmplines, "\n")
    fd.write(contents)
    fd.close()


def configure(interval=None, restart=None):
    msg = ""
    if interval:
        try:
            __configRhnsd(interval)
            msg = "rhnsd interval config updated. "
        except IOError:
            # i'm runing as root, must of been chattr'ed.
            # i'll resist the erge to unchattr this file
            return (37,"Could not modify %s" % RHNSD_CONFIG, {})

    if restart:
        rc = os.system("/sbin/service rhnsd restart > /dev/null")
        msg = msg + "rhnsd restarted"

    return(0,  msg, {})


if __name__ == "__main__":
    print configure("240")

    print configure("361", 1)

    print configure("127", restart=1)

    print configure(restart=1)

    print configure("192")
