#
# Common cli related functions for RHN Client Tools
# Copyright (c) 1999--2016 Red Hat, Inc.
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
# Authors:
#       Adrian Likins <alikins@redhat.com>
#       Preston Brown <pbrown@redhat.com>
#       James Bowes <jbowes@redhat.com>
#
# In addition, as a special exception, the copyright holders give
# permission to link the code of portions of this program with the
# OpenSSL library under certain conditions as described in each
# individual source file, and distribute linked combinations
# including the two.
# You must obey the GNU General Public License in all respects
# for all of the code used other than OpenSSL.  If you modify
# file(s) with this exception, you may extend this exception to your
# version of the file(s), but you are not obligated to do so.  If you
# do not wish to do so, delete this exception statement from your
# version.  If you delete this exception statement from all source
# files in the program, then also delete it here.

import sys
import os
import socket

from optparse import Option
from optparse import OptionParser

from OpenSSL import SSL
from OpenSSL import crypto

from rhn import rpclib
from rhn.i18n import sstr

try: # python2
    import xmlrpclib
except ImportError: # python3
    import xmlrpc.client as xmlrpclib

import gettext
t = gettext.translation('rhn-client-tools', fallback=True)
# Python 3 translations don't have a ugettext method
if not hasattr(t, 'ugettext'):
    t.ugettext = t.gettext
_ = t.ugettext

from up2date_client import config
from up2date_client import up2dateAuth
from up2date_client import up2dateErrors
from up2date_client import up2dateLog
from up2date_client import up2dateUtils
from up2date_client import pkgUtils

_optionsTable = [
    Option("-v", "--verbose", action="count", default=0,
        help=_("Show additional output")),
    Option("--proxy", action="store",
      help=_("Specify an http proxy to use")),
    Option("--proxyUser", action="store",
      help=_("Specify a username to use with an authenticated http proxy")),
    Option("--proxyPassword", action="store",
      help=_("Specify a password to use with an authenticated http proxy")),
   ]

class RhnCli(object):

    def __init__(self):
        self.optparser = OptionParser(option_list = _optionsTable,
            version = RhnCli.__versionString())

        self.options = None
        self.args = None

        self.hasGui = False

    def run(self):
        # catch any uncaught exceptions and handle them nicely
        sys.excepthook = exceptionHandler
        # main loop call
        try:
            self.initialize()
            sys.exit(self.main() or 0)
        except KeyboardInterrupt:
            sys.stderr.write(sstr(_("\nAborted.\n")))
            sys.exit(1)
        except OSError:
            sys.stderr.write(sstr(_("An unexpected OS error occurred: %s\n") % sys.exc_info()[1]))
            sys.exit(1)
        except rpclib.MalformedURIError: # Subclass of IOError so must come 1st?
            e = sys.exc_info()[1]
            if e is None or len(str(e)) == 0:
                sys.stderr.write(sstr(_("A connection was attempted with a malformed URI.\n")))
            else:
                sys.stderr.write(sstr(_("A connection was attempted with a malformed URI: %s.\n") % e))
        except IOError:
            sys.stderr.write(sstr(_("There was some sort of I/O error: %s\n") % sys.exc_info()[1]))
            sys.exit(1)
        except SSL.Error:
            sys.stderr.write(sstr(_("There was an SSL error: %s\n") % sys.exc_info()[1]))
            sys.stderr.write(sstr(_("A common cause of this error is the system time being incorrect. " \
                               "Verify that the time on this system is correct.\n")))
            sys.exit(1)
        except (SSL.SysCallError, socket.error):
            sys.stderr.write(sstr("OpenSSL.SSL.SysCallError: %s\n" % str(sys.exc_info()[1])))
            sys.exit(2)
        except crypto.Error:
            sys.stderr.write(sstr(_("There was a SSL crypto error: %s\n") % sys.exc_info()[1]))
        except SystemExit:
            raise
        except up2dateErrors.AuthenticationError:
            sys.stderr.write(sstr(_("There was an authentication error: %s\n") % sys.exc_info()[1]))
            sys.exit(1)
        except up2dateErrors.RpmError:
            sys.stderr.write(sstr("%s\n" % sys.exc_info()[1]))
            sys.exit(1)
        except xmlrpclib.ProtocolError:
            sys.stderr.write(sstr("XMLRPC ProtocolError: %s\n" % str(sys.exc_info()[1])))
            sys.exit(3)

    def initialize(self):
        (self.options, self.args) = self.optparser.parse_args()

        RhnCli.__setDebugLevel(self.options.verbose)

        # see if were running as root
        if os.geteuid() != 0:
            rootWarningMsg = _("You must be root to run %s") % sys.argv[0]
            self._warning_dialog(rootWarningMsg)
            sys.exit(1)

        self.__updateProxyConfig()

    def main(self):
        raise NotImplementedError

    def _testRhnLogin(self):
        try:
            up2dateAuth.updateLoginInfo()
            return True
        except up2dateErrors.ServerCapabilityError:
            print(sys.exc_info()[1])
            return False
        except up2dateErrors.AuthenticationError:
            return False
        except up2dateErrors.RhnServerException:
            log = up2dateLog.initLog()
            log.log_me('There was a RhnServerException while testing login:\n')
            log.log_exception(*sys.exc_info())
            return False

    def _warning_dialog(self, message):
        if self.hasGui:
            try:
                from up2date_client import gui
                gui.errorWindow(message)
            except:
                print(_("Unable to open gui. Try `up2date --nox`"))
                print(message)
        else:
            print(message)

    def __updateProxyConfig(self):
        """Update potential proxy configuration.
        Note: this will _not_ save the info to up2date's configuration file
        A separate call to config.initUp2dateConfig.save() is needed.
        """
        cfg = config.initUp2dateConfig()

        if self.options.proxy:
            cfg.set("httpProxy", self.options.proxy)
            cfg.set("enableProxy", 1)
        if self.options.proxyUser:
            cfg.set("proxyUser", self.options.proxyUser)
            cfg.set("enableProxyAuth", 1)
        if self.options.proxyPassword:
            cfg.set("proxyPassword", self.options.proxyPassword)
            cfg.set("enableProxyAuth", 1)

    def saveConfig(self):
        """
        Saves the current up2date configuration being used to disk.
        """
        cfg = config.initUp2dateConfig()
        cfg.save()

    def __faultError(self, errMsg):
        if self.hasGui:
            try:
                from up2date_client import gui
                gui.errorWindow(errMsg)
            except:
                print(_("Unable to open gui. Try `up2date --nox`"))
                print(errMsg)
        else:
            print(errMsg)

    @staticmethod
    def __versionString():
        versionString = _("%%prog (Spacewalk Client Tools) %s\n"
        "Copyright (C) 1999--2014 Red Hat, Inc.\n"
        "Licensed under the terms of the GPLv2.") % up2dateUtils.version()
        return versionString

    @staticmethod
    def __setDebugLevel(level):
        cfg = config.initUp2dateConfig()
        # figure out the debug level
        cfg["debug"] = cfg["debug"] + level
        if cfg["debug"] > 2:
            pkgUtils.setDebugVerbosity()

def exceptionHandler(type, value, tb):
    log = up2dateLog.initLog()
    sys.stderr.write(sstr(_("An error has occurred:") + "\n"))
    if hasattr(value, "errmsg"):
        sys.stderr.write(sstr(value.errmsg) + "\n")
        log.log_exception(type, value, tb)
    else:
        sys.stderr.write(sstr(str(type) + "\n"))
        log.log_exception(type, value, tb)

    sys.stderr.write(sstr(_("See /var/log/up2date for more information") + "\n"))
