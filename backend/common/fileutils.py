#
# Copyright (c) 2008--2015 Red Hat, Inc.
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
import bz2
import gzip
import pwd
import grp
import types
import shutil
import subprocess
import select
import stat
import tempfile
from checksum import getFileChecksum


def cleanupAbsPath(path):
    """ take ~taw/../some/path/$MOUNT_POINT/blah and make it sensible.

        Path returned is absolute.
        NOTE: python 2.2 fixes a number of bugs with this and eliminates
              the need for os.path.expanduser
    """

    if path is None:
        return None
    return os.path.abspath(
        os.path.expanduser(
            os.path.expandvars(path)))


def cleanupNormPath(path, dotYN=0):
    """ take ~taw/../some/path/$MOUNT_POINT/blah and make it sensible.

        Returned path may be relative.
        NOTE: python 2.2 fixes a number of bugs with this and eliminates
              the need for os.path.expanduser
    """
    if path is None:
        return None
    path = os.path.normpath(
        os.path.expanduser(
            os.path.expandvars(path)))
    if dotYN and not (path and path[0] == '/'):
        dirs = path.split('/')
        if dirs[:1] not in (['.'], ['..']):
            dirs = ['.'] + dirs
        path = '/'.join(dirs)
    return path


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
            if x.txt and x.txt.1 are identical (size or checksum), None is
            returned
    """

    # check argument sanity (should really be down outside of this function)
    if not filepath or not isinstance(filepath, type('')):
        raise ValueError("filepath '%s' is not a valid arguement" % filepath)
    if not isinstance(depth, type(0)) or depth < -1 \
            or depth > sys.maxint - 1 or depth == 0:
        raise ValueError("depth must fall within range "
                         "[-1, 1...%s]" % (sys.maxint - 1))

    # force verbosity to be a numeric value
    verbosity = verbosity or 0
    if not isinstance(verbosity, type(0)) or verbosity < -1 \
            or verbosity > sys.maxint - 1:
        raise ValueError('invalid verbosity value: %s' % (verbosity))

    filepath = cleanupAbsPath(filepath)
    if not os.path.isfile(filepath):
        raise ValueError("filepath '%s' does not lead to a file" % filepath)

    pathNSuffix = filepath + suffix
    pathNSuffix1 = pathNSuffix + '1'

    if verbosity > 1:
        sys.stderr.write("Working dir: %s\n"
                         % os.path.dirname(pathNSuffix))

    # is there anything to do? (existence, then size, then checksum)
    checksum_type = 'sha1'
    if os.path.exists(pathNSuffix1) and os.path.isfile(pathNSuffix1) \
            and os.stat(filepath)[6] == os.stat(pathNSuffix1)[6] \
            and getFileChecksum(checksum_type, filepath) == \
            getFileChecksum(checksum_type, pathNSuffix1):
        # nothing to do
        if verbosity:
            sys.stderr.write("File '%s' is identical to its rotation. "
                             "Nothing to do.\n" % os.path.basename(filepath))
        return None

    # find last in series (of rotations):
    last = 0
    while os.path.exists('%s%d' % (pathNSuffix, last + 1)):
        last = last + 1

    # percolate renames:
    for i in range(last, 0, -1):
        os.rename('%s%d' % (pathNSuffix, i), '%s%d' % (pathNSuffix, i + 1))
        if verbosity > 1:
            filename = os.path.basename(pathNSuffix)
            sys.stderr.write("Moving file: %s%d --> %s%d\n" % (filename, i,
                                                               filename, i + 1))

    # blow away excess rotations:
    if depth != -1:
        last = last + 1
        for i in range(depth + 1, last + 1):
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

    cmd_is_list = isinstance(cmd, (types.ListType, types.TupleType))
    if cmd_is_list:
        cmd = map(str, cmd)
    # pylint: disable=E1101
    c = subprocess.Popen(cmd, bufsize=0, stdin=subprocess.PIPE,
                         stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                         close_fds=True, shell=(not cmd_is_list))

    # We don't write to the child process
    c.stdin.close()

    # Create two temporary streams to hold the info from stdout and stderr
    child_out = tempfile.TemporaryFile(prefix='/tmp/my-popen-', mode='r+b')
    child_err = tempfile.TemporaryFile(prefix='/tmp/my-popen-', mode='r+b')

    # Map the input file descriptor with the temporary (output) one
    fd_mappings = [(c.stdout, child_out), (c.stderr, child_err)]
    exitcode = None
    count = 1

    while 1:
        # Is the child process done?
        status = c.poll()
        if status is not None:
            if status >= 0:
                # Save the exit code, we still have to read from the pipes
                exitcode = status
            else:
                # Some signal sent to this process
                if outputLog is not None:
                    outputLog("rhn_popen: Signal %s received\n" % (-status))
                exitcode = status
                break

        fd_set = [x[0] for x in fd_mappings]
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
            if e.errno != 17:  # File exists
                raise
            # Ignore the error
        try:
            os.chown(dirname, uid, gid)
        except OSError:
            # Changing permissions failed; ignore the error
            sys.stderr.write("Changing owner for %s failed\n" % dirname)


def createPath(path, user='apache', group='apache', chmod=0755):
    """advanced makedirs

    Will create the path if necessary.
    Will chmod, and chown that path properly.

    Uses the above makedirs() function.
    """

    path = cleanupAbsPath(path)
    if not os.path.exists(path):
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


def setPermsPath(path, user='apache', group='root', chmod=0750):
    """chown user.group and set permissions to chmod"""
    if not os.path.exists(path):
        raise OSError, "*** ERROR: Path doesn't exist (can't set permissions): %s" % path

    # If non-root, don't bother to change owners
    if os.getuid() != 0:
        return

    gc = GecosCache()
    uid = gc.getuid(user)
    if uid is None:
        raise OSError, "*** ERROR: user '%s' doesn't exist. Cannot set permissions properly." % user

    gid = gc.getgid(group)
    if gid is None:
        raise OSError, "*** ERROR: group '%s' doesn't exist. Cannot set permissions properly." % group

    uid_, gid_ = os.stat(path)[4:6]
    if uid_ != uid or gid_ != gid:
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
        user = None
    else:
        uid = gc.getuid(user)

    if group:
        gid = gc.getgid(group)
    else:
        gid = None

    if gid is None:
        gid = os.getgid()
    return uid, gid

# Duplicated in client/tools/rhncfg/config_common/file_utils.py to remove dependency
# requirement. If making changes make them there too.
FILETYPE2CHAR = {
    'file': '-',
    'directory': 'd',
    'symlink': 'l',
    'chardev': 'c',
    'blockdev': 'b',
}

# Duplicated in client/tools/rhncfg/config_common/file_utils.py to remove dependency
# requirement. If making changes make them there too.


def _ifelse(cond, thenval, elseval):
    if cond:
        return thenval
    else:
        return elseval

# Duplicated in client/tools/rhncfg/config_common/file_utils.py to remove dependency
# requirement. If making changes make them there too.


def ostr_to_sym(octstr, ftype):
    """ Convert filemode in octets (like '644') to string like "ls -l" ("-rwxrw-rw-")
        ftype is one of: file, directory, symlink, chardev, blockdev.
    """
    mode = int(str(octstr), 8)

    symstr = FILETYPE2CHAR.get(ftype, '?')

    symstr += _ifelse(mode & stat.S_IRUSR, 'r', '-')
    symstr += _ifelse(mode & stat.S_IWUSR, 'w', '-')
    symstr += _ifelse(mode & stat.S_IXUSR,
                      _ifelse(mode & stat.S_ISUID, 's', 'x'),
                      _ifelse(mode & stat.S_ISUID, 'S', '-'))
    symstr += _ifelse(mode & stat.S_IRGRP, 'r', '-')
    symstr += _ifelse(mode & stat.S_IWGRP, 'w', '-')
    symstr += _ifelse(mode & stat.S_IXGRP,
                      _ifelse(mode & stat.S_ISGID, 's', 'x'),
                      _ifelse(mode & stat.S_ISGID, 'S', '-'))
    symstr += _ifelse(mode & stat.S_IROTH, 'r', '-')
    symstr += _ifelse(mode & stat.S_IWOTH, 'w', '-')
    symstr += _ifelse(mode & stat.S_IXOTH,
                      _ifelse(mode & stat.S_ISVTX, 't', 'x'),
                      _ifelse(mode & stat.S_ISVTX, 'T', '-'))
    return symstr

# Duplicated in client/tools/rhncfg/config_common/file_utils.py to remove dependency
# requirement. If making changes make them there too.


def f_date(dbiDate):
    return "%04d-%02d-%02d %02d:%02d:%02d" % (dbiDate.year, dbiDate.month,
                                              dbiDate.day, dbiDate.hour, dbiDate.minute, dbiDate.second)


class payload:

    """ this class implements simple file like object usable for reading payload
        from rpm, mpm, etc.
        it skips first 'skip' bytes of header
    """

    def __init__(self, filename, skip=0):
        self.fileobj = open(filename, 'r')
        self.skip = skip
        self.seek(0)

    def seek(self, offset, whence=0):
        if whence == 0:
            offset += self.skip
        return self.fileobj.seek(offset, whence)

    def tell(self):
        return self.fileobj.tell() - self.skip

    @staticmethod
    def truncate(size=-1):
        # pylint: disable=W0613
        raise AttributeError("'Payload' object do not implement this method")

    @staticmethod
    def write(_s):
        raise AttributeError("'Payload' object do not implement this method")

    @staticmethod
    def writelines(_seq):
        raise AttributeError("'Payload' object do not implement this method")

    def __getattr__(self, x):
        return getattr(self.fileobj, x)


def decompress_open(filename, mode='r'):
    file_obj = None
    if filename.endswith('.gz'):
        file_obj = gzip.open(filename, mode)
    elif filename.endswith('.bz2'):
        file_obj = bz2.BZ2File(filename, mode)
    elif filename.endswith('.xz'):
        try:
            # pylint: disable=F0401
            import lzma
            file_obj = lzma.LZMAFile(filename, mode)
        except ImportError: # No LZMA lib - be sad
            # xz uncompresses foo.xml.xz to foo.xml
            # uncompress, keep both, return uncompressed file
            subprocess.call(['xz', '-d', '-k', filename])
            uncompressed_path = filename.rsplit('.', 1)[0]
            file_obj = open(uncompressed_path, mode)
    else:
        file_obj = open(filename, mode)
    return file_obj
