#!/usr/bin/python -u
""" Install RHN product specific RPMs

    Copyright (c) 2002-2005, Red Hat, Inc.
    All rights reserved.
"""
# $Id: installPackages.py,v 1.25 2006-01-05 15:45:22 misa Exp $

import os
import sys
import glob
from translate import _

import rhn_rpm
import satLog
from satErrors import *

def systemExit(code, msgs=None):
    "Exit with a code and optional message(s). Saved a few lines of code."

    if msgs:
        if type(msgs) not in [type([]), type(())]:
            msgs = (msgs, )
        for msg in msgs:
            sys.stderr.write(str(msg)+'\n')
    sys.exit(code)


def getInstalledPackageList():
    list = []
    
    mi = rhn_rpm.MatchIterator("name")
    while 1:
        h = mi.next()
        if not h:
            break
        epoch = h['epoch']
        if epoch is None:
            epoch = ""
        entry = (h['name'], h['version'], h['release'], epoch, h['arch'])
        list.append(entry)
    list.sort(lambda a, b: cmp(a[0], b[0]))
    return list


def getListOfPackagesToInstall(rpmPath):
    # or if we decide to use a manifest, do it here
    globPattern = "%s/*.rpm" % rpmPath

    packagesToInstall = {}
    installedPackages = getInstalledPackageList()
    # Hash them by name
    installedPackagesDict = {}
    for package in installedPackages:
        name = package[0]
	installedPackagesDict[name] = package

    availablePackages = {}
    filenames = glob.glob(globPattern)
    for filename in filenames:
        hdr = rhn_rpm.get_package_header(filename=filename)
        epoch = hdr['epoch']
        if epoch is None:  
            epoch = ""
        name = hdr['name']
        nvre = (name, hdr['version'], hdr['release'], epoch)
        availablePackages[nvre] = filename

        if not installedPackagesDict.has_key(name):
            # We need to install this nevertheless
            packagesToInstall[name] = filename
            continue

        installedPackage = installedPackagesDict[name]
        ret = rhn_rpm.nvre_compare(installedPackage, nvre)
        
        if ret >= 0:
            # already installed or older than what we have installed
            continue

        packagesToInstall[name] = filename
                
    return packagesToInstall.values()


def installPackages(filenames, rpmPath, rpmCallback):
    if not filenames:
        # Nothing to do, moving on
        return 0

    ts = rhn_rpm.RPMTransaction()

    for filename in filenames:
        hdr = rhn_rpm.get_package_header(filename=filename)
        if hdr is None:
            raise RpmError(_("Error reading header from package %s") %
                filename)
        ts.addInstall(hdr, hdr, 'u')

    deps = ts.check()

    # make this smarter, duh
    if deps:
        raise DependencyError(_(
            "Dependencies should have already been resolved, "\
            "but they are not."), deps)

    ts.order()
    rc = ts.run(rpmCallback, rpmPath)
    
    if rc:
        errors = "\n"
        for e in rc:
            try:
                errors = errors + e[1] + "\n"
            except:
                errors = errors + str(e) + "\n"
        raise RpmError(_("Failed installing packages: %s") % errors)

    return 0

class RPM_Callback:
    def __init__(self, total):
        self.total = total
        self.installed = 0
        self.message_template = "%%%ds/%%s Installing %%s" % len(str(self.total))
    
    def callback(self, what, amount, total, hdr, path):
        if what == rhn_rpm.RPMCALLBACK_INST_OPEN_FILE:
            fileName = "%s/%s-%s-%s.%s.rpm" % (path,
                                               hdr['name'],
                                               hdr['version'],
                                               hdr['release'],
                                               hdr['arch'])
            try:
                fd = os.open(fileName, os.O_RDONLY)
            except :
                print _("Error opening %s") % fileName
                raise RpmError(_("Error opening %s") % fileName)

            return fd

        if what == rhn_rpm.RPMCALLBACK_INST_START:
            fileName = "%s/%s-%s-%s.%s.rpm" % (path,
                                               hdr['name'],
                                               hdr['version'],
                                               hdr['release'],
                                               hdr['arch'])
            self.installed = self.installed + 1
            print self.message_template % (self.installed, self.total,
                fileName)
        elif what == rhn_rpm.RPMCALLBACK_INST_CLOSE_FILE:
            try:
                os.close(fd)
            except:
                pass

        elif what == rhn_rpm.RPMCALLBACK_INST_PROGRESS:
            pass

        elif what == rhn_rpm.RPMCALLBACK_UNINST_STOP:
            pass

        else:
            if hasattr(rhn_rpm, "RPMCALLBACK_UNPACK_ERROR") and \
               what == rhn_rpm.RPMCALLBACK_UNPACK_ERROR:
                pkg = "%s-%s-%s" % (hdr[rhn_rpm.RPMTAG_NAME],
                                hdr[rhn_rpm.RPMTAG_VERSION],
                                hdr[rhn_rpm.RPMTAG_RELEASE])
                raise RpmError(_("There was a rpm unpack error installing "
                                 "the package: %s") % pkg)

            if hasattr(rhn_rpm, "RPMCALLBACK_CPIO_ERROR") and \
               what == rhn_rpm.RPMCALLBACK_CPIO_ERROR:
                pkg = "%s-%s-%s" % (hdr[rhn_rpm.RPMTAG_NAME],
                                hdr[rhn_rpm.RPMTAG_VERSION],
                                hdr[rhn_rpm.RPMTAG_RELEASE])
                raise RpmError(_("There was a cpio error installing "
                                 "the package: %s") % pkg)


def doInstallation(rpms_dir):
    pkgList = getListOfPackagesToInstall(rpms_dir)
    if not pkgList:
        print "All required packages are already installed"
        return 0

    #do it
    # may raise a DependencyError
    installPackages(pkgList, rpms_dir, RPM_Callback(len(pkgList)).callback)

    print "All required packages have been installed"

    return 0


def main():
    os.chdir(os.path.dirname(sys.argv[0]))

    for rpmdir in ["../Satellite", "../EmbeddedDB"]:
        if os.path.isdir(rpmdir):
            doInstallation(rpmdir)

    return 0


if __name__ == "__main__":
    #  0 - all is well
    # -1 - help called
    # -2 - initLog failed
    # -3 - base directory access error
    # -4 - extra args on commandline
    # -5 - RpmError
    # -6 - rpm DependencyError
    # -100 - ^C
    try:
        satLog.initLog()
    except (OSError, IOError), e:
        systemExit(-2, "Unable to open log file. The error was: %s" % e)

    try:
        sys.exit(main() or 0)
    except KeyboardInterrupt, e:
        systemExit(-100, "User interrupted process")
    except (OSError, IOError), e:
        systemExit(-3, "Error accessing base directory: %s" % e)
    except ValueError, e:
        msg = "ERROR: these arguments make no sense in this context (try --help): %s\n" % repr(e.args)
        systemExit(-4, msg)
    except RpmError, e:
        systemExit(-5, repr(e))
    except DependencyError, e:
        systemExit(-6, 'ERROR: %s\n' % repr(e))


