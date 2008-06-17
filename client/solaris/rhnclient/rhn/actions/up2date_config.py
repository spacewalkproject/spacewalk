#!/usr/bin/python

# Copyright (c) 1999-2002 Red Hat, Inc.  Distributed under GPL.
#
# Author: Adrian Likins <alikins@redhat.com>
#

import sys
sys.path.append("/usr/share/rhn")
from rhn.client import config

cfg = config.initUp2dateConfig()

__rhnexport__ = [
    'update',
    'rpmmacros',
    'get']

argVerbose = 0
def update(configdict):
    """Invoke this to change the ondisk configuration of up2date"""
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

def get():
    """Reterieve the current configuration of up2date"""
    if argVerbose > 1:
        print "called get_up2date_config"

    ret = {}
    for k in cfg.keys():
        ret[k] = cfg[k]
    return (0, "configuration retrived", {'data' : ret})


def rpmmacros(macroName, macroValue):
    return (0, "%s set to %s" % (macroName, macroValue), {})

def main():
    configdatatup = get()
    configdata = configdatatup[2]['data']
#    print configdata

    import time
    timestamp = time.time()

    configdata['timeStampTest'] = timestamp
#    print
    print configdata
#    print
    import pprint
    
    pprint.pprint(update(configdata))

    configdata['serverURL'] = "http://hokeypokeyland.org/XMLRPC"
    pprint.pprint(update(configdata))
#    configdata= get()
#    print configdata

if __name__ == "__main__":
    main()
