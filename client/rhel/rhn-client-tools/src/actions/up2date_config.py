#!/usr/bin/python

# Copyright (c) 1999-2002 Red Hat, Inc.  Distributed under GPL.
#
# Author: Adrian Likins <alikins@redhat.com>
#

import os
import re
import sys

sys.path.append("/usr/share/rhn")
from up2date_client import config

cfg = config.initUp2dateConfig()

__rhnexport__ = [
    'update',
    'rpmmacros',
    'get']

argVerbose = 0
def update(configdict, cache_only=None):
    """Invoke this to change the ondisk configuration of up2date"""
    if cache_only:
        return (0, "no-ops for caching", {})
    if argVerbose > 1:
        print "called update_up2date_config"

    if type(configdict) != type({}):
        return (13, "Invalid arguments passed to function", {})

    unknownparams = []
    if cfg['disallowConfChanges']:
        skipParams = cfg['disallowConfChanges']
    else:
	skipParams = []
    for param in configdict.keys():
        # dont touch params in the skip params list
        if param in skipParams:
            continue
        # write out all params, even ones we dont know about
        # could be useful
        cfg.set(param, configdict[param])

    if len(unknownparams):
        return unknownparams

    cfg.save()

    return (0, "config updated", {})

def get(cache_only=None):
    """Reterieve the current configuration of up2date"""
    if cache_only:
        return (0, "no-ops for caching", {})
    if argVerbose > 1:
        print "called get_up2date_config"

    ret = {}
    for k in cfg.keys():
        ret[k] = cfg[k]
    return (0, "configuration retrived", {'data' : ret})


def rpmmacros(macroName, macroValue, cache_only):
    if cache_only:
        return (0, "no-ops for caching", {})
    writeUp2dateMacro(macroName, macroValue)
    return (0, "%s set to %s" % (macroName, macroValue), {})


def writeUp2dateMacro(macroName, macroValue):

    if os.access("/etc/rpm/macros.up2date", os.R_OK):
        f = open("/etc/rpm/macros.up2date", "r")
        lines = f.readlines()
        f.close()
    else:
        lines = []
    comment_r = re.compile("\s*#.*")
    value_r = re.compile("%s.*" % macroName)
    blank_r = re.compile("\s*")
    newfile = []
    for line in lines: 
        m = value_r.match(line)
        if m:
            continue

        m = comment_r.match(line)
        if m:
            newfile.append(line)
            continue

        newfile.append(line)
            
        # dont care about blank lines...

    newfile.append("\n")
    newfile.append("%s       %s" % (macroName, macroValue))


    f = open("/etc/rpm/macros.up2date", "w")
    for line in newfile:
        f.write(line)
    f.write("\n")
    f.close()


def main():
    configdatatup = get()
    configdata = configdatatup[2]['data']

    import time
    timestamp = time.time()

    configdata['timeStampTest'] = timestamp
    print configdata
    import pprint
    
    pprint.pprint(update(configdata))

    configdata['serverURL'] = "http://hokeypokeyland.org/XMLRPC"
    pprint.pprint(update(configdata))

if __name__ == "__main__":
    main()
