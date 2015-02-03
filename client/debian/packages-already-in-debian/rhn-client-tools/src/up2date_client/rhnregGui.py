#
# Copyright (c) 1999--2012 Red Hat, Inc.
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



# this is a module containing classes for the registration related windows in
# gui.py. The code is split up so we can reuse it in the firstboot modules
"""
Explanation of the RHN registration gui and how it is used from both
rhn_register and firstboot (from alikins):
Most of the "work" happens in rhnregGui.py. Thats where the
logic for the screens is.
gui.py has Gui which is the big monster class (using druid) that makes up the
main gui wizard for up2date/rhn_register. Gui implements showing the pages for
up2date/rhn_register. For up2date/rhnreg, it has methods that load the classes
from rhnregGui (by multiple inheritance...), but it's not too bad, it's all
mixin stuff, nothing wacky, no overridden methods or anything.
firstboot/* does more or less the same thing, but with a different style of
wrapper just to present the firstboot style api's. (Each "page" in firstboot is
a module with a class that inherits FirstBootGuiWindow.)
"""

import urlparse
import gtk
# Need to import gtk.glade to make this file work alone even though we always
# access it as gtk.glade. Not sure why. Maybe gtk's got weird hackish stuff
# going on?
import gtk.glade
import gobject
import sys
import os
import gettext
t = gettext.translation('rhn-client-tools', fallback=True)
_ = t.ugettext
gtk.glade.bindtextdomain("rhn-client-tools")

import rhnreg
from rhnreg import ActivationResult
import up2dateErrors
import hardware
import messageWindow
import progress
from up2date_client import pkgUtils
import up2dateAuth
import up2dateUtils
import config
import OpenSSL
import up2dateLog
from rhn import rpclib
from rhn.connections import idn_puny_to_unicode
import rhnreg_constants

cfg = config.initUp2dateConfig()
log = up2dateLog.initLog()

gladefile = "/usr/share/rhn/up2date_client/rh_register.glade"

# we need to carry these values between screen, so stash at module scope
username = None
password = None
newAccount = None # Should be assigned True or False
productInfo = None
hw_activation_code = None
serverType = None
chosen_channel = None

# _hasBaseChannelAndUpdates gets set by the code in create profile which
# registers the system and used by hasBaseChannelAndUpdates()
_hasBaseChannelAndUpdates = False
_autoActivatedNumbers = False # used by autoActivateNumbersOnce()

class ReviewLog:
    def __init__(self):
        self._text = gtk.TextBuffer()
        self._boldTag = self._text.create_tag(weight=700)

    def prependBoldText(self, text):
        """Adds a blob of bolded text to the beggining specified section. Adds a newline
        after the text.
        """
        self.prependText(text)
        # Make it bold
        startOfText = self._text.get_start_iter()
        endOfText = self._text.get_start_iter()
        endOfText.forward_chars(len(text) +1 )
        self._text.apply_tag(self._boldTag, startOfText, endOfText)

    def addBoldText(self, text):
        """Adds a blob of bolded text to the specified section. Adds a newline
        after the text.

        """
        self.addText(text)
        # Make it bold
        startOfText = self._text.get_end_iter()
        startOfText.backward_chars(len(text) +1 )
        end = self._text.get_end_iter()
        self._text.apply_tag(self._boldTag, startOfText, end)

    def prependText(self, text):
        """ Insert a blob of text at the beggining of section. Adds a newline
            after the text.
        """
        start = self._text.get_start_iter()
        self._text.insert(start, text + '\n')

    def addText(self, text):
        """Adds a blob of text to the specified section. Adds a newline after
        the text.

        """
        end = self._text.get_end_iter()
        self._text.insert(end, text + '\n')

    def addBulletedText(self, text):
        self.addText(u'\u2022' + ' ' + text)

    def getTextBuffer(self):
        return self._text

    def usedUniversalActivationKey(self, keyName):
        self.addBoldText(_("Notice"))
        keys = ', '.join(keyName)
        self.addText(rhnreg_constants.ACTIVATION_KEY % (keys))
        self.addText('') # adds newline

    def yum_plugin_warning(self):
        """ Add to review screen warning that yum-rhn-plugin is not installed """
        # prepending -> reverse order
        self.prependText('') # adds newline
        self.prependText(rhnreg_constants.YUM_PLUGIN_WARNING)
        self.prependBoldText(_("Warning"))

    def yum_plugin_conf_changed(self):
        """ Add to review screen warning that yum-rhn-plugin config file has been changed """
        # prepending -> reverse order
        self.prependText('') # adds newline
        self.prependText(rhnreg_constants.YUM_PLUGIN_CONF_CHANGED)
        self.prependBoldText(_("Notice"))

    def yum_plugin_conf_error(self):
        """ Add to review screen warning that yum-rhn-plugin config file can not be open """
        # prepending -> reverse order
        self.prependText('') # adds newline
        self.prependText(rhnreg_constants.YUM_PLUGIN_CONF_ERROR)
        self.prependBoldText(_("Warning"))

    def channels(self, subscribedChannels, failedChannels):
        self.addBoldText(rhnreg_constants.CHANNELS_TITLE)
        if len(subscribedChannels) > 0:
            self.addText(rhnreg_constants.OK_CHANNELS)
            for channel in subscribedChannels:
                self.addBulletedText(channel)

            # If it's hosted, reference the hosted url,
            # otherwise, we don't know the url for their sat.
            if serverType == 'hosted':
                self.addText(rhnreg_constants.CHANNELS_HOSTED_WARNING)
            else:
                self.addText(rhnreg_constants.CHANNELS_SAT_WARNING)
        else:
            self.addText(rhnreg_constants.NO_BASE_CHANNEL)
        if len(failedChannels) > 0:
            self.addText(rhnreg_constants.FAILED_CHANNELS)
            for channel in failedChannels:
                self.addBulletedText(channel)
        self.addText('') # adds newline

    def systemSlots(self, slots, failedSlots):
        self.addBoldText(rhnreg_constants.SLOTS_TITLE)
        self.addText(rhnreg_constants.OK_SLOTS)
        if len(slots) > 0:
            for slot in slots:
                self.addBulletedText(slot)
        else:
            self.addText(rhnreg_constants.NO_SYS_ENTITLEMENT)
        if len(failedSlots) > 0:
            self.addText(rhnreg_constants.FAILED_SLOTS)
            for slot in failedSlots:
                self.addBulletedText(slot)
        self.addText('') # adds newline

reviewLog = ReviewLog()


class StartPage:
    """There is a section of this page which asks if the user wants to register,
    which will only be shown in firstboot. This is specified by the arg to the
    constructor.

    """
    def __init__(self, firstboot=False):
        self.startXml = gtk.glade.XML(gladefile, "startWindowVbox",
                                                    domain="rhn-client-tools")
        self.startXml.signal_autoconnect({
            "onWhyRegisterButtonClicked" : self.startPageWhyRegisterButton,
        })
        self.registerNowButton = self.startXml.get_widget("registerNowButton")
        if not firstboot:
            startWindowVbox = self.startXml.get_widget("startWindowVbox")
            chooseToRegisterVbox = self.startXml.get_widget('chooseToRegisterVbox')
            startWindowVbox.remove(chooseToRegisterVbox)

    def startPageVbox(self):
        return self.startXml.get_widget("startWindowVbox")

    def startPageWhyRegisterButton(self, button):
        WhyRegisterDialog()

    def startPageRegisterNow(self):
        """Returns True if the user has selected to register now. False if
        they've selected to register later.

        """
        return self.registerNowButton.get_active()


class ChooseServerPage:
    def __init__(self):
        self.chooseServerXml = gtk.glade.XML(gladefile,
                                             "chooseServerWindowVbox",
                                             domain="rhn-client-tools")
        self.chooseServerXml.signal_autoconnect ({
            "onSatelliteButtonToggled" : self.onSatelliteButtonToggled,
            "onAdvancedNetworkConfigurationButtonClicked" : self.showNetworkConfigDialog
        })
        self.hostedButton = self.chooseServerXml.get_widget('hostedButton')
        self.satelliteButton = self.chooseServerXml.get_widget('satelliteButton')
        self.customServerEntry = self.chooseServerXml.get_widget('satelliteServerEntry')

        self.customServerBox = self.chooseServerXml.get_widget('customServerTable')

    def chooseServerPagePrepare(self):
        self.server = config.getServerlURL()[0]

        log.log_debug("server is %s" % self.server)
        if "rhn.redhat.com/XMLRPC" in self.server:
            self.hostedButton.set_active(True)
        else:
            self.satelliteButton.set_active(True)
            self.customServerEntry.set_text(self.server)

    def chooseServerPageVbox(self):
        return self.chooseServerXml.get_widget("chooseServerWindowVbox")

    def onSatelliteButtonToggled(self, entry):
        is_sensitive = False
        if self.satelliteButton.get_active():
            is_sensitive = True
        self.customServerBox.set_sensitive(is_sensitive)

    def showNetworkConfigDialog(self, button):
        NetworkConfigDialog()

    def chooseServerPageApply(self):
        """Returns True if an error happened so we shouldn't advance to the next
        screen, but it was already dealt with. False if everything is peachy.
        Can raise an SSLCertificateVerifyFailedError.
        """
        status = callAndFilterExceptions(
                self._chooseServerPageApply,
                [up2dateErrors.SSLCertificateVerifyFailedError, up2dateErrors.SSLCertificateFileNotFound],
                _("There was an error while applying your choice.")
        )
        if status is False:
            return False
        else:
            return True

    def _chooseServerPageApply(self):
        """Returns True if an error happened so we shouldn't advance to the next
        screen, but it was already dealt with. False if everything is peachy.
        Can probably raise all sorts of exceptions, but I wish it only raised
        SSLCertificateVerifyFailedError.
        """
        global serverType
        up2dateConfig = config.initUp2dateConfig()
        if self.hostedButton.get_active():
            config.setServerURL('https://xmlrpc.rhn.redhat.com/XMLRPC')
            if not cfg['sslCACert']:
                up2dateConfig.set('sslCACert', '/usr/share/rhn/RHNS-CA-CERT')
        else:
            customServer = self.customServerEntry.get_text()
            try:
                customServer = rhnreg.makeNiceServerUrl(customServer)
            except up2dateErrors.InvalidProtocolError:
                errorWindow(_('You specified an invalid protocol. Only '
                              'https and http are allowed.'))
                return True

            # If they changed the value, write it back to the config file.
            if customServer != self.server:
                config.setServerURL(customServer)
            if not cfg['sslCACert']:
                up2dateConfig.set('sslCACert',
                                  '/usr/share/rhn/RHN-ORG-TRUSTED-SSL-CERT')

        serverType = rhnreg.getServerType()

        NEED_SERVER_MESSAGE = _("You will not be able to successfully register "
                                "this system without contacting a Red Hat Network server.")

        # Try to contact the server to see if we have a good cert
        try:
            setBusyCursor()
            # get the caps info before we show the activastion page which needs the
            # caps. _but_ we need to do this after we configure the network...
            rhnreg.getCaps()
            setArrowCursor()
        except up2dateErrors.SSLCertificateVerifyFailedError:
            setArrowCursor()
            raise
        except up2dateErrors.SSLCertificateFileNotFound:
            setArrowCursor()
            raise
        except up2dateErrors.CommunicationError:
            setArrowCursor()
            log.log_exception(*sys.exc_info())
            protocol, host, path, parameters, query, fragmentIdentifier = urlparse.urlparse(config.getServerlURL()[0])
            dialog = messageWindow.BulletedOkDialog(_("Cannot contact selected server"))
            if serverType == 'hosted':
                dialog.add_text(_("We could not contact Red Hat Network (%s).")
                                  % host)
                dialog.add_bullet(_("Make sure the network connection on this "
                                    "system is operational."))
                dialog.add_bullet(_("Did you mean to register to a Red Hat "
                                    "Network Satellite or Proxy? If so, you can "
                                    "enter a Satellite or Proxy location "
                                    "instead."))
                dialog.add_text(NEED_SERVER_MESSAGE)
            else:
                dialog.add_text(_("We could not contact the Satellite or Proxy "
                                  "at '%s.'") % host)
                dialog.add_bullet(_("Double-check the location - is '%s' "
                                    "correct? If not, you can correct it and "
                                    "try again.") % host)
                dialog.add_bullet(_("Make sure the network connection on this "
                                    "system is operational."))
                dialog.add_text(NEED_SERVER_MESSAGE)
            dialog.run()
            return True
        except up2dateErrors.RhnServerException:
            setArrowCursor()
            log.log_exception(*sys.exc_info())
            dialog = messageWindow.BulletedOkDialog()

            dialog.add_text(_("There was an error communicating with Red Hat Network."))
            dialog.add_bullet(_("The server may be in outage mode. You may have to try "
                "connecting later."))
            dialog.add_bullet(_("You may be running a client that is incompatible with "
                "the server."))

            dialog.add_text(NEED_SERVER_MESSAGE)
            dialog.run()
            return True

        return False


class LoginPage:
    def __init__(self):
        # Derived classes must implement a function called goToPageAfterLogin
        # which the create account dialog will use.
        assert hasattr(self, "goToPageAfterLogin"), \
               "LoginPage must be derived from, by a class that implements goToPageAfterLogin."
        self.loginXml = gtk.glade.XML(gladefile,
                                      "initialLoginWindowVbox", domain="rhn-client-tools")
        self.loginXml.signal_autoconnect ({
              "onLoginUserEntryActivate" : self.loginPageAccountInfoActivate,
              "onLoginPasswordEntryActivate" : self.loginPageAccountInfoActivate,
              })
        instructionsLabel = self.loginXml.get_widget('instructionsLabel')
        self.loginPageHostedLabelText = instructionsLabel.get_label()

    def loginPagePrepare(self):
        """Changes the screen slightly depending on whether hosted or satellite
        is being used.

        """
        assert serverType in ['hosted', 'satellite']
        instructionsLabel = self.loginXml.get_widget('instructionsLabel')
        forgotInfoHosted = self.loginXml.get_widget('forgotInfoHosted')
        forgotInfoSatellite = self.loginXml.get_widget('forgotInfoSatellite')
        tipIconHosted = self.loginXml.get_widget('tipIconHosted')
        tipIconSatellite = self.loginXml.get_widget('tipIconSatellite')
        server = config.getServerlURL()[0]
        if serverType == 'satellite':
            protocol, host, path, parameters, query, fragmentIdentifier = urlparse.urlparse(server)
            satelliteText = _("Please enter your account information for the <b>%s</b> Red Hat Network Satellite:") % host
            instructionsLabel.set_label(satelliteText)
            forgotInfoHosted.hide()
            forgotInfoSatellite.show()
            tipIconHosted.hide()
            tipIconSatellite.show()
        else: # Hosted
            instructionsLabel.set_label(self.loginPageHostedLabelText)
            forgotInfoSatellite.hide()
            forgotInfoHosted.show()
            tipIconSatellite.hide()
            tipIconHosted.show()

    def loginPageVbox(self):
        return self.loginXml.get_widget("initialLoginWindowVbox")

    def loginPageAccountInfoActivate(self, entry):
        """Handles activation (hitting enter) in the username and password fields.

        If a password was entered or the focus is already in the password field,
        tries to advance the screen if possible. If focus in elsewhere and
        nothing is in the password field, puts the focus in there.

        """
        passwordEntry = self.loginXml.get_widget("loginPasswordEntry")
        if entry == passwordEntry or len(passwordEntry.get_text()) > 0:
            # Automatically advance on enter if possible
            if hasattr(self, "onLoginPageNext"):
                self.onLoginPageNext(None, None)
        else:
            passwordEntry.grab_focus()

    def loginPageVerify(self):
        """Returns True if there's an error with the user input, False
        otherwise.
        """
        self.loginPw = self.loginXml.get_widget("loginPasswordEntry")
        self.loginUname = self.loginXml.get_widget("loginUserEntry")

        global username, password
        username = self.loginUname.get_text()
        password = self.loginPw.get_text()

        global newAccount
        newAccount = False
        # validate / check user name
        if self.loginUname.get_text() == "":
            # we assume someone else creates this method...
            setArrowCursor()
            errorWindow(_("You must enter a login."))
            self.loginUname.grab_focus()
            return True

        if self.loginPw.get_text() == "":
            setArrowCursor()
            errorWindow(_("You must enter a password."))
            self.loginPw.grab_focus()
            return True

        # this is hosted only and will test login/password as side effect
        # we need it for chooseChannel page, but it set global variable
        # so we can call it here and verify login to hosted
        try:
            try_to_activate_hardware()
        except up2dateErrors.ValidationError, e:
            setArrowCursor()
            self.alreadyRegistered = 0
            log.log_me("An exception was raised causing login to fail. This is "
                       "usually correct. Exception information:")
            log.log_exception(*sys.exc_info())
            errorWindow(e.errmsg)
            return True
        except up2dateErrors.CommunicationError, e:
            setArrowCursor()
            print e.errmsg
            self.fatalError(_("There was an error communicating with the registration server.  The message was:\n") + e.errmsg)
            return True # fatalError in firstboot will return to here

        return False

    def loginPageApply(self):
        """Returns True if an error happened (the user will have gotten an error
        message) or False if everything was ok.

        """
        status = callAndFilterExceptions(
                self._loginPageApply,
                [],
                _("There was an error while logging in.")
        )
        if status is False:
            return False
        else:
            return True

    def _loginPageApply(self):
        """Returns False if everything's ok, True if there was a problem."""
        try:
            setBusyCursor()
            self.alreadyRegistered = 1
            self.alreadyRegistered = rhnreg.reserveUser(self.loginUname.get_text(),
                                                        self.loginPw.get_text())
        except up2dateErrors.ValidationError, e:
            setArrowCursor()
            self.alreadyRegistered = 0
            log.log_me("An exception was raised causing login to fail. This is "
                       "usually correct. Exception information:")
            log.log_exception(*sys.exc_info())
            errorWindow(e.errmsg)
            return True
        except up2dateErrors.CommunicationError, e:
            setArrowCursor()
            print e.errmsg
            self.fatalError(_("There was an error communicating with the registration server.  The message was:\n") + e.errmsg)
            return True # fatalError in firstboot will return to here

        setArrowCursor()
        return False


class ReviewSubscriptionPage:
    def __init__(self):
        self.reviewSubscriptionXml = gtk.glade.XML(gladefile,
                                                "reviewSubscriptionWindowVbox",
                                                domain="rhn-client-tools")
        self.reviewTextView = \
                        self.reviewSubscriptionXml.get_widget("reviewTextView")

    def reviewSubscriptionPagePrepare(self):
        self.reviewTextView.set_buffer(reviewLog.getTextBuffer())

    def reviewSubscriptionPageVbox(self):
        return self.reviewSubscriptionXml.get_widget("reviewSubscriptionWindowVbox")


class ConfirmAllUpdatesDialog:
    def __init__(self):
        self.xml = gtk.glade.XML(gladefile, "confirmAllUpdatesDialog",
                                 domain="rhn-client-tools")
        self.dialog = self.xml.get_widget("confirmAllUpdatesDialog")

        self.rc = self.dialog.run()
        if self.rc != 1:
            self.rc = 0
        self.dialog.destroy()


class ChooseChannelPage:
    def __init__(self):
        self.chooseChannelXml = gtk.glade.XML(gladefile,
                                              "chooseChannelWindowVbox",
                                              domain = "rhn-client-tools")
        self.chooseChannelList = self.chooseChannelXml.get_widget("chooseChannelList")
        self.chooseChannelList.appears_as_list = True
        self.limited_updates_button = self.chooseChannelXml.get_widget("limited_updates_button")
        self.all_updates_button = self.chooseChannelXml.get_widget("all_updates_button")
        self.chose_all_updates = False
        self.chose_default_channel = True

    def chooseChannelPageVbox(self):
        return self.chooseChannelXml.get_widget("chooseChannelWindowVbox")

    def channel_changed_cb(self, combobox):
        self.limited_updates_button.set_active(True)

    def chooseChannelPagePrepare(self):

        global username, password

        # The self.eus_channels was populated in chooseChannelShouldBeShown

        self.channels = self.eus_channels['channels']
        self.receiving_updates = self.eus_channels['receiving_updates']

        list_entry = gtk.ListStore(gobject.TYPE_STRING)
        self.chooseChannelList.set_model(list_entry)
        cell = gtk.CellRendererText()
        self.chooseChannelList.pack_start(cell, False)

        self.chooseChannelList.connect('changed', self.channel_changed_cb)

        self.chooseChannelList.remove_text(0)

        for label, name in self.channels.items():
            if label in self.receiving_updates:
                self.channels[label] = name + ' *'

        channel_values = self.channels.values()
        channel_values.sort()
        for name in channel_values:
            self.chooseChannelList.append_text(name)

        self.chooseChannelList.set_active(0)
        self.all_updates_button.set_active(True)

        setArrowCursor()

    def chooseChannelPageApply(self):
        if self.limited_updates_button.get_active():
            global chosen_channel
            self.chose_all_updates = False
            # Save the label of the chosen channel
            for key, value in self.channels.items():
                if value == self.chooseChannelList.get_active_text():
                    chosen_channel = key

            if chosen_channel != self.eus_channels['default_channel']:
                self.chose_default_channel = False
            else:
                self.chose_default_channel = True

            return True
        else:
            self.chose_all_updates = True

    def chooseChannelShouldBeShown(self):
        '''
        Returns True if the choose channel window should be shown, else
        returns False.
        '''
        # does the server support eus?
        if rhnreg.server_supports_eus():

            global username, password

            self.eus_channels = rhnreg.getAvailableChannels(username, password)

            if len(self.eus_channels['channels']) > 0:
                return True
        else:
            return False


class CreateProfilePage:
    def __init__(self):
        self.createProfileXml = gtk.glade.XML(gladefile,
                                                "createProfileWindowVbox",
                                                domain="rhn-client-tools")
        self.createProfileXml.signal_autoconnect({
            "onViewHardwareButtonClicked" : self.createProfilePageShowHardwareDialog,
            "onViewPackageListButtonClicked" : self.createProfilePageShowPackageDialog
        })
        self.initProfile = None # TODO Is this still needed?
        self.activationNoPackages = None # used by fb
        self.noChannels = None # used by fb
        self.serviceNotEnabled = None # used by fb

    def createProfilePagePrepare(self):
        callAndFilterExceptions(
                self._createProfilePagePrepare,
                [],
                _("There was an error while assembling information for the profile.")
        )

    def _createProfilePagePrepare(self):
        # There was a comment by these calls that said "part of fix for #144704"
        # I don't understand how the code fixed that bug. It might be that
        # they had originally been run at screen initialization which would
        # break stuff and it was changed to only run them when the user got
        # to this screen.
        self.getHardware()
        self.populateProfile()

    def createProfilePageVbox(self):
        return self.createProfileXml.get_widget("createProfileWindowVbox")

    # we cant do this on module load because there might be a valid interface
    # but zero connectivity
    def getHardware(self):
        try:
            self.hardware = hardware.Hardware()
        except:
            print _("Error running hardware profile")

    def populateProfile(self):
        try:
            if not self.initProfile:
                profileName = None
                hostname = None
                ipaddr = None
                if self.hardware:
                    for hw in self.hardware:
                        if hw.has_key('class'):
                            if hw['class'] == 'NETINFO':
                                hostname = hw.get('hostname')
                                ipaddr = hw.get('ipaddr')
                                ip6addr = hw.get('ip6addr')
            # the check against "unknown" is a bit lame, but it's
            # the minimal change to fix #144704
                if hostname and (hostname != "unknown"):
                    profileName = hostname
                elif ipaddr:
                    profileName = ipaddr
                elif ip6addr:
                    profileName = ip6addr

                if profileName:
                    self.createProfileXml.get_widget("systemNameEntry").set_text(profileName)
                else:
                    profileName = "unknown"
                self.initProfile = True
        except:
            unexpectedError(_("There was an error while populating the profile."), sys.exc_info())
        setArrowCursor()

    def createProfilePageShowHardwareDialog(self, button):
        HardwareDialog()

    def createProfilePageShowPackageDialog(self, button):
        PackageDialog()

    def createProfilePageVerify(self):
        """Returns True if an error happened (the user will have gotten an error
        message) or False if everything was ok.

        """
        systemNameEntry = self.createProfileXml.get_widget("systemNameEntry")
        sendHardwareButton = self.createProfileXml.get_widget("sendHardwareButton")
        sendPackageListButton = self.createProfileXml.get_widget("sendPackageListButton")
        self.sendHardware = sendHardwareButton.get_active()
        self.sendPackages = sendPackageListButton.get_active()
        if systemNameEntry.get_text() == "":
            errorWindow(_("You must choose a name for this profile."))
            systemNameEntry.grab_focus()
            return True
        if not self.sendPackages:
            self.activationNoPackages = 1
        return False

    def createProfilePageApply(self):
        """Returns True if an error happened (the user will have gotten an error
        message) or False if everything was ok.

        """
        status = callAndFilterExceptions(
                self._createProfilePageApply,
                [],
                _("There was an error while creating the profile.")
        )
        if status is False:
            return False
        else:
            return True

    def _createProfilePageApply(self):
        """Returns False if everything's ok or True if something's wrong."""
        setBusyCursor()
        pwin = progress.Progress()
        pwin.setLabel(_("Sending your profile information to Red Hat Network.  Please wait."))
        self.systemId = None
        global newAccount, username, password, hw_activation_code, \
               _hasBaseChannelAndUpdates, chosen_channel
        other = {}
        if hw_activation_code:
            other['registration_number'] = hw_activation_code
        if chosen_channel is not None:
            other['channel'] = chosen_channel

        (virt_uuid, virt_type) = rhnreg.get_virt_info()
        if not virt_uuid is None:
            other['virt_uuid'] = virt_uuid
            other['virt_type'] = virt_type

        profileName  = self.createProfileXml.get_widget("systemNameEntry").get_text()

        pwin.setProgress(1, 6)

        pwin.setStatusLabel(_("Registering System"))
        try:
            reg_info = rhnreg.registerSystem2(username, password, profileName, other=other)
            log.log_me("Registered system.")
            self.systemId = reg_info.getSystemId()
            _hasBaseChannelAndUpdates = reg_info.hasBaseAndUpdates()
            if reg_info.getUniversalActivationKey():
                reviewLog.usedUniversalActivationKey(
                        reg_info.getUniversalActivationKey())
            reviewLog.channels(reg_info.getChannels(), reg_info.getFailedChannels())
            reviewLog.systemSlots(reg_info.getSystemSlotDescriptions(),
                                  reg_info.getFailedSystemSlotDescriptions())
        except up2dateErrors.CommunicationError, e:
            pwin.hide()
            self.fatalError(_("Problem registering system:\n") + e.errmsg)
            return True # fatalError in firstboot will return to here
        except up2dateErrors.RhnUuidUniquenessError, e:
            pwin.hide()
            self.fatalError(_("Problem registering system:\n") + e.errmsg)
            return True # fatalError in firstboot will return to here
        except up2dateErrors.InsuffMgmntEntsError, e:
            pwin.hide()
            self.fatalError(_("Problem registering system:\n") + e.errmsg)
        except up2dateErrors.InvalidProductRegistrationError, e:
            pwin.hide()
            errorWindow(_("The installation number [ %s ] provided is not a valid installation number. Please go back to the previous screen and fix it." %
                                              other['registration_number']))
            return True
        except up2dateErrors.ActivationKeyUsageLimitError, e:
            pwin.hide()
            self.fatalError(rhnreg_constants.ACT_KEY_USAGE_LIMIT_ERROR)
            return True # fatalError in firstboot will return to here
        except:
            setArrowCursor()
            pwin.hide()
            errorWindow(_("Problem registering system."))
            log.log_exception(*sys.exc_info())
            return True
        pwin.setProgress(2,6)

        # write the system id out.
        if self.systemId:
            if not rhnreg.writeSystemId(self.systemId):
                setArrowCursor()
                pwin.hide()
                errorWindow(_("Problem writing out system id to disk."))
                return True
            log.log_me("Wrote system id to disk.")
        else:
            setArrowCursor()
            pwin.hide()
            errorWindow(_("There was a problem registering this system."))
            return True
        global productInfo # Contains the user's info (name, e-mail, etc)
        if cfg['supportsUpdateContactInfo']:
            ret = self.__updateContactInfo(newAccount, productInfo, username, password, pwin)
        else:
            ret = self.__registerProduct(newAccount, productInfo, pwin)
        if ret:
            return ret
        pwin.setProgress(3, 6)

        # maybe upload hardware profile
        if self.sendHardware:
            pwin.setStatusLabel(_("Sending hardware information"))
            try:
                rhnreg.sendHardware(self.systemId, self.hardware)
                log.log_me("Sent hardware profile.")
            except:
                pwin.setStatusLabel(_("Problem sending hardware information."))
                import time
                time.sleep(1)
        pwin.setProgress(4, 6)

        if self.sendPackages:
            getArch = 0
            if cfg['supportsExtendedPackageProfile']:
                getArch = 1
            packageList = pkgUtils.getInstalledPackageList(progressCallback = lambda amount,
                                                           total: gtk.main_iteration(False),
                                                           getArch=getArch)
##            selection = []
            # FIXME
            selectedPackages = packageList
##            for row in range(self.regPackageArea.n_rows):
##                rowData = self.regPackageArea.get_row_data(row)
##                if rowData[0] == 1:
##                    selection.append(rowData[1])
##            print "gh270"
##            selectedPackages = []
##            for pkg in packageList:
##                if pkg[0] in selection:
##                    selectedPackages.append(pkg)
            pwin.setStatusLabel(_("Sending package information"))
            try:
                rhnreg.sendPackages(self.systemId, selectedPackages)
                log.log_me("Sent package list.")
            except:
                pwin.setStatusLabel(_("Problem sending package information."))
                import time
                time.sleep(1)

            # Send virtualization information to the server.
            rhnreg.sendVirtInfo(self.systemId)

        li = None
        try:
            li = up2dateAuth.updateLoginInfo()
        except up2dateErrors.InsuffMgmntEntsError, e:
            self.serviceNotEnabled = 1
            self.fatalError(str(e), wrap=0)
        except up2dateErrors.RhnServerException, e:
            self.fatalError(str(e), wrap=0)
            return True # fatalError in firstboot will return to here

        if li:
            # see if we have any active channels
            if li['X-RHN-Auth-Channels'] == []:
                # no channels subscribe
                self.noChannels = 1

        # enable yum-rhn-plugin
        try:
            present, conf_changed = rhnreg.pluginEnable()
            if not present:
                reviewLog.yum_plugin_warning()
            if conf_changed:
                reviewLog.yum_plugin_conf_changed()
        except IOError, e:
            errorWindow(_("Could not open /etc/yum/pluginconf.d/rhnplugin.conf\nyum-rhn-plugin is not enabled.\n") + e.errmsg)
            reviewLog.yum_plugin_conf_error()
        rhnreg.spawnRhnCheckForUI()
        pwin.setProgress(6,6)
        pwin.hide()

        setArrowCursor()
        return False


    def __updateContactInfo(self, newAccount, productInfo, uname, password, pwin):
        try:
            if newAccount:
                rhnreg.updateContactInfo(uname, password, productInfo)
        except up2dateErrors.CommunicationError, e:
            pwin.hide()
            self.fatalError(_("Problem registering personal information:\n") + e.errmsg)
            return True # fatalError in firstboot will return to here
        except:
            setArrowCursor()
            pwin.hide()
            errorWindow(_("Problem registering personal information"))
            return True
        return False

    def __registerProduct(self, newAccount, productInfo, pwin):
        try:
            if newAccount:
                # incorporate the info from the oemInfoFile as well
                oemInfo = rhnreg.getOemInfo()
                rhnreg.registerProduct(self.systemId, productInfo, oemInfo)
        except up2dateErrors.CommunicationError, e:
            pwin.hide()
            self.fatalError(_("Problem registering personal information:\n") + e.errmsg)
            return True # fatalError in firstboot will return to here
        except:
            setArrowCursor()
            pwin.hide()
            errorWindow(_("Problem registering personal information"))
            return True
        return False


class ProvideCertificatePage:
    def __init__(self):
        self.provideCertificateXml = gtk.glade.XML(gladefile,
                                                "provideCertificateWindowVbox",
                                                domain="rhn-client-tools")

        self.orig_cert_label_template = self.provideCertificateXml.get_widget("SecurityCertLabel").get_text()

    def provideCertificatePageVbox(self):
        return self.provideCertificateXml.get_widget("provideCertificateWindowVbox")

    def setUrlInWidget(self):
        """
        sets the security cert label's server url at runtime
        """
        securityCertlabel = self.provideCertificateXml.get_widget("SecurityCertLabel")
        securityCertlabel.set_text(self.orig_cert_label_template % config.getServerlURL()[0] )

    def provideCertificatePageApply(self):
        """If the 'I have a cert' radio button is selected, this function will
        copy the cert to /usr/share/rhn. If we're using hosted it will name it
        RHNS-CA-CERT otherwise it will name it RHN-ORG-TRUSTED-SSL-CERT. It will
        change the owner to root and the perms to 644. If a file with
        that name already exists it will add a '.save<lowest available integer>' to
        the end of the old file's name. It will update the config file to point
        to the new cert.
        Returns:
            0- cert was installed
            1- the user doesn't want to provide a cert right now
            2- an error occurred and the user was notified
            3- the cert was installed ok, but the server doesn't support needed
               calls
        Doesn't raise any exceptions.
        """
        status = callAndFilterExceptions(
                self._provideCertificatePageApply,
                [],
                _("There was an error while installing the certificate.")
        )
        if status == 0 or status == 1 or status == 3:
            return status
        else:
            return 2

    def _provideCertificatePageApply(self):
        """Does what the comment for provideCertificatePageApply says, but might
        raise various exceptions.

        """
        CERT_INSTALLED = 0
        NOT_INSTALLING_CERT = 1
        ERROR_WAS_HANDLED = 2
        SERVER_TOO_OLD = 3

        assert serverType in ['hosted', 'satellite']
        try:
            provideCertButton = self.provideCertificateXml.get_widget("provideCertificateButton")
            provideCert = provideCertButton.get_active()
            if not provideCert:
                return NOT_INSTALLING_CERT
            fileChooser = self.provideCertificateXml.get_widget("certificateChooserButton")
            certFile = fileChooser.get_filename()
            if certFile is None:
                errorWindow(_("You must select a certificate."))
                return ERROR_WAS_HANDLED
            up2dateConfig = config.initUp2dateConfig()
            if serverType == 'hosted':
                destinationName = '/usr/share/rhn/RHNS-CA-CERT'
            else: # Satellite
                destinationName = '/usr/share/rhn/RHN-ORG-TRUSTED-SSL-CERT'
            if certFile != destinationName:
                if os.path.exists(certFile):
                    destinationName = certFile
            up2dateConfig.set('sslCACert', destinationName)
            up2dateConfig.save()
            # Take the new cert for a spin
            try:
                rhnreg.getCaps()
            except up2dateErrors.SSLCertificateVerifyFailedError:
                server_url = config.getServerlURL()[0]
                #TODO: we could point the user to grab the cert from /pub if its sat

                #bz439383 - Handle error message for expired certificate
                f = open(certFile, "r")
                buf = f.read()
                f.close()
                tempCert = OpenSSL.crypto.load_certificate(OpenSSL.crypto.FILETYPE_PEM, buf)
                if tempCert.has_expired():
                    errorWindow(rhnreg_constants.SSL_CERT_EXPIRED)
                else:
                    errorWindow(rhnreg_constants.SSL_CERT_ERROR_MSG % (certFile, server_url))

                return ERROR_WAS_HANDLED
            except OpenSSL.SSL.Error:
                # TODO Modify rhnlib to raise a unique exception for the not a
                # cert file case.
                errorWindow(_("There was an SSL error. This could be because the file you picked was not a certificate file."))
                return ERROR_WAS_HANDLED

            return CERT_INSTALLED

        except IOError, e:
            # TODO Provide better messages
            message = _("Something went wrong while installing the new certificate:\n")
            message = message + e.strerror
            errorWindow(message)
            return ERROR_WAS_HANDLED


class FinishPage:
    """The finish screen. This can show two different versions: successful and
    unsuccessful.

    """
    def __init__(self):
        self.failedFinishXml = gtk.glade.XML(gladefile,
                                                "failedFinishWindowVbox",
                                                domain="rhn-client-tools")
        self.successfulFinishXml = gtk.glade.XML(gladefile,
                                                "successfulFinishWindowVbox",
                                                domain="rhn-client-tools")
        # This is an intermediate vbox that this class provides to it's users.
        # On prepare, the right version of the screen will be put into it.
        self.finishContainerVbox = gtk.VBox()
        # The vboxes that contain the two versions of the screen:
        self.failedFinishVbox = \
                self.failedFinishXml.get_widget("failedFinishWindowVbox")
        self.successfulFinishVbox = \
                self.successfulFinishXml.get_widget("successfulFinishWindowVbox")
        # Put one in now (either one) to make the prepare code simpler
        self.finishContainerVbox.pack_start(self.failedFinishVbox)

    def finishPageVbox(self):
        return self.finishContainerVbox

    def finishPagePrepare(self):
        containerChildren = self.finishContainerVbox.get_children()
        assert len(containerChildren) == 1
        self.finishContainerVbox.remove(containerChildren[0])
        if hasBaseChannelAndUpdates():
            self.finishContainerVbox.pack_start(self.successfulFinishVbox)
        else:
            self.finishContainerVbox.pack_start(self.failedFinishVbox)


class AlreadyRegisteredDialog:
    def __init__(self):
        """Returns when dialog closes. Dialog.rc will be set to 1 if the user
        clicked continue, or 0 if they clicked cancel or close the dialog.

        """
        self.xml = gtk.glade.XML(gladefile, "alreadyRegisteredDialog",
                                 domain="rhn-client-tools")
        self.dialog = self.xml.get_widget("alreadyRegisteredDialog")

        server = _('unknown')
        oldUsername = _('unknown')
        systemId = _('unknown')
        try:
            # If the serverURL config value is a list, we have no way of knowing
            # for sure which one the machine registered against,
            # so default to the
            # first element.
            server = config.getServerlURL()[0]

            if server.endswith('/XMLRPC'):
                server = server[:-7] # don't display trailing /XMLRPC
            systemIdXml = rpclib.xmlrpclib.loads(up2dateAuth.getSystemId())
            oldUsername = systemIdXml[0][0]['username']
            systemId = systemIdXml[0][0]['system_id']
        except:
            pass

        self.xml.get_widget('serverUrlLabel').set_label(server)
        self.xml.get_widget('usernameLabel').set_label(oldUsername)
        self.xml.get_widget('systemIdLabel').set_label(systemId)

        self.rc = self.dialog.run()
        if self.rc != 1:
            self.rc = 0
        self.dialog.destroy()

class AlreadyRegisteredSubscriptionManagerDialog:
    """ Window with text:
        You are already subscribed using subscription manager. Exit. Continue
    """

    def __init__(self):
        """Returns when dialog closes. Dialog.rc will be set to 1 if the user
           clicked continue, or 0 if they clicked cancel or close the dialog.
        """
        self.xml = gtk.glade.XML(gladefile, "alreadyRegisteredSubscriptionManagerDialog",
                                 domain="rhn-client-tools")
        self.dialog = self.xml.get_widget("alreadyRegisteredSubscriptionManagerDialog")

        self.rc = self.dialog.run()
        if self.rc != 1:
            self.rc = 0
        self.dialog.destroy()

class ConfirmQuitDialog:
    def __init__(self):
        """Returns when dialog closes. Dialog.rc will be set to 0 if the user
        clicked "take me back" or closed the dialog, or 1 if they clicked "i'll
        register later". I've they clicked I'll register later, the remind file
        will be written to disk.

        """
        self.xml = gtk.glade.XML(gladefile, "confirmQuitDialog",
                                 domain="rhn-client-tools")
        self.dialog = self.xml.get_widget("confirmQuitDialog")

        self.rc = self.dialog.run()
        if self.rc == gtk.RESPONSE_NONE:
            self.rc = 0
        if self.rc == 1:
            try:
                rhnreg.createSystemRegisterRemindFile()
            except (OSError, IOError), error:
                log.log_me("Reminder file couldn't be written. Details: %s" %
                           error)
        self.dialog.destroy()


class WhyRegisterDialog:
    def __init__(self):
        self.whyRegisterXml = gtk.glade.XML(gladefile,
            "whyRegisterDialog", domain="rhn-client-tools")
        self.dlg = self.whyRegisterXml.get_widget("whyRegisterDialog")
        self.whyRegisterXml.signal_autoconnect({
            "onBackToRegistrationButtonClicked" : self.finish,
        })

    def finish(self, button):
        self.dlg.hide()
        self.rc = 1 # What does this do? Is it needed?


class HardwareDialog:
    def __init__(self):
        self.hwXml = gtk.glade.XML(
            gladefile,
            "hardwareDialog", domain="rhn-client-tools")
        self.dlg = self.hwXml.get_widget("hardwareDialog")

        self.hwXml.get_widget("okButton").connect("clicked", self.finish)
        callAndFilterExceptions(
                self.populateHardware,
                [],
                _("There was an error getting the list of hardware.")
        )

    def populateHardware(self):
        # Read all hardware in
        self.hardware = hardware.Hardware()

        for hw in self.hardware:
            if hw['class'] == 'CPU':
                label = self.hwXml.get_widget("cpuLabel")
                label.set_text(hw['model'])
                label = self.hwXml.get_widget("speedLabel")
                label.set_text(_("%d MHz") % hw['speed'])
            elif hw['class'] == 'MEMORY':
                label = self.hwXml.get_widget("ramLabel")
                try:
                    label.set_text(_("%s MB") % hw['ram'])
                except:
                    pass
            elif hw['class'] == 'NETINFO':
                label = self.hwXml.get_widget("hostnameLabel")
                try:
                    label.set_text(idn_puny_to_unicode(hw['hostname']))
                except:
                    pass
                label = self.hwXml.get_widget("ipLabel")
                try:
                    label.set_text(hw['ipaddr'])
                except:
                    pass


        label = self.hwXml.get_widget("versionLabel")
        try:
            distversion = up2dateUtils.getVersion()
        except up2dateErrors.RpmError, e:
            # TODO Do something similar during registration if the same
            # situation can happen. Even better, factor out the code to get the
            # hardware.
            errorWindow(e.errmsg)
            distversion = 'unknown'
        label.set_text(distversion)

    def finish(self, button):
        self.dlg.hide()
        self.rc = 1


class PackageDialog:
    def __init__(self):
        self.swXml = gtk.glade.XML(
            gladefile,
            "packageDialog", domain="rhn-client-tools")
        self.dlg = self.swXml.get_widget("packageDialog")

        self.swXml.get_widget("okButton").connect("clicked", self.finish)

        callAndFilterExceptions(
                self.populateDialog,
                [],
                _("There was an error building the list of packages.")
        )

    def populateDialog(self):
        # name-version-release, arch
        self.packageStore = gtk.ListStore(gobject.TYPE_STRING, gobject.TYPE_STRING)
        for package in self.getPackageList():
            nvr = "%s-%s-%s" % (package['name'], package['version'], package['release'])
            arch = package['arch']
            self.packageStore.append((nvr, arch))
        self.packageTreeView = self.swXml.get_widget("packageTreeView")
        self.packageTreeView.set_model(self.packageStore)

        self.packageTreeView.set_rules_hint(True)

        col = gtk.TreeViewColumn(_("Package"), gtk.CellRendererText(), text=0)
        col.set_sort_column_id(0)
        col.set_sort_order(gtk.SORT_ASCENDING)
        self.packageTreeView.append_column(col)

        col = gtk.TreeViewColumn(_("Arch"), gtk.CellRendererText(), text=1)
        self.packageTreeView.append_column(col)

        self.packageStore.set_sort_column_id(0, gtk.SORT_ASCENDING)

    def getPackageList(self):
        pwin = progress.Progress()
        pwin.setLabel(_("Building a list of RPM packages installed on your system.  Please wait."))
        packageDialogPackages = pkgUtils.getInstalledPackageList(progressCallback = pwin.setProgress, getArch=1)
        pwin.hide()
        return packageDialogPackages

    def finish(self, button):
        self.dlg.hide()
        self.rc = 1


class NetworkConfigDialog:
    """This is the dialog that allows setting http proxy settings.

    It uses the instant apply paradigm or whatever you wanna call it that the
    gnome HIG recommends. Whenever a toggle button is flipped or a text entry
    changed, the new setting will be saved.

    """
    def __init__(self):
        self.xml = gtk.glade.XML(gladefile, "networkConfigDialog",
                                        domain="rhn-client-tools")
        # Get widgets we'll need to access
        self.dlg = self.xml.get_widget("networkConfigDialog")
        self.enableProxyButton = self.xml.get_widget("enableProxyButton")
        self.enableProxyAuthButton = self.xml.get_widget("enableProxyAuthButton")
        self.proxyEntry = self.xml.get_widget("proxyEntry")
        self.proxyUserEntry = self.xml.get_widget("proxyUserEntry")
        self.proxyPasswordEntry = self.xml.get_widget("proxyPasswordEntry")
        try:
            self.cfg = config.initUp2dateConfig()
        except:
            gnome.ui.GnomeErrorDialog(_("There was an error loading your "
                                        "configuration.  Make sure that\nyou "
                                        "have read access to /etc/sysconfig/rhn."),
                                      self.dlg)
        # Need to load values before connecting signals because when the dialog
        # starts up it seems to trigger the signals which overwrites the config
        # with the blank values.
        self.setInitialValues()
        self.enableProxyButton.connect("toggled", self.enableAction)
        self.enableProxyAuthButton.connect("toggled", self.enableAction)
        self.enableProxyButton.connect("toggled", self.writeValues)
        self.enableProxyAuthButton.connect("toggled", self.writeValues)
        self.proxyEntry.connect("focus-out-event", self.writeValues)
        self.proxyUserEntry.connect("focus-out-event", self.writeValues)
        self.proxyPasswordEntry.connect("focus-out-event", self.writeValues)
        self.xml.get_widget("closeButton").connect("clicked", self.close)
        self.dlg.show()

    def setInitialValues(self):
        self.xml.get_widget("enableProxyButton").set_active(self.cfg["enableProxy"])
        self.enableAction(self.xml.get_widget("enableProxyButton"))
        self.xml.get_widget("proxyEntry").set_text(self.cfg["httpProxy"])
        self.xml.get_widget("enableProxyAuthButton").set_active(self.cfg["enableProxyAuth"])
        self.enableAction(self.xml.get_widget("enableProxyAuthButton"))
        self.xml.get_widget("proxyUserEntry").set_text(str(self.cfg["proxyUser"]))
        self.xml.get_widget("proxyPasswordEntry").set_text(str(self.cfg["proxyPassword"]))

    def writeValues(self, widget=None, dummy=None):
        self.cfg.set("enableProxy",
                     int(self.xml.get_widget("enableProxyButton").get_active()))
        self.cfg.set("httpProxy",
                     self.xml.get_widget("proxyEntry").get_text())
        self.cfg.set("enableProxyAuth",
                     int(self.xml.get_widget("enableProxyAuthButton").get_active()))
        self.cfg.set("proxyUser",
                     str(self.xml.get_widget("proxyUserEntry").get_text()))
        self.cfg.set("proxyPassword",
                     str(self.xml.get_widget("proxyPasswordEntry").get_text()))
        try:
            self.cfg.save()
        except:
            gnome.ui.GnomeErrorDialog(_(
                "There was an error saving your configuration. "\
                "Make sure that\nyou own %s.") % self.cfg.fileName,
                                            self.dlg)

    def close(self, button):
        self.dlg.hide()

    def enableAction(self, button):
        if button.get_name() == "enableProxyButton":
            self.xml.get_widget("proxyEntry").set_sensitive(button.get_active())
            self.xml.get_widget("proxyEntry").grab_focus()
        elif button.get_name() == "enableProxyAuthButton":
            self.xml.get_widget("proxyUserEntry").set_sensitive(button.get_active())
            self.xml.get_widget("proxyPasswordEntry").set_sensitive(button.get_active())
            self.xml.get_widget("usernameLabel").set_sensitive(button.get_active())
            self.xml.get_widget("passwordLabel").set_sensitive(button.get_active())


def errorWindow(message):
    messageWindow.ErrorDialog(messageWindow.wrap_text(message))

def unexpectedError(message, exc_info=None):
    """Shows an error dialog with the message and logs that an error happened.

    This function is designed to be used in an except block like so:
        unexpectedError(_("Your error here."), sys.exc_info())

    """
    setArrowCursor()
    logFile = cfg['logFile'] or '/var/log/up2date'
    message = message + "\n" + (_("This error shouldn't have happened. If you'd "
                                 "like to help us improve this program, please "
                                 "file a bug at bugzilla.redhat.com. Including "
                                 "the relevant parts of '%s' would be very "
                                 "helpful. Thanks!") % logFile)
    errorWindow(message)
    if exc_info:
        (etype, value, stack_trace) = exc_info
        log.log_exception(etype, value, stack_trace)
    else:
        log.log_me("An unexpected error happened, but exc_info wasn't provided.")

def callAndFilterExceptions(function, allowedExceptions,
        disallowedExceptionMessage, errorHandler=unexpectedError):
    """Calls function and limits the exceptions that can be raised to those in
    the list provided and SystemExit. If an exception is raised which isn't
    allowed, errorHandler will be called and then None will be returned.
    errorHandler defaults to the unexpectedError function and will be passed
    disallowedExceptionMessage. If it is overridden, the function provided must
    take a string and a tuple (see below for details). If no exceptions are
    raised, functions's return value is returned.

    I need this function because if some of the functions in the Pages raise
    unexpected exceptions, the druid might advance when it shouldn't or go to
    the wrong page. I think it's shorter and more readable to factor this out
    rather than have similar functionality in all those functions.
    """
    assert callable(function)
    allowedExceptions.append(SystemExit)
    try:
        return function()
    except:
        (exceptionType, exception, stackTrace) = sys.exc_info()
        if exceptionType in allowedExceptions:
            raise
        else:
            errorHandler(disallowedExceptionMessage,
                    (exceptionType, exception, stackTrace))

def try_to_activate_hardware():
    global hw_activation_code
    if serverType == 'hosted':
        # hardware asset codes only make sense on hosted
        setBusyCursor()
        code = rhnreg._activate_hardware(username, password)
        if code != None:
            hw_activation_code = code
        setArrowCursor()

def hasBaseChannelAndUpdates():
    """Returns a bool indicating whether the system has registered, subscribed
    to a base channel, and has at least update entitlements.
    Uses information from the most recent time the create profile screen was run
    through.

    """
    global _hasBaseChannelAndUpdates
    return _hasBaseChannelAndUpdates


def setBusyCursor():
    """Dummy function that will be overidden by rhn_register's standalone gui
    and firstboot in different ways.

    """
    pass

def setArrowCursor():
    """Dummy function that will be overidden by rhn_register's standalone gui
    and firstboot in different ways.

    """
    pass
