#
# Copyright (c) 2008--2010 Red Hat, Inc.
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
try:
    import hashlib
except ImportError:
    import sha
    class hashlib:
        @staticmethod
        def new(checksum):
            if checksum == 'sha1':
                return sha.new()
            else:
                raise ValueError, "Incompatible checksum type"
import re
import shutil
import pwd
import urlparse
from config_common.rhn_log import log_debug

_normpath_re = re.compile("^(%s)+" % os.sep)
def normalize_path(path):
    """
    os.path.normpath does not remove path separator duplicates at the
    beginning of the path
    """
    return _normpath_re.sub(os.sep, os.path.normpath(path))

def join_path(*args):
    return normalize_path(os.sep.join(args))

def path_full_split(path):
    """
    Given a path, it fully splits it into constituent path
    components (as opposed to os.path.split which splits it into
    trailing component and preceeding path
    """
    
    path = normalize_path(path)
    splitpath = []
    while 1:
        path, current = os.path.split(path)
        if current == '':
            if path:
                # Absolute path
                splitpath.append(os.sep)
            break
        splitpath.append(current)

    splitpath.reverse()
    return splitpath

def copyfile_p(src, dst):
    """
    Simple util function, copies src path to dst path, making
    directories as necessary. File permissions are not preserved.
    """
    
    directory = os.path.split(dst)[0]
    try:
        os.makedirs(directory)
    except OSError, e:
        if e.errno != 17:
            # not File exists
            raise

    if os.path.isdir(src):
        if not os.path.exists(dst):
            os.mkdir(dst)
    elif os.path.islink(src):
        exists = hasattr(os.path, "lexists") and os.path.lexists or os.path.exists
        if exists(dst):
            os.remove(dst)
        os.symlink(os.readlink(src), dst)
    else:
        shutil.copyfile(src, dst)

def mkdir_p(path, mode=None):
    """
    Similar to 'mkdir -p' -- makes all directories necessary to ensure
    the 'path' is a directory, and return the list of directories that were 
    made as a result
    """
    if not mode:
        mode = 0700
    dirs_created = []

    components = path_full_split(path)
    for i in range(1,len(components)):
        d = os.path.join(*components[:i+1])
        log_debug(8, "testing",d)
        try:
            os.mkdir(d, mode)
        except OSError, e:
            if e.errno != 17:
                raise
            else:
                log_debug(8, "created",d)
        dirs_created.append(d)

    log_debug(6, "dirs_created:",dirs_created)
	
    return dirs_created
	
def rmdir_p(path, stoppath):
    """
    if rmdir had a -p option, this would be it.  remove dir and up
    until empty dir is hit, or stoppath is reached

    path and stoppath have to be absolute paths
    """

    # First normalize both paths
    stoppath = normalize_path(os.sep + stoppath)
    path = normalize_path(os.sep + path)

    # stoppath has to be a prefix of path
    if path[:len(stoppath)] != stoppath:
        raise OSError, "Could not remove %s: %s is not a prefix" % (
            path, stoppath)
    
    while 1:
        if stoppath == path:
            # We're done
            break

        # Try to remove the directory
        try:
            os.rmdir(path)
        except OSError:
            # Either the directory is full, or we don't have permissions; stop
            break

        path, current = os.path.split(path)
        if current == '':
            # We're done - reached the root
            break
           
#returns slashstring with any trailing slash removed
def rm_trailing_slash(slashstring):
    if slashstring[-1] == "/":
        slashstring = slashstring[0:-1]
    return slashstring


def sha1_file(filename):
    engine = hashlib.new('sha1')

    fh = open(filename, "r")
    while 1:
        buf = fh.read(4096)
        if not buf:
            break

        engine.update(buf)

    return engine.hexdigest()

def parse_url(server_url, scheme="https"):
    return urlparse.urlparse(server_url, scheme=scheme)
    
def unparse_url(url_tuple):
    return urlparse.urlunparse(url_tuple)

def get_home_dir():
    uid = os.getuid()
    ent = pwd.getpwuid(uid)
    return ent[5]
