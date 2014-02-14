#!/usr/bin/python

# Copyright (c) 1999--2012 Red Hat, Inc.  Distributed under GPLv2.
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



def main():
    configdatatup = get()
    configdata = configdatatup[2]['data']

    import time
    timestamp = time.time()

    configdata['timeStampTest'] = timestamp
    print configdata
    import pprint

    pprint.pprint(update(configdata))

    configdata['serverURL'] = "http://localhost/XMLRPC"
    pprint.pprint(update(configdata))

if __name__ == "__main__":
    main()
