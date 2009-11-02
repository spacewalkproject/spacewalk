#
# Copyright (c) 1999-2006 Red Hat, Inc.  Distributed under GPL.
#
# Authors:
#    ?
#    Daniel Benamy <dbenamy@redhat.com>

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
import socket
import gtk
# Need to import gtk.glade to make this file work alone even though we always 
# access it as gtk.glade. Not sure why. Maybe gtk's got weird hackish stuff 
# going on?
import gtk.glade
import gobject
import sys
import os
import stat
import gettext
_ = gettext.gettext
gettext.textdomain("rhn-client-tools")
gtk.glade.bindtextdomain("rhn-client-tools")

import rhnreg
from rhnreg import ActivationResult
import up2dateErrors
import hardware
import messageWindow
import progress
from up2date_client import rpmUtils
import up2dateAuth
import up2dateUtils
import config
import OpenSSL
import up2dateLog
from rhn import rpclib
import rhnreg_constants

cfg = config.initUp2dateConfig()
log = up2dateLog.initLog()

if cfg['development']:
    gladefile = "../../data/rh_register.glade"
else:
    gladefile = "/usr/share/rhn/up2date_client/rh_register.glade"

# we need to carry these values between screen, so stash at module scope
username = None
password = None
email = ""
# organization will be set to a string which is the org id to use. It should be 
# None if the server doesn't support multi-orgs, or to use the default org.
organization = None
newAccount = None # Should be assigned True or False
productInfo = None
regNum = None
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
    
    def foundRegNumButCouldntActivate(self):
        self.addBoldText(_("Notice"))
        self.addText(rhnreg_constants.INST_NUM_ON_DISK)
        self.addText('') # adds newline
    
    def autoActivatedRegistrationNumber(self, registrationNumber, 
                                        activationResult):
        self.addBoldText(_("Automatic Subscription Activation"))
        text = rhnreg_constants.SUB_NUM % registrationNumber
        text = text + ' ' + rhnreg_constants.SUB_NUM_RESULT
        self.addText(text)
        for channel, quantity in activationResult.getChannelsActivated().items():
            self.addBulletedText("%s (%s)" % (channel, quantity))
        for service, quantity in activationResult.getSystemSlotsActivated().items():
            self.addBulletedText("%s (%s)" % (service, quantity))
        self.addText('') # adds newline
    
    def autoActivatedHardwareInfo(self, activationResult):
        self.addBoldText(_("Automatic Subscription Activation"))
        text = rhnreg_constants.SUB_NUM % activationResult.getRegistrationNumber()
        text = text + ' ' + rhnreg_constants.SUB_NUM_RESULT
        self.addText(text)
        for channel, quantity in activationResult.getChannelsActivated().items():
            self.addBulletedText("%s (%s)" % (channel, quantity))
        for service, quantity in activationResult.getSystemSlotsActivated().items():
            self.addBulletedText("%s (%s)" % (service, quantity))
        self.addText('') # adds newline
    
    def activatedRegistrationNumber(self, registrationNumber, 
                                        activationResult):
        self.addBoldText(_("Subscription Activation"))
        text = rhnreg_constants.SUB_NUM % registrationNumber
        text = text + ' ' + rhnreg_constants.SUB_NUM_RESULT
        self.addText(text)
        for channel, quantity in activationResult.getChannelsActivated().items():
            self.addBulletedText("%s (%s)" % (channel, quantity))
        for service, quantity in activationResult.getSystemSlotsActivated().items():
            self.addBulletedText("%s (%s)" % (service, quantity))
        self.addText('') # adds newline
    
    def usedUniversalActivationKey(self, keyName):
        self.addBoldText(_("Notice"))
        keys = ', '.join(keyName)
        self.addText(rhnreg_constants.ACTIVATION_KEY % (keys))
        self.addText('') # adds newline
    
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
        # Prepopulate the server to use from the config
        up2dateConfig = config.initUp2dateConfig()
        self.server = up2dateConfig['serverURL']

        if type(self.server) == type([]):
            self.server = self.server[0]
            
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
            up2dateConfig.set('serverURL', 
                              'https://xmlrpc.rhn.redhat.com/XMLRPC')
            if not cfg['sslCACert']:
                up2dateConfig.set('sslCACert', '/usr/share/rhn/RHNS-CA-CERT')
            serverType = 'hosted'
        else:
            customServer = self.chooseServerXml.get_widget(
                                'satelliteServerEntry').get_text()
            try:
                customServer = rhnreg.makeNiceServerUrl(customServer)
            except up2dateErrors.InvalidProtocolError:
                errorWindow(_('You specified an invalid protocol. Only '
                              'https and http are allowed.'))
                return True

            # If they changed the value, write it back to the config file.
            if customServer != self.server:
                up2dateConfig.set('serverURL', customServer)
            if not cfg['sslCACert']:
                up2dateConfig.set('sslCACert', 
                                  '/usr/share/rhn/RHN-ORG-TRUSTED-SSL-CERT')
            serverType = 'satellite'    
            
        
        NEED_SERVER_MESSAGE = _("You will not be able to successfully register "
                                "this system without contacting a Red Hat Network server.")

        # Try to contact the server to see if we have a good cert
        try:
            setBusyCursor()
            rhnreg.privacyText()
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
            if isinstance(up2dateConfig['serverURL'], list):
                protocol, host, path, parameters, query, fragmentIdentifier = urlparse.urlparse(up2dateConfig['serverURL'][0])
            else:
                protocol, host, path, parameters, query, fragmentIdentifier = urlparse.urlparse(up2dateConfig['serverURL'])
            dialog = messageWindow.BulletedOkDialog()
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

        if validateCaps() is True: # There was an error
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
        up2dateConfig = config.initUp2dateConfig()
        assert serverType in ['hosted', 'satellite']
        instructionsLabel = self.loginXml.get_widget('instructionsLabel')
        forgotInfoHosted = self.loginXml.get_widget('forgotInfoHosted')
        forgotInfoSatellite = self.loginXml.get_widget('forgotInfoSatellite')
        tipIconHosted = self.loginXml.get_widget('tipIconHosted')
        tipIconSatellite = self.loginXml.get_widget('tipIconSatellite')
        if isinstance(up2dateConfig['serverURL'], list):
            server = up2dateConfig['serverURL'][0]
        else:
            server = up2dateConfig['serverURL']
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
            # get the caps info before we show the activastion page which needs the
            # caps. _but_ we need to do this after we configure the network...
            rhnreg.getCaps()
            self.alreadyRegistered = 1
            self.alreadyRegistered = rhnreg.reserveUser(self.loginUname.get_text(),
                                                        self.loginPw.get_text())
        except up2dateErrors.ValidationError, e:
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
        
        # I don't know why we call registerUser when logging in an existing 
        # user, but the code did this. There was a comment which might have been
        # referring to this which said "legacy cruft". Maybe some old sat needs
        # this?
        try:
            rhnreg.registerUser(username, password)
            log.log_me("Registered login info.")
        except up2dateErrors.CommunicationError, e:
            setArrowCursor()
            errorWindow(_("There was a problem logging in:\n%s") % 
                                      e.errmsg)
            return True
        except:
            setArrowCursor()
            errorWindow(_("There was problem logging in."))
            return True
        
        setArrowCursor()
        return False
    
    def showPrivacyDialog(self, button):
        PrivacyDialog()


def chooseOrgShouldBeShown():
    """Decides whether we should show the choose org page or not.
    
    Returns True if we're talking to hosted and the user belongs to at least 2
    orgs. If an error occurs, it is logged and True returned. Returns False 
    otherwise.
    
    This is a loose function because it's difficult to use it in firstboot 
    where we want to without a hack if it's in ChooseOrgPage.
    
    """
    global organization
    organization = None
    try:
        setBusyCursor()
        possibleOrgs = rhnreg.getPossibleOrgs(username, password)
        setArrowCursor()
        if len(possibleOrgs.getOrgs()) < 2:
            return False
    except:
        setArrowCursor()
        log.log_me("There was an exception while trying to get the list of orgs"
                   " to determine whether or not to show the choose org screen:")
        log.log_exception(*sys.exc_info())
        return False
    return True

class ChooseOrgPage:
    def __init__(self):
        self.chooseOrgXml = gtk.glade.XML(gladefile,
                                          "chooseOrgWindowVbox",
                                          domain="rhn-client-tools")
        # self.orgsList will have the org id in the 0th column and the 
        # org name in the 1st column.
        self.orgsList = gtk.ListStore(gobject.TYPE_INT, gobject.TYPE_STRING)
        self.orgsComboBox = self.chooseOrgXml.get_widget("orgsComboBox")
        self.orgsComboBox.set_model(self.orgsList)
        cell = gtk.CellRendererText()
        self.orgsComboBox.pack_start(cell, True)
        self.orgsComboBox.add_attribute(cell, 'text', 1)  
        self.useCachedOrgs = False
    
    def chooseOrgPageVbox(self):
        return self.chooseOrgXml.get_widget("chooseOrgWindowVbox")
    
    def chooseOrgPagePrepare(self, useCachedOrgs=False):
        """The loose function chooseOrgShouldBeShown() should be used to find
        out if this page should be shown or not.
        
        """
        # TODO add support for args to callAndFilterExceptions and pass 
        # useCachedOrgs as an arg
        self.useCachedOrgs = useCachedOrgs
        callAndFilterExceptions(
                self._chooseOrgPagePrepare,
                [], 
                _("There was an error while getting the list of organizations.")
        )
    
    def _chooseOrgPagePrepare(self):
        """Functionality for chooseOrgPagePrepare but might raise exceptions."""
        global username, password
        setBusyCursor()
        possibleOrgs = rhnreg.getPossibleOrgs(username, password, 
                                               self.useCachedOrgs)
        setArrowCursor()
        self.orgsList.clear()
        for orgId, orgName in possibleOrgs.getOrgs().items():
            row = self.orgsList.append([orgId, orgName])
            if orgId == possibleOrgs.getDefaultOrg():
                self.orgsComboBox.set_active_iter(row)
    
    def chooseOrgPageApply(self):
        global organization
        activeIndex = self.orgsComboBox.get_active()
        organization = self.orgsList[activeIndex][0]


def activateSubscriptionShouldBeShown():
    """If we activate an EN from disk and/or hardware info (eg asset tag) and 
    one of them provides an entitlement for the base channel the system needs 
    OR they have at least one available entitlement of the type the system 
    needs, then we skip the activation screen (return False).
    
    This is a loose function because it's difficult to use it in firstboot 
    where we want to without a hack if it's in ActivateSubscriptionPage.
    
    """
    try:
        setBusyCursor()
        
        # We have to call autoActivateNumbersOnce for satellite b/c it reads 
        # and stores the IN # on disk, which we need.
        registrationNumberStatus, oemNumberStatus = autoActivateNumbersOnce()
        # Go ahead and return False if we're satellite.
        if rhnreg.getServerType() == 'satellite':
            return False
        
        # We should only skip the screen based on available subs (not 
        # autoactivation) if we pass through any time after the first. That's 
        # implemented by autoActivateNumbersOnce returning None, None on any 
        # call after the first.
        if registrationNumberStatus and \
           registrationNumberStatus.getStatus() == ActivationResult.ACTIVATED_NOW:# and \
           # TODO up2dateUtils.getOSRelease() in registrationNumberStatus[ActivationResult.RELEASE]:
           return False
        if oemNumberStatus and \
           oemNumberStatus.getStatus() == ActivationResult.ACTIVATED_NOW:# and \
           # TODO up2dateUtils.getOSRelease() in oemNumberStatus[ActivationResult.RELEASE]:
           return False
        availableSubs = rhnreg.getAvailableSubscriptions(username, password)

        # I use != instead of > because -1 == infinite
        if int(availableSubs) != 0: 
            return False
    except up2dateErrors.Error:
        setArrowCursor()
        log.log_me("There was an error while trying to figure out if we should "
                   "skip the activation screen, so we'll show it. Error info:")
        log.log_exception(*sys.exc_info())
    setArrowCursor()
    return True


class ActivateSubscriptionPage:
    """The screen that allows activation a installation number.
    
    activateSubscriptionShouldBeShown() should be used to decide whether to show
    this page or not.
    
    """
    def __init__(self):
        self.activateSubscriptionNoneXml = gtk.glade.XML(gladefile,
                                                "activateSubscriptionNoneWindowVbox",
                                                domain="rhn-client-tools")
        self.activateSubscriptionNoneVbox = \
                self.activateSubscriptionNoneXml.get_widget(
                "activateSubscriptionNoneWindowVbox")
        self.registrationNumberEntry = \
                self.activateSubscriptionNoneXml.get_widget(
                "registrationNumberEntry")
        self.registrationNumberStatusLabel = \
                self.activateSubscriptionNoneXml.get_widget(
                "registrationNumberStatusLabel")
        self.registrationNumberEntry.connect("changed", 
                self.activateSubscriptionPageRegistrationNumberChanged)
        self.activatedRegNums = []
    
    def activateSubscriptionPageVbox(self):
        return self.activateSubscriptionNoneVbox
    
    def activateSubscriptionPagePrepare(self):
        # We need to call this manually otherwise it won't say the number's been
        # activated when they click back from the create profile page until they
        # change it.
        self.activateSubscriptionPageRegistrationNumberChanged()
    
    def activateSubscriptionPageVerify(self):
        """Returns False if everything is ok. Returns True if there's a problem
        and the user was notified.
        
        """
        newRegNum = self.registrationNumberEntry.get_text()
        if newRegNum == "":
            errorWindow(_("You must enter an installation number."))
            self.registrationNumberEntry.grab_focus()
            return True
        return False
    
    def activateSubscriptionPageApply(self):
        """Returns False if everything is ok. Returns True if there's a problem
        and the user was notified.
        
        """
        status = callAndFilterExceptions(
                self._activateSubscriptionPageApply,
                [],
                _("There was an error activating your number.")
        )
        # Need to handle a filtering returning None
        if status is False:
            return False
        else:
            return True
    
    def _activateSubscriptionPageApply(self):
        """See comment for activateSubscriptionPageApply."""
        global username, password, organization, regNum
        regNum = self.registrationNumberEntry.get_text()
        if regNum not in self.activatedRegNums:
            try:
                setBusyCursor()
                result = rhnreg.activateRegistrationNumber(username, password, 
                                                        regNum, organization)
            except up2dateErrors.InvalidRegistrationNumberError:
                setArrowCursor()
                errorWindow(rhnreg_constants.INVALID_NUMBER % regNum)
                return True
            except up2dateErrors.NotEntitlingError:
                setArrowCursor()
                errorWindow(rhnreg_constants.NONENTITLING_NUMBER)
                return True
            setArrowCursor()
            if result.getStatus() == ActivationResult.ALREADY_USED:
                errorWindow(rhnreg_constants.ALREADY_USED_NUMBER)
                return True
            else:
                assert result.getStatus() == ActivationResult.ACTIVATED_NOW
                reviewLog.activatedRegistrationNumber(regNum, result)
                self.activatedRegNums.append(regNum)
                rhnreg.writeRegNum(regNum)
        else:
            log.debug_log("Skipping activation because this number has already "
                          "been activated.")
        return False
    
    def activateSubscriptionPageRegistrationNumberChanged(self, entry=None):
        newRegNum = self.registrationNumberEntry.get_text()
        if newRegNum in self.activatedRegNums:
            status = _("This installation number has already been activated.")
        else:
            status = ""
        status = "<small><i>%s</i></small>" % status
        self.registrationNumberStatusLabel.set_label(status)


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

        
def chooseChannelShouldBeShown():
    '''
    Returns True if the choose channel window should be shown, else
    returns False.
    '''
    
    # First and foremost, does the server support eus?
    if rhnreg.server_supports_eus():
    
        global username, password, oragnization
        other = {}
        if organization is not None:
            other['org_id'] = organization
            
        channels = rhnreg.getAvailableChannels(username, password,
                                                    other)

        channels = channels['channels']

        if len(channels) > 0:
            return True
    else:
        return False
        
        
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
    
        global username, password, organization
        other = {}
        if organization is not None:
            other['org_id'] = organization
            
        self.eus_channels = rhnreg.getAvailableChannels(username, password,
                                                    other)
                                                    
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
            # the check against "unknown" is a bit lame, but it's
            # the minimal change to fix #144704 
                if hostname and (hostname != "unknown"):
                    profileName = hostname
                else:
                    if ipaddr:
                        profileName = ipaddr
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
        global newAccount, email, username, password, regNum, \
               _hasBaseChannelAndUpdates, chosen_channel
        other = {}
        if regNum:
            other['registration_number'] = regNum
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
##            self.regNumEntry.grab_focus()
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
            # interesting...
            getInfo = 0
#            if self.cfg['supportsExtendedPackageProfile']
            #FIXME
            getInfo = 1
            packageList = rpmUtils.getInstalledPackageList(progressCallback = lambda amount,
                                                           total: gtk.main_iteration(False),
                                                           getInfo=getInfo)
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
        
        # set server url at runtime
        self.setUrlInWidget()

    def provideCertificatePageVbox(self):
        return self.provideCertificateXml.get_widget("provideCertificateWindowVbox")

    def setUrlInWidget(self):
        """ 
        sets the security cert label's server url at runtime 
        """
        securityCertlabel = self.provideCertificateXml.get_widget("SecurityCertLabel")
        text = securityCertlabel.get_text()
        text = text % cfg['serverURL'] 
        securityCertlabel.set_text(text)

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
                rhnreg.privacyText()
            except up2dateErrors.SSLCertificateVerifyFailedError:
                server_url = up2dateConfig['serverURL']
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

            if validateCaps() is True: # There was an error
                return SERVER_TOO_OLD
            
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
            server = cfg['serverURL']

            # If the serverURL config value is a list, we have no way of knowing
            # for sure which one the machine registered against, 
            # so default to the
            # first element.
            if type(server) == type([]):
                server = server[0]

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
        self.whyRegisterXml.get_widget("privacyButton").connect("clicked", self.showPrivacyDialog)
    
    def finish(self, button):
        self.dlg.hide()
        self.rc = 1 # What does this do? Is it needed?

    
    def showPrivacyDialog(self, button):
        PrivacyDialog()

class PrivacyDialog:
    def __init__(self):
        self.privXml = gtk.glade.XML(
            gladefile,
            "privacyDialog", domain="rhn-client-tools")
        self.dlg = self.privXml.get_widget("privacyDialog")

        self.privXml.get_widget("okButton").connect("clicked", self.finish)
        
        privacyArea = self.privXml.get_widget("privacyArea")
        socket.setdefaulttimeout(5)
        # see bz #165157

        try:
            text = callAndFilterExceptions(
                    rhnreg.privacyText,
                    [socket.timeout, up2dateErrors.CommunicationError],
                    _("There was an error retrieving the privacy statement.")
            )
            if text is None:
                text = ""
        except (socket.timeout, up2dateErrors.CommunicationError), error:
            self.dlg.hide()
            messageWindow.ErrorDialog(_("Unable to access the server. Please "
                "check your network settings."), parent=self.dlg)
            log.log_me(error)
            return None
            
        textBuffer = gtk.TextBuffer(None)
        textBuffer.set_text(text)
        privacyArea.set_buffer(textBuffer)


    def finish(self, button):
        self.dlg.hide()
        self.rc = 1


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
                    label.set_text(hw['hostname'])
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
        packageDialogPackages = rpmUtils.getInstalledPackageList(progressCallback = pwin.setProgress, getArch=1)
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

def autoActivateNumbersOnce():
    """Activates the registration/installation number from disk and the hardware
    info from the bios.
    
    Returns two values. They will be ActivationResults for the registration
    number from disk and the hardware info respectively if the activations 
    happened. Each value will be None if that activation didn't take place or 
    there was an error. If this call is made more than once, every call after 
    the first will return (None, None).
    
    After activating the numbers, it will refresh the cached available 
    subscriptions used by rhnreg.getAvailableSubscriptions.
    
    If something is activated, the resulting reg num will be stored so it will
    be used when creating the system profile (for child channels). A number
    from disk takes precedence over hardware info if both are activated.
    
    Can raise CommunicationError.
    
    """
    global _autoActivatedNumbers, regNum
    if _autoActivatedNumbers:
        return (None, None)
    _autoActivatedNumbers = True
    
    log.log_debug("Trying to automatically activate stuff.")
    
    activateHWResult = None
    if serverType == 'hosted':        
        hardwareInfo = None
        try:
            hardwareInfo = hardware.get_hal_system_and_smbios()
        except:
            log.log_me("There was an error while reading the hardware info from "
                       "the bios. Traceback:\n")
            log.log_exception(*sys.exc_info())
        if hardwareInfo:
            try:
                activateHWResult = rhnreg.activateHardwareInfo(username, password, 
                                                        hardwareInfo, organization)
                if activateHWResult.getStatus() == ActivationResult.ACTIVATED_NOW:
                    reviewLog.autoActivatedHardwareInfo(activateHWResult)
                regNum = activateHWResult.getRegistrationNumber()
                rhnreg.writeRegNum(regNum)
            except up2dateErrors.NotEntitlingError:
                log.log_debug('There are are no entitlements associated with this '
                              'hardware.')
            except up2dateErrors.InvalidRegistrationNumberError:
                log.log_debug('The hardware id was not recognized as valid.')

    # Try number from file after hardware info so this takes precedence for the
    # one we use later.
    activateRegNumResult = None
    registrationNumber = None
    try:
        registrationNumber = rhnreg.readRegNum()
    except IOError, error:
        log.log_me("There was an error while reading the registration "
                   "number from disk:\n%s" % error)
    if registrationNumber:
        if serverType == 'hosted':
            try:
                activateRegNumResult = rhnreg.activateRegistrationNumber(
                                                   username, password, registrationNumber, 
                                                   organization)
                if activateRegNumResult.getStatus() == ActivationResult.ACTIVATED_NOW:
                    reviewLog.autoActivatedRegistrationNumber(registrationNumber, 
                                                    activateRegNumResult)
                regNum = activateRegNumResult.getRegistrationNumber()
                rhnreg.writeRegNum(regNum)
            except up2dateErrors.NotEntitlingError:
                log.log_me("The installation number on disk is not entitling.")
                regNum = registrationNumber
                rhnreg.writeRegNum(regNum)
            except up2dateErrors.Error, error:
                log.log_me("There was an error while activating the installation "
                           "number found on disk:\n%s" % error)
                reviewLog.foundRegNumButCouldntActivate()
        else:
            regNum = registrationNumber
        
        # Call getAvailableSubscriptions to refresh its cache
        rhnreg.getAvailableSubscriptions(username, password)
        ##            log.log_me("It looks like the EN was successfully activated"
        ##                       " but there still aren't any available "
        ##                       "entitlements in the account. Maybe there's a "
        ##                       "delay with them activating, so we'll continue "
        ##                       "with registration and hope they show up later "
        ##                       "and apply to this profile.")
    return (activateRegNumResult, activateHWResult)


def hasBaseChannelAndUpdates():
    """Returns a bool indicating whether the system has registered, subscribed 
    to a base channel, and has at least update entitlements.
    Uses information from the most recent time the create profile screen was run 
    through.
    
    """
    global _hasBaseChannelAndUpdates
    return _hasBaseChannelAndUpdates


def validateCaps():
    """If the server doesn't support the needed capabilities, informs the user
    and returns True. If it does, returns False. This is kinda backwards, but I 
    wanted it to work the same way as most of the other calls.
    
    """
    setBusyCursor()
    if rhnreg.serverSupportsRhelFiveCalls():
        setArrowCursor()
        return False
    else:
        setArrowCursor()
        errorWindow(rhnreg_constants.SERVER_TOO_OLD)
        return True


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
