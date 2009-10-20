# some high level utility stuff for rpm handling

# Client code for Update Agent
# Copyright (c) 1999-2002 Red Hat, Inc.  Distributed under GPL.
#
# Author: Preston Brown <pbrown@redhat.com>
#         Adrian Likins <alikins@redhat.com>
#


#
#  FIXME: Some exceptions in here are currently in up2date.py
#         fix by moving to up2dateErrors.py and importing from there
#
#

import os
import rpm
import transaction

import gettext
_ = gettext.gettext


def installedHeaderByKeyword(**kwargs):    
    """ just cause this is such a potentially useful looking method... """
    _ts = transaction.initReadOnlyTransaction()   
    mi = _ts.dbMatch()   
    for keyword in kwargs.keys():   
        mi.pattern(keyword, rpm.RPMMIRE_GLOB, kwargs[keyword])     
        # we really shouldnt be getting multiples here, but what the heck     
    headerList = []      
    for h in mi:    
        headerList.append(h)   
    
    return headerList

def verifyPackages(packages):
    """ given a list of package labels, run rpm -V on them
        and return a dict keyed off that data
    """
    data = {}
    missing_packages = []                                                                            
    # data structure is keyed off package
    # label, with value being an array of each
    # line of the output from -V


    retlist = []
    for package in packages:
        (n,v,r,e,a) = package
        # we have to have at least name...

        # Note: we cant reliable match on epoch, so just
        # skip it... two packages that only diff by epoch is
        # way broken anyway
        name = version = release = arch = None
        if n != "":
            name = n
        if v != "":
            version = v
        if r != "":
            release = r
        if a != "":
            arch = a

        keywords = {}
        for token, value  in (("name", name),
                              ("version", version),
                              ("release",release),
#                              ("epoch",epoch),
                              ("arch", arch)):
            if value != None:
                keywords[token] = value

        headers = installedHeaderByKeyword(**keywords)
	if len(headers) == 0:            
	    missing_packages.append(package)

        for header in headers:
            epoch = header['epoch']
            if epoch == None:
                epoch = ""
            # gpg-pubkey "packages" can have an arch of None, see bz #162701
            h_arch = header["arch"] 
            if h_arch == None:
                h_arch = ""
                
            pkg = (header['name'], header['version'],
                   header['release'], epoch,
                   h_arch)

            # dont include arch in the label if it's a None arch, #162701
            if pkg[4] == "":
                packageLabel = "%s-%s-%s" % (pkg[0], pkg[1], pkg[2])
            else:
                packageLabel = "%s-%s-%s.%s" % (pkg[0], pkg[1], pkg[2], pkg[4])
                
            verifystring = "/usr/bin/rpmverify -V %s" % packageLabel
                                                                                
            fd = os.popen(verifystring)
            res = fd.readlines()
            fd.close()
                                                                                
            reslist = []
            for line in res:
                reslist.append(line.strip())
            retlist.append([pkg, reslist])

    return retlist, missing_packages

def verifyAllPackages():
    """ run the equiv of `rpm -Va`. It aint gonna
        be fast, but...
    """
    data = {}

    packages = getInstalledPackageList(getArch=1)

    ret,missing_packages =  verifyPackages(packages)
    return ret


#FIXME: this looks like a good candidate for caching, since it takes a second
# or two to run, and I can call it a couple of times
def getInstalledPackageList(msgCallback = None, progressCallback = None,
                            getArch=None, getInfo = None):
    pkg_list = []

    
    if msgCallback != None:
        msgCallback(_("Getting list of packages installed on the system"))
 
    _ts = transaction.initReadOnlyTransaction()   
    count = 0
    total = 0
    
    for h in _ts.dbMatch():
        if h == None:
            break
        count = count + 1
    
    total = count
    
    count = 0
    for h in _ts.dbMatch():
        if h == None:
            break
        name = h['name']
        epoch = h['epoch']
        if epoch == None:
            epoch = ""
        version = h['version']
        release = h['release']
        if getArch:
            arch = h['arch']
            # the arch on gpg-pubkeys is "None"...
            if arch:
                pkg_list.append([name, version, release, epoch, arch])
        elif getInfo:
            arch = h['arch']
            cookie = h['cookie']
            if arch and cookie:
                pkg_list.append([name, version, release, epoch, arch, cookie])
            elif arch:
                pkg_list.append([name, version, release, epoch, arch])
        else:
            pkg_list.append([name, version, release, epoch])

        
        if progressCallback != None:
            progressCallback(count, total)
        count = count + 1
    
    pkg_list.sort()
    return pkg_list
