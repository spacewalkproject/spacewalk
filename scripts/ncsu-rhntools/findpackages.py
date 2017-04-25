#!/usr/bin/python

# findpackages.py - Generate Yum'able trees from the sat package store
# Copyright (C) 2007 NC State University
# Written by Jack Neely <jjneely@ncsu.edu>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

import os
import os.path
import config
import string
from types import IntType, FloatType, StringType, LongType
from rhnapi import RHNClient

TreeLocation = "/var/satellite/yum/channels"
PackageRoot = "/var/satellite/redhat"
PackageDirs = os.listdir(PackageRoot)

# Stolen from Yum
def stringToVersion(verstring):
    if verstring is None:
        return ('0', None, None)
    i = string.find(verstring, ':')
    if i != -1:
        try:
            epoch = verstring[:i]
        except ValueError:
            # look, garbage in the epoch field, how fun, kill it
            epoch = '0' # this is our fallback, deal
    else:
        epoch = '0'
    j = string.find(verstring, '-')
    if j != -1:
        if verstring[i + 1:j] == '':
            version = None
        else:
            version = verstring[i + 1:j]
        release = verstring[j + 1:]
    else:
        if verstring[i + 1:] == '':
            version = None
        else:
            version = verstring[i + 1:]
        release = None
    return (epoch, version, release)

def match(string, unknown, epsilon = 0.0001):
    # Does the string evaluate to the unknown typed value close enough
    # to be equal?

    if isinstance(unknown, StringType):
        return string == unknown

    if isinstance(unknown, IntType) or isinstance(unknown, LongType):
        try:
            i = int(string)
        except ValueError:
            return False
        return unknown == i

    if isinstance(unknown, FloatType):
        try:
            f = float(string)
        except ValueError:
            return False
        return (f - epsilon) <= unknown <= (f + epsilon)

    print "Unknown package EVR value %s of type %s could not be matched to %s" \
            % (unknown, type(unknown), string)
    return False

def bruteForceFind(p):
    for dir in PackageDirs:
        if dir.startswith('.'):
            continue

        namedir = os.path.join(PackageRoot, dir, p['package_name'])
        if not os.path.exists(namedir):
            continue

        for evr in [os.path.basename(i) for i in os.listdir(namedir)]:
            e, v, r = stringToVersion(evr)
            #print "Directory: %s + %s" % (namedir, evr)
            #print "EVR: (%s, %s, %s)" % (e, v, r)
            #print "%s, %s, %s" % (type(e), type(v), type(r))

            # Epoch
            if evr.find(':') == -1:
                # The directory doesn't include the epoch -- pray with me now
                pass
            elif p['package_epoch'].strip() == "" and e == "0":
                pass
            elif match(e, p['package_epoch']):
                pass
            else:
                continue

            # Version
            if not (match(v, p['package_version']) and
               match(r, p['package_release'])):
                continue

            # If we are here then we have a directory name that matched
            bindir = os.path.join(namedir, evr, p['package_arch_label'])
            srcdir = os.path.join(namedir, evr, 'SRPMS/')
            binpath = None
            srcpath = None

            # Okay, there should be ONE rpm file here
            if not os.access(bindir, os.R_OK):
                print "Directory not found: %s" % bindir
                print "Found packages but arch directory missing?"
                continue
            for file in os.listdir(bindir):
                if file.endswith("%(package_arch_label)s.rpm" % p):
                    binpath = os.path.join(bindir, file)
                    break

            # and one src rpm file
            if os.access(srcdir, os.R_OK):
                for file in os.listdir(srcdir):
                    if file.endswith("src.rpm"):
                        srcpath = os.path.join(srcdir, file)
                        break

            return binpath, srcpath

    print "Error:  Could not find packages: %s" % str(p)
    return None, None

def buildTreeUsing(label, rpm, srpm):
    if rpm == None:
        return

    location = os.path.join(TreeLocation, label, 'RPMS', os.path.basename(rpm))
    dir, file = os.path.split(location)
    if not os.path.exists(dir):
        os.makedirs(dir, 0755)
    if not os.path.exists(location):
        os.symlink(rpm, location)

    if srpm == None:
        return
    location = os.path.join(TreeLocation, label, 'SRPMS',
                            os.path.basename(srpm))
    dir, file = os.path.split(location)
    if not os.path.exists(dir):
        os.makedirs(dir, 0755)
    if not os.path.exists(location):
        os.symlink(srpm, location)

def havePackage(chan, p):
    # Check and see if our link farm has a matching package
    # We are going to take a good guess at the package name
    rpm = "%(package_name)s-%(package_version)s-%(package_release)s.%(package_arch_label)s.rpm" % p

    return os.path.exists(os.path.join(TreeLocation, chan, 'RPMS', rpm))

def test():
    p = {'package_arch_label': 'noarch', 'package_name': 'dejagnu', 'package_epoch': '1', 'package_version': '1.4.4', 'package_release': '2', 'package_id': 3066, 'package_last_modified': '2006-08-22 22:00:25'}
    q = {'package_arch_label': 'x86_64', 'package_name': 'sendmail-doc', 'package_epoch': '100', 'package_version': '8.12.11', 'package_release': '3.3.ncsu', 'package_id': 8555, 'package_last_modified': '2007-04-04 15:42:15'}

    print bruteForceFind(q)

def main():
    rhncfg = config.RHNConfig()
    rhn = RHNClient(rhncfg.getURL())
    rhn.connect(rhncfg.getUserName(), rhncfg.getPassword())

    channels = rhn.server.channel.list_software_channels(rhn.session)

    for chan in channels:
        packages = rhn.server.channel.software.list_all_packages(rhn.session,
                                                  chan['channel_label'])

        for p in packages:
            if havePackage(chan['channel_label'], p):
                continue

            location, source = bruteForceFind(p)

            if location == None:
                print "Error: Could not find binary package:"
                print p
            else:
                buildTreeUsing(chan['channel_label'], location, source)

if __name__ == "__main__":
    main()

