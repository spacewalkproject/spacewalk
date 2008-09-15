""" Log classes/functions for the installer

    Copyright (c) 2002-2005, Red Hat, Inc.
    All rights reserved.
"""

#-------------------------------------------------------------------------------
# $Id: satLog.py,v 1.14 2005-07-05 17:50:13 wregglej Exp $

import sys
import time
import string


DEFAULT_LOG_FILE = "/var/log/rhn_satellite_install.log"
LOG = None


class Log:

    """attempt to log all interesting stuff, namely, anything that hits
    the network any error messages, package installs, etc

    This log class stolen from up2date (mostly)
    """

    def __init__(self, filename=None):

        self.app = "sat-install"
        self.filename = filename

        self.log_me("new satinstall run started");

    def log_me(self, *args):
        self.log_info = "[%s] %s" % (time.ctime(time.time()), self.app)
        s = ""
        for i in args:
            s = s + "%s" % i
        self.write_log(s)

    def log_me_clean(self, *args):
        self.log_info = ""
        s = ""
        for i in args:
            s = s + "%s" % i
        self.write_log(s)

    def trace_me(self):
        import traceback
        x = traceback.extract_stack()
        bar = string.join(traceback.format_list(x))
        self.write_log(bar)

    def write_log(self, s):
        self.fo = open(self.filename, 'a')
        msg = "%s %s\n" % (self.log_info, str(s))
        self.fo.write(msg)
        self.fo.flush()
        self.fo.close()


def initLog(filename=DEFAULT_LOG_FILE):
    global LOG
    if LOG == None:
        LOG = Log(filename=filename)
    return LOG


def log_me(*args):
    global LOG
    if LOG is None:
        raise SystemError("The log file has not been initialized yet")
    apply(LOG.log_me, args)


def log_me_clean(*args):
    global LOG
    if LOG is None:
        raise SystemError("The log file has not been initialized yet")
    apply(LOG.log_me_clean, args)


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

#===============================================================================
