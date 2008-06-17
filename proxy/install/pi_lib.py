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
""" Helper functions that can be used by more than one module.
"""
#------------------------------------------------------------------------------
# $Id: pi_lib.py,v 1.12 2004/06/18 20:17:04 taw Exp $

## language imports
import os
import sys
import rpm
import md5
import time
import types
import select
import popen2
import shutil
import socket
import urlparse
import traceback

from cStringIO import StringIO

## local imports
from pi_log import log_me, log_me_clean
import pi_errors
from translate import _

# until we merge newer common code...
from rhn_rpm import get_package_header, labelCompare, sortRPMs, \
                    hdrLabelCompare, rpmLabelCompare

DEFAULT_RHN_ETC_DIR = '/etc/sysconfig/rhn'
DEFAULT_SYSTEMID_LOCATION = '%s/systemid' % DEFAULT_RHN_ETC_DIR
DEFAULT_RHN_REGISTER_CONFIG_LOCATION = '%s/rhn_register' % DEFAULT_RHN_ETC_DIR
DEFAULT_UP2DATE_CONFIG_LOCATION = '%s/up2date' % DEFAULT_RHN_ETC_DIR
DEFAULT_RHN_PARENT = "xmlrpc.rhn.redhat.com"
DEFAULT_RHN_HANDLER = '/XMLRPC'
DEFAULT_RHN_TRUSTED_SSL_CERT = "/usr/share/rhn/RHNS-CA-CERT"
DEFAULT_ORG_TRUSTED_SSL_CERT = "/usr/share/rhn/RHN-ORG-TRUSTED-SSL-CERT"
DEFAULT_GPG_KEY = "/usr/share/rhn/RPM-GPG-KEY"
DEFAULT_CONFIG_FILE = "/etc/rhn/rhn.conf"
DEFAULT_CA_CERT_EXP = 10
DEFAULT_HTTPD_SSL_CERT_EXP = 1

# for the bootstrap script generator
DEFAULT_APACHE_PUB_DIRECTORY = '/var/www/html/pub/'
DEFAULT_BOOTSTRAP_DIRECTORY = DEFAULT_APACHE_PUB_DIRECTORY + 'bootstrap/'
DEFAULT_CLIENT_CONFIG_OVERRIDES = '%sclient-config-overrides.txt' % DEFAULT_BOOTSTRAP_DIRECTORY

# examples
EXAMPLE_HTTP_PROXY = 'my.corporate.gateway.example.com:3128'
EXAMPLE_EMAILS = 'admin@example.com, adminsSidekick@example.com'


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


def myPopen(cmd, progressCallback=None, bufferSize=16384, writeFo=None):
    """ popen-like function, that accepts execvp-style arguments too (i.e. an
        array of params, thus making shell escaping unnecessary)

        cmd can be either a string (like "ls -l /dev"), or an array of arguments
        ["ls", "-l", "/dev"]

        Returns the command's error code, a stream with stdout's contents and a 
        stream with stderr's contents

        progressCallback --> progress bar twiddler
        writeFo --> show progress to writeFo as well (e.g., sys.stdout)
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
                log_me("myPopen: terminated: Signal %s received" % sig)
                exitcode = -sig
                break
            elif os.WIFSTOPPED(status):
                # Some signal stopped this process
                sig = os.WSTOPSIG(status)
                log_me("myPopen: stopped: Signal %s received" % sig)
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

                    # log everything.
                    log_me_clean(output)

                    # show a tickmark per read:
                    if writeFo is not None:
                        writeFo.write('.')
                        writeFo.flush()

                    # write to the output buffer(s)
                    out_fd.write(output)
                    out_fd.flush()

        if exitcode is not None:
            # Child process is done
            break

    if writeFo is not None:
        writeFo.write('\n')
        writeFo.flush()

    for f_in, f_out in fd_mappings:
        f_in.close()
        f_out.seek(0, 0)

    return exitcode, child_out, child_err


def openrpmdb(option=1):
    dbpath = '/var/lib/rpm'
    log_me("Opening rpmdb in %s with option: %s" % (dbpath, option))
    try:
        db = rpm.opendb(option)
    except rpm.error:
        raise pi_errors.RpmError(_("Could not open RPM database for reading. "
                                   "Perhaps it is already in use?"))
    return db


def fetchTraceback(method=None, req=None, extra=None):

    #NOTE: must be here, as you may need it *prior* to having code deployed.
    """ returns an traceback error

        NOTE: this function is a modified version of function Traceback()
              from common.rhnTB.py
    """

    def printreq(req, fo=sys.stderr):
        """ get some debugging information about the current exception
            for sending out when we raise an exception.
        """

        fo.write("Request object information:\n")
        fo.write("Remote Host: %s\nServer Name: %s:%d\n" % (
            req.get_remote_host(), req.server.server_hostname, req.server.port))
        fo.write("Headers passed in:\n")
        kl = req.headers_in.keys()
        kl.sort()
        for k in kl:
            fo.write("\t%s: %s\n" % (k, req.headers_in[k]))
        return 0

    # NOTE: extra = extra text information.
    e_type, e_value = sys.exc_info()[:2]
    t = time.ctime(time.time())
    exc = StringIO()
   
    exc.write("Exception reported from %s\nTime: %s\n" % (socket.gethostname(), t))
    exc.write("Exception type %s\n" % (e_type,))
    if method:
        exc.write("Exception while handling function %s\n" % method)

    # print information about the request being served
    if req:
        printreq(req, exc)
    if extra:
        exc.write("Extra information about this error:\n%s\n" % extra)
        
    # Print the traceback
    exc.write("\nException Handler Information\n")
    traceback.print_exc(None, exc)

    ret = "%s\n" % exc.getvalue()
    exc.close()
    return ret


def printTraceback(stream=sys.stderr, prettyYN=1):
    tb = fetchTraceback()
    if prettyYN:
        line = '-'*79 + '\n'
        stream.write(line)
        stream.write(tb)
        stream.write(line)
    else:
        stream.write(tb)

