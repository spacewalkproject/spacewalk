# some high level utility stuff for rpm handling

# Client code for Update Agent
# Copyright (c) 1999--2016 Red Hat, Inc.  Distributed under GPLv2.
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
from rhn.i18n import sstr
from up2date_client import transaction

import gettext
t = gettext.translation('rhn-client-tools', fallback=True)
# Python 3 translations don't have a ugettext method
if not hasattr(t, 'ugettext'):
    t.ugettext = t.gettext
_ = t.ugettext

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
        # we have to have at least name...

        # Note: we cant reliable match on epoch, so just
        # skip it... two packages that only diff by epoch is
        # way broken anyway
        keywords = {'name': package[0],
                    'version': package[1],
                    'release': package[2],
                    # we left our epoch
                    'arch': package[4]
                    }
        for key in (keywords.keys()):
            if (keywords[key] == None) or (keywords[key] == ""):
                del(keywords[key])

        headers = installedHeaderByKeyword(**keywords)
        if len(headers) == 0:
            missing_packages.append(package)

        for header in headers:
            epoch = header['epoch']
            if epoch == None:
                epoch = ""
            # gpg-pubkey "packages" can have an arch of None, see bz #162701
            arch = header["arch"]
            if arch == None:
                arch = ""

            pkg = (header['name'], header['version'],
                   header['release'], epoch,
                   arch)

            # dont include arch in the label if it's a None arch, #162701
            if header["arch"] == "":
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

#FIXME: this looks like a good candidate for caching, since it takes a second
# or two to run, and I can call it a couple of times
def getInstalledPackageList(msgCallback = None, progressCallback = None,
                            getArch=None, getInfo = None):
    """ Return list of packages. Package is hash with keys name, epoch,
        version, release and optionaly arch and cookie
    """
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
        package = {
            'name': sstr(h['name']),
            'epoch': h['epoch'],
            'version': sstr(h['version']),
            'release': sstr(h['release']),
            'installtime': h['installtime']
        }
        if package['epoch'] == None:
            package['epoch'] = ""
        else: # convert it to string
            package['epoch'] = "%s" % package['epoch']
        if getArch:
            package['arch'] = h['arch']
            # the arch on gpg-pubkeys is "None"...
            if package['arch']:
                package['arch'] = sstr(package['arch'])
                pkg_list.append(package)
        elif getInfo:
            if h['arch']:
                package['arch'] = sstr(h['arch'])
            if h['cookie']:
                package['cookie'] = sstr(h['cookie'])
            pkg_list.append(package)
        else:
            pkg_list.append(package)

        if progressCallback != None:
            progressCallback(count, total)
        count = count + 1

    pkg_list.sort(key=lambda x:(x['name'], x['epoch'], x['version'], x['release']))
    return pkg_list

def setDebugVerbosity():
    """Set rpm's verbosity mode
    """
    try:
        rpm.setVerbosity(rpm.RPMLOG_DEBUG)
    except AttributeError:
        print("extra verbosity not supported in this version of rpm")
