#
# Common cli related functions for RHN Client Tools
# Copyright (c) 1999--2010 Red Hat, Inc.
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

import sys
import os
import xmlrpclib
import rpm

from optparse import Option
from optparse import OptionParser

from OpenSSL import SSL
from OpenSSL import crypto

from rhn import rpclib

import gettext
_ = gettext.gettext

sys.path.append("/usr/share/rhn/")

from up2date_client import config
from up2date_client import up2dateAuth
from up2date_client import up2dateErrors
from up2date_client import up2dateLog
from up2date_client import up2dateUtils

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
	gettext.textdomain("rhn-client-tools")
        self.optparser = OptionParser(option_list = _optionsTable,
            version = RhnCli.__versionString())

        self.options = None
        self.args = None
        
        self.hasGui = False

    def run(self):
        # catch any uncaught exceptions and handle them nicely
        sys.excepthook = RhnCli.__exceptionHandler
        # main loop call
        try:
            self.initialize()
            sys.exit(self.main() or 0)
        except KeyboardInterrupt:
            sys.stderr.write(_("\nAborted.\n"))
            sys.exit(1)
        except OSError, e:
            sys.stderr.write(_("An unexpected OS error occurred: %s\n") % e)
            sys.exit(1)
        except rpclib.MalformedURIError, e: # Subclass of IOError so must come 1st?
            if e is None or len(str(e)) == 0:
                sys.stderr.write(_("A connection was attempted with a malformed URI.\n"))
            else:
                sys.stderr.write(_("A connection was attempted with a malformed URI: %s.\n") % e)
        except IOError, e:
            sys.stderr.write(_("There was some sort of I/O error: %s\n") % e)
            sys.exit(1)
        except SSL.Error, e:
            sys.stderr.write(_("There was an SSL error: %s\n") % e)
            sys.stderr.write(_("A common cause of this error is the system time being incorrect. " \
                               "Verify that the time on this system is correct.\n"))
            sys.exit(1)
        except SSL.SysCallError, socket.error:
            sys.stderr.write("OpenSSL.SSL.SysCallError: %s\n" % str(e))
            sys.exit(2)
        except crypto.Error, e:
            sys.stderr.write(_("There was a SSL crypto error: %s\n") % e)
        except SystemExit, e:
            raise e
        except up2dateErrors.AuthenticationError, e:
            sys.stderr.write(_("There was an authentication error: %s\n") % e)
            sys.exit(1)
        except up2dateErrors.RpmError, e:
            sys.stderr.write("%s\n" % e)
            sys.exit(1)
        except xmlrpclib.ProtocolError, e:
            sys.stderr.write("XMLRPC ProtocolError: %s\n" % str(e))
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
        except up2dateErrors.ServerCapabilityError, e:
            print e
            return False
        except up2dateErrors.AuthenticationError, e:
            return False
        except up2dateErrors.RhnServerException, e:
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
                print _("Unable to open gui. Try `up2date --nox`")
                print message
        else:
            print message

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
                print _("Unable to open gui. Try `up2date --nox`")
                print errMsg
        else:
            print errMsg

    @staticmethod
    def __versionString():
        versionString = _("%%prog (Red Hat Network Client Tools) %s\n"
        "Copyright (C) 1999--2010 Red Hat, Inc.\n"
        "Licensed under the terms of the GPLv2.") % up2dateUtils.version()
        return versionString

    @staticmethod
    def __setDebugLevel(level):
        cfg = config.initUp2dateConfig()
        # figure out the debug level
        cfg["debug"] = cfg["debug"] + level 
        if cfg["debug"] > 2:
            # Set rpm's verbosity mode
            try:
                rpm.setVerbosity(rpm.RPMLOG_DEBUG)
            except AttributeError:
                print "extra verbosity not supported in this version of rpm"

    @staticmethod
    def __exceptionHandler(type, value, tb):
        log = up2dateLog.initLog()
        print _("An error has occurred:")
        if hasattr(value, "errmsg"):
            print value.errmsg
            log.log_exception(type, value, tb)
        else:
            print type
            log.log_exception(type, value, tb)

        print _("See /var/log/up2date for more information")
