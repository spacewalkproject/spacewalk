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
import string
import shutil
import pwd
import grp
import up2date_config_parser
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
    return normalize_path(string.join(args, os.sep))

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
    
    (directory, filename) = os.path.split(dst)
    try:
        mkdir_p(directory)
    except OSError, e:
        if e.errno != 17:
            # not File exists
            raise

    if os.path.isdir(src):
	if not os.path.exists(dst):
	    os.mkdir(dst)
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
	d = apply(os.path.join, components[:i+1])
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


def sha1_file(file):
    engine = hashlib.new('sha1')

    fh = open(file, "r")
    while 1:
        buf = fh.read(4096)
        if not buf:
            break

        engine.update(buf)

    return engine.hexdigest()

def endswith(s, suffix):
    return (s[:len(suffix)] == suffix)

def startswith(s, prefix):
    return (s[:len(prefix)] == prefix)

def get_up2date_config():
    c = up2date_config_parser.ConfigFile()
    c.load()

    result = {}

    # load result with values from the parser
    # in a way that works on RHEL 2.1 and 3
    for key in c.keys():
        result[key] = c[key]
    
    #6/29/05 wregglej 152388
    # If there are multiple servers listing in the up2date config file, then serverURL is a list
    # and has to be placed as the value for the 'server_list' key. The value for 'server_url' is
    # pieced together from 'proto' and 'server_name', so those always have to be set to something.
    # In this case I've grabbed their values from the first element in the serverURL list.
    if c.has_key('serverURL'):
        server_url = c['serverURL']
        if server_url:
            # Check to see if serverURL is a list, which means there were multiple servers in the up2date config.
            if type(server_url) == type([]):
                
                #'server_list' is set. The rest of rhncfg should be smart enough to use this if it's present, unless
                #the rhncfg config explicitly lists a server.
                result['server_list'] = server_url 
                
                #set 'proto' and 'server_name', which will form 'server_url', which rhncfg needs.
                arr = parse_url(server_url[0], scheme="https")
                result['proto'] = arr[0]
                result['server_name'] = arr[1]

            # If we get here, then the serverURL was only a single a single server.
            else:
                ret = {}
                arr = parse_url(server_url, scheme="https")
                ret['proto'] = arr[0]
                ret['server_name'] = arr[1]
                result['serverURL'] = [ret]
                result['proto'] = result['serverURL'][0]['proto']
                result['server_name'] = result['serverURL'][0]['server_name']
    return result

def parse_url_list(server_url_list, scheme="https"):
    ret = []
    for i in range(len(server_url_list)):
        result = {}
        arr = parse_url(server_url_list[i], scheme)
        result['proto'] = arr[0]
        result['server_name'] = arr[1]
        ret.append(result)
    return ret
        

def parse_url(server_url, scheme="https"):
    return urlparse.urlparse(server_url, scheme=scheme)
    
def unparse_url(url_tuple):
    return urlparse.urlunparse(url_tuple)

def get_home_dir():
    uid = os.getuid()
    ent = pwd.getpwuid(uid)
    return ent[5]

def set_file_info(file, finfo):
       os.chmod(file, int(str(finfo['filemode']),8))
       uid = pwd.getpwnam(finfo['username'])[2]
       gid = grp.getgrnam(finfo['groupname'])[2]
       os.chown(file, uid, gid)

