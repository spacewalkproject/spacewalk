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
import sys
import pwd
import grp
import time
import types
import shutil
import string
import popen2
import select
import urlparse
from common import log_debug, log_error

try:
    import hashlib
except ImportError:
    import md5
    import sha
    from Crypto.Hash import SHA256 as sha256
    class hashlib:
        @staticmethod
        def new(checksum):
            if checksum == 'md5':
                return md5.new()
            elif checksum == 'sha1':
                return sha.new()
            elif checksum == 'sha256':
                return sha256.new()
            else:
                raise ValueError, "Incompatible checksum type"


def setHeaderValue(mp_table, name, values):
    """
    Function that correctly sets headers in an Apache-like table
    The values may be a string (which are set as for a dictionary),
    or an array.
    """
    # mp_table is an Apache mp_table (like headers_in or headers_out)
    # Sets the header name to the values
    if type(values) in (types.ListType, types.TupleType):
        for v in values:
            mp_table.add(name, str(v))
    else:
        mp_table[name] = str(values)


def rfc822time(arg):
    """
    Return time as a string formatted such as: 'Wed, 23 Jun 2001 23:08:35 GMT'.
    """
    format = "%a, %d %b %Y %H:%M:%S GMT"
    if type(arg) in (types.ListType, types.TupleType):
        # Already a list
        return time.strftime(format, arg)
    # Assume it's a float
    return time.strftime(format, time.gmtime(arg))


rfc822_days = ('Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun')
rfc822_mons = ('Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', \
               'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec')


def rfc822time(arg):
    """
    Return time as a string formatted such as: 'Wed, 23 Jun 2001 23:08:35 GMT'.
    We must not use locale-specific functions such as strftime here because
    the RFC explicitly requires C-locale only formatting.  To satisfy this
    requirement, we declare our own days and months here and do the formatting
    manually.

    This function accepts a single argument.  If it is a List or Tuple type,
    it is assumed to be of the form struct_time, as specified in the Python
    time module reference.  If the argument is a float, it is expected to be
    the number of seconds from the epoch.

    NOTE:  In all cases, the argument is assumed to be in local time.  It will
           be translated to GMT in the return value.
    """

    if type(arg) in (types.ListType, types.TupleType):
        # Convert to float.
        arg = time.mktime(arg)

    # Now, the arg must be a float.

    (tm_year, tm_mon, tm_mday, tm_hour, tm_min, \
         tm_sec, tm_wday, tm_yday, tm_isdst) = time.gmtime(arg)

    return \
        "%s, %02d %s %04d %02d:%02d:%02d %s" % \
            (rfc822_days[tm_wday], tm_mday, rfc822_mons[tm_mon - 1], tm_year, \
             tm_hour, tm_min, tm_sec, "GMT")


def timestamp(s):
    """
    Converts the string in format YYYYMMDDHHMISS to seconds from the epoch
    """
    if type(s) in (types.IntType, types.FloatType):
        # Presumably already a timestamp
        return s
    if len(s) == 14:
        format_string = "%Y%m%d%H%M%S"
    elif len(s) == 19:
        format_string = "%Y-%m-%d %H:%M:%S"
    else:
        raise TypeError("String '%s' is not a YYYYMMDDHHMISS" % s)
    # Get the current DST setting
    timeval = list(time.strptime(s, format_string))
    # No daylight information available
    timeval[8] = -1
    return time.mktime(timeval)


def checkValue(val, *args):
    """ A type/value checker
        Check value against the list of acceptable values / types
    """

    for a in args:
        if type(a) is types.TypeType:
            # Is val of type a?
            if type(val) is a:
                return 1
        else:
            # This is an actual value we allow
            if val == a:
                return 1
    return 0


def cleanupAbsPath(path):
    """ take ~taw/../some/path/$MOUNT_POINT/blah and make it sensible.

        Path return is absolute.
        NOTE: python 2.2 fixes a number of bugs with this and eliminates
              the need for os.path.expanduser
    """

    if path is None:
        return None
    return os.path.abspath(
             os.path.expanduser(
               os.path.expandvars(path)))


def cleanupNormPath(path):
    """ take ~taw/../some/path/$MOUNT_POINT/blah and make it sensible.

        Returned path may be relative.
        NOTE: python 2.2 fixes a number of bugs with this and eliminates
              the need for os.path.expanduser
    """
    if path is None:
        return None
    return os.path.normpath(
             os.path.expanduser(
               os.path.expandvars(path)))


def parseUrl(url):
    """ urlparse is more complicated than what we need.

        We make the assumption that the URL has real URL information.
        NOTE: http/https ONLY for right now.

        The normal behavior of urlparse:
            - if no {http[s],file}:// then the string is considered everything
              that normally follows the URL, e.g. /XMLRPC
            - if {http[s],file}:// exists, anything between that and the next /
              is the URL.

        The behavior of *this* function:
            - if no {http[s],file}:// then the string is simply assumed to be a
              URL without the {http[s],file}:// attached. The parsed info is
              reparsed as one would think it would be:

            - returns: (addressing scheme, network location, path,
                        parameters, query, fragment identifier).

              NOTE: netloc (or network location) can be HOSTNAME:PORT
    """
    schemes = ('http', 'https')
    if url is None:
        return None
    parsed = list(urlparse.urlparse(url))
    if not parsed[0] or parsed[0] not in schemes:
        url = 'https://' + url
        parsed = list(urlparse.urlparse(url))
        parsed[0] = ''
    return tuple(parsed)


class InvalidUrlError(Exception):
    pass


def fix_url(url, scheme="http", path="/"):
    if string.lower(scheme) not in ('http', 'https'):
        # Programmer error
        raise ValueError("Unknown URL scheme %s" % scheme)
    _scheme, _netloc, _path, _params, _query, _fragment = \
        urlparse.urlparse(url)

    if not _netloc:
        # No schema - trying to patch it up
        new_url = scheme + '://' + url
        _scheme, _netloc, _path, _params, _query, _fragment = \
            urlparse.urlparse(new_url)

    if string.lower(_scheme) not in ('http', 'https'):
        raise InvalidUrlError("Invalid scheme %s for URL %s" % (_scheme, url))

    if not _netloc:
        raise InvalidUrlError(url)

    if _path == '':
        _path = path

    url = urlparse.urlunparse((_scheme, _netloc, _path, _params, _query,
        _fragment))
    return url


def maketemp(prefix):
    """ Creates a temporary file (guaranteed to be new), using the
        specified prefix.
        Returns the filename and an open file descriptor (low-level)
    """

    filename = "%s-%s-%.8f" % (prefix, os.getpid(), time.time())
    tries = 10
    while tries > 0:
        tries = tries - 1
        try:
            fd = os.open(filename, os.O_RDWR | os.O_CREAT | os.O_EXCL, 0600)
        except OSError, e:
            if e.errno != 17:
                raise e
            # File already exists
            filename = "%s-%.8f" % (filename, time.time())
        else:
            break
    else:
        raise OSError("Could not create temp file")

    return filename, fd


def make_temp_file(prefix):
    """Creates a temporary file stream (returns an open file object)

    Returns a read/write stream pointing to a file that goes away once the
    stream is closed
    """

    filename, fd = maketemp(prefix)

    os.unlink(filename)
    # Since maketemp returns a freshly created file, we can skip the truncation
    # part (w+); r+ should do just fine
    return os.fdopen(fd, "r+b")


def rotateFile(filepath, depth=5, suffix='.', verbosity=0):
    """ backup/rotate a file
        depth (-1==no limit) refers to num. of backups (rotations) to keep.

        Behavior:
          (1)
            x.txt (current)
            x.txt.1 (old)
            x.txt.2 (older)
            x.txt.3 (oldest)
          (2)
            all file stats preserved. Doesn't blow away original file.
          (3)
            if x.txt and x.txt.1 are identical (size or md5sum), None is
            returned
    """

    # check argument sanity (should really be down outside of this function)
    if not filepath or type(filepath) != type(''):
        raise ValueError("filepath '%s' is not a valid arguement" % filepath)
    if type(depth) != type(0) or depth < -1 \
      or depth > sys.maxint-1 or depth == 0:
        raise ValueError("depth must fall within range "
                         "[-1, 1...%s]" % (sys.maxint-1))

    # force verbosity to be a numeric value
    verbosity = verbosity or 0
    if type(verbosity) != type(0) or verbosity < -1 \
      or verbosity > sys.maxint-1:
        raise ValueError('invalid verbosity value: %s' % (verbosity))

    filepath = cleanupAbsPath(filepath)
    if not os.path.isfile(filepath):
        raise ValueError("filepath '%s' does not lead to a file" % filepath)

    pathNSuffix = filepath + suffix
    pathNSuffix1 = pathNSuffix + '1'


    if verbosity > 1:
        sys.stderr.write("Working dir: %s\n"
                         % os.path.dirname(pathNSuffix))

    # is there anything to do? (existence, then size, then md5sum)
    if os.path.exists(pathNSuffix1) and os.path.isfile(pathNSuffix1) \
      and os.stat(filepath)[6] == os.stat(pathNSuffix1)[6] \
      and getFileMD5(filepath) == getFileMD5(pathNSuffix1):
        # nothing to do
        if verbosity:
            sys.stderr.write("File '%s' is identical to it's rotation. "
                             "Nothing to do.\n" % os.path.basename(filepath))
        return None

    # find last in series (of rotations):
    last = 0
    while os.path.exists('%s%d' % (pathNSuffix, last+1)):
        last = last+1

    # percolate renames:
    for i in range(last, 0, -1):
        os.rename('%s%d' % (pathNSuffix, i), '%s%d' % (pathNSuffix, i+1))
        if verbosity > 1:
            filename = os.path.basename(pathNSuffix)
            sys.stderr.write("Moving file: %s%d --> %s%d\n" % (filename, i,
                                                               filename, i+1))

    # blow away excess rotations:
    if depth != -1:
        last = last+1
        for i in range(depth+1, last+1):
            path = '%s%d' % (pathNSuffix, i)
            os.unlink(path)
            if verbosity:
                sys.stderr.write("Rotated out: '%s'\n" % (
                    os.path.basename(path)))

    # do the actual rotation
    shutil.copy2(filepath, pathNSuffix1)
    if os.path.exists(pathNSuffix1) and verbosity:
        sys.stderr.write("Backup made: '%s' --> '%s'\n"
                         % (os.path.basename(filepath),
                            os.path.basename(pathNSuffix1)))

    # return the full filepath of the backed up file
    return pathNSuffix1


def getFileMD5(filename=None, fd=None, file=None, buffer_size=None):
    """ Compute a file's md5sum
        Used by rotateFile()
    """
    return getFileChecksum('md5', filename, fd, file, buffer_size)

def getFileChecksum(hashtype, filename=None, fd=None, file=None, buffer_size=None):
    """ Compute a file's checksum
        Used by rotateFile()
    """

    # python's md5 lib sucks
    # there's no way to directly import a file.
    if buffer_size is None:
        buffer_size = 65536

    if filename is None and fd is None and file is None:
        raise ValueError("no file specified")
    if file:
        f = file
    elif fd is not None:
        f = os.fdopen(os.dup(fd), "r")
    else:
        f = open(filename, "r")
    # Rewind it
    f.seek(0, 0)
    m = hashlib.new(hashtype)
    while 1:
        buffer = f.read(buffer_size)
        if not buffer:
            break
        m.update(buffer)

    # cleanup time
    if file is not None:
        file.seek(0, 0)
    else:
        f.close()
    return m.hexdigest()


def rhn_popen(cmd, progressCallback=None, bufferSize=16384, outputLog=None):
    """ popen-like function, that accepts execvp-style arguments too (i.e. an
        array of params, thus making shell escaping unnecessary)

        cmd can be either a string (like "ls -l /dev"), or an array of
        arguments ["ls", "-l", "/dev"]

        Returns the command's error code, a stream with stdout's contents
        and a stream with stderr's contents

        progressCallback --> progress bar twiddler
        outputLog --> optional log file file object write method
    """

    popen2._cleanup()

    # If you want unbuffered, set bufsize to 0
    if type(cmd) in (types.ListType, types.TupleType):
        cmd = map(str, cmd)
    c = popen2.Popen3(cmd, capturestderr=1, bufsize=0)

    # We don't write to the child process
    c.tochild.close()

    # Create two temporary streams to hold the info from stdout and stderr
    child_out = make_temp_file("/tmp/my-popen-")
    child_err = make_temp_file("/tmp/my-popen-")

    # Map the input file descriptor with the temporary (output) one
    fd_mappings = [(c.fromchild, child_out), (c.childerr, child_err)]
    exitcode = None
    count = 1

    while 1:
        # Is the child process done?
        status = c.poll()
        if status != -1:
            if os.WIFEXITED(status):
                # Save the exit code, we still have to read from the pipes
                exitcode = os.WEXITSTATUS(status)
            elif os.WIFSIGNALED(status):
                # Some signal terminated this process
                sig = os.WTERMSIG(status)
                if outputLog is not None:
                    outputLog("rhn_popen: terminated: Signal %s received\n" % (
                              sig))
                exitcode = -sig
                break
            elif os.WIFSTOPPED(status):
                # Some signal stopped this process
                sig = os.WSTOPSIG(status)
                if outputLog is not None:
                    outputLog("rhn_popen: stopped: Signal %s received\n" % sig)
                exitcode = -sig
                break

        fd_set = map(lambda x: x[0], fd_mappings)
        readfds = select.select(fd_set, [], [])[0]

        for in_fd, out_fd in fd_mappings:
            if in_fd in readfds:
                # There was activity on this file descriptor
                output = os.read(in_fd.fileno(), bufferSize)
                if output:
                    # show progress
                    if progressCallback:
                        count = count + len(output)
                        progressCallback(count)

                    if outputLog is not None:
                        outputLog(output)

                    # write to the output buffer(s)
                    out_fd.write(output)
                    out_fd.flush()

        if exitcode is not None:
            # Child process is done
            break

    for f_in, f_out in fd_mappings:
        f_in.close()
        f_out.seek(0, 0)

    return exitcode, child_out, child_err


def startswith(s, prefix):
    """
    Trivial function that I wish existed in python 1.5
    """
    return s[:len(prefix)] == prefix


def setPermsPath(path, user='apache', group='root', chmod=0750):
    """chown user.group and set permissions to chmod"""
    if not os.path.exists(path):
        log_error("*** ERROR: Path doesn't exist (can't set permissions): %s" % path)
        sys.exit(-1)

    # If non-root, don't bother to change owners
    if os.getuid() != 0:
        return 

    gc = GecosCache()
    uid = gc.getuid(user)
    if uid is None:
        log_error(messages.missing_user % user)
        sys.exit(-1)

    gid = gc.getgid(group)
    if gid is None:
        log_error(messages.missing_group % group)
        sys.exit(-1)

    uid_, gid_ = os.stat(path)[4:6]
    if uid_ != uid or gid_ != gid:
        log_debug(3, "   Performing 'chown %s.%s %s'" % (user, group, path))
        os.chown(path, uid, gid)
    os.chmod(path, chmod)

class GecosCache:
    "Cache getpwnam() and getgrnam() calls"
    __shared_data = {}

    def __init__(self):
        self.__dict__ = self.__shared_data
        if len(self.__shared_data.keys()) == 0:
            # Not initialized
            self._users = {}
            self._groups = {}

    def getuid(self, name):
        "Return the UID of the user by name"
        if self._users.has_key(name):
            return self._users[name]
        try:
            uid = pwd.getpwnam(name)[2]
        except KeyError:
            # XXX misa: gripe? taw: I think we need to do something!
            sys.stderr.write("XXX: User %s does not exist\n" % name)
            return None
        self._users[name] = uid
        return uid

    def getgid(self, name):
        "Return the GID of the group by name"
        if self._groups.has_key(name):
            return self._groups[name]
        try:
            gid = grp.getgrnam(name)[2]
        except KeyError:
            # XXX misa: gripe?
            sys.stderr.write("XXX: Group %s does not exist\n" % name)
            return None
        self._groups[name] = gid
        return gid

    def reset(self):
        self.__shared_data.clear()
        self.__init__()

def getUidGid(user=None, group=None):
    "return uid, gid given user and group"

    gc = GecosCache()
    uid = os.getuid()
    if uid != 0:
        # Don't bother to change the owner, it will fail anyway
        # group ownership may work though
        user=None
    else:
        uid = gc.getuid(user)

    if group:
        gid = gc.getgid(group)
    else:
        gid = None

    if gid is None:
        gid = os.getgid()
    return uid, gid

def makedirs(path,  mode=0755, user=None, group=None):
    "makedirs function that also changes the owners"
    
    dirs_to_create = []
    dirname = path 
    
    uid, gid = getUidGid(user, group)

    while 1:
        if os.path.isdir(dirname):
            # We're done with this step
            break
        # We have to create this directory
        dirs_to_create.append(dirname)
        dirname, last = os.path.split(dirname)
        if not last:
            # We reached the top directory
            break

    # Now create the directories
    while dirs_to_create:
        dirname = dirs_to_create.pop()
        try:
            os.mkdir(dirname, mode)
        except OSError, e:
            if e.errno != 17: # File exists
                raise
            # Ignore the error
        try:
            os.chown(dirname, uid, gid)
        except OSError:
            # Changing permissions failed; ignore the error
            sys.stderr.write("Changing owner for %s failed\n" % dirname)

def createPath(path, user='apache', group='root', chmod=0755, logging=1):
    """advanced makedirs
    
    Will create the path if necessary.
    Will chmod, and chown that path properly.

    Uses the above makedirs() function.
    """

    path = cleanupAbsPath(path)
    if not os.path.exists(path):
        if logging:
            log_debug(4, "   Creating path: %s" % path)
        makedirs(path, mode=chmod, user=user, group=group)
    elif not os.path.isdir(path):
        raise ValueError, "ERROR: createPath('%s'): path doesn't lead to a directory" % str(path)
    else:
        os.chmod(path, chmod)
        uid, gid = getUidGid(user, group)
        try:
            os.chown(path, uid, gid)
        except OSError:
            # Changing permissions failed; ignore the error
            sys.stderr.write("Changing owner for %s failed\n" % path)

