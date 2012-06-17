#
# actions.packages dispatcher for Debian clients 
#
# Author: Simon Lukasik
#         Lukas Durfina
# License: GPLv2
#
# TODO:   Be strict on architectures and package versions
#         Staging content
#
# Copyright (c) 2012 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public License,
# version 2 (GPLv2). There is NO WARRANTY for this software, express or
# implied, including the implied warranties of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
# along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

import os
import sys
import time
import apt

sys.path.append("/usr/share/rhn/")
from up2date_client import up2dateLog
from up2date_client import pkgUtils
from up2date_client import rhnPackageInfo

log = up2dateLog.initLog()

# file used to keep track of the next time rhn_check 
# is allowed to update the package list on the server
LAST_UPDATE_FILE="/var/lib/up2date/dbtimestamp"

__rhnexport__ = [
    'update',
    'remove',
    'refresh_list',
    'fullUpdate',
    'checkNeedUpdate',
    'runTransaction',
    'verify'
]

def remove(package_list, cache_only=None):
    """We have been told that we should remove packages"""
    if cache_only:
        return (0, "no-ops for caching", {})
    if type(package_list) != type([]):
        return (13, "Invalid arguments passed to function", {})
    log.log_debug("Called remove_packages", package_list)

    try:
        cache = apt.Cache()
        cache.update()
        cache.open(None)
        for pkg in package_list:
            try:
                package = cache[pkg[0]]
                package.mark_delete()
            except:
                log.log_debug("Failed to remove package", pkg)
                return (1, "remove_packages failed", {})
        cache.commit()
        return (0, "remove_packages OK", {})
    except:
        return (1, "remove_packages failed", {})

def update(package_list, cache_only=None):
    """We have been told that we should retrieve/install packages"""
    if type(package_list) != type([]):
        return (13, "Invalid arguments passed to function", {})
    log.log_debug("Called update", package_list)

    try:
        cache = apt.Cache()
        cache.update()
        cache.open(None)
        for pkg in package_list:
            try:
                package = cache[pkg[0]]
                if not package.is_installed:
                    package.mark_install()
                else:
                    package.mark_upgrade()
            except:
                log.log_debug("Failed to update package", pkg)
                return (1, "update failed", {})
        cache.commit()
        return (0, "update OK", {})
    except:
        return (1, "update failed", {})

def fullUpdate(force=0, cache_only=None):
    """ Update all packages on the system. """
    log.log_debug("Called packages.fullUpdate")
    try:
        cache = apt.Cache()
        cache.update()
        cache.open(None)
        cache.upgrade(True)
        cache.commit()
    except:
        return (1, "packages.fullUpdate failed", {})
    return (0, "packages.fullUpdate OK", {})

def checkNeedUpdate(rhnsd=None, cache_only=None):
    """ Check if the locally installed package list changed, if
        needed the list is updated on the server
        In case of error avoid pushing data to stay safe
    """
    if cache_only:
        return (0, "no-ops for caching", {})
    try:
        last = os.stat(LAST_UPDATE_FILE)[8]
    except:
        last = 0

    # Never update the package list more than once every 1/2 hour
    if int(time.time()) - last <= 60:
        return (0, "dpkg database not modified since last update (or package "
            "list recently updated)", {})

    if last == 0:
        try:
            file = open(LAST_UPDATE_FILE, "w+")
            file.close()
        except:
            return (0, "unable to open the timestamp file", {})

    # call the refresh_list action with a argument so we know it's
    # from rhnsd
    return refresh_list(rhnsd=1)


def refresh_list(rhnsd=None, cache_only=None):
    """ push again the list of rpm packages to the server """
    if cache_only:
        return (0, "no-ops for caching", {})
    log.log_debug("Called refresh_list")

    try:
        rhnPackageInfo.updatePackageProfile()
    except:
        print "ERROR: refreshing remote package list for System Profile"
        return (20, "Error refreshing package list", {})

    touch_time_stamp()
    return (0, "package list refreshed", {})

def touch_time_stamp():
    try:
        file_d = open(LAST_UPDATE_FILE, "w+")
        file_d.close()
    except:
        return (0, "unable to open the timestamp file", {})
    # Never update the package list more than once every hour.
    t = time.time()
    try:
        os.utime(LAST_UPDATE_FILE, (t, t))
    except:
        return (0, "unable to set the time stamp on the time stamp file %s"
                % LAST_UPDATE_FILE, {})

def verify(packages, cache_only=None):
    log.log_debug("Called packages.verify")
    if cache_only:
        return (0, "no-ops for caching", {})

    data = {}
    data['name'] = "packages.verify"
    data['version'] = 0
    ret, missing_packages = pkgUtils.verifyPackages(packages)
                                                                                
    data['verify_info'] = ret
    
    if len(missing_packages):
        data['name'] = "packages.verify.missing_packages"
        data['version'] = 0
        data['missing_packages'] = missing_packages
        return(43, "packages requested to be verified are missing "
            "in the Apt cache", data)

    return (0, "packages verified", data)
