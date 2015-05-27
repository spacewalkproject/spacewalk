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

# system imports:
import os
import sys
import time

from StringIO import StringIO

# rhn imports:
from spacewalk.common import rhnLib
from spacewalk.common.rhnConfig import CFG
from spacewalk.common.rhnLog import log_time, log_clean
from spacewalk.common.fileutils import createPath, setPermsPath

import messages

EMAIL_LOG = None


def initEMAIL_LOG(reinit=0):
    global EMAIL_LOG
    if EMAIL_LOG is None or reinit:
        EMAIL_LOG = StringIO()


def dumpEMAIL_LOG():
    if EMAIL_LOG is not None:
        return EMAIL_LOG.getvalue()
    return None


class RhnSyncException(Exception):

    """General exception handler for all sync activity."""
    pass


class ReprocessingNeeded(Exception):

    """Exception raised when a contition has been hit that would require a new
    run of the sync process"""
    pass

# logging functions:
# log levels rule of thumb:
# 0  - no logging, yet no feedback either
# 1  - minimal logging/feedback
# 2  - normal level of logging/feedback
# 3  - a bit much
##  4+ - excessive


def _timeString1():
    """time string as: "2002/11/18 12:56:34" """
    return log_time()


def _timeString2():
    """time string as: "12:56:34" """
    return time.strftime("%H:%M:%S", time.localtime(time.time()))


def _prepLogMsg(msg, cleanYN=0, notimeYN=0, shortYN=0):
    """prepare formating of message for logging.

    cleanYN -  no extra info, period.
    notimeYN - spaced as if there were a time-stamp.
    shortYN -  no date (used for stdout/stderr really)
    """
    if not cleanYN:
        if shortYN:
            if notimeYN:
                msg = '%s %s' % (' ' * len(_timeString2()), msg)
            else:
                msg = '%s %s' % (_timeString2(), msg)
        else:
            if notimeYN:
                msg = '%s %s' % (' ' * len(_timeString1()), msg)
            else:
                msg = '%s %s' % (_timeString1(), msg)
    return msg


def log2disk(level, msg, cleanYN=0, notimeYN=0):
    """Log to a log file.
    Arguments: see def _prepLogMsg(...) above.
    """
    if not isinstance(msg, type([])):
        msg = [msg]
    for m in msg:
        try:
            log_clean(level=level, msg=_prepLogMsg(m, cleanYN, notimeYN))
        except (KeyboardInterrupt, SystemExit):
            raise
        except Exception, e:  # pylint: disable=E0012, W0703
            sys.stderr.write('ERROR: upon attempt to write to log file: %s' % e)


def log2stream(level, msg, cleanYN, notimeYN, stream):
    """Log to a specified stream.
    Arguments: see def _prepLogMsg(...) above.
    """
    if not isinstance(msg, type([])):
        msg = [msg]
    if CFG.DEBUG >= level:
        for m in msg:
            stream.write(_prepLogMsg(m, cleanYN, notimeYN, shortYN=1) + '\n')
        stream.flush()


def log2email(level, msg, cleanYN=0, notimeYN=0):
    """ Log to the email log.
        Arguments: see def _prepLogMsg(...) above.
    """
    if EMAIL_LOG is not None:
        log2stream(level, msg, cleanYN, notimeYN, EMAIL_LOG)


def log2stderr(level, msg, cleanYN=0, notimeYN=0):
    """Log to standard error
    Arguments: see def _prepLogMsg(...) above.
    """
    log2email(level, msg, cleanYN, notimeYN)
    log2stream(level, msg, cleanYN, notimeYN, sys.stderr)


def log2stdout(level, msg, cleanYN=0, notimeYN=0):
    """Log to standard out
    Arguments: see def _prepLogMsg(...) above.
    """
    log2email(level, msg, cleanYN, notimeYN)
    log2stream(level, msg, cleanYN, notimeYN, sys.stdout)


def log2(levelDisk, levelStream, msg, cleanYN=0, notimeYN=0, stream=sys.stdout):
    """Log to disk and some stream --- differing log levels.
    Arguments: see def _prepLogMsg(...) above.
    """
    log2disk(levelDisk, msg, cleanYN, notimeYN)
    if stream is sys.stdout:
        log2stdout(levelStream, msg, cleanYN, notimeYN)
    elif stream is sys.stderr:
        log2stderr(levelStream, msg, cleanYN, notimeYN)
    else:
        log2stream(levelStream, msg, cleanYN, notimeYN, stream=stream)


def log(level, msg, cleanYN=0, notimeYN=0, stream=sys.stdout):
    """Log to disk and some stream --- share same log level.
    Arguments: see def _prepLogMsg(...) above.
    """
    log2(level, level, msg, cleanYN, notimeYN, stream=stream)


class FileCreationError(Exception):
    pass


class FileManip:

    "Generic file manipulation class"

    def __init__(self, relative_path, timestamp, file_size):
        self.relative_path = relative_path
        self.timestamp = rhnLib.timestamp(timestamp)
        self.file_size = file_size
        self.full_path = os.path.join(CFG.MOUNT_POINT, self.relative_path)
        self.buffer_size = CFG.BUFFER_SIZE

    def write_file(self, stream_in):
        """Writes the contents of stream_in to the filesystem
        Returns the file size(success) or raises FileCreationError"""
        dirname = os.path.dirname(self.full_path)
        createPath(dirname)
        stat = os.statvfs(dirname)

        f_bsize = stat[0]  # file system block size
        # misa: it's kind of icky whether to use f_bfree (free blocks) or
        # f_bavail (free blocks for non-root). f_bavail is more correct, since
        # you don't want to have the system out of disk space because of
        # satsync; but people would get confused when looking at the output of
        # df
        f_bavail = stat[4]  # free blocks
        freespace = f_bsize * float(f_bavail)
        if self.file_size is not None and self.file_size > freespace:
            msg = messages.not_enough_diskspace % (freespace / 1024)
            log(-1, msg, stream=sys.stderr)
            # pkilambi: As the metadata download does'nt check for unfetched rpms
            # abort the sync when it runs out of disc space
            sys.exit(-1)
            #raise FileCreationError(msg)
        if freespace < 5000 * 1024:  # arbitrary
            msg = messages.not_enough_diskspace % (freespace / 1024)
            log(-1, msg, stream=sys.stderr)
            # pkilambi: As the metadata download does'nt check for unfetched rpms
            # abort the sync when it runs out of disc space
            sys.exit(-1)
            #raise FileCreationError(msg)

        fout = open(self.full_path, 'wb')
        # setting file permissions; NOTE: rhnpush uses apache to write to disk,
        # hence the 6 setting.
        setPermsPath(self.full_path, user='apache', group='apache', chmod=0644)
        size = 0
        try:
            while 1:
                buf = stream_in.read(self.buffer_size)
                if not buf:
                    break
                buf_len = len(buf)
                fout.write(buf)
                size = size + buf_len
        except IOError, e:
            msg = "IOError: %s" % e
            log(-1, msg, stream=sys.stderr)
            # Try not to leave garbage around
            try:
                os.unlink(self.full_path)
            except (OSError, IOError):
                pass
            raise FileCreationError(msg), None, sys.exc_info()[2]
        l_file_size = fout.tell()
        fout.close()

        if self.file_size is not None and self.file_size != l_file_size:
            # Something bad happened
            msg = "Error: expected %s bytes, got %s bytes" % (self.file_size,
                                                              l_file_size)
            log(-1, msg, stream=sys.stderr)
            # Try not to leave garbage around
            try:
                os.unlink(self.full_path)
            except (OSError, IOError):
                pass
            raise FileCreationError(msg)

        os.utime(self.full_path, (self.timestamp, self.timestamp))
        return l_file_size


class RpmManip(FileManip):

    """General [S]RPM manipulation class.

    o Check checksums for mismatches
    o Write RPMs to the filesystem
    o get NVRE and NVREA
    """

    def __init__(self, pdict, path):
        FileManip.__init__(self, relative_path=path,
                           timestamp=pdict['last_modified'], file_size=pdict['package_size'])
        self.pdict = pdict

    def nvrea(self):
        return tuple([self.pdict[x] for x in
                      ['name', 'version', 'release', 'epoch', 'arch']])
