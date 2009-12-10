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
#
# rhn-ssl-tool general library
#
# $Id$

## language imports
import os
import re
import sys
import md5
import time
import types
import string
import shutil
import popen2
import select
import tempfile
from timeLib import DAY, now, secs2days, secs2years, secs2str, \
                    str2secs


class RhnSslToolException(Exception):
    """ general exception class for the tool """

errnoGeneralError = 1
errnoSuccess = 0


def fixSerial(serial):
    """ fixes a serial number this may be wrongly formatted """

    if not serial:
        serial = '00'

    if string.find(serial, '0x') == -1:
        serial = '0x'+serial

    # strip the '0x' if present
    serial = string.split(serial, 'x')[-1]

    # the string might have a trailing L
    serial = string.replace(serial, 'L', '')

    # make sure the padding is correct
    # if odd number of digits, pad with a 0
    # e.g., '100' --> '0100'
    if len(serial)/2.0 != len(serial)/2:
        serial = '0'+serial

    return serial


def incSerial(serial):
    """ increment a serial hex number """

    if not serial:
        serial = '00'

    if string.find(serial, '0x') == -1:
        serial = '0x'+serial

    serial = eval(serial) + 1
    serial = hex(serial)

    serial = string.split(serial, 'x')[-1]
    return fixSerial(serial)


def getMachineName(hostname):
    """ xxx.yyy.zzz.com --> xxx.yyy
        yyy.zzz.com     --> yyy
        zzz.com         --> zzz.com
        xxx             --> xxx
    """
    hn = string.split(hostname, '.')
    if len(hn) < 3:
        return hostname
    return string.join(hn[:-2], '.')

#
# NOTE: the Unix epoch overflows at: 2038-01-19 03:14:07 (2^31 seconds)
#

def secsTil18Jan2038():
    """ (int) secs til 1 day before the great 32-bit overflow
        We are making it 1 day just to be safe.
    """
    return int(2L**31 - 1) - now() - DAY

def daysTil18Jan2038():
    "(float) days til 1 day before the great 32-bit overflow"
    return secs2days(secsTil18Jan2038())

def yearsTil18Jan2038():
    "(float) approximate years til 1 day before the great 32-bit overflow"
    return secs2years(secsTil18Jan2038())


def gendir(directory):
    "makedirs, but only if it doesn't exist first"
    if not os.path.exists(directory):
        try:
            os.makedirs(directory, 0700)
        except OSError, e:
            print "Error: %s" % (e, )
            sys.exit(1)

def chdir(newdir):
    "chdir with the previous cwd as the return value"
    cwd = os.getcwd()
    os.chdir(newdir)
    return cwd


##
## common.rhnLib stuff that I duplicate here to make the tool "stand-alone"
##
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
    """take ~taw/../some/path/$MOUNT_POINT/blah and make it sensible.

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
    """ Creates a temporary file stream (returns an open file object)

        Returns a read/write stream pointing to a file that goes away once the
        stream is closed
    """

    filename, fd = maketemp(prefix)

    os.unlink(filename)
    # Since maketemp retuns a freshly created file, we can skip the truncation
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
    if type(depth) != type(0) or depth < -1 or depth > sys.maxint-1 or depth == 0:
        raise ValueError("depth must fall within range [-1, 1...%s]" % (sys.maxint-1))

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
          if verbosity>=0:
              sys.stderr.write("File '%s' is identical to it's rotation. Nothing "
                               "to do.\n" % os.path.basename(filepath))
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
            if verbosity >=0:
                print("Rotated out: '%s'\n" % os.path.basename(path))

    # do the actual rotation
    shutil.copy2(filepath, pathNSuffix1)
    if os.path.exists(pathNSuffix1) and verbosity >=0:
        print("Backup made: '%s' --> '%s'\n"
                         % (os.path.basename(filepath),
                            os.path.basename(pathNSuffix1)))

    # return the full filepath of the backed up file
    return pathNSuffix1


def getFileMD5(filename=None, fd=None, file=None, buffer_size=None):
    "Compute a file's md5sum"

    # python's md5 lib sucks.  hexdigest() doesn't show up until 2.0,
    # and there's no way to directly import a file.
    if buffer_size is None:
        buffer_size = 65536

    if filename is None and fd is None and file is None:
	raise ValueError("no file specified");
    if file:
        f = file
    elif fd is not None:
        f = os.fdopen(os.dup(fd), "r")
    else:
        f = open(filename, "r")
    # Rewind it
    f.seek(0, 0)
    m = md5.new()
    while 1:
        _buffer = f.read(buffer_size)
        if not _buffer:
            break
        m.update(_buffer)

    # cleanup time
    if file is not None:
        file.seek(0, 0)
    else:
        f.close()
    return hexify_string(m.digest())


def hexify_string(s):
    return ("%02x" * len(s)) % tuple(map(ord, s))

##
## end rhnLib.py duplication
##


def rhn_popen(cmd, progressCallback=None, bufferSize=16384, outputLog=None):
    """ popen-like function, that accepts execvp-style arguments too (i.e. an
        array of params, thus making shell escaping unnecessary)

        cmd can be either a string (like "ls -l /dev"), or an array of arguments
        ["ls", "-l", "/dev"]

        Returns the command's error code, a stream with stdout's contents and a 
        stream with stderr's contents

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
                    outputLog("rhn_popen: terminated: Signal %s received\n" % sig)
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

def getCertValidityRange(certPath, daysYN=0):
    """ parse a cert (x509) and snag the validity range.
        Returns (notBefore, notAfter) in seconds or days the epoch.
    """
    certPath = cleanupAbsPath(certPath)
    if not os.path.exists(certPath):
        return None, None

    args = "/usr/bin/openssl x509 -dates -noout -in %s" % certPath
    ret, out_stream, err_stream = rhn_popen(args)

    out = out_stream.read(); out_stream.close()
    err = err_stream.read(); err_stream.close()

    out = string.strip(out)

    if ret or not out:
        raise RhnSslToolException("certificate parse (for validity range) "
                                  "failed:\n%s\n%s" % (out, err))

    if out \
      and string.find(out, 'notBefore=')!=-1 \
      and string.find(out, 'notAfter=')!=-1:
        notBefore, notAfter = string.split(out, '\n')
        notBefore = string.strip(string.split(notBefore, 'notBefore=')[1])[:-4]
        notAfter = string.strip(string.split(notAfter, 'notAfter=')[1])[:-4]
        # secs from epoch
        notBefore = str2secs(notBefore, '%b %d %H:%M:%S %Y')
        notAfter = str2secs(notAfter, '%b %d %H:%M:%S %Y')
        if daysYN:
            # days from epoch
            notBefore = secs2days(notBefore)
            notAfter = secs2days(notAfter)
        return notBefore, notAfter
    else:
        raise RhnSslToolException("certificate parse (for validity range) "
                                  "failed:\n%s\n%s" % (out, err))


def getCertValidityDates(certPath, format="%a %b %d %H:%M:%S %Y"):
    """ parse a cert (x509) and snag the validity dates.
        Returns (notBefore, notAfter) - strings of course.
    """

    # validity in seconds 
    notBefore, notAfter = getCertValidityRange(certPath)

    if notBefore is not None:
        notBefore = secs2str(format, notBefore)
    if notAfter is not None:
        notAfter = secs2str(format, notAfter)

    # validity as strings
    return notBefore, notAfter


class TempDir:

    """ temp directory class with a cleanup destructor and method """
    
    _shutil = shutil # trying to hang onto shutil during garbage collection

    def __init__(self, suffix='-rhn-ssl-tool'):
        "create a temporary directory in /tmp"

        if string.find(suffix, '/') != -1:
            raise ValueError("suffix cannot be a path, only a name")

        # add some quick and dirty randomness to the tempfilename
        s = ''
        x = open('/dev/urandom', 'rb')
        while len(s) < 10:
            s = s + str(ord(x.read(1)))
        x.close()
        self.path = self._getTempPath(suffix='-'+s+suffix)
        # tempfile.mkdtemp actaully *creates* the directory
        if not os.path.exists(self.path):
            os.makedirs(self.path, 0700)

    def _getTempPath(self, suffix):
        """ fetch the temporary directory path using the most "correct"
            mk*temp function for this python version
        """
        
        mktemp = None
        if hasattr(tempfile, 'mkdtemp'):
            # python 2.3+
            mktemp = tempfile.mkdtemp
        else:
            # pre-python 2.3
            mktemp = tempfile.mktemp
        return mktemp(suffix=suffix)

    def getdir(self):
        return self.path
    getpath = getdir

    def __del__(self):
        "a destructor that may never be called because python 1.5.2 sucks"
        self._shutil.rmtree(self.path)

    close = __del__
        

# next two functions orgininally stolen/adapted from backend/server/rhnLib.py

# reg exp for splitting package names.
re_rpmName = re.compile("^(.*)-([^-]*)-([^-]*)$")
def parseRPMName(pkgName):
    """ 'n-n-n-v.v.v-r.r_r' --> (name, release, version, epoch) """

    reg = re_rpmName.match(pkgName)
    if reg == None:
        return None, None, None, None
    n, v, r = reg.group(1,2,3)
    e = ""
    ind = string.find(r, ':')
    if ind < 0: # no epoch
        return str(n), str(v), str(r), str(e)
    e = r[ind+1:]
    r = r[0:ind]
    return str(n), str(v), str(r), str(e)


def parseRPMFilename(pkgFilename):
    """ 'n_n-n-v.v.v-r_r.r:e.ARCH.rpm' --> [n,v,r,e,a]
        IN: Package Name: xxx-yyy-ver.ver.ver-rel.rel_rel:e.ARCH.rpm (string)
        Understood rules:
           o Name can have nearly any char, but end in a - (well seperated by).
             Any character; may include - as well.
           o Version cannot have a -, but ends in one.
           o Release should be an actual number, and can't have any -'s.
           o Release can include the Epoch, e.g.: 2:4 (4 is the epoch)
           o Epoch: Can include anything except a - and the : seperator???
             XXX: Is epoch info above correct?
        OUT: [n,v,r,e, arch].
    """

    pkgFilename = os.path.basename(pkgFilename)
    pkg = string.split(pkgFilename, '.')
    if string.lower(pkg[-1]) != 'rpm':
	raise ValueError('not an rpm package name: %s' % pkgFilename)
    _arch = pkg[-2]
    pkg = string.join(pkg[:-2], '.')
    ret = list(parseRPMName(pkg))
    if ret:
        ret.append(_arch)
    return  ret


#===============================================================================

