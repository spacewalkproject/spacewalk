# Client code for Update Agent
# Copyright (c) 2011--2012 Red Hat, Inc.  Distributed under GPLv2.
#
# Author: Simon Lukasik
#         Lukas Durfina
#

import os
import apt
import gettext
t = gettext.translation('rhn-client-tools', fallback=True)
_ = t.ugettext


# FIXME: After Debian bug 187019 is resolved
def verifyPackages(packages):
    cache = apt.Cache()
    missing_packages = []
    for package in packages:
        pkg = cache[package[0]]
        if pkg == None or not pkg.is_installed:
            missing_packages.append(package)

    return [], missing_packages

# Patch to ignore the epoch so version matches with spacewalk server and ERRATA (pandujar)
def parseVRE(version):
    epoch = ''
    version_tmpArr = version.split('-')
    if len(version_tmpArr) == 1 :
        version = version
	release = 'X'

    else:
        version = version_tmpArr[0]
        release = version_tmpArr[1]

    return version, release, epoch

#def parseVRE(version):
#    epoch = ''
#    release = 'X'
#    if version.find(':') != -1:
#        epoch, version = version.split(':')
#    if version.find('-') != -1:
#        tmp = version.split('-')
#        version = '-'.join(tmp[:-1])
#        release = tmp[-1]
#    return version, release, epoch

def installTime(pkg_name, arch=None):
    paths = ['/var/lib/dpkg/info/%s.list' % (pkg_name,)]
    if arch:
        paths.append('/var/lib/dpkg/info/%s:%s.list' % (pkg_name, arch))
    for path in paths:
        if os.path.isfile(path):
           return os.path.getmtime(path)
    return None

#FIXME: Using Apt cache might not be an ultimate solution.
# It could be better to parse /var/lib/dpkg/status manually.
# Apt cache might not contain all the packages.
def getInstalledPackageList(msgCallback = None, progressCallback = None,
                            getArch=None, getInfo = None):
    """ Return list of packages. Package is dict with following keys:
        name, epoch, version, release and optionaly arch.
    """
    if msgCallback != None:
        msgCallback(_("Getting list of packages installed on the system"))
    cache = apt.Cache()

    total = 0
    for pkg in cache:
        if pkg.installed != None:
            total += 1

    count = 0
    pkg_list = []
    for pkg in cache:
        if pkg.installed == None:
            continue
        version, release, epoch = parseVRE(pkg.installed.version)
        package = {
            'name': pkg.name,
            'epoch': epoch,
            'version': version,
            'release': release,
            'arch': pkg.installed.architecture + '-deb',
            'installtime': installTime(pkg.name, pkg.installed.architecture)
            }
        pkg_list.append(package)

        if progressCallback != None:
            progressCallback(count, total)
        count = count + 1

    pkg_list.sort()
    return pkg_list

def setDebugVerbosity():
    pass
