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
import fcntl
from errno import EWOULDBLOCK, EEXIST
import fcntl

class LockfileLockedException(Exception):
    """thrown ONLY when pid file is locked."""
    pass

class Lockfile:

    """class that provides simple access to a PID-style lockfile.

    methods: __init__(lockfile), acquire(), and release()
    NOTE: currently acquires upon init
    The *.pid file will be acquired, or an LockfileLockedException is raised.
    """

    def __init__(self, lockfile, pid=None):
        """create (if need be), and acquire lock on lockfile

        lockfile example: '/var/run/up2date.pid'
        """

        # cleanup the path and assign it.
        self.lockfile = os.path.abspath(
                          os.path.expanduser(
                            os.path.expandvars(lockfile)))

        self.pid = pid
        if not self.pid:
            self.pid = os.getpid()

        # create the directory structure
        dirname = os.path.dirname(self.lockfile)
        if not os.path.exists(dirname):
            try:
                os.makedirs(dirname)
            except OSError, e:
                if hasattr(e, 'errno') and e.errno == EEXIST:
                    # race condition... dirname exists now.
                    pass
                else:
                    raise

        # open the file -- non-destructive read-write, unless it needs
        # to be created XXX: potential race condition upon create?
        self.f = os.open(self.lockfile, os.O_RDWR|os.O_CREAT|os.O_SYNC)
        self.acquire()

    def acquire(self):
        """acquire the lock; else raise LockfileLockedException."""

        try:
            fcntl.flock(self.f, fcntl.LOCK_EX|fcntl.LOCK_NB)
        except IOError, e:
            if e.errno == EWOULDBLOCK:
                raise LockfileLockedException(
                  "cannot acquire lock on %s." % self.lockfile)
            else:
                raise
        # unlock upon exit
        fcntl.fcntl(self.f, fcntl.F_SETFD, 1)
        # truncate and write the pid
        os.ftruncate(self.f, 0)
        os.write(self.f, str(self.pid) + '\n')

    def release(self):
        # Remove the lock file
        os.unlink(self.lockfile)
        fcntl.flock(self.f, fcntl.LOCK_UN)
        os.close(self.f)


def main():
    """test code"""

    try:
        L = Lockfile('./test.pid')
    except LockfileLockedException, e:
        sys.stderr.write("%s\n" % e)
        sys.exit(-1)
    else:
        print "lock acquired "
        print "...sleeping for 10 seconds"
        import time
        time.sleep(10)
        L.release()
        print "lock released "

if __name__ == '__main__':
    # test code
    sys.exit(main() or 0)

