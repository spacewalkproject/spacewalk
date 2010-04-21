# Client code for Update Agent
# Copyright (c) 1999-2002 Red Hat, Inc.  Distributed under GPL.
#
# Author: Preston Brown <pbrown@redhat.com>
#         Adrian Likins <alikins@redhat.com>
#
"""utility functions for up2date"""

import os
import string

import up2dateErrors
import transaction
import config


import gettext
_ = gettext.gettext


def _getOSVersionAndRelease():
    cfg = config.initUp2dateConfig()
    ts = transaction.initReadOnlyTransaction()
    for h in ts.dbMatch('Providename', "redhat-release"):
        if cfg["versionOverride"]:
            version = cfg["versionOverride"]
        else:
            version = h['version']

        osVersionRelease = (h['name'], version, h['release'])
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
    if not os.access("/etc/rpm/platform", os.R_OK):
        return os.uname()[4]

    fd = open("/etc/rpm/platform", "r")
    platform = string.strip(fd.read())

    #bz 216225
    #handle some replacements..
    replace = {"ia32e-redhat-linux": "x86_64-redhat-linux"}
    if replace.has_key(platform):
        platform = replace[platform]

    return platform


def version():
    # substituted to the real version by the Makefile at installation time.
    return "@VERSION@"
