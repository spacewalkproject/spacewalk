#!/usr/bin/python


# Copyright (c) 1999-2002 Red Hat, Inc.  Distributed under GPL.
#
# Author: Adrian Likins <alikins@redhat.com>


# imports are a bit weird here to avoid name collions on "harware"
import sys
sys.path.append("/usr/share/rhn/")
from up2date_client import hardware
from up2date_client import up2dateAuth
from up2date_client import rpcServer
argVerbose = 0

__rhnexport__ = [
    'refresh_list' ]

# resync hardware information with the server profile
def refresh_list(cache_only=None):
    if cache_only:
        return (0, "no-ops for caching", {})

    # read all hardware in
    hardwareList = hardware.Hardware()

    s = rpcServer.getServer()

    if argVerbose > 1:
        print "Called refresh_hardware"

    try:
        s.registration.refresh_hw_profile(up2dateAuth.getSystemId(),
                                          hardwareList)
    except:
        print "ERROR: sending hardware database for System Profile"
        return (12, "Error refreshing system hardware", {})

    return (0, "hardware list refreshed", {})

def main():
	print refresh_list()

if __name__ == "__main__":
	main()
