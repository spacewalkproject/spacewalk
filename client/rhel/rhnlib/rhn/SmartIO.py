#
# Smart IO class
#
# Copyright (c) 2002-2005 Red Hat, Inc.
#
# Author: Mihai Ibanescu <misa@redhat.com>

# $Id$
"""
This module implements the SmartIO class
"""

import os
import time
from cStringIO import StringIO

class SmartIO:
    """
    The SmartIO class allows one to put a cap on the memory consumption.
    StringIO objects are very fast, because they are stored in memory, but
    if they are too big the memory footprint becomes noticeable.
    The write method of a SmartIO determines if the data that is to be added
    to the (initially) StrintIO object does not exceed a certain threshold; if
    it does, it switches the storage to a temporary disk file
    """
    def __init__(self, max_mem_size=16384, force_mem=0):
        self._max_mem_size = max_mem_size
        self._io = StringIO()
        # self._fixed is a flag to show if we're supposed to consider moving
        # the StringIO object into a tempfile
        # Invariant: if self._fixed == 0, we have a StringIO (if self._fixed
        # is 1 and force_mem was 0, then we have a file)
        if force_mem:
            self._fixed = 1
        else:
            self._fixed = 0

    def set_max_mem_size(self, max_mem_size):
        self._max_mem_size = max_mem_size

    def get_max_mem_size(self):
        return self._max_mem_size

    def write(self, data):
        if not self._fixed:
            # let's consider moving it to a file
            if len(data) + self._io.tell() > self._max_mem_size:
                # We'll overflow, change to a tempfile
                tmpfile = _tempfile()
                tmpfile.write(self._io.getvalue())
                self._fixed = 1
                self._io = tmpfile

        self._io.write(data)

    def __getattr__(self, name):
        return getattr(self._io, name)

# Creates a temporary file and passes back its file descriptor
def _tempfile(tmpdir=None):
    import tempfile
    if not tmpdir:
        tmpdir = getDefaultStorage()
    (fd, fname) = tempfile.mkstemp(prefix="_rhn_transports-%d-" \
                                   % os.getpid(), dir=tmpdir)
    # tempfile, unlink it
    os.unlink(fname)
    return os.fdopen(fd, "wb+")

def getDefaultStorage():
    """ Reads the default temp dir from up2date config.
    if defined uses that else use /tmp. """
    up2dateCfg = "/etc/sysconfig/rhn/up2date"
    tmpdir = "/tmp"
    try:
        f = open(up2dateCfg)
    except IOError:
        return tmpdir
    for line in f.readlines():
        if line.startswith("tmpDir="): 
            cfgdir = line.split("=")
            if len(cfgdir) > 1:
               tmpdir = cfgdir[-1].strip() or tmpdir
    f.close()
    # if tmpdir is still not acquired, default to /tmp
    return tmpdir
