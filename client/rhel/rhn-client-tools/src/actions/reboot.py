#!/usr/bin/python

# Client code for Update Agent
# Copyright (c) 1999-2002 Red Hat, Inc.  Distributed under GPL.
#
# Author: Adrian Likins <alikins@redhat.com
#

import sys
import os
sys.path.append("/usr/share/rhn/")

__rhnexport__ = [
    'reboot']

from up2date_client import up2dateLog
from up2date_client import config

cfg = config.initUp2dateConfig()
log = up2dateLog.initLog()

# action version we understand
ACTION_VERSION = 2 

def reboot(test=None, cache_only=None):
    if cache_only:
        return (0, "no-ops for caching", {})

    if cfg['noReboot']:
        return (38, "Up2date is configured not to allow reboots", {})
    
    pid = os.fork()
    data = {'version': '0'}
    if not pid:
        try:
            if test:
                os.execvp("/sbin/shutdown", ['/sbin/shutdown','-r','-k', '+3'])
            else:
                os.execvp("/sbin/shutdown", ['/sbin/shutdown','-r', '+3'])
        except OSError:
            data['name'] = "reboot.reboot.shutdown_failed"
            return (34, "Could not execute /sbin/shutdown", data)

    log.log_me("Rebooting the system now")
    # no point in waiting around

    return (0, "Reboot sucessfully started", data)


def main():
    print reboot(test=1)

if __name__ == "__main__":
    main()
