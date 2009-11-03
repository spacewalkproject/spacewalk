#!/usr/bin/python
#
# Copyright (c) 2008 Red Hat, Inc.
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
# This module implements a simple object caching system using shelves
# stored in files on the file system
#

import os
import gzip
import cPickle
import cStringIO
import fcntl
from struct import pack
from stat import ST_MTIME
from errno import EEXIST

from rhnLib import timestamp, makedirs, setPermsPath
import rhn_posix
import rhn_fcntl

# this is a constant I'm not too happy about but one way or another we have
# to reserve our own shared memory space.
CACHEDIR = "/var/cache/rhn"

# easy structures for locking stuff
WRLOCK = pack("hhiiii", rhn_fcntl.F_WRLCK, rhn_posix.SEEK_SET, 0, 0, 0, 0)
RDLOCK = pack("hhiiii", rhn_fcntl.F_RDLCK, rhn_posix.SEEK_SET, 0, 0, 0, 0)
UNLOCK = pack("hhiiii", rhn_fcntl.F_UNLCK, rhn_posix.SEEK_SET, 0, 0, 0, 0)

def cleanupPath(path):
    """take ~taw/../some/path/$MOUNT_POINT/blah and make it sensible."""
    if path is None:
        return None
    return os.path.normpath(
             os.path.expanduser(
               os.path.expandvars(path)))

# build a filename for storing the key - eventually this is going to get
# more compelx as we observe issues
def _fname(name):
    fname = "%s/%s" % (CACHEDIR, name)
    return cleanupPath(fname)
# Lock it, using default mode rhn_fcntl.F_WRLCK.
def _lock(fd, lock = WRLOCK):
    fcntl.fcntl(fd, rhn_fcntl.F_SETLKW, lock)

def _unlock(fd):
    try:
        fcntl.fcntl(fd, rhn_fcntl.F_SETLKW, UNLOCK)
    except IOError:
        # If LOCK is not relinquished try flock, 
        # its usually more forgiving.
        fcntl.flock(fd, fcntl.LOCK_UN)

### The following functions expose this module as a dictionary


    
def get(name, modified = None, raw = None, compressed=None, missing_is_null=1):
    cache = __get_cache(raw, compressed)

    if missing_is_null:
        cache = NullCache(cache)

    return cache.get(name, modified)

    
def set(name, value, modified = None, raw = None, compressed=None, \
        user='root', group='root', mode=0755):
    cache = __get_cache(raw, compressed)

    cache.set(name, value, modified, user, group, mode)
    
def has_key(name, modified = None):
    cache = Cache()
    return cache.has_key(name, modified)


def delete(name):
    cache = Cache()
    cache.delete(name)


def __get_cache(raw, compressed):
    cache = Cache()
    if compressed:
        cache = CompressedCache(cache)
    if not raw:
        cache = ObjectCache(cache)

    return cache

class UnreadableFileError(Exception):
    pass


# This function returns a file descriptor for the open file fname
# If the file is already there, it is truncated
# otherwise, all the directories up to it are created and the file is created
# as well
def _safe_create(fname, user, group, mode):
    # There can be race conditions between the moment we check for the file
    # existence and when we actually create it, so retry if something fails
    tries = 5
    while tries:
        tries = tries - 1
        # we're really picky about what can we do
        if os.access(fname, os.F_OK): # file exists
            if not os.access(fname, os.R_OK|os.W_OK):
                raise UnreadableFileError()

            fd = os.open(fname, os.O_WRONLY | os.O_TRUNC )
            # We're done
            return fd

        # If directory does not exist, attempt to create it
        dirname = os.path.dirname(fname)
        if not os.path.isdir(dirname):
            try:
                #os.makedirs(dirname, 0755)
                makedirs(dirname, mode, user, group)
            except OSError, e:
                # There is a window between the moment we check the disk and
                # the one we try to create the directory
                # We double-check the file existance here
                if not (e.errno == EEXIST and os.path.isdir(dirname)):
                    # If the exception was thrown on a parent dir
                    # check the subdirectory to go through next loop.
                    if os.path.isdir(e.filename):
                        continue
                    # Pass exception through
                    raise
            except:
                # Pass exception through
                raise
        # If we got here, it means the directory exists
            
        # file does not exist, attempt to create it
        # we pass most of the exceptions through
        try:
            fd = os.open(fname, os.O_WRONLY | os.O_CREAT | os.O_EXCL, 0644)
        except OSError, e:
            # The file may be already there
            if e.errno == EEXIST and os.access(fname, os.F_OK):
                # Retry
                continue
            # Pass exception through
            raise
        # If we got here, the file is created, so break out of the loop
        setPermsPath(fname, user, group, mode)
        return fd

    # Ran out of tries; something is fishy
    # (if we manage to create or truncate the file, we've returned from the
    # function already)
    raise RuntimeError, "Attempt to create file %s failed" % fname


class LockedFile(object):

    def __init__(self, name, modified = None, user='root', group='root', \
                 mode=0755):
        if modified:
            self.modified = timestamp(modified)
        else:
            self.modified = None
        
        self.fname = _fname(name)
        self.fd = self.get_fd(name, user, group, mode)

        self.closed = False

    def close(self):
        if not self.closed:
            self.close_fd()

            _unlock(self.fd.fileno())
            self.fd.close()
            self.closed = True

#    def __del__(self):
#        if not self.closed:
#            self.close()

    def __getattr__(self, x):
        return getattr(self.fd, x)


class ReadLockedFile(LockedFile):

    def get_fd(self, name, user, group, mode):
        if not os.access(self.fname, os.R_OK):
            raise KeyError(name)
        fd = open(self.fname, "r")

        _lock(fd.fileno(), RDLOCK)

        if self.modified:
            if os.fstat(fd.fileno())[ST_MTIME] != self.modified:
                fd.close()
                raise KeyError(name)

        return fd

    def close_fd(self):
        pass

class WriteLockedFile(LockedFile):

    def get_fd(self, name, user, group, mode):
        try:
            fd = _safe_create(self.fname, user, group, mode)
        except UnreadableFileError:
            raise OSError, "cache entry exists, but is not accessible: %s" % \
                name

        # now we have the fd open, lock it
        _lock(fd)
        return os.fdopen(fd, 'w')

    def close_fd(self):
        # Set the file's mtime if necessary
        self.flush()
        if self.modified:
            os.utime(self.fname, (self.modified, self.modified))


class Cache:

    def get(self, name, modified = None):
        fd = self.get_file(name, modified)

        s = fd.read()
        fd.close()

        return s

    def set(self, name, value, modified = None, user='root', group='root',\
            mode=0755):
        fd = self.set_file(name, modified, user, group, mode)

        fd.write(value)
        fd.close()

    def has_key(self, name, modified = None):
        fname = _fname(name)
        if modified is not None:
            modified = timestamp(modified)
        if not os.access(fname, os.R_OK):
            return False
        # the file exists, so os.stat should not raise an exception
        statinfo = os.stat(fname)
        if modified is not None and statinfo[ST_MTIME] != modified:
            return False
        return True

    def delete(self, name):
        fname = _fname(name)
        # test for valid entry
        if not os.access(fname, os.R_OK):
            raise KeyError, "Invalid cache key for delete: %s" % name
        # now can we delete it?
        if not os.access(fname, os.W_OK):
            raise OSError, "Read-Only access for cache entry: %s" % name
        os.unlink(fname)

    def get_file(self, name, modified = None):
        fd = ReadLockedFile(name, modified)
        return fd

    def set_file(self, name, modified = None, user='root', group='root', \
                 mode=0755):
        fd = WriteLockedFile(name, modified, user, group, mode)
        return fd


class ClosingZipFile(object):

    """ Like a GzipFile, but close closes both files. """

    def __init__(self, mode, io):
        self.zipfile = gzip.GzipFile(None, mode, 5, io)
        self.rawfile = io

    def close(self):
        self.zipfile.close()
        self.rawfile.close()

    def __getattr__(self, x):
        return getattr(self.zipfile, x)


class CompressedCache:
    def __init__(self, cache):
        self.cache = cache

    def get(self, name, modified = None):
        fd = self.get_file(name, modified) 
        try:
            value = fd.read()
        except (ValueError, IOError, gzip.zlib.error), e:
            # Some gzip error
            # XXX poking at gzip.zlib may not be such a good idea
            fd.close()
            raise KeyError(name)
        fd.close()

        return value
    
    def set(self, name, value, modified = None, user='root', group='root', \
            mode=0755):
        # Since most of the data is kept in memory anyway, don't bother to
        # write it to a temp file at this point
        f = self.set_file(name, modified, user, group, mode)
        f.write(value)
        f.close()

    def has_key(self, name, modified = None):
        return self.cache.has_key(name, modified)
        
    def delete(self, name):
        self.cache.delete(name)
        
    def get_file(self, name, modified = None):
        compressed_file = self.cache.get_file(name, modified)
        return ClosingZipFile('r', compressed_file)

    def set_file(self, name, modified = None, user='root', group='root', \
                 mode=0755):
        io = self.cache.set_file(name, modified, user, group, mode)

        f = ClosingZipFile('w', io)
        return f

class ObjectCache:
    def __init__(self, cache):
        self.cache = cache

    def get(self, name, modified = None):
        pickled = self.cache.get(name, modified)

        try:
            return cPickle.loads(pickled)
        except cPickle.UnpicklingError:
            raise KeyError(name)
    
    def set(self, name, value, modified = None, user='root', group='root',\
            mode=0755):
        pickled = cPickle.dumps(value, -1)
        self.cache.set(name, pickled, modified, user, group, mode)

    def has_key(self, name, modified = None):
        return self.cache.has_key(name, modified)
        
    def delete(self, name):
        self.cache.delete(name)
        
    def get_file(self, name, modified = None):
        """ Getting a file descriptor for an object makes no sense. """
        raise NotImplementedError

class NullCache:
    """ A cache that returns None rather than raises a KeyError. """

    def __init__(self, cache):
        self.cache = cache

    def get(self, name, modified = None):
        try:
            return self.cache.get(name, modified)
        except KeyError:
            return None

    def set(self, name, value, modified = None, user='root', group='root', \
            mode=0755):
        self.cache.set(name, value, modified, user, group, mode)

    def has_key(self, name, modified = None):
        return self.cache.has_key(name, modified)

    def delete(self, name):
        self.cache.delete(name)

    def get_file(self, name, modified = None):
        try:
            return self.cache.get_file(name, modified)
        except KeyError:
            return None

    def set_file(self, name, modified = None, user='root', group='root', \
                 mode=0755):
        return self.cache.set_file(name, modified, user, group, mode)
