#!/usr/bin/python

# Copyright (c) 1999-2002 Red Hat, Inc.  Distributed under GPL.
#
# Author: Adrian Likins <alikins@redhat.com>
#

import string
import os

# mark this module as acceptable
__rhnexport__ = [
    'configure',
]

def __configRhnsd(interval, cache_only=None):
    rhnsdconfig = "/etc/sysconfig/rhn/rhnsd"
    fd = open(rhnsdconfig, "r")
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
    fd = open(rhnsdconfig, "w")
    contents = string.join(tmplines, "\n")
    fd.write(contents)
    fd.close()


def configure(interval=None, restart=None, cache_only=None):
    if cache_only:
        return (0, "no-ops for caching", {})
    msg = ""
    if interval:
        try:
            __configRhnsd(interval)
            msg = "rhnsd interval config updated. "
        except IOError:
            # i'm runing as root, must of been chattr'ed.
            # i'll resist the erge to unchattr this file
            return (37,"Could not modify /etc/sysconfig/rhn/rhnsd", {})

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
