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
""" installer general logging lib
"""
# $Id: pi_log.py,v 1.13 2004/03/16 21:05:48 taw Exp $

import os
import sys
import time
import string


LOG = None
LOG_FILE = "/var/log/rhn/proxy_install"


# log class stolen from up2date...
class Log:
    """attempt to log all interesting stuff, namely, anything that hits the network
       any error messages, package installs, etc"""
    def __init__(self, log_file=None):
        global LOG_FILE
        if not log_file:
            log_file = LOG_FILE
        else:
            LOG_FILE = log_file

        # TODO: allow stdout and stderr

        self.app = "proxy-install"
        self.log_file_name = log_file

        # attempt to create the path to the log file if neccessary
        if log_file not in ('stderr', 'stdout', None) \
        and not os.path.exists(os.path.dirname(log_file)):
            log_path = os.path.dirname(log_file)
            self.log_stderr("WARNING: log path not found; attempting to create %s" % log_path,
                       sys.exc_info()[:2])
            try:
                os.makedirs(log_path)
            except:
                self.log_stderr("ERROR: unable to create log file path %s" % log_path,
                           sys.exc_info()[:2])
                return

        self.log_me("new %s run started" % self.app);

    def _timeString(self):
        """time string as: "2002/11/18 12:56:34"
        """
        return time.strftime("%Y/%m/%d %H:%M:%S", time.localtime(time.time()))

    def log_me(self, *args):
        self.log_info = "[%s] %s" % (self._timeString(), self.app)
        s = ""
        for a in args:
            s = s + str(a)
        self.write_log(s)

    def log_clean(self, *args):
        self.log_info = ""
        s = ""
        for a in args:
            s = s + str(a)
        self.write_log(s)

    def trace_me(self):
        import traceback
        x = traceback.extract_stack()
        bar = string.join(traceback.format_list(x))
        self.write_log(bar)

    def write_log(self, s):
        self.log_file = open(self.log_file_name, 'a')
        msg = self.log_info
        if msg:
            msg = "%s %s\n" % (msg, str(s))
        else:
            msg = str(s)
        self.log_file.write(msg)
        self.log_file.flush()
        self.log_file.close()

    def log_stderr(self, *msg):
        sys.stderr.write(repr(msg))


def initLog(log_file=None):
    global LOG
    if LOG is None:
        LOG = Log(log_file)
    return LOG


def log_me(*args):
    global LOG
    if LOG is None:
        raise SystemError("The log file has not been initialized yet")
    apply(LOG.log_me, args)


def log_clean(*args):
    global LOG
    if LOG is None:
        raise SystemError("The log file has not been initialized yet")
    apply(LOG.log_clean, args)
log_me_clean = log_clean


def log_me_stderr_clean(*args):
    "write to both stderr/stdout and the log file"

    log_me_clean(args)
    s = ''
    for a in args:
        s = s+str(a)
    sys.stderr.write(s+'\n')


def log_me_stdout_clean(*args):
    log_me_clean(args)
    s = ''
    for a in args:
        s = s+str(a)
    sys.stdout.write(s+'\n')


def log_me_stderr(*args):
    log_me(args)
    s = ''
    for a in args:
        s = s+str(a)
    sys.stderr.write(s+'\n')


def log_me_stdout(*args):
    log_me(args)
    s = ''
    for a in args:
        s = s+str(a)
    sys.stdout.write(s+'\n')

#
# initialize the logger
#
try:
    initLog()
except IOError, e:
    print "Unable to open log file. The error was: %s" % e
    sys.exit(1)

