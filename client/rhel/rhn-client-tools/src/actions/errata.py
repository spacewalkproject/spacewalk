#!/usr/bin/python

# Client code for Update Agent
# Copyright (c) 1999-2002 Red Hat, Inc.  Distributed under GPL.
#
# Author: Adrian Likins <alikins@redhat.com
#

import sys
sys.path.append("/usr/share/rhn/")
from up2date_client import rhnserver
from up2date_client import up2dateAuth
from up2date_client import rpmUtils
from actions import packages

__rhnexport__ = [
    'update']

# action version we understand
ACTION_VERSION = 2 

def __getErrataInfo(errata_id):
    s = rhnserver.RhnServer()
    return s.errata.getErrataInfo(up2dateAuth.getSystemId(), errata_id)

def update(errataidlist, cache_only=None):
    if cache_only:
        return (0, "no-ops for caching", {})
    packagelist = []

    if type(errataidlist) not in [type([]), type(())]:
        errataidlist = [ errataidlist ]
        
    for errataid in errataidlist:
        tmpList = __getErrataInfo(errataid)
        packagelist = packagelist + tmpList

    current_packages_with_arch = {}
    current_packages ={}
    for p in rpmUtils.getInstalledPackageList(getArch=1):
        current_packages_with_arch[p['name']+p['arch']] = p
        current_packages[p['name']] = p

    u = {}   
    # only update packages that are currently installed
    # since an "applicable errata" may only contain some packages
    # that actually apply. aka kernel. Fun fun fun. 

    if len(packagelist[0]) > 4:
        # Newer sats send down arch, filter using name+arch
        for p in packagelist:
	    if current_packages_with_arch.has_key(p[0]+p[4]):
	        u[p[0]+p[4]] = p
    else:
        # 5.2 and older sats + hosted dont send arch
        for p in packagelist:
            if current_packages.has_key(p[0]):
                u[p[0]] = p


    # XXX: Fix me - once we keep all errata packages around,
    # this is the WRONG thing to do - we want to keep the specific versions
    # that the user has asked for.
    packagelist = map(lambda a: u[a], u.keys())
   
    if packagelist == []:
	data = {}
	data['version'] = "0"
	data['name'] = "errata.update.no_packages"
	data['erratas'] = errataidlist
	
	return (39, 
		"No packages from that errata are available", 
		data)
 
    return packages.update(packagelist)
   

def main():
	print update([23423423])


if __name__ == "__main__":
	main()
 
