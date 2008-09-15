#!/usr/bin/python
#
# Copyright (c) 2005 Red Hat, Inc.
#
# Written by Joel Martin <jmartin@redhat.com>
#
# This file is part of Smart Package Manager.
#
# Smart Package Manager is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as published
# by the Free Software Foundation; either version 2 of the License, or (at
# your option) any later version.
#
# Smart Package Manager is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Smart Package Manager; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#

# code to handle solaris RHN package management actions

__rhnexport__ = [
    'remove',
    'install',
    'patchInstall',
    'patchRemove',
    'patchClusterInstall',
    'checkNeedUpdate',
    'refresh_list'
    ]

from smart import init, iface

def install(pkgs):
    print "Installing packages %s" % pkgs
    import smart.commands.install as install

    inst_pkgs = []
    for (pkg, data) in pkgs:
        inst_pkgs.append("%s-%s-%s" % (pkg[0], pkg[1], pkg[2]))
        if data.has_key('answerfile'):
            # FIXME (20050426): Handle answer file
            pass

    ctrl = init()
    opts = install.parse_options([])
    opts.args = inst_pkgs
    opts.yes = True

    try:
        install.main(ctrl, opts)
        refresh_list()
    except Exception, e:
        msg = "Package install failed"
        if e.args:
            msg += ": %s"
            msg %= str(e.args[0])
        data = {'version': 0, 'name' : 'solarispkgs.install'}
        return (101, msg, data)
    else:
        return (0, "%s installed successfully" % pkgs, {})

def remove(pkgs):
    print "Removing packages %s" % pkgs
    import smart.commands.remove as remove

    del_pkgs = []
    for (pkg, data) in pkgs:
        del_pkgs.append(pkg[0])

    ctrl = init()
    opts = remove.parse_options([])
    opts.args = del_pkgs
    opts.yes = True

    print pkgs, del_pkgs

    try:
        remove.main(ctrl, opts)
        refresh_list()
    except Exception, e:
        msg = "Package remove failed"
        if e.args:
            msg += ": %s"
            msg %= str(e.args[0])
        data = {'version': 0, 'name' : 'solarispkgs.remove'}
        return (100, msg, data)
    else:
        return (0, "%s removed successfully" % pkgs, {})

def patchInstall(pkgs, keepBackup=None):
    print "Installing patches %s" % pkgs

    import smart.commands.install as install

    inst_pkgs = []
    for (pkg, data) in pkgs:
        inst_pkgs.append("%s-%s-%s" % (pkg[0], pkg[1], pkg[2]))

    ctrl = init()
    opts = install.parse_options([])
    opts.args = inst_pkgs
    opts.yes = True

    try:
        install.main(ctrl, opts)
        refresh_list()
    except Exception, e:
        msg = "Patch install failed"
        if e.args:
            msg += ": %s"
            msg %= str(e.args[0])
        data = {'version': 0, 'name' : 'solarispkgs.patchInstall'}
        return (102, msg, data)
    else:
        return (0, "%s installed successfully" % pkgs, {})

def patchRemove(pkgs):
    print "Removing patches %s" % pkgs

    import smart.commands.remove as remove

    del_pkgs = []
    for (pkg, data) in pkgs:
        # name-version-release (skip epoch)
        pkgname = '-'.join(pkg[:-1])
        del_pkgs.append(pkgname)

    ctrl = init()
    opts = remove.parse_options([])
    opts.args = del_pkgs
    opts.yes = True

    print pkgs, del_pkgs

    try:
        remove.main(ctrl, opts)
        refresh_list()
    except Exception, e:
        msg = "Patch remove failed"
        if e.args:
            msg += ": %s"
            msg %= str(e.args[0])
        data = {'version': 0, 'name' : 'solarispkgs.patchRemove'}
        return (103, msg, data)
    else:
        return (0, "%s removed  successfully" % pkgs, {})


def patchClusterInstall(pkgs):
    print "Installing patch cluster: ", pkgs

    import smart.commands.install as install

    inst_pkgs = []
    for (pkg, data) in pkgs:
        inst_pkgs.append("%s-%s-%s" % (pkg[0], pkg[1], pkg[2]))

    ctrl = init()
    opts = install.parse_options([])
    opts.args = inst_pkgs
    opts.yes = True

    try:
        install.main(ctrl, opts)
        refresh_list()
    except Exception, e:
        msg = "Patch cluster install failed"
        if e.args:
            msg += ": %s"
            msg %= str(e.args[0])
        data = {'version': 0, 'name' : 'solarispkgs.patchClusterInstall'}
        # FIXME (20050613): What is the proper return value here?
        return (102, msg, data)
    else:
        return (0, "%s installed successfully" % pkgs, {})

def checkNeedUpdate(rhnsd=None):
    print "Doing checkNeedUpdate"

    # FIXME (20050426): This should check to see if an update is
    # needed.
    #return (0, "package database not modified since last update", {})

    return refresh_list()


# format: [name, version, release, epoch, arch]
# arch values: sysv-solaris, solaris-patch, solaris-patch-cluster
def refresh_list():
    command = {"action" : "packages"}
    ctrl = init(command, interface="up2date")
    exitdata = iface.run(command)
    #return exitdata

    return (0, "package list refresh successfully", {})

if __name__ == "__main__":
    pass

