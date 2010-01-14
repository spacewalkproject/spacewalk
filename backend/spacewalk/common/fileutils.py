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
import sys
import time
import types
import shutil
import string
import popen2
import select
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
        dirs = string.split(path, '/')
        if dirs[:1] not in (['.'], ['..']):
            dirs = ['.'] + dirs
        path = string.join(dirs, '/')
    return path


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
            if x.txt and x.txt.1 are identical (size or checksum), None is
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

    # is there anything to do? (existence, then size, then checksum)
    checksum_type = 'md5'       # FIXME: this should be configuation option
    if os.path.exists(pathNSuffix1) and os.path.isfile(pathNSuffix1) \
      and os.stat(filepath)[6] == os.stat(pathNSuffix1)[6] \
      and getFileChecksum(checksum_type, filepath) == \
          getFileChecksum(checksum_type, pathNSuffix1):
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

