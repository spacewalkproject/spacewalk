#
# TUI for RHN Registration
# Copyright (c) 2000--2015 Red Hat, Inc.
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

from os import geteuid
import sys
import string

import gettext
t = gettext.translation('rhn-client-tools', fallback=True)
_ = t.ugettext

import snack
import signal

import rhnreg, hardware
import up2dateErrors
import up2dateUtils
import pkgUtils
import up2dateLog
import config
from config import convert_url_from_puny
import up2dateAuth
from rhn import rpclib
from rhn.connections import idn_puny_to_unicode
from pmPlugin import PM_PLUGIN_NAME, PM_PLUGIN_CONF
from rhnreg_constants import *

log = up2dateLog.initLog()
cfg = config.initUp2dateConfig()

def ErrorWindow(screen, errmsg):
    snack.ButtonChoiceWindow(screen, ERROR.encode('utf-8'), (u"%s" % errmsg).encode('utf-8'),
                             [BACK.encode('utf-8')])

def FatalErrorWindow(screen, errmsg):
    snack.ButtonChoiceWindow(screen, FATAL_ERROR.encode('utf-8'), (u"%s" % errmsg).encode('utf-8'),
                             [OK.encode('utf-8')])
    screen.finish()
    sys.exit(1)

def WarningWindow(screen, errmsg):
    snack.ButtonChoiceWindow(screen, WARNING.encode('utf-8'), ("%s" % errmsg).encode('utf-8'),
                             [OK.encode('utf-8')])
    screen.finish()


def ConfirmQuitWindow(screen):
    button = snack.ButtonChoiceWindow(screen, CONFIRM_QUIT.encode('utf-8'),
                             CONFIRM_QUIT_SURE.encode('utf-8') + "\n" + \
                             WHY_REGISTER_SEC.encode('utf-8')  + "\n" + \
                             WHY_REGISTER_SEC_TXT.encode('utf-8') + "\n\n" + \
                             WHY_REGISTER_DLD.encode('utf-8') + "\n" + \
                             WHY_REGISTER_DLD_TXT.encode('utf-8') + "\n\n" + \
                             WHY_REGISTER_SUPP.encode('utf-8') + "\n" + \
                             WHY_REGISTER_SUPP_TXT.encode('utf-8') + "\n\n" + \
                             WHY_REGISTER_COMP.encode('utf-8') + "\n" + \
                             WHY_REGISTER_COMP_TXT.encode('utf-8') + "\n\n" + \
                             CONFIRM_QUIT_WILLNOT.encode('utf-8') + "\n" + \
                             WHY_REGISTER_TIP.encode('utf-8'),
                             [CONTINUE_REGISTERING.encode('utf-8'), REGISTER_LATER2.encode('utf-8')],
                             width = 70)

    if button == string.lower(REGISTER_LATER2.encode('utf-8')):
        screen.finish()
        return 1
    else:
        return 0


def tui_call_wrapper(screen, func, *params):

    try:
        results = func(*params)
    except up2dateErrors.CommunicationError:
        ErrorWindow(screen, HOSTED_CONNECTION_ERROR % config.getServerlURL()[0])
        raise sys.exc_info()[1]
    except up2dateErrors.SSLCertificateVerifyFailedError:
        ErrorWindow(screen, e.errmsg)
        raise sys.exc_info()[1]
    except up2dateErrors.NoBaseChannelError:
        e = sys.exc_info()[1]
        FatalErrorWindow(screen, e.errmsg + '\n' +
                         BASECHANNELERROR % (up2dateUtils.getArch(),
                                             up2dateUtils.getOSRelease(),
                                             up2dateUtils.getVersion()))
    except up2dateErrors.SSLCertificateFileNotFound:
        e = sys.exc_info()[1]
        ErrorWindow(screen, e.errmsg + '\n\n' +
                         SSL_CERT_FILE_NOT_FOUND_ERRER)
        raise e

    return results

class WindowSkipException:

    def __init__(self):
        pass

class AlreadyRegisteredWindow:
    name = "AlreadyRegisteredWindow"

    def __init__(self, screen, tui):

        if not rhnreg.registered() or tui.test:
            raise WindowSkipException()

        self.screen = screen
        self.tui = tui
        size = snack._snack.size()

        systemIdXml = rpclib.xmlrpclib.loads(up2dateAuth.getSystemId())
        oldUsername = systemIdXml[0][0]['username']
        oldsystemId = systemIdXml[0][0]['system_id']

        toplevel = snack.GridForm(self.screen, SYSTEM_ALREADY_SETUP.encode('utf-8'), 1, 2)
        self.bb = snack.ButtonBar(self.screen,
                                  [(YES_CONT.encode('utf-8'), "next"),
                                   (NO_CANCEL.encode('utf-8'), "exit")])
        toplevel.add(self.bb, 0, 1, growx = 1)

        tb = snack.Textbox(size[0]-30, size[1]-20,
                            (SYSTEM_ALREADY_REGISTERED + "\n\n"
                            + _("Spacewalk Location:") + " " + convert_url_from_puny(self.tui.serverURL) + "\n"
                            + _("Login:") + " " + oldUsername + "\n"
                            + _("System ID:") + " " + oldsystemId + "\n\n"
                            + SYSTEM_ALREADY_REGISTERED_CONT + "\n").encode('utf-8'),
                            1, 1)
        toplevel.add(tb, 0, 0, padding = (0, 0, 0, 1))

        self.g = toplevel

    def saveResults(self):
            pass

    def run(self):
        log.log_debug("Running %s" % self.name)

        result = self.g.runOnce()
        button = self.bb.buttonPressed(result)

        if result == "F12":
            return "next"

        return button

class SatelliteUrlWindow:
    name = "SatelliteUrlWindow"

    def __init__(self, screen, tui):
        self.screen = screen
        self.tui = tui
        self.tui.alreadyRegistered = 0

        self.server = convert_url_from_puny(self.tui.serverURL)
        fixed_server_url = rhnreg.makeNiceServerUrl(self.server)

        #Save the config only if the url is different
        if fixed_server_url != self.server:
            self.server = fixed_server_url
            config.setServerURL(self.server)
            cfg.save()

        size = snack._snack.size()

        toplevel = snack.GridForm(screen, SATELLITE_URL_WINDOW.encode('utf-8'),
                1, 4)

        prompt_text = SATELLITE_URL_TEXT
        url_label = SATELLITE_URL_PROMPT
        ssl_label = SATELLITE_URL_PROMPT2

        label = snack.Textbox(size[0]-10, 3,
                                  prompt_text.encode('utf-8'),
                                  scroll = 0, wrap = 1)

        toplevel.add(label, 0, 0, anchorLeft = 1)

        # spacer
        label = snack.Label("".encode('utf-8'))
        toplevel.add(label, 0, 1)

        grid = snack.Grid(2, 3)

        label = snack.Label(url_label.encode('utf-8'))
        grid.setField(label, 0, 0, padding = (0, 0, 1, 0),
                          anchorRight = 1)

        self.urlEntry = snack.Entry(40)
        self.urlEntry.set(self.server)
        grid.setField(self.urlEntry, 1, 0, anchorLeft = 1)

        label = snack.Label(ssl_label.encode('utf-8'))
        grid.setField(label, 0, 1, padding = (0, 0, 1, 0),
                          anchorRight = 1)

        self.sslEntry = snack.Entry(40)
        self.sslEntry.set(tui.sslCACert)
        grid.setField(self.sslEntry, 1, 1, anchorLeft = 1)

        toplevel.add(grid, 0, 2)

        # BUTTON BAR
        self.bb = snack.ButtonBar(screen,
                                   [(NEXT.encode('utf-8'), "next"),
                                   (BACK.encode('utf-8'), "back"),
                                   (CANCEL.encode('utf-8'), "cancel")])

        toplevel.add(self.bb, 0, 3, padding = (0, 1, 0, 0),
                 growx = 1)


        self.g = toplevel

    def validateFields(self):
        if self.urlEntry.value() == "":
            snack.ButtonChoiceWindow(self.screen, ERROR.encode('utf-8'),
                                     SATELLITE_REQUIRED.encode('utf-8'),
                                     buttons = [OK.encode('utf-8')])
            self.g.setCurrent(self.urlEntry)
            return 0

        if (self.urlEntry.value()[:5] == 'https' and
                self.sslEntry.value() == ""):
            snack.ButtonChoiceWindow(self.screen, ERROR.encode('utf-8'),
                                     SSL_REQUIRED.encode('utf-8'),
                                     buttons = [OK.encode('utf-8')])
            self.g.setCurrent(self.sslEntry)
            return 0
        return 1

    def saveResults(self):
        serverEntry = self.urlEntry.value()
        # fix up the server url, E.G. if someone left off /XMLRPC
        fixed_server_url = rhnreg.makeNiceServerUrl(serverEntry)
        if fixed_server_url != serverEntry:
            serverEntry = fixed_server_url

        self.tui.serverURL = serverEntry
        self.tui.sslCACert = self.sslEntry.value()
        config.setServerURL(serverEntry)
        config.setSSLCACert(self.sslEntry.value())
        cfg.save()

    def run(self):
        log.log_debug("Running %s" % self.name)
        self.screen.refresh()
        valid = 0
        while not valid:
            result = self.g.run()
            button = self.bb.buttonPressed(result)

            if result == "F12":
                button = "next"

            if button == "next":
                valid = self.validateFields()

            else:
                break

        self.screen.popWindow()

        return button

class AlreadyRegisteredSubscriptionManagerWindow:
    name = "AlreadyRegisteredSubscriptionManagerWindow"

    def __init__(self, screen, tui):

        if not rhnreg.rhsm_registered() or tui.test:
            raise WindowSkipException()

        self.screen = screen
        self.tui = tui
        size = snack._snack.size()

        toplevel = snack.GridForm(self.screen, SYSTEM_ALREADY_SETUP.encode('utf-8'), 1, 2)
        self.bb = snack.ButtonBar(self.screen,
                                  [(YES_CONT.encode('utf-8'), "next"),
                                   (NO_CANCEL.encode('utf-8'), "exit")])
        toplevel.add(self.bb, 0, 1, growx = 1)

        tb = snack.Textbox(size[0]-30, size[1]-20,
                            (WARNING + "\n\n"
                            + RHSM_SYSTEM_ALREADY_REGISTERED + "\n\n"
                            + SYSTEM_ALREADY_REGISTERED_CONT + "\n").encode('utf-8'),
                            1, 1)
        toplevel.add(tb, 0, 0, padding = (0, 0, 0, 1))

        self.g = toplevel

    def saveResults(self):
            pass

    def run(self):
        log.log_debug("Running %s" % self.name)

        result = self.g.runOnce()
        button = self.bb.buttonPressed(result)

        if result == "F12":
            return "next"

        return button

class ConnectWindow:
    name = "ConnectWindow"

    def __init__(self, screen, tui):
        self.screen = screen
        self.tui = tui
        size = snack._snack.size()

        self.server = convert_url_from_puny(self.tui.serverURL)

        self.proxy = cfg['httpProxy']

        toplevel = snack.GridForm(self.screen, CONNECT_WINDOW.encode('utf-8'), 1, 1)

        text = CONNECT_WINDOW_TEXT % self.server + "\n\n"

        if self.proxy:
            text += CONNECT_WINDOW_TEXT2 % self.proxy

        tb = snack.Textbox(size[0]-30, size[1]-20,
                           text.encode('utf-8'),
                           1, 1)

        toplevel.add(tb, 0, 0, padding = (0, 0, 0, 1))

        self.g = toplevel


    def run(self):
        log.log_debug("Running %s" % self.name)

        # We draw and display the window.  The window gets displayed as
        # long as we are attempting to connect to the server.  Once we
        # connect the window is gone.
        result = self.g.draw()
        self.screen.refresh()
        # try to connect given the server url and ssl cert provided. If
        # unsuccessful, return to previous screen to allow user to fix.
        try:
            tui_call_wrapper(self.screen, rhnreg.getCaps)
        except:
            return "back"

        self.screen.popWindow()

        # Just return next, although the user wouldn't have actually pressed
        # anything.
        return "next"

    def saveResults(self):
        pass

class StartWindow:
    name = "StartWindow"

    def __init__(self, screen, tui):
        self.screen = screen
        self.tui = tui
        size = snack._snack.size()
        toplevel = snack.GridForm(self.screen, START_REGISTER_WINDOW.encode('utf-8'),
                                  1, 2)

        start_register_text = START_REGISTER_TEXT.encode('utf-8')

        tb = snack.Textbox(size[0]-10, size[1]-14, start_register_text, 1, 1)
        toplevel.add(tb, 0, 0, padding = (0, 0, 0, 1))

        self.bb = snack.ButtonBar(self.screen,
                                  [(WHY_REGISTER.encode('utf-8'), "why_register"),
                                   (NEXT.encode('utf-8'), "next"),
                                   (CANCEL.encode('utf-8'), "cancel")])
        toplevel.add(self.bb, 0, 1, growx = 1)

        self.g = toplevel

    def saveResults(self):
        pass


    def run(self):
        log.log_debug("Running %s" % self.name)
        result = self.g.runOnce()
        button = self.bb.buttonPressed(result)

        if result == "F12":
            return "next"
        elif button == "why_register":
            why_reg_win = WhyRegisterWindow(self.screen, self.tui)
            why_reg_win.run()
            return button

        return button

class WhyRegisterWindow:
    name = "WhyRegisterWindow"

    def __init__(self, screen, tui):
        self.screen = screen
        self.tui = tui
        size = snack._snack.size()
        toplevel = snack.GridForm(self.screen, WHY_REGISTER_WINDOW.encode('utf-8'),
                                  1, 2)


        why_register_text = WHY_REGISTER_TEXT + "\n\n" + \
                            WHY_REGISTER_SEC  + "\n" + \
                            WHY_REGISTER_SEC_TXT + "\n\n" + \
                            WHY_REGISTER_DLD + "\n" + \
                            WHY_REGISTER_DLD_TXT + "\n\n" + \
                            WHY_REGISTER_SUPP + "\n" + \
                            WHY_REGISTER_SUPP_TXT + "\n\n" + \
                            WHY_REGISTER_COMP + "\n" + \
                            WHY_REGISTER_COMP_TXT + "\n\n" + \
                            WHY_REGISTER_TIP

        tb = snack.Textbox(size[0]-10, size[1]-14, why_register_text.encode('utf-8'), 1, 1)

        toplevel.add(tb, 0, 0, padding = (0, 0, 0, 1))


        self.bb = snack.ButtonBar(self.screen,
                                  [(BACK_REGISTER.encode('utf-8'), "back")])
        toplevel.add(self.bb, 0, 1, growx = 1)

        self.g = toplevel

    def run(self):
        log.log_debug("Running %s" % self.name)
        result = self.g.runOnce()
        button = self.bb.buttonPressed(result)

        return button


class InfoWindow:
    name = "InfoWindow"

    def __init__(self, screen, tui):
        self.screen = screen
        self.tui = tui
        self.tui.alreadyRegistered = 0

        self.server = self.tui.serverURL

        size = snack._snack.size()

        toplevel = snack.GridForm(screen, REGISTER_WINDOW.encode('utf-8'), 1, 4)

        decoded_server = convert_url_from_puny(self.server)
        url = self.server
        if decoded_server != self.server:
            url += " (%s)" % decoded_server
        login_prompt = LOGIN_PROMPT % url
        login_label = LOGIN
        login_tip = LOGIN_TIP

        label = snack.Textbox(size[0]-10, 3,
                                  login_prompt.encode('utf-8'),
                                  scroll = 0, wrap = 1)

        toplevel.add(label, 0, 0, anchorLeft = 1)

        grid = snack.Grid(2, 3)

        label = snack.Label(login_label.encode('utf-8'))
        grid.setField(label, 0, 0, padding = (0, 0, 1, 0),
                          anchorRight = 1)

        self.userNameEntry = snack.Entry(20)
        self.userNameEntry.set(tui.userName)
        grid.setField(self.userNameEntry, 1, 0, anchorLeft = 1)

        label = snack.Label(PASSWORD.encode('utf-8'))
        grid.setField(label, 0, 1, padding = (0, 0, 1, 0),
                          anchorRight = 1)

        try:
            self.passwordEntry = snack.Entry(20, password = 1)
        except TypeError:
            self.passwordEntry = snack.Entry(20, hidden = 1)
        self.passwordEntry.set(tui.password)
        grid.setField(self.passwordEntry, 1, 1, anchorLeft = 1)

        toplevel.add(grid, 0, 1)

        label = snack.TextboxReflowed(size[0]-10, login_tip.encode('utf-8'))
        toplevel.add(label, 0, 2, anchorLeft=1)

        # BUTTON BAR
        self.bb = snack.ButtonBar(screen,
                                   [(NEXT.encode('utf-8'), "next"),
                                   (BACK.encode('utf-8'), "back"),
                                   (CANCEL.encode('utf-8'), "cancel")])

        toplevel.add(self.bb, 0, 3, padding = (0, 1, 0, 0),
                 growx = 1)


        self.g = toplevel


    def validateFields(self):
        if self.userNameEntry.value() == "":
            snack.ButtonChoiceWindow(self.screen, ERROR.encode('utf-8'),
                                     USER_REQUIRED.encode('utf-8'),
                                     buttons = [OK.encode('utf-8')])
            self.g.setCurrent(self.userNameEntry)
            return 0
        if self.passwordEntry.value() == "":
            snack.ButtonChoiceWindow(self.screen, ERROR.encode('utf-8'),
                                     PASSWORD_REQUIRED.encode('utf-8'),
                                     buttons = [OK.encode('utf-8')])
            self.g.setCurrent(self.passwordEntry)
            return 0


        try:
            self.tui.alreadyRegistered = rhnreg.reserveUser(self.userNameEntry.value(), self.passwordEntry.value())
        except up2dateErrors.ValidationError:
            e = sys.exc_info()[1]
            snack.ButtonChoiceWindow(self.screen, _("Error").encode('utf-8'), _("The server indicated an error:\n").encode('utf-8') + e.errmsg.encode('utf-8'), buttons = [_("OK").encode('utf-8')])
            self.g.setCurrent(self.userNameEntry)
            return 0
        except up2dateErrors.CommunicationError:
            e = sys.exc_info()[1]
            FatalErrorWindow(self.screen, _("There was an error communicating with the registration server:\n") + e.errmsg)
        return 1


    def saveResults(self):
        self.tui.userName = self.userNameEntry.value()
        self.tui.password = self.passwordEntry.value()

    def run(self):
        log.log_debug("Running %s" % self.name)
        self.screen.refresh()
        valid = 0
        while not valid:
            result = self.g.run()
            button = self.bb.buttonPressed(result)

            if result == "F12":
                button = "next"

            if button == "next":
                valid = self.validateFields()

            else:
                break

        self.screen.popWindow()
        return button

class OSReleaseWindow:
    name = "OSReleaseWindow"

    def __init__(self, screen, tui):

        self.tui = tui
        if not rhnreg.server_supports_eus():
            log.log_debug("Server does not support EUS, skipping OSReleaseWindow")
            raise WindowSkipException()

        self.available_channels = rhnreg.getAvailableChannels(
                        tui.userName, tui.password)
        if len(self.available_channels['channels']) < 1:
            log.log_debug("No available EUS channels, skipping OSReleaseWindow")
            raise WindowSkipException()

        self.screen = screen
        self.size = snack._snack.size()

        self.selectChannel = False

        toplevel = snack.GridForm(self.screen, SELECT_OSRELEASE.encode('utf-8'), 1, 7)
        self.g = toplevel

        self.ostext = snack.TextboxReflowed(self.size[0]-10, OS_VERSION.encode('utf-8'))
        toplevel.add(self.ostext, 0, 0, anchorLeft = 1)
        optiontext1 = LIMITED_UPDATES.encode('utf-8')

        if self.tui.limited_updates_button:
            self.limited_updates_button = snack.SingleRadioButton(optiontext1,
                                                None, isOn = 1)
        else:
            self.limited_updates_button = snack.SingleRadioButton(optiontext1,
                                                None)

        toplevel.add(self.limited_updates_button, 0, 1, padding = (0, 1, 0, 1),
                     anchorLeft = 1)

        self.sublabel = snack.Label(MINOR_RELEASE.encode('utf-8'))
        toplevel.add(self.sublabel, 0, 2, anchorLeft = 1)

        self.channelList = snack.Listbox(self.size[1]-22, 1,
                                 width = self.size[0]-10)
        toplevel.add(self.channelList, 0, 3)

        for key, value in sorted(self.available_channels['channels'].items(), key=lambda a:a[0]):
            if key in self.available_channels['receiving_updates']:
                value = value + "*"
            self.channelList.append(" " + value, key)

        self.tip = snack.TextboxReflowed(self.size[0]-10, CHANNEL_PAGE_TIP.encode('utf-8'))
        toplevel.add(self.tip, 0, 4, anchorLeft = 1)

        optiontext2 = ALL_UPDATES.encode('utf-8')

        if self.tui.all_updates_button:
            self.all_updates_button = snack.SingleRadioButton(optiontext2,
                                            self.limited_updates_button, isOn=1)
        else:
            self.all_updates_button = snack.SingleRadioButton(optiontext2,
                                            self.limited_updates_button)

        toplevel.add(self.all_updates_button, 0, 5, padding = (0, 0, 0, 1),
                     anchorLeft = 1)

        #self.warning = snack.TextboxReflowed(self.size[0]-10,
        #                     CHANNEL_PAGE_WARNING.encode('utf-8'))
        #toplevel.add(self.warning, 0, 9, anchorLeft = 1)


        self.bb = snack.ButtonBar(screen,
                          [(NEXT.encode('utf-8'), "next"),
                           (BACK.encode('utf-8'), "back"),
                           (CANCEL.encode('utf-8'), "cancel")])
        toplevel.add(self.bb, 0, 6, growx = 1)

        self.screen.refresh()



    def run(self):
        log.log_debug("Running %s" % self.name)
        self.screen.refresh()
        valid = "cancel"
        while valid == "cancel":
            result = self.g.run()
            button = self.bb.buttonPressed(result)

            if result == "F12":
                button = "next"

            if button == "next":
                valid = self.validateFields()
            else:
                break

        self.screen.popWindow()
        return button

    def validateFields(self):
        msgbox = "ok"
        later_release = False
        if self.limited_updates_button.selected():
            later_release = self.channelList.current() != \
                                 self.available_channels['default_channel']

        title = CONFIRM_OS_RELEASE_SELECTION.encode('utf-8')
        if later_release:
            msgbox = snack.ButtonChoiceWindow(self.screen, title,
                           CONFIRM_OS_WARNING.encode('utf-8') % self.channelList.current(),
                           buttons =[OK.encode('utf-8'), CANCEL.encode('utf-8')])
            return msgbox

        if self.all_updates_button.selected() or later_release:
            msgbox = snack.ButtonChoiceWindow(self.screen, title,
                                  CONFIRM_OS_ALL.encode('utf-8'), buttons =[OK.encode('utf-8'), CANCEL.encode('utf-8')])
            return msgbox
        return msgbox

        if self.limited_updates_button.selected():
            #TODO: warn
            return msgbox

    def saveResults(self):
        # if limited updates save the channel and selction
        # for future use
        if self.limited_updates_button.selected():
            log.log_debug("Selected Channel %s" % self.channelList.current())
            self.tui.other['channel'] = self.channelList.current()
            self.tui.limited_updates_button = self.limited_updates_button.selected()
            self.tui.all_updates_button = 0

        # saving data for all updates button
        if self.all_updates_button.selected():
            self.tui.all_updates_button = self.all_updates_button.selected()
            self.tui.limited_updates_button = 0


class HardwareWindow:
    name = "HardwareWindow"

    def __init__(self, screen, tui):
        self.screen = screen
        self.tui = tui
        size = snack._snack.size()

        #get the virtualization uuid and set it to other.
        (virt_uuid, virt_type) = rhnreg.get_virt_info()
        if not virt_uuid is None:
            self.tui.other['virt_uuid'] = virt_uuid
            self.tui.other['virt_type'] = virt_type

        # read all hardware in
        tui.hardware = hardware.Hardware()

        toplevel = snack.GridForm(screen, HARDWARE_WINDOW.encode('utf-8'), 1, 7)

        text = snack.TextboxReflowed(70, HARDWARE_WINDOW_DESC1.encode('utf-8'))

        toplevel.add(text, 0, 0, anchorLeft = 1)

        grid = snack.Grid(2, 2)

        label = snack.Label(_("Profile name:").encode('utf-8'))
        grid.setField(label, 0, 0, padding = (0, 0, 1, 0), anchorRight = 1)

        self.profileEntry = snack.Entry(40)
        grid.setField(self.profileEntry, 1, 0, anchorLeft = 1)

        toplevel.add(grid, 0, 1, anchorLeft = 1)

        if tui.includeHardware:
            self.hardwareButton = snack.Checkbox(HARDWARE_WINDOW_CHECKBOX.encode('utf-8'), isOn = 1)
        else:
            self.hardwareButton = snack.Checkbox(HARDWARE_WINDOW_CHECKBOX.encode('utf-8'))

        toplevel.add(self.hardwareButton, 0, 2, padding = (0, 1, 0, 0),
                     anchorLeft = 1)

        label = snack.Label(DESELECT.encode('utf-8'))
        toplevel.add(label, 0, 3, anchorLeft = 1, padding = (0, 0, 0, 1))

        grid = snack.Grid(4, 3)
        hardware_text = ''

        hardware_text += _("Version: ") + up2dateUtils.getVersion() + "  "
        self.versionLabel = snack.Label(_("Version: ").encode('utf-8'))
        grid.setField(self.versionLabel, 0, 0, padding = (0, 0, 1, 0), anchorLeft = 1)

        self.versionLabel2 = snack.Label(up2dateUtils.getVersion())
        grid.setField(self.versionLabel2, 1, 0, anchorLeft = 1)

        hardware_text += _("CPU model: ")

        for hw in tui.hardware:
            if hw['class'] == 'CPU':
                hardware_text += hw['model'] +"\n"

        hardware_text += _("Hostname: ")

        for hw in tui.hardware:
            if hw['class'] == 'NETINFO':
                unicode_hostname = idn_puny_to_unicode(hw['hostname'])
                hardware_text += unicode_hostname + "\n"

                if tui.profileName != "":
                    self.profileEntry.set(tui.profileName)
                else:
                    self.profileEntry.set(unicode_hostname.encode('utf-8'))

        hardware_text += _("CPU speed: ")

        for hw in tui.hardware:
            if hw['class'] == 'CPU':
                hardware_text += _("%d MHz") % hw['speed'] + "  "

        hardware_text += _("IP Address: ")

        for hw in tui.hardware:
            if hw['class'] == 'NETINFO':
                if hw['ipaddr']:
                    hardware_text += hw['ipaddr'] + "  "
                elif hw['ip6addr']:
                    hardware_text += hw['ip6addr'] + "  "

        hardware_text += _("Memory: ")

        for hw in tui.hardware:
            if hw['class'] == 'MEMORY':
                hardware_text += _("%s megabytes") % hw['ram']

        tb = snack.TextboxReflowed(80, hardware_text.encode('utf-8'))
        toplevel.add(tb, 0, 4)

        self.additionalHWLabel = snack.TextboxReflowed(size[0]-10, HARDWARE_WINDOW_DESC2.encode('utf-8'))

        toplevel.add(self.additionalHWLabel, 0, 5, padding = (0, 1, 0, 0),
                     anchorLeft = 1)

        # BUTTON BAR
        self.bb = snack.ButtonBar(screen,
                                  [(NEXT.encode('utf-8'), "next"),
                                   (BACK.encode('utf-8'), "back"),
                                   (CANCEL.encode('utf-8'), "cancel")])
        toplevel.add(self.bb, 0, 6, padding = (0, 1, 0, 0),
                     growx = 1)

        self.g = toplevel

        # self.screen.gridWrappedWindow(toplevel, 'HardwareWindow', 80, 14)

    def saveResults(self):
        self.tui.profileName = self.profileEntry.value()
        self.tui.includeHardware = self.hardwareButton.selected()

    def run(self):
        log.log_debug("Running %s" % self.name)
        result = self.g.runOnce()
        button = self.bb.buttonPressed(result)

        if result == "F12":
            return "next"
        return button

class PackagesWindow:
    name = "PackagesWindow"

    def __init__(self, screen, tui):
        self.screen = screen
        self.tui = tui
        size = snack._snack.size()
        toplevel = snack.GridForm(screen, PACKAGES_WINDOW.encode('utf-8'), 1, 5)
        self.g = toplevel


        text = snack.TextboxReflowed(size[0]-10, PACKAGES_WINDOW_DESC1.encode('utf-8'))

        toplevel.add(text, 0, 0, anchorLeft = 1)

        self.packagesButton = snack.Checkbox(PACKAGES_WINDOW_DESC2.encode('utf-8'), 1)
        toplevel.add(self.packagesButton, 0, 1, padding = (0, 1, 0, 1),
                     anchorLeft = 1)

        label = snack.Label(PACKAGES_WINDOW_UNCHECK.encode('utf-8'))
        toplevel.add(label, 0, 2, anchorLeft = 1)

        #self.packageList = snack.Listbox(size[1]-18, 1, width = size[0]-10)
        self.packageList = snack.CheckboxTree(size[1]-18, 1)
        toplevel.add(self.packageList, 0, 3)

        # do we need to read the packages from disk?
        if tui.packageList == []:
            self.pwin = snack.GridForm(screen, PACKAGES_WINDOW_PKGLIST.encode('utf-8'), 1, 1)

            self.scale = snack.Scale(40, 100)
            self.pwin.add(self.scale, 0, 0)
            self.pwin.draw()
            self.screen.refresh()
            getArch = 0
            if rhnreg.cfg['supportsExtendedPackageProfile']:
                getArch = 1
            tui.packageList = pkgUtils.getInstalledPackageList(getArch=getArch)
            self.screen.popWindow()

        for package in tui.packageList:
            self.packageList.append("%s-%s-%s" % (package['name'],
                                                  package['version'],
                                                  package['release']),
                                                  item = package['name'],
                                                  selected = 1)

        # BUTTON BAR
        self.bb = snack.ButtonBar(screen,
                                  [(NEXT.encode('utf-8'), "next"),
                                   (BACK.encode('utf-8'), "back"),
                                   (CANCEL.encode('utf-8'), "cancel")])
        toplevel.add(self.bb, 0, 4, padding = (0, 1, 0, 0),
                     growx = 1)



    def setScale(self, amount, total):
        self.scale.set(int(((amount * 1.0)/ total) * 100))
        self.pwin.draw()
        self.screen.refresh()


    def saveResults(self):
        self.tui.includePackages = self.packagesButton.selected()
        selection = self.packageList.getSelection()
        for pkg in self.tui.packageList:
            if pkg['name'] in selection:
                self.tui.selectedPackages.append(pkg)


    def run(self):
        log.log_debug("Running %s" % self.name)
        result = self.g.runOnce()
        button = self.bb.buttonPressed(result)

        if result == "F12":
            return "next"
        return button

class SendWindow:
    name = "SendWindow"

    def __init__(self, screen, tui):
        self.screen = screen
        self.tui = tui
        size = snack._snack.size()

        toplevel = snack.GridForm(screen, SEND_WINDOW.encode('utf-8'), 1, 2)

        text = snack.TextboxReflowed(size[0]-15, SEND_WINDOW_DESC.encode('utf-8'))
        toplevel.add(text, 0, 0)

        # BUTTON BAR
        self.bb = snack.ButtonBar(screen,
                                  [(NEXT.encode('utf-8'), "next"),
                                   (BACK.encode('utf-8'), "back"),
                                   (CANCEL.encode('utf-8'), "cancel")])
        toplevel.add(self.bb, 0, 1, padding = (0, 1, 0, 0),
                     growx = 1)

        self.g = toplevel

    def saveResults(self):
        pass


    def run(self):
        log.log_debug("Running %s" % self.name)
        result = self.g.runOnce()
        button = self.bb.buttonPressed(result)

        if result == "F12":
            return "next"
        return button

class SendingWindow:
    name = "SendingWindow"

    def __init__(self, screen, tui):
        self.screen = screen
        self.tui = tui
        size = snack._snack.size()

        self.pwin = snack.GridForm(screen, SENDING_WINDOW.encode('utf-8'), 1, 1)

        self.scale = snack.Scale(40, 100)
        self.pwin.add(self.scale, 0, 0)

    def run(self):
        log.log_debug("Running %s" % self.name)

        self.pwin.draw()
        self.screen.refresh()

        reg_info = None
        try:
            # reg_info dict contains: 'system_id', 'channels',
            # 'failed_channels', 'slots', 'failed_slots'
            log.log_debug('other is %s' % str(self.tui.other))

            reg_info = rhnreg.registerSystem2(self.tui.userName, self.tui.password,
                                             self.tui.profileName,
                                             other = self.tui.other)
            reg_info = reg_info.rawDict

            if isinstance(reg_info['system_id'], unicode):
                systemId = unicode.encode(reg_info['system_id'], 'utf-8')
            else:
                systemId = reg_info['system_id']

        except up2dateErrors.CommunicationError:
            e = sys.exc_info()[1]
            FatalErrorWindow(self.screen,
                             _("Problem registering system:\n") + e.errmsg)
        except up2dateErrors.RhnUuidUniquenessError:
            e = sys.exc_info()[1]
            FatalErrorWindow(self.screen,
                             _("Problem registering system:\n") + e.errmsg)
        except up2dateErrors.InsuffMgmntEntsError:
            e = sys.exc_info()[1]
            FatalErrorWindow(self.screen,
                             _("Problem registering system:\n") + e.errmsg)
        except up2dateErrors.RegistrationDeniedError:
            e = sys.exc_info()[1]
            FatalErrorWindow(self.screen,
                             _("Problem registering system:\n") + e.errmsg)
        except up2dateErrors.ActivationKeyUsageLimitError:
            FatalErrorWindow(self.screen,
                             ACT_KEY_USAGE_LIMIT_ERROR)
        except:
            log.log_exception(*sys.exc_info())
            FatalErrorWindow(self.screen, _("Problem registering system."))

        # write the system id out.
        if not rhnreg.writeSystemId(systemId):
            FatalErrorWindow(self.screen,
                             _("Problem writing out system id to disk."))

        self.setScale(1, 4)

        # include the info from the oeminfo file as well
        self.oemInfo = rhnreg.getOemInfo()

        self.setScale(2, 4)

        # maybe upload hardware profile
        if self.tui.includeHardware:
            try:
                rhnreg.sendHardware(systemId, self.tui.hardware)
            except up2dateErrors.CommunicationError:
                e = sys.exc_info()[1]
                FatalErrorWindow(self.screen,
                                 _("Problem sending hardware profile:\n") + e.errmsg)
            except:
                log.log_exception(*sys.exc_info())
                FatalErrorWindow(self.screen,
                                 _("Problem sending hardware profile."))

        self.setScale(3, 4)

        # build up package list if necessary
        if self.tui.includePackages:
            try:
                rhnreg.sendPackages(systemId, self.tui.selectedPackages)
            except up2dateErrors.CommunicationError:
                e = sys.exc_info()[1]
                FatalErrorWindow(self.screen, _("Problem sending package list:\n") + e.errmsg)
            except:
                log.log_exception(*sys.exc_info())
                FatalErrorWindow(self.screen, _("Problem sending package list."))

        li = None
        try:
            li = up2dateAuth.updateLoginInfo()
        except up2dateErrors.InsuffMgmntEntsError:
            FatalErrorWindow(self.screen, sys.exc_info()[1])

        # Send virtualization information to the server.
        rhnreg.sendVirtInfo(systemId)

        # enable yum-rhn-plugin / dnf-plugin-spacewalk
        try:
            self.tui.pm_plugin_present, self.tui.pm_plugin_conf_changed = rhnreg.pluginEnable()
        except IOError:
            e = sys.exc_info()[1]
            WarningWindow(self.screen, _("Could not open %s\n%s is not enabled.\n") % (PM_PLUGIN_CONF, PM_PLUGIN_NAME) + e.errmsg)
            self.tui.pm_plugin_conf_error = 1

        rhnreg.spawnRhnCheckForUI()
        self.setScale(4, 4)

        # Pop the pwin (Progress bar window)
        self.screen.popWindow()

        self.tui.reg_info = reg_info

        return "next"

    def saveResults(self):
        pass

    def setScale(self, amount, total):
        self.scale.set(int(((amount * 1.0)/ total) * 100))
        self.pwin.draw()
        self.screen.refresh()


class FinishWindow:
    name = "FinishWindow"

    def __init__(self, screen, tui):
        self.screen = screen
        self.tui = tui
        size = snack._snack.size()

        toplevel = snack.GridForm(screen, FINISH_WINDOW.encode('utf-8'),
                                  1, 2)

        text = snack.TextboxReflowed(size[0]-11, FINISH_WINDOW_TEXT_TUI.encode('utf-8'))
        toplevel.add(text, 0, 0)

        # BUTTON BAR
        self.bb = snack.ButtonBar(screen,
                                  [(_("Finish").encode('utf-8'), "next")])
        toplevel.add(self.bb, 0, 1, padding = (0, 1, 0, 0),
                     growx = 1)

        self.g = toplevel

    def saveResults(self):
        pass


    def run(self):
        log.log_debug("Running %s" % self.name)
        result = self.g.runOnce()
        button = self.bb.buttonPressed(result)

        if result == "F12":
            return "next"
        return button

class ReviewWindow:
    name = "ReviewWindow"

    def __init__(self, screen, tui):
        self.screen = screen
        self.tui = tui
        self.reg_info = tui.reg_info
        size = snack._snack.size()

        toplevel = snack.GridForm(screen, REVIEW_WINDOW.encode('utf-8'), 1, 2)
        review_window_text = ''

        if not self.tui.pm_plugin_present:
            review_window_text += PM_PLUGIN_WARNING + "\n\n"
        if self.tui.pm_plugin_conf_error:
            review_window_text += PM_PLUGIN_CONF_ERROR + "\n\n"
        if self.tui.pm_plugin_conf_changed:
            review_window_text += PM_PLUGIN_CONF_CHANGED + "\n\n"

        # Build up the review_window_text based on the data in self.reg_info
        review_window_text += REVIEW_WINDOW_PROMPT + "\n\n"

        # Create and add the text for what channels the system was
        # subscribed to.
        if len(self.reg_info['channels']) > 0:
            channel_list = ""
            for channel in self.reg_info['channels']:
                channel_list += channel + "\n"

            channels = CHANNELS_TITLE + "\n" + \
                       OK_CHANNELS + "\n" + \
                       "%s\n"

            log.log_debug("server type is %s " % self.tui.serverType)
            channels += CHANNELS_SAT_WARNING

            review_window_text += channels % channel_list + "\n\n"

        if len(self.reg_info['system_slots']) > 0:
            slot_list = ""
            for slot in self.reg_info['system_slots']:
                if slot == 'enterprise_entitled':
                    slot_list += MANAGEMENT + "\n"
                elif slot == 'virtualization_host':
                    slot_list += VIRT + "\n"
                else:
                    slot_list += slot + "\n"
            review_window_text += SLOTS % slot_list + "\n\n"

        if len(self.reg_info['universal_activation_key']) > 0:
            act_key_list = ""
            for act_key in self.reg_info['universal_activation_key']:
                act_key_list += act_key
            review_window_text += ACTIVATION_KEY % (act_key_list)

        self.review_window = snack.Textbox(size[0]-10, size[1]-14, review_window_text.encode('utf-8'), 1, 1)

        toplevel.add(self.review_window, 0, 0, padding = (0, 1, 0, 0))

        # BUTTON BAR
        self.bb = snack.ButtonBar(screen, [(OK.encode('utf-8'), "next")])
        toplevel.add(self.bb, 0, 1, padding = (0, 1, 0, 0),
                     growx = 1)

        self.g = toplevel

    def saveResults(self):
        return 1

    def run(self):
        log.log_debug("Running %s" % self.name)
        result = self.g.runOnce()
        button = self.bb.buttonPressed(result)

        if result == "F12":
            button = "next"
        if not self.tui.pm_plugin_present:
            button = "exit"
        if self.tui.pm_plugin_conf_error:
            button = "exit"

        return button

class Tui:
    name = "RHN_REGISTER_TUI"

    def __init__(self, screen, test):
        self.screen = screen
        self.test = test
        self.size = snack._snack.size()
        self.drawFrame()
        self.alreadyRegistered = 0
        try:
            self.serverType = rhnreg.getServerType()
        except up2dateErrors.InvalidProtocolError:
            FatalErrorWindow(screen, _("You specified an invalid protocol." +
                                     "Only https and http are allowed."))

        self.windows = [
            AlreadyRegisteredSubscriptionManagerWindow,
            AlreadyRegisteredWindow,
            StartWindow,
            SatelliteUrlWindow,
            ConnectWindow,
            InfoWindow,
            OSReleaseWindow,
            HardwareWindow,
            PackagesWindow,
            SendWindow,
            SendingWindow,
            ReviewWindow,
            FinishWindow
            ]
        self.serverURL = config.getServerlURL()[0]

        if not cfg['sslCACert']:
            cfg.set('sslCACert', '/usr/share/rhn/RHN-ORG-TRUSTED-SSL-CERT')
        self.sslCACert = cfg['sslCACert']

    def __del__(self):
        self.screen.finish()


    def drawFrame(self):
        self.welcomeText = COPYRIGHT_TEXT
        self.screen.drawRootText(0, 0, self.welcomeText.encode('utf-8'))
        self.screen.pushHelpLine(_("  <Tab>/<Alt-Tab> between elements  |  <Space> selects  |  <F12> next screen").encode('utf-8'))


    def initResults(self):
        self.userName = ""
        self.password = ""

        self.oemInfo = {}
        self.productInfo = {
            "entitlement_num" : "",
            "registration_num" : "",
            "first_name" : "",
            "last_name" : "",
            "company" : "",
            "address" : "",
            "city" : "",
            "state" : "",
            "zip" : "",
            "country" : "",
           }

        self.other = {}
        self.other['registration_number'] = ''

        self.profileName = ""
        self.includeHardware = 1

        self.limited_updates_button = 1
        self.all_updates_button = 0
        self.includePackages = 0
        self.packageList = []
        self.selectedPackages = []
        self.pm_plugin_present = 1
        self.pm_plugin_conf_error = 0
        self.pm_plugin_conf_changed = 0

    def run(self):
        log.log_debug("Running %s" % self.name)
        self.initResults()

        direction = "forward"

        try:
            index = 0
            while index < len(self.windows):

                win = None
                try:
                    win = self.windows[index](self.screen, self)
                except WindowSkipException:
                    if direction == "forward":
                        index = index + 1
                    else:
                        index = index - 1
                    continue

                log.log_debug("index is %s" % index)

                result = win.run()
                log.log_debug("Result %s" % result)

                if result == "back":
                    if index > 0:
                        index = index - 1

                    # If we're on the info window, "back" means go back
                    # to the satellite url window, not back to the
                    # temporary connection test window.
                    if (index > 0 and
                            self.windows[index].name == ConnectWindow.name):
                        index -= 1

                    direction = "backward"

                elif result == "exit":
                    return

                elif result == "cancel":
                    log.log_debug("Caught a cancel request")

                    # Show the confirm quit window
                    if ConfirmQuitWindow(self.screen) == 1:
                        return

                elif result == "next":
                    index = index + 1
                    win.saveResults()
                    direction = "forward"

        finally:
            self.screen.finish()


def main():
    test = 0
    signal.signal(signal.SIGINT, signal.SIG_IGN)

    if len(sys.argv) > 1:
        if sys.argv[1] == "-t" or sys.argv[1] == "--test":
            test = 1

    screen = snack.SnackScreen()

    if geteuid() != 0 and not test:
        FatalErrorWindow(screen, _("You must run the RHN registration program as root."))

    tui = Tui(screen, test)
    tui.run()


if __name__ == "__main__":
    main()
