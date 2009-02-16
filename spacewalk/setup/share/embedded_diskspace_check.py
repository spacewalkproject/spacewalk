#!/usr/bin/python
""" Checks diskspace sizes for for /rhnsat and /opt.
    Used only by the install.sh code.

    Copyright (c) 2002-2005, Red Hat, Inc.
    All rights reserved.

    Author: Todd Warner <taw@redhat.com>
"""
# $Id: embedded_diskspace_check.py,v 1.4 2005-07-12 19:01:14 misa Exp $

import os
import sys
import stat
import string
import statvfs

# these numbers are for *after* package installation.
DEFAULT_NEEDS = {'/rhnsat':          12*(2**30),  # 12GB
                 '/opt/apps/oracle': 0.5*(2**30)}  # 0.5GB additionally


def _listify(seq):
    if type(seq) not in [type([]), type(())]:
        seq = [seq]
    return seq


def _unique(seq):
    """ return a list that has unique members """
    seq = _listify(seq)
    useq = {}
    for elem in seq:
        useq[elem] = 1
    return useq.keys()


def _abspath(path):
    # cleanup absolute path:
    if os.path.exists(path) and os.path.islink(path):
        path = os.readlink(path)
    path = os.path.abspath(
             os.path.expanduser(
               os.path.expandvars(path)))
    return path


def _firstDir(path):
    """ takes a path and walks backwards until it finds an existing directory.
        Follows symlinks.
        FIXME: need to test against NFS directory.
    """

    path = _abspath(path)
    while not (os.path.exists(path) and os.path.isdir(path)):
        path = os.path.dirname(path)
    return path


def _mountpoint(path):
    """ figures out the mountpoint of a directory (or what would be the
        mountpoint if just about to create the directory).
        FIXME: need to test against NFS directory.
    """

    path = _firstDir(path)
    st_dev = os.stat(path)[stat.ST_DEV]
    _next = os.path.dirname(path)
    while os.stat(_next)[stat.ST_DEV] == st_dev and path != '/':
        path = _next
        _next = os.path.dirname(path)
    return path


def paths2mountpoints(paths):
    """ returns a tuple of two dictionaries - one indexed by path, one indexed
        by mountpoint:
        (
            {path00: mpoint0?, path01: mpoint0?, ...},
            {mpoint00: [path00, path01, ...],
             mpoint02: [path05, path06, ...], ...},
        )
    """
    paths = _unique(paths)
    pathsd = {} # 1:1
    mpointsd = {} # indexed on mpoints 1:N
    for path in paths:
        mpoint = _mountpoint(path)
        pathsd[path] = mpoint
        if not mpointsd.has_key(mpoint):
            mpointsd[mpoint] = []
        mpointsd[mpoint].append(path)
    return pathsd, mpointsd


def paths2freespace(paths):
    """ returns a dictionary indexed by path:
        {path00: freespace, path01: freespace, ...}
    """

    paths = _unique(paths)
    pathsd = {} # 1:1
    for path in paths:
        _statvfs = os.statvfs(path)
        f_bavail = _statvfs[statvfs.F_BAVAIL] # non-super user space
        f_bsize = _statvfs[statvfs.F_BSIZE] # respective blocksize
        # build dict indexed by path
        pathsd[path] = long(f_bavail)*f_bsize
    return pathsd


def getNeeds(needsDict=None):
    """ returns two dictionaries of fulfilled and unfilled space per
        mountpoint:

        unfullfilled = {
            mountpoint00: (paths, needs, freespace),
            mountpoint01: (paths, needs, freespace),
            ...,
        }

        fulfilled = {
            mountpoint00: (paths, needs, freespace),
            mountpoint01: (paths, needs, freespace),
            ...,
        }

        needsDict is by default DEFAULT_NEEDS (see top of module)
    """

    needsDict = needsDict or DEFAULT_NEEDS
    mp2pMap = paths2mountpoints(needsDict.keys())[1]
    mp2fsMap = paths2freespace(mp2pMap.keys())

    unfulfilled = {}
    fulfilled = {}

    for mountpoint, paths in mp2pMap.items():
        totalNeeds = 0
        for path in paths:
            totalNeeds = totalNeeds + needsDict[path]
        freespace = mp2fsMap[mountpoint]
        if freespace < totalNeeds:
            unfulfilled[mountpoint] = (paths, totalNeeds, freespace)
        else:
            fulfilled[mountpoint] = (paths, totalNeeds, freespace)

    return unfulfilled, fulfilled


def _humanReadable(n):
    s = repr(n)
    if n >= 2**10:
        s = '%.1fK' % (n/(2**10))
    if n >= 2**20:
        s = '%.1fM' % (n/(2**20))
    if n >= 2**30:
        s = '%.1fG' % (n/(2**30))
    return s


def main(needsDict=None):
    """ determine failed needs if any given needsDict.
        needsDict is by default DEFAULT_NEEDS (see top of module)
    """

    needsDict = needsDict or DEFAULT_NEEDS

    unfulfilled = getNeeds()[0]
    if unfulfilled:
        sys.stderr.write("ERROR: diskspace does not meet minimum system "
                         "requirements:\n")
        items = unfulfilled.items()
        lenItems = len(items)
        for mountpoint, data in items:
            paths, totalNeeds, freespace = data
            msg = """\
           Mountpoint: %s
           Relevant paths serviced by mountpoint: %s
           Disk space needed:    %s bytes (app. %s)
           Disk space available: %s bytes (app. %s)
""" % (mountpoint, string.join(paths, ', '),
       totalNeeds, _humanReadable(totalNeeds),
       freespace, _humanReadable(freespace))
            sys.stderr.write(msg)
            lenItems = lenItems - 1
            if lenItems:
                sys.stderr.write('\n')

    if unfulfilled:
        return 1

    return 0


if __name__ == "__main__":
    sys.exit(main() or 0)

