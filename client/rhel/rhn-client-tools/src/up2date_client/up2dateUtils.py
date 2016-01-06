# Client code for Update Agent
# Copyright (c) 1999--2012 Red Hat, Inc.  Distributed under GPLv2.
#
# Author: Preston Brown <pbrown@redhat.com>
#         Adrian Likins <alikins@redhat.com>
#
"""utility functions for up2date"""

import os
import string
import gettext
from up2date_client import up2dateErrors
from up2date_client import config
from up2date_client.pkgplatform import getPlatform
from pkgplatform import getPlatform
t = gettext.translation('rhn-client-tools', fallback=True)
# Python 3 translations don't have a ugettext method
if not hasattr(t, 'ugettext'):
    t.ugettext = t.gettext
_ = t.ugettext

if getPlatform() == 'deb':
    import lsb_release
    def _getOSVersionAndRelease():
        dist_info = lsb_release.get_distro_information()
        os_name = dist_info['ID']
        os_version = 'n/a'
        if 'CODENAME' in dist_info:
            os_version = dist_info['CODENAME']
        os_release = dist_info['RELEASE']
        return os_name, os_version, os_release

else:
    from up2date_client import transaction
    def _getOSVersionAndRelease():
        ts = transaction.initReadOnlyTransaction()
        for h in ts.dbMatch('Providename', "redhat-release"):
            SYSRELVER = 'system-release(releasever)'
            version = h['version']
            release = h['release']
            if SYSRELVER in h['providename']:
                provides = dict(zip(h['providename'], h['provideversion']))
                release = '%s-%s' % (version, release)
                version = provides[SYSRELVER]
            osVersionRelease = (h['name'], version, release)
            return osVersionRelease
        else:
            for h in ts.dbMatch('Providename', "distribution-release"):
                osVersionRelease = (h['name'], h['version'], h['release'])
                # zypper requires a exclusive lock on the rpmdb. So we need
                # to close it here.
                ts.ts.closeDB()
                return osVersionRelease
            else:
                raise up2dateErrors.RpmError(
                    "Could not determine what version of Red Hat Linux you "\
                    "are running.\nIf you get this error, try running \n\n"\
                    "\t\trpm --rebuilddb\n\n")

def getVersion():
    '''
    Returns the version of redhat-release rpm
    '''
    cfg = config.initUp2dateConfig()
    if cfg["versionOverride"]:
        return str(cfg["versionOverride"])
    os_release, version, release = _getOSVersionAndRelease()
    return version

def getOSRelease():
    '''
    Returns the name of the redhat-release rpm
    '''
    os_release, version, release = _getOSVersionAndRelease()
    return os_release

def getRelease():
    '''
    Returns the release of the redhat-release rpm
    '''
    os_release, version, release = _getOSVersionAndRelease()
    return release

def getArch():
    if os.access("/etc/rpm/platform", os.R_OK):
        fd = open("/etc/rpm/platform", "r")
        platform = string.strip(fd.read())

        #bz 216225
        #handle some replacements..
        replace = {"ia32e-redhat-linux": "x86_64-redhat-linux"}
        if replace.has_key(platform):
            platform = replace[platform]
        return platform
    arch = os.uname()[4]
    if getPlatform() == 'deb':
        # On debian we only support i386
        if arch in ['i486', 'i586', 'i686']:
            arch = 'i386'
        if arch == 'x86_64':
            arch = 'amd64'
        arch += '-debian-linux'
    return arch

def version():
    # substituted to the real version by the Makefile at installation time.
    return "@VERSION@"
