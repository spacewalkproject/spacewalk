#!/usr/bin/python
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
""" GUI for RHN Proxy Server configuration

    Authors: Adrian Likins <alikins@redhat.com>
             Todd Warner <taw@redhat.com>

"""
#------------------------------------------------------------------------------
# $Id: gui.py,v 1.106 2004/06/27 00:51:12 taw Exp $

## system imports
import os
import re
import sys
import rpm
import time
import getopt
import string
import socket

# save the args before gtk gets to them and complains about unknown
# ones
_ARGS = []
for a in sys.argv[1:]:
    _ARGS.append(a)
    sys.argv.remove(a)

## gtk/gnome imports
import gtk
from gtk import TRUE
from gtk import FALSE
import GDK
import gnome.ui
import libglade

## local imports
from pi_log import LOG_FILE, log_me
import pi_config
import pi
from pi_errors import ServiceRestartError, \
                      genCAKeyError, \
                      genPublicCaCertError, genPrivateCaKeyError, \
                      RpmError, DependencyError, InvalidUsernamePassword, \
                      RhnEntitlementError
from pi_errors import _depsAsText

from translate import _
from pi_lib import fetchTraceback, printTraceback, \
  DEFAULT_RHN_TRUSTED_SSL_CERT, DEFAULT_ORG_TRUSTED_SSL_CERT, \
  DEFAULT_RHN_PARENT, EXAMPLE_HTTP_PROXY, DEFAULT_RHN_ETC_DIR, parseUrl

from ssl_cert_gen import fetchSslData

class Gui:

    """ Main gui/python-druid handler code. """

    def __init__(self, opts):
        self.opts = opts
        self.running = FALSE
        self.xml = libglade.GladeXML('gui.glade', "mainWin",
                                     domain="proxy_install")

        handlers = [
            "onDruidCancel",
            # druid page 1
            "onStartPageNext",
            # druid page 2
            "onInstallPagePrepare",
            "onInstallPageBack",
            "onRhnAccountInfoPageBack",
            "onRhnAccountInfoPageNext",
            "onRhnAccountInfoPagePrepare",
            "onSkipRegistrationButtonToggled",
            "onConfigSatelliteButtonToggled",
            "onUseHttpProxyToggled",
            # druid page 4
            "onProxyApplicationSettingsPageBack",
            "onProxyApplicationSettingsPagePrepare",
            "onProxyApplicationSettingsPageNext",
            # druid page 5
            "onProxyUp2datePageBack",
            "onProxyUp2datePagePrepare",
            "onProxyUp2datePageNext",
            # druid page 6
            "onSslCertInfoPageBack",
            "onSslCertInfoPageNext",
            "onSslCertInfoPagePrepare",
            "onConfigSSLCertButtonToggled",
            # druid page 7
            "onFinishPagePrepare",
            "onFinishPageFinish",
            ]

        handlers_dict = {}
        for h in handlers:
            if not hasattr(self, h):
                sys.stderr.write("ERROR: System requested a handler for %s, "
                                 "a function is not defined!\n" % h)
                sys.exit(-1)
            handlers_dict[h] = getattr(self, h)
        self.xml.signal_autoconnect(handlers_dict)

        self.mainWin = self.xml.get_widget("mainWin")
        self.druid = self.xml.get_widget("druid1")
        self.mainWin.connect("delete-event", gtk.mainquit)
        self.mainWin.connect("hide", gtk.mainquit)

        self.thisbox = socket.gethostname()

        sys.path.append("/usr/share/rhn/")

        # init some of the variables
        self.config = {
            "rhnUsername": None,
            "rhnPassword": None,
            "rhnPasswordConfirm" : None,
            "serverHostname": None,
            "caCert": None,
            # the corp gateway *not* the RHN Proxy cache...
            "httpProxy": None,
            "httpProxyUsername": None,
            "httpProxyPassword": None,

            # SSL stuff
            # Just creating the keys here for convenience and reference.
            # Values not populated until the SSL prepare step
            'keyPassword': '',
            'keyPasswordConfirm': '',
            'countryCode': '',
            'state': '',
            'locality': '',
            'orgName': '',
            'orgUnit': '',
            'commonName': '',
            'hostname': '',
            'caCertExpiration': None, #set in ssl prepare stuff
            'serverCertExpiration': None, #set in ssl prepare stuff
        }

        #print 'XXXXXX', self.config['caCertExpiration']
        #print 'XXXXXX', self.config['serverCertExpiration']
        
        self.haveRegisteredYN = 0
        self.xml.get_widget("installingFinishedLabel").set_text("...")
        self.hasInstalledPackages = FALSE
        self.running = TRUE

        self.squidSetupYN = 0
        self.httpdSetupYN = 0

        # add the gpg key
        pi.addGPGKey()

        # config file manipulation object
        self.proxyConfig = pi_config.ProxyConfig()

        self.xml.get_widget("configSSLCertButton").set_active(0)
        for k in ('keyPassword', 'keyPasswordConfirm', 'countryCode',
                  'state', 'locality', 'orgName', 'orgUnit'):
            if self.config[k]:
                self.xml.get_widget("configSSLCertButton").set_active(1)
                break

    def onDruidCancel(self, dummy):
        gtk.mainquit()
        sys.exit(2)

    def __fatalError(self, error):
        self.__setArrowCursor()
        dlg = gnome.ui.GnomeErrorDialog(wrap_text(error), self.mainWin)
        dlg.show_all()
        dlg.run_and_close()
        if self.running:
            gtk.mainquit()
        sys.exit(1)

    def __error(self, error):
        self.__setArrowCursor()
        dlg = gnome.ui.GnomeErrorDialog(wrap_text(error), self.mainWin)
        dlg.show_all()
        sys.stderr.write(error)
        if error and error[-1] != '\n':
            sys.stderr.write('\n')

    def __setArrowCursor(self):
        cursor = gtk.cursor_new(GDK.LEFT_PTR)
        self.mainWin.get_window().set_cursor(cursor)
        while gtk.events_pending():
            gtk.mainiteration(FALSE)

    def __setBusyCursor(self):
        # gtk 1.2
        cursor = gtk.cursor_new(GDK.WATCH)
        # gtk 2.0
        #cursor = gdk.cursor_new(gtk.gdk.WATCH)
        self.mainWin.get_window().set_cursor(cursor)
        while gtk.events_pending():
            gtk.mainiteration(FALSE)

    def __rpmCallback(self, what, amount, total, hdr, path):
        if what == rpm.RPMCALLBACK_INST_OPEN_FILE:
            fileName = "%s/%s-%s-%s.%s.rpm" % (path,
                                               hdr['name'],
                                               hdr['version'],
                                               hdr['release'],
                                               hdr['arch'])
            try:
                self.fd = os.open(fileName, os.O_RDONLY)
            except:
                raise RpmError(_("Error opening %s") % fileName)

            return self.fd

        elif what == rpm.RPMCALLBACK_INST_START:
            fileName = "%s/%s-%s-%s.%s.rpm" % (path,
                                               hdr['name'],
                                               hdr['version'],
                                               hdr['release'],
                                               hdr['arch'])
            self.pkgIndex = self.pkgIndex + 1
            self.pkgLabel.set_text(fileName)

        elif what == rpm.RPMCALLBACK_INST_CLOSE_FILE:
            os.close(self.fd)
            # we used to do a up2date.remoteAddPackage() here

            i = (self.pkgIndex * 1.0) / self.pkgCount
            if i > 1:
                i = 1.0
            elif i < 0:
                i = 0
            self.totalProgress.update(i)

        elif what == rpm.RPMCALLBACK_INST_PROGRESS:
            i = (amount + 1.0) / total
            if i > 1:
                i = 1.0
            elif i < 0:
                i = 0
            self.progress.update(i)

        elif what == rpm.RPMCALLBACK_UNINST_STOP:
            # we used to do a up2date.remoteDelPackage() here
            pass

        else:
            if hasattr(rpm, "RPMCALLBACK_UNPACK_ERROR") \
              and what == rpm.RPMCALLBACK_UNPACK_ERROR:
                pkg = "%s-%s-%s" % (hdr[rpm.RPMTAG_NAME],
                                hdr[rpm.RPMTAG_VERSION],
                                hdr[rpm.RPMTAG_RELEASE])
                raise RpmError(_("There was an rpm unpack error "
                                 "installing the package: %s") % pkg)

            if hasattr(rpm, "RPMCALLBACK_CPIO_ERROR") \
              and what == rpm.RPMCALLBACK_CPIO_ERROR:
                pkg = "%s-%s-%s" % (hdr[rpm.RPMTAG_NAME],
                                hdr[rpm.RPMTAG_VERSION],
                                hdr[rpm.RPMTAG_RELEASE])
                raise RpmError(_("There was a cpio error installing "
                                 "the package: %s") % pkg)

        while gtk.events_pending():
            gtk.mainiteration(FALSE)

    #
    # druid page 1
    #
    def onStartPageNext(self, page, dummy):
        # figure out execution path (and clean it up)
        self.baseDir = os.path.dirname(sys.argv[0])
        self.baseDir = os.path.abspath(
                         os.path.expanduser(
                           os.path.expandvars(self.baseDir)))
        self.baseDir = os.path.abspath(self.baseDir + '/..')

        self.pkgList = pi.getListOfPackagesToInstall(self.baseDir+'/RPMS')
        self.pkgCount = len(self.pkgList)

        print 'Package list of RPMs to install immediately:', self.pkgList
        if self.pkgCount == 0 or self.hasInstalledPackages:
             self.druid.set_page(self.xml.get_widget("rhnAccountInfoPage"))
        else:
            self.druid.set_page(self.xml.get_widget("installPage"))
        return TRUE

    #
    # druid page 2
    #
    def onInstallPagePrepare(self, page, dummy):
        self.druid.set_buttons_sensitive(FALSE, FALSE, TRUE)
        while gtk.events_pending():
            gtk.mainiteration(FALSE)

        # total hack to get this function to start as soon as this
        # one exits.  GTK makes me do ugly things.
        gtk.timeout_add(0, self.__doInstallation)

    def onInstallPageBack(self, page, dummy):
        self.xml.get_widget("installingFinishedLabel").set_text("...")
        self.druid.set_page(self.xml.get_widget("packagePage"))
        return TRUE

    def __doInstallation(self):
        gtk.threads_enter()
        self.progress = self.xml.get_widget("installPackageProgress")
        self.totalProgress = self.xml.get_widget("installTotalProgress")
        self.totalProgress.update(0)
        self.pkgLabel = self.xml.get_widget("installPackageNameLabel")
        self.pkgIndex = 0

        self.xml.get_widget("installingFinishedLabel").set_text("...")
        self.xml.get_widget("installingFinishedLabel").show()

        if self.hasInstalledPackages or self.pkgCount == 0:
            self.xml.get_widget("installingFinishedLabel").set_text(_(
                "All finished.  Click \"Next\" to continue."))
            self.druid.set_buttons_sensitive(FALSE, TRUE, TRUE)
            print _("All required packages are already installed")
            return 0

        #do it
        self.__setBusyCursor()
        try:
            pi.installPackages(self.baseDir+'/RPMS', self.__rpmCallback)
        except DependencyError, e:
            self.__setArrowCursor()
            etext = _depsAsText(e.deps)
            print etext
            self.__fatalError(etext)
            return FALSE
        except RpmError, e:
            self.__setArrowCursor()
            etext = _("RPM header read error: %s\n.") % e.errmsg
            print etext
            self.__fatalError(etext)
            return FALSE

        self.xml.get_widget("installingFinishedLabel").set_text(
          _("All finished.  Click \"Next\" to continue."))
        self.hasInstalledPackages = TRUE
        self.druid.set_buttons_sensitive(FALSE, TRUE, TRUE)

        while gtk.events_pending():
            gtk.mainiteration(FALSE)

        # XXX remove me when locking is fixed in gtk
        self.__setArrowCursor()
        gtk.threads_leave()

        # Force it to say 100% even if it is not. :)
        self.totalProgress.update(1)

        return 0

    #
    # druid page 3
    #
    def onRhnAccountInfoPageBack(self, page, dummy):
        pass

    def __initRHNAccountInfoPage_server(self):
        ## set up paths:
        DEFAULT_PATH = '/usr/share/rhn'
        if DEFAULT_PATH not in sys.path:
            sys.path.append(DEFAULT_PATH)
        from common import initCFG, CFG
        initCFG('proxy')

        # init some of the variables
        self.config['serverHostname'] = parseUrl(CFG.RHN_PARENT)[1]
        self.config['caCert'] = CFG.CA_CHAIN
        self.config['httpProxy'] = CFG.HTTP_PROXY
        self.config['httpProxyUsername'] = CFG.HTTP_PROXY_USERNAME
        self.config['httpProxyPassword'] = CFG.HTTP_PROXY_PASSWORD

    def __resetRhnAccountInfoPage_server(self):
        """Force the satellite url/ca cert toggles to be triggered.
        o grey out or enable the appropriate settings
        o set the appropriate values
        """
        # if not... set to defaults
        if not self.config["serverHostname"]:
            self.config["serverHostname"] = DEFAULT_RHN_PARENT
        if self.config['serverHostname'] != DEFAULT_RHN_PARENT:
            self.xml.get_widget("configSatelliteButton").set_active(1)
            #self.onConfigSatelliteButtonToggled(1)
        if not self.config["caCert"]:
            self.config["caCert"] = DEFAULT_RHN_TRUSTED_SSL_CERT
        if self.config['caCert'] != DEFAULT_RHN_TRUSTED_SSL_CERT:
            self.xml.get_widget("configSatelliteButton").set_active(1)
            #self.onConfigSatelliteButtonToggled(1)
        self.xml.get_widget("satelliteUrlEntry").set_text(self.config["serverHostname"])
        self.xml.get_widget("caCertEntry").set_text(self.config["caCert"])

    def __resetRhnAccountInfoPage_http_proxy(self):
        """Force the http proxy toggles to be triggered.
        o grey out or enable the appropriate settings
        o set the appropriate values
        """
        # if not... set to defaults
        if not self.config["httpProxy"]:
            self.config["httpProxy"] = EXAMPLE_HTTP_PROXY
            self.config['httpProxyUsername'] = \
              self.config['httpProxyPassword'] = ''
        if self.config["httpProxy"] != EXAMPLE_HTTP_PROXY:
            self.xml.get_widget("useHttpProxyButton").set_active(1)
            #self.onUseHttpProxyToggled(1)
        if not self.config["httpProxyUsername"]:
            self.config["httpProxyUsername"] = ''
        if not self.config["httpProxyPassword"]:
            self.config["httpProxyPassword"] = ''
        self.xml.get_widget("httpProxyEntry").set_text(self.config["httpProxy"])
        self.xml.get_widget("httpProxyUsernameEntry").set_text(
          self.config["httpProxyUsername"])
        self.xml.get_widget("httpProxyPasswordEntry").set_text(
          self.config["httpProxyPassword"])

    def onRhnAccountInfoPagePrepare(self, page, dummy):
        """ Force the satellite url/ca cert & http proxy toggles to be trigged.

            (ie. grey out or enable the appropriate settings)
            Also, set the appropriate values (useful if people start hitting
            the back button).
        """
        # common code is in place, now populate some variables.
        self.__initRHNAccountInfoPage_server()

        self.onSkipRegistrationButtonToggled(
          self.xml.get_widget("skipRegistrationButton"))
        self.onConfigSatelliteButtonToggled(
          self.xml.get_widget("configSatelliteButton"))
        self.onUseHttpProxyToggled(self.xml.get_widget("useHttpProxyButton"))

        self.__resetRhnAccountInfoPage_server()
        self.__resetRhnAccountInfoPage_http_proxy()

    def onSkipRegistrationButtonToggled(self, button):
        if not button.get_active():
            self.xml.get_widget("rhnUsernameLabel").set_sensitive(TRUE)
            self.xml.get_widget("rhnUsernameEntry").set_sensitive(TRUE)
            self.xml.get_widget("rhnPasswordLabel").set_sensitive(TRUE)
            self.xml.get_widget("rhnPasswordEntry").set_sensitive(TRUE)
            self.xml.get_widget("rhnPasswordConfirmLabel").set_sensitive(TRUE)
            self.xml.get_widget("rhnPasswordConfirmEntry").set_sensitive(TRUE)
        else:
            self.xml.get_widget("rhnUsernameLabel").set_sensitive(FALSE)
            self.xml.get_widget("rhnUsernameEntry").set_sensitive(FALSE)
            self.xml.get_widget("rhnPasswordLabel").set_sensitive(FALSE)
            self.xml.get_widget("rhnPasswordEntry").set_sensitive(FALSE)
            self.xml.get_widget("rhnPasswordConfirmLabel").set_sensitive(FALSE)
            self.xml.get_widget("rhnPasswordConfirmEntry").set_sensitive(FALSE)


    def onConfigSatelliteButtonToggled(self, button):
        if button.get_active():
            self.xml.get_widget("satelliteLabel").set_sensitive(TRUE)
            self.xml.get_widget("satelliteUrlEntry").set_sensitive(TRUE)
            self.xml.get_widget("caCertLabel").set_sensitive(TRUE)
            self.xml.get_widget("caCertEntry").set_sensitive(TRUE)
        else:
            self.xml.get_widget("satelliteLabel").set_sensitive(FALSE)
            self.xml.get_widget("satelliteUrlEntry").set_sensitive(FALSE)
            self.xml.get_widget("caCertLabel").set_sensitive(FALSE)
            self.xml.get_widget("caCertEntry").set_sensitive(FALSE)

    def onUseHttpProxyToggled(self, button):
        if button.get_active():
            self.xml.get_widget("httpProxyEntry").set_sensitive(TRUE)
            self.xml.get_widget("httpProxyUsernameEntry").set_sensitive(TRUE)
            self.xml.get_widget("httpProxyPasswordEntry").set_sensitive(TRUE)
            self.xml.get_widget("httpProxyLabel").set_sensitive(TRUE)
            self.xml.get_widget("httpProxyUsernameLabel").set_sensitive(TRUE)
            self.xml.get_widget("httpProxyPasswordLabel").set_sensitive(TRUE)
        else:
            self.xml.get_widget("httpProxyEntry").set_sensitive(FALSE)
            self.xml.get_widget("httpProxyUsernameEntry").set_sensitive(FALSE)
            self.xml.get_widget("httpProxyPasswordEntry").set_sensitive(FALSE)
            self.xml.get_widget("httpProxyLabel").set_sensitive(FALSE)
            self.xml.get_widget("httpProxyUsernameLabel").set_sensitive(FALSE)
            self.xml.get_widget("httpProxyPasswordLabel").set_sensitive(FALSE)

    def __runRegistration(self):
        """ Register using username and password. """

        if not self.config["rhnUsername"] \
        or (self.config["rhnUsername"] and not self.config["rhnPassword"]) \
        or (self.config["rhnPassword"] and not self.config["rhnUsername"]):
            self.__setArrowCursor()
            self.__error(_("You must enter a RHN username and a RHN password."))
            if not self.config["rhnPassword"]:
                self.xml.get_widget("rhnPasswordEntry").grab_focus()
            if not self.config["rhnUsername"]:
                self.xml.get_widget("rhnUsernameEntry").grab_focus()
            return TRUE

        if self.config['rhnPassword'] != self.config['rhnPasswordConfirm']:
            self.__setArrowCursor()
            self.__error(_("Your passwords do not match. "
                           "Please re-type the second password."))
            self.xml.get_widget("rhnPasswordConfirmEntry").grab_focus()
            return TRUE

        # Create an account (username/password) if doesn't exist already.
        try:
            httpProxy = self.config["httpProxy"]
            httpProxyUsername = self.config["httpProxyUsername"]
            httpProxyPassword = self.config["httpProxyPassword"]
            if not self.useHttpProxyYN:
                httpProxy, httpProxyUsername, httpProxyPassword = None, None, None

            pi.validateRhnLogin(self.config["serverHostname"],
                                      httpProxy,
                                      httpProxyUsername, httpProxyPassword,
                                      self.config["rhnUsername"], self.config["rhnPassword"])
        except InvalidUsernamePassword:
            self.__setArrowCursor()
            self.__error(_("The username and password do not match "
                           "an existing RHN account."))
            if not self.config["rhnPassword"]:
                self.xml.get_widget("rhnPasswordEntry").grab_focus()
            return TRUE
        except socket.error:
            self.__setArrowCursor()
            self.__error(_("Socket error: %s") % fetchTraceback())
            return TRUE

        # Register a box given and rhn username/password.
        try:
            pi.registerSystem(self.config["rhnUsername"], self.config["rhnPassword"])
        except RhnEntitlementError, e:
            self.__setArrowCursor()
            self.__error(_("There was a problem registering this system: %s") % e.errmsg)
            return TRUE

    def __urlToHostname(self, url):
        """ Takes a stab at parsing the url given and pulling out the hostname.
        """
        return parseUrl(url)[1]

    def __redhatDomainYN(self, hostname):
        x = string.split(hostname, '.')
        if len(x) < 3:
            return 0
        if x[-1] == 'com' and x[-2] == 'redhat':
            return 1
        return 0

    def onRhnAccountInfoPageNext(self, page, dummy):
        """ Account info for RHN in general: ie. for update agent, etc.

            THREE SECTIONS:
              Get username/password
              Get RHN Satellite Server settings (and CA Cert).
              Get http proxy settings.
        """
        ### (1) USERNAME AND PASSWORD SECTION ---------------------------------

        # Username and Password:
        rhnUsername = self.xml.get_widget("rhnUsernameEntry").get_text()
        rhnPassword = self.xml.get_widget("rhnPasswordEntry").get_text()
        rhnPasswordConfirm = self.xml.get_widget("rhnPasswordConfirmEntry").get_text()

        ### (2) RHN SATELLITE SERVER (AND CA CERT) SECTION --------------------

        # Server/Satellite URL and CA Cert stuff:
        self.configSatelliteYN = self.xml.get_widget("configSatelliteButton").get_active()
        
        serverHostname = caCert = None
        if self.configSatelliteYN:
            url = string.strip(self.xml.get_widget("satelliteUrlEntry").get_text())
            serverHostname = self.__urlToHostname(url)
            caCert = string.strip(self.xml.get_widget("caCertEntry").get_text())

            if not serverHostname:
                serverHostname = DEFAULT_RHN_PARENT
            if not caCert:
                caCert = DEFAULT_RHN_TRUSTED_SSL_CERT

            # Check to see that this hostname resolves.
            try:
                socket.gethostbyname(serverHostname)
            except socket.error:
                self.__error(_("Hostname selected did not resolve: '%s'") % serverHostname)
                self.xml.get_widget("satelliteUrlEntry").grab_focus()
                return TRUE

            # If the default, don't set these things.
            if serverHostname != DEFAULT_RHN_PARENT:
                self.proxyConfig.set('proxy.rhn_parent', parseUrl(serverHostname)[1])
            if caCert != DEFAULT_RHN_TRUSTED_SSL_CERT:
                self.proxyConfig.set('proxy.ca_chain', caCert)

            if not os.path.exists(caCert):
                self.__error(_("CA Certificate file, %s, does not exist. Ensure "
                               "that the client-side SSL certificate for server "
                               "%s, has been installed on this machine.")
                             % (caCert, serverHostname))
                self.xml.get_widget("caCertEntry").grab_focus()
                return TRUE
        else:
            # reset everything back to the original defaults.
            self.config["serverHostname"] = ''
            self.config["caCert"] = ''
            self.__resetRhnAccountInfoPage_server()
            serverHostname = self.config["serverHostname"]
            caCert = self.config["caCert"]

        # check against previously stored serverHostname/caCert and store.
        if serverHostname != self.config["serverHostname"] \
        or caCert != self.config["caCert"] \
        or rhnUsername != self.config["rhnUsername"] \
        or rhnPassword != self.config["rhnPassword"] \
        or rhnPassword != self.config["rhnPasswordConfirm"]:
            self.config["serverHostname"] = serverHostname
            self.config["caCert"] = caCert
            self.config["rhnUsername"] = rhnUsername
            self.config["rhnPassword"] = rhnPassword
            self.config["rhnPasswordConfirm"] = rhnPasswordConfirm
            self.haveRegisteredYN = 0

        print 'RHN Server/Satellite hostname: %s' % self.config["serverHostname"]
        print "CA Cert:                       %s" % self.config["caCert"]

        ### (3) HTTP PROXY SECTION --------------------------------------------

        # HTTP Proxy stuff:
        self.useHttpProxyYN = self.xml.get_widget("useHttpProxyButton").get_active()
        self.config["httpProxy"] = ""
        self.config["httpProxyUsername"]  = ""
        self.config["httpProxyPassword"] = ""

        if self.useHttpProxyYN:
            self.config["httpProxy"] = self.xml.get_widget("httpProxyEntry").get_text()
            if self.config["httpProxy"] == "":
                self.__error(_("You must enter proxy url."))
                self.xml.get_widget("httpProxyEntry").grab_focus()
                return TRUE

            # get and check sanity of http proxy username/password settings.
            self.config["httpProxyUsername"] = \
              self.xml.get_widget("httpProxyUsernameEntry").get_text()
            self.config["httpProxyPassword"] = \
              self.xml.get_widget("httpProxyPasswordEntry").get_text()
            if self.config["httpProxyPassword"] \
              and not self.config["httpProxyUsername"]:
                self.__error(_("You must enter an http proxy username if you "
                               "enter an http proxy user password."))
                self.xml.get_widget("httpProxyUsernameEntry").grab_focus()
                return TRUE

            # turn on http proxy...
            pi_config.up2dateCfg.writeEntry("enableProxy", 1)
            pi_config.registerCfg.writeEntry("enableProxy", 1)

            pi_config.up2dateCfg.writeEntry("httpProxy",
                                            self.config["httpProxy"])
            pi_config.registerCfg.writeEntry("httpProxy",
                                             self.config["httpProxy"])

            self.proxyConfig.set('proxy.http_proxy', self.config["httpProxy"])

            if self.config['httpProxyUsername'] \
              or self.config['httpProxyPassword']:
                # turn on http proxy auth...
                pi_config.up2dateCfg.writeEntry("enableProxyAuth", 1)
                pi_config.registerCfg.writeEntry("enableProxyAuth", 1)
            else:
                # turn off http proxy auth...
                pi_config.up2dateCfg.writeEntry("enableProxyAuth", 0)
                pi_config.registerCfg.writeEntry("enableProxyAuth", 0)

            if self.config["httpProxyUsername"]:
                self.proxyConfig.set('proxy.http_proxy_username',
                                     self.config["httpProxyUsername"])

            if self.config["httpProxyPassword"]:
                self.proxyConfig.set('proxy.http_proxy_password',
                                     self.config["httpProxyPassword"])

            # write http proxy settings...
            pi_config.up2dateCfg.writeEntry("proxyUser",
                                            self.config["httpProxyUsername"])
            pi_config.registerCfg.writeEntry("proxyUser",
                                             self.config["httpProxyUsername"])
            pi_config.up2dateCfg.writeEntry("proxyPassword",
                                            self.config["httpProxyPassword"])
            pi_config.registerCfg.writeEntry("proxyPassword",
                                             self.config["httpProxyPassword"])

            print "HTTP Gateway HTTP Proxy      : %s" \
                  % self.config["httpProxy"]
            print 'HTTP Gateway HTTP Proxy User : %s' \
                  % self.config["httpProxyUsername"]
            if self.config["httpProxyPassword"]:
                print 'HTTP Gateway HTTP Proxy Pass : %s' % '<password>'
            else:
                print 'HTTP Gateway HTTP Proxy Pass : '
        else:
            # reset everything back to the original defaults.
            self.config["httpProxy"] = ''
            self.config["httpProxyUsername"] = ''
            self.config["httpProxyPassword"] = ''
            # turn off http proxy...
            pi_config.up2dateCfg.writeEntry("enableProxy", 0)
            pi_config.registerCfg.writeEntry("enableProxy", 0)
            pi_config.up2dateCfg.writeEntry("enableProxyAuth", 0)
            pi_config.registerCfg.writeEntry("enableProxyAuth", 0)
            # write empty http proxy settings...
            p = self.config["httpProxy"]
            pu = self.config["httpProxyUsername"]
            pp = self.config["httpProxyPassword"]
            pi_config.up2dateCfg.writeEntry("httpProxy", p)
            pi_config.registerCfg.writeEntry("httpProxy", p)
            pi_config.up2dateCfg.writeEntry("proxyUser", pu)
            pi_config.registerCfg.writeEntry("proxyUser", pu)
            pi_config.up2dateCfg.writeEntry("proxyPassword", pp)
            pi_config.registerCfg.writeEntry("proxyPassword", pp)
            self.__resetRhnAccountInfoPage_http_proxy()

        # Write server info to the up2date and rhn_register config files.
        pi_config.up2dateCfg.writeEntry("noSSLServerURL",
                                        'http://'+serverHostname+'/XMLRPC')
        pi_config.up2dateCfg.writeEntry("serverURL",
                                        'https://'+serverHostname+'/XMLRPC')
        pi_config.registerCfg.writeEntry("noSSLServerURL",
                                         'http://'+serverHostname+'/XMLRPC')
        pi_config.registerCfg.writeEntry("serverURL",
                                         'https://'+serverHostname+'/XMLRPC')

        pi_config.up2dateCfg.writeEntry("sslCACert", caCert)
        pi_config.registerCfg.writeEntry("sslCACert", caCert)

        pi_config.up2dateCfg.save()
        pi_config.registerCfg.save()

        if not self.xml.get_widget("skipRegistrationButton").get_active() \
          and not self.haveRegisteredYN:
            # register this configuration.
            self.__setBusyCursor()
            ret = self.__runRegistration()
            self.__setArrowCursor()
            if ret:
                return ret
            self.xml.get_widget("skipRegistrationButton").set_active(1)
            self.haveRegisteredYN = 1

    #
    # druid page 4
    #
    def onProxyApplicationSettingsPagePrepare(self, page, dummy):
        ## set up paths:
        DEFAULT_PATH = '/usr/share/rhn'
        if DEFAULT_PATH not in sys.path:
            sys.path.append(DEFAULT_PATH)
        from common import initCFG, CFG
        initCFG('proxy')

        proxyAdminEmail = self.xml.get_widget("proxyApplicationSettingsAdminEmailEntry").get_text()
        proxyMountPoint = self.xml.get_widget("proxyMountPointEntry").get_text()
        if not proxyAdminEmail:
            traceback_mail = CFG.TRACEBACK_MAIL
            if type(traceback_mail) == type([]):
                traceback_mail = string.join(traceback_mail, ', ')
            self.xml.get_widget("proxyApplicationSettingsAdminEmailEntry").set_text(traceback_mail)
        if not proxyMountPoint:
            self.xml.get_widget("proxyMountPointEntry").set_text(CFG.PKG_DIR)

    def onProxyApplicationSettingsPageBack(self, page, dummy):
        pass

    def onProxyApplicationSettingsPageNext(self, page, dummy):
        self.proxyAdminEmail = self.xml.get_widget("proxyApplicationSettingsAdminEmailEntry").get_text()
        self.proxyMountPoint = self.xml.get_widget("proxyMountPointEntry").get_text()

        self.proxyConfig.set("traceback_mail", self.proxyAdminEmail)
        self.proxyConfig.set("proxy.pkg_dir", self.proxyMountPoint)

        self.__setArrowCursor()

        ## can't activate or update the system if we dont register
        #if not self.haveRegisteredYN:
        #    return FALSE

        httpProxy = self.config["httpProxy"]
        httpProxyUsername = self.config["httpProxyUsername"]
        httpProxyPassword = self.config["httpProxyPassword"]
        if not self.useHttpProxyYN:
            httpProxy, httpProxyUsername, httpProxyPassword = None, None, None

        funct = pi.activateProxy_v1_1
        try:
            apiVersion = pi.getAPIVersion(self.config["serverHostname"],
                                          httpProxy,
                                          httpProxyUsername,
                                          httpProxyPassword)
            if apiVersion[0] == '1':
                funct = pi.activateProxy_v1_1
            elif apiVersion[0] == 3:
                funct = pi.activateProxy_v3_2
            elif int(apiVersion[0]) >= 3:
                funct = pi.activateProxy_v3_2

            errorCode, errorString = funct(self.config["serverHostname"],
                                           httpProxy,
                                           httpProxyUsername,
                                           httpProxyPassword, apiVersion)
        except:
            print ('Exception occurred while attempting to fetch upstream API '
                   'version. Assuming v1.1.')
            fetchTraceback()

        if errorCode == -1 and not errorString:
            # ancient satellite will produce a -1 error-code... nothing else should.
            errorString = _("An unknown error occured; consult with your Red Hat representative.\n")
            log_me(errorString)
            self.__error(_("There was a problem activating the RHN Proxy entitlement:\n\n%s") % errorString)
            return FALSE # do not loop

        if errorCode != 1:
            if not errorString:
                errorString = ("An unknown error occured. Consult with your Red Hat representative.\n")
            self.__error(_("There was a problem activating the RHN Proxy entitlement:\n\n%s") % errorString)
            return TRUE


    #
    # druid page 5
    #
    def onProxyUp2datePagePrepare(self, page, dummy):
        pass

    def onProxyUp2datePageBack(self, page, dummy):
        pass

    def onProxyUp2datePageNext(self, page, dummy):
        # Write rhn.conf here cuz the proxy packages blow away the
        # one we wrote.
        try:
            self.proxyConfig.write()
        except IOError:
            self.__error(_("There was a problem (IOError) writing to /etc/rhn/rhn.conf: %s") % fetchTraceback())
            return TRUE
        except Exception:
            self.__error(_("There was a problem writing to /etc/rhn/rhn.conf: %s") % fetchTraceback())
            return TRUE
        
	# short-circuit the rest of this process... up2date done outside of
	# this wizard now.
        return
    
    #
    # druid page 6
    #
    def onSslCertInfoPagePrepare(self, page, dummy):
        from certs.sslToolLib import getMachineName, getCertValidityRange, \
                                     yearsTil12Jan2037

        sslDir = os.path.join(DEFAULT_RHN_ETC_DIR, 'ssl')
        machineSslDir = os.path.join(sslDir, getMachineName(self.thisbox))

        caCertConfFile = os.path.join(sslDir, 'rhn-ca-openssl.cnf')
        serverCertConfFile = os.path.join(machineSslDir,
                                          'rhn-server-openssl.cnf')

        cad, sed = fetchSslData(caCertConfFile, serverCertConfFile)

        trustedCaCert = os.path.join(
          sslDir, os.path.basename(DEFAULT_ORG_TRUSTED_SSL_CERT))
        xxx, notAfter_ca = getCertValidityRange(trustedCaCert)

        serverCert = os.path.join(machineSslDir, 'server.crt') 
        xxx, notAfter_server = getCertValidityRange(serverCert)

        if notAfter_ca is not None:
            # subtract time now
            notAfter_ca = notAfter_ca - time.time()
            # secs --> years
            yearInSecs = 31536000.0 #365*24*60*60
            notAfter_ca = int(round(notAfter_ca/yearInSecs))

        if notAfter_server is not None:
            # subtract time now
            notAfter_server = notAfter_server - time.time()
            # secs --> years
            yearInSecs = 31536000.0 #365*24*60*60
            notAfter_server = int(round(notAfter_server/yearInSecs))

        self.config.update({
            'keyPassword': '',
            'keyPasswordConfirm': '',
            'countryCode': cad.get('C', ''),
            'state': cad.get('ST', ''),
            'locality': cad.get('L', ''),
            'orgName': cad.get('O', ''),
            'orgUnit': cad.get('OU', ''),
            'commonName': cad.get('CN', ""),
            'hostname': sed.get('CN', self.thisbox),
            'caCertExpiration' : notAfter_ca or int(round(yearsTil12Jan2037())),
            'serverCertExpiration' : notAfter_server or int(round(yearsTil12Jan2037())),
        })
        self.xml.get_widget("sslCertUrlLabel").set_text('http://' + self.thisbox + '/pub/')
        self.xml.get_widget("sslKeyPasswordEntry").set_text(self.config['keyPassword'])
        self.xml.get_widget("sslKeyPasswordConfirmEntry").set_text(self.config['keyPasswordConfirm'])
        self.xml.get_widget("countryCodeEntry").set_text(self.config['countryCode'])
        self.xml.get_widget("stateEntry").set_text(self.config['state'])
        self.xml.get_widget("localityEntry").set_text(self.config['locality'])
        self.xml.get_widget("orgNameEntry").set_text(self.config['orgName'])
        self.xml.get_widget("orgUnitEntry").set_text(self.config['orgUnit'])
        self.xml.get_widget("commonNameEntry").set_text(self.config['commonName'])
        self.xml.get_widget("sslHostnameEntry").set_text(self.config['hostname'])
        self.xml.get_widget("sslCaCertExpirationEntry").set_text(str(self.config['caCertExpiration']))
        self.xml.get_widget("sslServerCertExpirationEntry").set_text(str(self.config['serverCertExpiration']))

    def onSslCertInfoPageBack(self, page, dummy):
        pass

    def onConfigSSLCertButtonToggled(self, button):
        if not button.get_active():
            self.xml.get_widget("sslKeyPasswordLabel").set_sensitive(TRUE)
            self.xml.get_widget("sslKeyPasswordConfirmLabel").set_sensitive(TRUE)
            self.xml.get_widget("countryCodeLabel").set_sensitive(TRUE)
            self.xml.get_widget("stateLabel").set_sensitive(TRUE)
            self.xml.get_widget("localityLabel").set_sensitive(TRUE)
            self.xml.get_widget("orgNameLabel").set_sensitive(TRUE)
            self.xml.get_widget("orgUnitLabel").set_sensitive(TRUE)
            self.xml.get_widget("sslHostnameLabel").set_sensitive(TRUE)
            self.xml.get_widget("commonNameLabel").set_sensitive(TRUE)
            self.xml.get_widget("sslCaCertExpirationLabel").set_sensitive(TRUE)
            self.xml.get_widget("sslServerCertExpirationLabel").set_sensitive(TRUE)

            self.xml.get_widget("sslKeyPasswordEntry").set_sensitive(TRUE)
            self.xml.get_widget("sslKeyPasswordConfirmEntry").set_sensitive(TRUE)
            self.xml.get_widget("countryCodeEntry").set_sensitive(TRUE)
            self.xml.get_widget("stateEntry").set_sensitive(TRUE)
            self.xml.get_widget("localityEntry").set_sensitive(TRUE)
            self.xml.get_widget("orgNameEntry").set_sensitive(TRUE)
            self.xml.get_widget("orgUnitEntry").set_sensitive(TRUE)
            self.xml.get_widget("sslHostnameEntry").set_sensitive(TRUE)
            self.xml.get_widget("commonNameEntry").set_sensitive(TRUE)
            self.xml.get_widget("sslCaCertExpirationEntry").set_sensitive(TRUE)
            self.xml.get_widget("sslServerCertExpirationEntry").set_sensitive(TRUE)
        else:
            self.xml.get_widget("sslKeyPasswordLabel").set_sensitive(FALSE)
            self.xml.get_widget("sslKeyPasswordConfirmLabel").set_sensitive(FALSE)
            self.xml.get_widget("countryCodeLabel").set_sensitive(FALSE)
            self.xml.get_widget("stateLabel").set_sensitive(FALSE)
            self.xml.get_widget("localityLabel").set_sensitive(FALSE)
            self.xml.get_widget("orgNameLabel").set_sensitive(FALSE)
            self.xml.get_widget("orgUnitLabel").set_sensitive(FALSE)
            self.xml.get_widget("sslHostnameLabel").set_sensitive(FALSE)
            self.xml.get_widget("commonNameLabel").set_sensitive(FALSE)
            self.xml.get_widget("sslCaCertExpirationLabel").set_sensitive(FALSE)
            self.xml.get_widget("sslServerCertExpirationLabel").set_sensitive(FALSE)

            self.xml.get_widget("sslKeyPasswordEntry").set_sensitive(FALSE)
            self.xml.get_widget("sslKeyPasswordConfirmEntry").set_sensitive(FALSE)
            self.xml.get_widget("countryCodeEntry").set_sensitive(FALSE)
            self.xml.get_widget("stateEntry").set_sensitive(FALSE)
            self.xml.get_widget("localityEntry").set_sensitive(FALSE)
            self.xml.get_widget("orgNameEntry").set_sensitive(FALSE)
            self.xml.get_widget("orgUnitEntry").set_sensitive(FALSE)
            self.xml.get_widget("sslHostnameEntry").set_sensitive(FALSE)
            self.xml.get_widget("commonNameEntry").set_sensitive(FALSE)
            self.xml.get_widget("sslCaCertExpirationEntry").set_sensitive(FALSE)
            self.xml.get_widget("sslServerCertExpirationEntry").set_sensitive(FALSE)

    def onSslCertInfoPageNext(self, page, dummy):
        sys.path.append("/usr/share/rhn/")
        from certs.sslToolLib import RhnSslToolException, yearsTil12Jan2037

        keyPassword = self.xml.get_widget("sslKeyPasswordEntry").get_text()
        keyPasswordConfirm = self.xml.get_widget("sslKeyPasswordConfirmEntry").get_text()
        countryCode = self.xml.get_widget("countryCodeEntry").get_text()
        state = self.xml.get_widget("stateEntry").get_text()
        locality = self.xml.get_widget("localityEntry").get_text()
        orgName = self.xml.get_widget("orgNameEntry").get_text()
        orgUnit = self.xml.get_widget("orgUnitEntry").get_text()
        commonName = self.xml.get_widget("commonNameEntry").get_text()
        hostname = self.xml.get_widget("sslHostnameEntry").get_text()
        caCertExpiration = self.xml.get_widget("sslCaCertExpirationEntry").get_text()
        serverCertExpiration = self.xml.get_widget("sslServerCertExpirationEntry").get_text()

        if not self.xml.get_widget("configSSLCertButton").get_active():
            if keyPassword == "":
                self.__error(_("You must enter a password."))
                self.xml.get_widget("sslKeyPasswordEntry").grab_focus()
                return TRUE

            # invalid character check
            # ***NOTE*** Must coordinate with web and app folks about any
            # changes to this set of characters!!!!
            invalid_re = re.compile(".*[\t\r\n\f\013&+%'`\"=#]", re.I)
            tmp = invalid_re.match(keyPassword)
            if tmp is not None:
                pos = tmp.regs[0]
                self.__error(_("ERROR: the password contains an invalid character: '%s'"
                  % keyPassword[pos[1]-1]))
                self.xml.get_widget("sslKeyPasswordEntry").grab_focus()
                return TRUE

            if keyPasswordConfirm != keyPassword:
                self.__error(_("The password and it's confirmation do not match!"))
                self.xml.get_widget("sslKeyPasswordConfirmEntry").grab_focus()
                return TRUE

            if len(countryCode) != 2:
                self.__error(_("You must enter a two character country code."))
                self.xml.get_widget("countryCodeEntry").grab_focus()
                return TRUE

            if state == "":
                self.__error(_("You must enter a state or province name."))
                self.xml.get_widget("stateEntry").grab_focus()
                return TRUE

            if locality == "":
                self.__error(_("You must enter a locality or city."))
                self.xml.get_widget("localityEntry").grab_focus()
                return TRUE

            if orgName == "":
                self.__error(_("You must enter an organization name."))
                self.xml.get_widget("orgNameEntry").grab_focus()
                return TRUE

            if orgUnit == "":
                self.__error(_("You must enter a organization unit."))
                self.xml.get_widget("orgUnitEntry").grab_focus()
                return TRUE

#            if commonName == "":
#                self.__error(_("You must enter a common name."))
#                self.xml.get_widget("commonNameEntry").grab_focus()
#                return TRUE

        try:
            (caCertExpiration, serverCertExpiration) = \
              checkExpirationRanges(caCertExpiration, serverCertExpiration)
        except ValueError, e:
            self.__error(e.args[0])
            self.xml.get_widget("sslCaCertExpirationEntry").grab_focus()
            return TRUE

        if hostname == "":
            self.__error(_("You must enter a hostname (FQDN)."))
            self.xml.get_widget("sslHostnameEntry").grab_focus()
            self.xml.get_widget("sslHostnameEntry").set_text(socket.gethostname())
            return TRUE

        if len(string.split(hostname, '.')) < 3:
            self.__warning(_("Hostname (%s) doesn't appear to be a FQDN")
                           % hostname)

        # ugly, but I am in a hurry
        if self.config['keyPassword'] != keyPassword \
        or self.config['countryCode'] != countryCode \
        or self.config['state'] != state \
        or self.config['locality'] != locality \
        or self.config['orgName'] != orgName \
        or self.config['orgUnit'] != orgUnit \
        or self.config['commonName'] != commonName:
            self.config['keyPassword'] = keyPassword
            self.config['countryCode'] = countryCode
            self.config['state'] = state
            self.config['locality'] = locality
            self.config['orgName'] = orgName
            self.config['orgUnit'] = orgUnit
            self.config['hostname'] = hostname
            self.config['commonName'] = commonName
            self.config['caCertExpiration'] = caCertExpiration
            self.config['serverCertExpiration'] = serverCertExpiration
            #self.xml.get_widget("configSSLCertButton").set_active(0)

        self.__setBusyCursor()
        if not self.xml.get_widget("configSSLCertButton").get_active():
            try:
                sslCertRpmPath, caCertRpmPath = \
                  pi.genSslCerts(keyPassword, countryCode, state,
                                 locality, orgName, orgUnit,
                                 commonName, self.proxyAdminEmail,
                                 self.thisbox, caCertExpiration, serverCertExpiration)
            except (RhnSslToolException, genCAKeyError, genPublicCaCertError):
                self.__error(_("Error upon generation of SSL RPMs: %s") % fetchTraceback())
                return TRUE
            else:
                self.xml.get_widget("sslCertUrlLabel").set_text('http://' + self.thisbox + '/pub/' + os.path.basename(caCertRpmPath))

        self.xml.get_widget("configSSLCertButton").set_active(1)

        # setup squid (copy over the sample/default squid.conf).
        if not self.squidSetupYN:
            pi.setupSquid()
            self.squidSetupYN = 1

        # setup up apache with the new configs
        if not self.httpdSetupYN:
            pi.setupHttpds(self.baseDir)
            self.httpdSetupYN = 1

        # switch them all on according to chkconfig
        pi.switchOnAllServices()

        self.__setArrowCursor()


    #
    # druid page 7
    #
    def onFinishPagePrepare(self, page, dummy):
        pass

    def onFinishPageFinish(self, page, dummy):
        gtk.mainquit()
        sys.exit(0)




def wrap_line(line, max_line_size = 100):
    """ wrap a long line... """
    if len(line) < max_line_size:
        return line
    ret = []
    l = ""
    for w in string.split(line):
        if not len(l):
            l = w
            continue
        if len(l) > max_line_size:
            ret.append(l)
            l = w
        else:
            l = "%s %s" % (l, w)
    if len(l):
        ret.append(l)
    return string.join(ret, '\n')


def wrap_text(txt):
    """ wrap an entire piece of text """
    return string.join(map(wrap_line, string.split(txt, '\n')), '\n')


def usage():
    """ display an usage message """
    print """
    RHN Proxy Server Installer valid options:
    --nosig     When up2date is run as part of the install process, do not
                check for signatures (NOT RECOMMENDED).

    --help      This help usage page
    """

def parseArgs():
    """ Parse/respond-to the commandline arguments. """

    # default values...
    options = {
                # we check signatures by default.
                "nosig" : 0,
              }
    try:
        opts, args = getopt.getopt(_ARGS, "h", ["nosig",
                                                "help"])
    except getopt.error, e:
        print "ERROR: %s" % e
        usage()
        sys.exit(0)

    for opt, val in opts:
        if opt == "--nosig":
            options["nosig"] = 1
        elif opt in ["--help", "-h"]:
            usage()
            sys.exit(0)
    if args:
        print "WARNING: Ignoring unknown args", args
    return options


def checkExpirationRanges(ssl_ca_cert_expiration, ssl_httpd_cert_expiration):
    sys.path.append("/usr/share/rhn/")
    from certs.sslToolLib import yearsTil12Jan2037
    years = int(round(yearsTil12Jan2037()))
    allowedRange = range(years+1)[1:] # 1...13
    for exp in (ssl_ca_cert_expiration, ssl_httpd_cert_expiration):
        msg = ('ERROR: expirations must be within the range %s-%s '
               'years (integers only)' % (allowedRange[0], allowedRange[-1]))
        try:
            exp = int(exp)
            if exp not in allowedRange:
                raise ValueError(msg)
        except ValueError:
            raise ValueError(msg)
    return ssl_ca_cert_expiration, ssl_httpd_cert_expiration


#------------------------------------------------------------------------------
def main():
    try:
        gtk._disable_gdk_threading()
    except AttributeError:
        #print 'NOTE: old pygtk bindings detected. Continuing...'
        pass
    # make sure we're root
    if os.getuid():
        print "ERROR: You need to run this install program as root"
        sys.exit(-1)
    options = parseArgs()
    Gui(options)
    gtk.mainloop()

if __name__ == "__main__":
    try:
        sys.exit(main() or 0)
    except KeyboardInterrupt:
        print 'User interrupted process.'
        sys.exit(0)
    except SystemExit:
        raise
    except:
        printTraceback()
#------------------------------------------------------------------------------

