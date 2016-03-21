#
# Copyright (c) 2015 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public License,
# version 2 (GPLv2). There is NO WARRANTY for this software, express or
# implied, including the implied warranties of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
# along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
#
# Red Hat trademarks are not licensed under GPLv2. No permission is
# granted to use or replicate Red Hat trademarks that are incorporated
# in this software or its documentation.
#

import os
import sys
import time

import dnf.exceptions
import dnf.cli

sys.path.append("/usr/share/rhn/")

from up2date_client import up2dateLog
from up2date_client import config
from up2date_client import rpmUtils
from up2date_client import rhnPackageInfo

log = up2dateLog.initLog()

# file used to keep track of the next time rhn_check
# is allowed to update the package list on the server
LAST_UPDATE_FILE = "/var/lib/up2date/dbtimestamp"

# mark this module as acceptable
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

    if not isinstance(package_list, list):
        return (13, "Invalid arguments passed to function", {})

    log.log_debug("Called remove_packages", package_list)

    # initialize dnf
    base = _dnf_base(load_system_repo=True, load_available_repos=False)
    installed = base.sack.query().installed()
    to_remove = [_package_tup2obj(installed, tup) for tup in package_list]
    return _dnf_transaction(base, remove=to_remove, allow_erasing=True,
                            cache_only=cache_only)


def update(package_list, cache_only=None):
    """We have been told that we should retrieve/install packages"""
    if not isinstance(package_list, list):
        return (13, "Invalid arguments passed to function", {})

    log.log_debug("Called update", package_list)

    # initialize dnf
    base = _dnf_base(load_system_repo=True, load_available_repos=True)
    installed = base.sack.query().installed()
    available = base.sack.query().available()

    # skip already installed packages
    err = None
    errmsgs = []
    to_install = []
    for package in package_list:
        if len(package) < 5:
            package.append('')

        (name, version, release, epoch, arch) = package
        if version == '' and release == '' \
           and epoch == '' and arch == '' \
           and installed.filter(name=name):
            log.log_debug('Package %s is already installed' % name)
            continue

        if epoch == '':
            epoch = 0

        pkgs = installed.filter(name=name, arch=arch).latest()
        requested_pkg = _package_tup2obj(available, package)

        if not requested_pkg:
                err = 'Package %s is not available for installation' \
                      % _package_tup2str(package)
                log.log_me('E: ', err)
                errmsgs.append(err)
                continue

        for pkg in pkgs:
            pkg_cmp = pkg.evr_cmp(requested_pkg)
            if pkg_cmp == 0:
                log.log_debug('Package %s already installed'
                              % _package_tup2str(package))
                break
            elif pkg_cmp > 0:
                log.log_debug('More recent version of package %s is already installed'
                              % _package_tup2str(package))
                break
        else:
            to_install.append(requested_pkg)

    # Don't proceed further with empty list,
    # since this would result into an empty yum transaction
    if not to_install:
        if err:
            ret = (32, "Failed: Packages failed to install properly:\n" + '\n'.join(errmsgs),
                   {'version': '1', 'name': "package_install_failure"})
        else:
            ret = (0, "Requested packages already installed", {})
        # workaround for RhBug:1218071
        base.plugins.unload()
        base.close()
        return ret

    return _dnf_transaction(base, install=to_install, cache_only=cache_only)


def runTransaction(transaction_data, cache_only=None):
    """ Run a transaction on a group of packages.
        This was historicaly meant as generic call, but
        is only called for rollback.
    """
    if cache_only:
        return (0, "no-ops for caching", {})

    # initialize dnf
    base = _dnf_base(load_system_repo=True, load_available_repos=True)
    installed = base.sack.query().installed()
    available = base.sack.query().available()
    to_install = []
    to_remove = []
    for package_object in transaction_data['packages'][:]:
        [package, action] = package_object
        pkg = _package_tup2obj(installed, package)

        if action == 'e' and pkg:
            to_remove.append(pkg)
        elif action == 'i' and not pkg:
            new = _package_tup2obj(available, package)
            to_install.append(new)

    # Don't proceed further with empty package lists
    if not to_install and not to_remove:
        return (0, "Requested package actions have already been performed.", {})

    return _dnf_transaction(base, install=to_install, remove=to_remove,
                            allow_erasing=True, cache_only=cache_only)


def fullUpdate(force=0, cache_only=None):
    """ Update all packages on the system. """
    base = _dnf_base(load_system_repo=True, load_available_repos=True)
    return _dnf_transaction(base, full_update=True, cache_only=cache_only)


# The following functions are the same as the old up2date ones.
def checkNeedUpdate(rhnsd=None, cache_only=None):
    """ Check if the locally installed package list changed, if
        needed the list is updated on the server
        In case of error avoid pushing data to stay safe
    """
    if cache_only:
        return (0, "no-ops for caching", {})

    data = {}
    dbpath = "/var/lib/rpm"
    cfg = config.initUp2dateConfig()
    if cfg['dbpath']:
        dbpath = cfg['dbpath']
    RPM_PACKAGE_FILE = "%s/Packages" % dbpath

    try:
        dbtime = os.stat(RPM_PACKAGE_FILE)[8]  # 8 is st_mtime
    except:
        return (0, "unable to stat the rpm database", data)
    try:
        last = os.stat(LAST_UPDATE_FILE)[8]
    except:
        last = 0

    # Never update the package list more than once every 1/2 hour
    if last >= (dbtime - 10):
        return (0, "rpm database not modified since last update (or package "
                "list recently updated)", data)

    if last == 0:
        try:
            file = open(LAST_UPDATE_FILE, "w+")
            file.close()
        except:
            return (0, "unable to open the timestamp file", data)

    # call the refresh_list action with a argument so we know it's
    # from rhnsd
    return refresh_list(rhnsd=1)


def refresh_list(rhnsd=None, cache_only=None):
    """ push again the list of rpm packages to the server """
    if cache_only:
        return (0, "no-ops for caching", {})
    log.log_debug("Called refresh_rpmlist")

    ret = None

    try:
        rhnPackageInfo.updatePackageProfile()
    except:
        print("ERROR: refreshing remote package list for System Profile")
        return (20, "Error refreshing package list", {})

    touch_time_stamp()
    return (0, "rpmlist refreshed", {})


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
    ret, missing_packages = rpmUtils.verifyPackages(packages)

    data['verify_info'] = ret

    if len(missing_packages):
        data['name'] = "packages.verify.missing_packages"
        data['version'] = 0
        data['missing_packages'] = missing_packages
        return(43, "packages requested to be verified are missing", data)

    return (0, "packages verified", data)


def _dnf_base(load_system_repo=True, load_available_repos=True):
    # initialize dnf
    base = dnf.Base()

    # this is actually workaround for RhBug:1218071
    if not base.plugins.plugins and base.conf.plugins:
        base.plugins.load(base.conf.pluginpath, [])
        base.plugins.run_init(base)
        plugin = [p for p in base.plugins.plugins if p.name == 'spacewalk'][0]
        plugin.activate_channels()
    if load_available_repos:
        base.read_all_repos()
    base.fill_sack(load_system_repo=True, load_available_repos=True)
    return base


def _dnf_transaction(base, install=[], remove=[], full_update=False,
                     allow_erasing=False, cache_only=None):
    """
    command is an function excpecting dnf.Base() as an argument
    """
    try:
        if full_update:
            base.upgrade_all()
        else:
            for pkg in install:
                if pkg:
                    base.package_install(pkg)
            for pkg in remove:
                if pkg:
                    base.package_remove(pkg)

        base.resolve(allow_erasing)
        log.log_debug("Dependencies Resolved")
        if not len(base.transaction):
            raise dnf.exceptions.Error('empty transaction')
        if base.transaction.install_set:
            log.log_debug("Downloading and installing: ",
                          [str(p) for p in base.transaction.install_set])
            base.download_packages(base.transaction.install_set)
        if base.transaction.remove_set:
            log.log_debug("Removing: ",
                          [str(p) for p in base.transaction.remove_set])
        if not cache_only:
            base.do_transaction()

    except dnf.exceptions.MarkingError as e:
        data = {}
        data['version'] = "1"
        data['name'] = "package_install_failure"

        return (32, "Failed: Packages failed to install "
                "properly: %s" % str(e), data)
    except dnf.exceptions.MarkingError as e:
        data = {}
        data['version'] = 0
        data['name'] = "rpmremoveerrors"

        return (15, "%s" % str(e), data)
    except dnf.exceptions.DepsolveError as e:
        data = {}
        data["version"] = "1"
        data["name"] = "failed_deps"
        return (18, "Failed: packages requested raised "
                "dependency problems: %s" % str(e), data)
    except dnf.exceptions.Error as e:
        status = 6,
        message = "Error while executing packages action: %s" % str(e)
        data = {}
        return (status, message, data)
    finally:
        # workaround for RhBug:1218071
        base.plugins.unload()
        base.close()

    return (0, "Update Succeeded", {})


def _package_tup2obj(q, tup):
    (name, version, release, epoch) = tup[:4]
    arch = tup[4] if len(tup) > 4 else None
    query = {'name': name}
    if version is not None and len(version) > 0:
        query['version'] = version
    if release is not None and len(release) > 0:
        query['release'] = release
    if epoch is not None and len(epoch) > 0:
        query['epoch'] = int(epoch)
    if arch is not None and len(arch) > 0:
        query['arch'] = arch
    pkgs = q.filter(**query).run()
    if pkgs:
        return pkgs[0]
    return None


def _package_tup2str(package_tup):
    """ Create a package name from an rhn package tuple.
    """
    n, v, r, e, a = package_tup[:]
    if not e:
        e = '0'
    pkginfo = '%s-%s:%s-%s' % (n, e, v, r)
    if a:
        pkginfo += '.%s' % (a)
    return (pkginfo,)

