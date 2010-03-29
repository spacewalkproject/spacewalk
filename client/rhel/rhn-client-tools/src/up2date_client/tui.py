#
# TUI for RHN Registration
# Copyright (c) 2000--2010 Red Hat, Inc.
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
_ = gettext.gettext
gettext.textdomain("rhn-client-tools")

import snack

import signal

import rhnreg, hardware
import up2dateErrors
import up2dateUtils
import rpmUtils
import up2dateLog
import config
import up2dateAuth
from rhn import rpclib

from rhnreg_constants import *

log = up2dateLog.initLog()
cfg = config.initUp2dateConfig()

def FatalErrorWindow(screen, errmsg):
    snack.ButtonChoiceWindow(screen, FATAL_ERROR, "%s" % errmsg,
                             [OK])
    screen.finish()
    sys.exit(1)
    
def RecoverableErrorWindow(screen, errmsg):
    snack.ButtonChoiceWindow(screen, RECOVERABLE_ERROR, "%s" % errmsg,
                             [OK])

def ConfirmQuitWindow(screen):
    button = snack.ButtonChoiceWindow(screen, CONFIRM_QUIT,
                             CONFIRM_QUIT_SURE + "\n" + \
                             WHY_REGISTER_SEC  + "\n" + \
                             WHY_REGISTER_SEC_TXT + "\n\n" + \
                             WHY_REGISTER_DLD + "\n" + \
                             WHY_REGISTER_DLD_TXT + "\n\n" + \
                             WHY_REGISTER_SUPP + "\n" + \
                             WHY_REGISTER_SUPP_TXT + "\n\n" + \
                             WHY_REGISTER_COMP + "\n" + \
                             WHY_REGISTER_COMP_TXT + "\n\n" + \
                             CONFIRM_QUIT_WILLNOT + "\n" + \
                             WHY_REGISTER_TIP,
                             [CONTINUE_REGISTERING, REGISTER_LATER2],
                             width = 70)

    if button == string.lower(REGISTER_LATER2):
        screen.finish()
        return 1
    else:
        return 0
    
    
def tui_call_wrapper(screen, func, *params):

    try:
        results = func(*params)
    except up2dateErrors.CommunicationError, e:
        FatalErrorWindow(screen, HOSTED_CONNECTION_ERROR % cfg['serverURL'])
    except up2dateErrors.SSLCertificateVerifyFailedError, e:
        FatalErrorWindow(screen, e.errmsg)
    except up2dateErrors.NoBaseChannelError, e:
        FatalErrorWindow(screen, e.errmsg + '\n' + 
                         BASECHANNELERROR % (up2dateUtils.getArch(), 
                                             up2dateUtils.getOSRelease(),
                                             up2dateUtils.getVersion()))
    except up2dateErrors.SSLCertificateFileNotFound, e:
        FatalErrorWindow(screen, e.errmsg + '\n\n' +
                         SSL_CERT_FILE_NOT_FOUND_ERRER)
        
    return results

class WindowSkipException:

    def __init__(self):
        pass

class ConnectWindow:

    def __init__(self, screen, tui):
        self.name = "ConnectWindow"
        self.screen = screen
        self.tui = tui
        size = snack._snack.size()

        self.server = self.tui.serverURL

        fixed_server_url = rhnreg.makeNiceServerUrl(self.server)

        #Save the config only if the url is different
        if fixed_server_url != self.server:
            self.server = fixed_server_url
            cfg.set('serverURL', self.server)

            cfg.save()
        
        self.proxy = cfg['httpProxy']

        toplevel = snack.GridForm(self.screen, CONNECT_WINDOW, 1, 1)

        text = CONNECT_WINDOW_TEXT % self.server + "\n\n"

        if self.proxy:
            text += CONNECT_WINDOW_TEXT2 % self.proxy

        tb = snack.Textbox(size[0]-30, size[1]-20, 
                           text,
                           1, 1)

        toplevel.add(tb, 0, 0, padding = (0, 0, 0, 1))                           

        self.g = toplevel


    def run(self):
        log.log_debug("Running %s" % self.__class__.__name__)

        # We draw and display the window.  The window gets displayed as
        # long as we are attempting to connect to the server.  Once we
        # connect the window is gone.
        result = self.g.draw()
        self.screen.refresh()
        tui_call_wrapper(self.screen, rhnreg.getCaps)
            
        self.screen.popWindow()

        # Just return next, although the user wouldn't have actually pressed
        # anything.
        return "next"

    def saveResults(self):
        pass
    
class StartWindow:
    
    def __init__(self, screen, tui):
        self.name = "StartWindow"
        self.screen = screen
        self.tui = tui
        size = snack._snack.size()
        toplevel = snack.GridForm(self.screen, START_REGISTER_WINDOW,
                                  1, 2)

        start_register_text = START_REGISTER_TEXT

        tb = snack.Textbox(size[0]-10, size[1]-14, start_register_text, 1, 1)
        toplevel.add(tb, 0, 0, padding = (0, 0, 0, 1))

        self.bb = snack.ButtonBar(self.screen,
                                  [(WHY_REGISTER, "why_register"),
                                   (NEXT, "next"),
                                   (CANCEL, "cancel")])
        toplevel.add(self.bb, 0, 1, growx = 1)

        self.g = toplevel

    def saveResults(self):
        pass


    def run(self):
        log.log_debug("Running %s" % self.__class__.__name__)
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

    def __init__(self, screen, tui):
        self.name = "WhyRegisterWindow"
        self.screen = screen
        self.tui = tui
        size = snack._snack.size()
        toplevel = snack.GridForm(self.screen, WHY_REGISTER_WINDOW,
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

        tb = snack.Textbox(size[0]-10, size[1]-14, why_register_text, 1, 1)

        toplevel.add(tb, 0, 0, padding = (0, 0, 0, 1))


        self.bb = snack.ButtonBar(self.screen,
                                  [(BACK_REGISTER, "back")])
        toplevel.add(self.bb, 0, 1, growx = 1)

        self.g = toplevel

    def run(self):
        log.log_debug("Running %s" % self.__class__.__name__)
        result = self.g.runOnce()
        button = self.bb.buttonPressed(result)

        return button
    

class InfoWindow:

    def __init__(self, screen, tui):
        self.name = "InfoWindow"
        self.screen = screen
        self.tui = tui
        self.tui.alreadyRegistered = 0

        self.server = self.tui.serverURL
        
        size = snack._snack.size()

        toplevel = snack.GridForm(screen, REGISTER_WINDOW, 1, 12)

        # Satellite
        if self.tui.serverType == 'satellite':
            login_prompt = LOGIN_PROMPT % self.server
            login_label = LOGIN
            login_tip = LOGIN_TIP

        # Hosted
        else:
            login_prompt = HOSTED_LOGIN_PROMPT
            login_label = HOSTED_LOGIN
            login_tip = HOSTED_LOGIN_TIP


        label = snack.Textbox(size[0]-10, 3,
                                  login_prompt,
                                  scroll = 0, wrap = 1)

        toplevel.add(label, 0, 0, anchorLeft = 1)

        grid = snack.Grid(2, 3)

        label = snack.Label(login_label)
        grid.setField(label, 0, 0, padding = (0, 0, 1, 0),
                          anchorRight = 1)

        self.userNameEntry = snack.Entry(20)
        self.userNameEntry.set(tui.userName)
        grid.setField(self.userNameEntry, 1, 0, anchorLeft = 1)

        label = snack.Label(PASSWORD)
        grid.setField(label, 0, 1, padding = (0, 0, 1, 0),
                          anchorRight = 1)

        try:
            self.passwordEntry = snack.Entry(20, password = 1)
        except TypeError:
            self.passwordEntry = snack.Entry(20, hidden = 1)
        self.passwordEntry.set(tui.password)
        grid.setField(self.passwordEntry, 1, 1, anchorLeft = 1)

        toplevel.add(grid, 0, 3)

        label = snack.TextboxReflowed(size[0]-10, login_tip)
        toplevel.add(label, 0, 4, anchorLeft=1)

        # BUTTON BAR
        self.bb = snack.ButtonBar(screen,
                                   [(NEXT, "next"),
                                   (BACK, "back"),
                                   (CANCEL, "cancel")])

        toplevel.add(self.bb, 0, 8, padding = (0, 1, 0, 0),
                 growx = 1)


        self.g = toplevel


    def validateFields(self):
        if self.userNameEntry.value() == "":
            snack.ButtonChoiceWindow(self.screen, ERROR,
                                     USER_REQUIRED,
                                     buttons = [OK])
            self.g.setCurrent(self.userNameEntry)
            return 0
        if self.passwordEntry.value() == "":
            snack.ButtonChoiceWindow(self.screen, ERROR,
                                     PASSWORD_REQUIRED,
                                     buttons = [OK])
            self.g.setCurrent(self.passwordEntry)
            return 0


        try:
            self.tui.alreadyRegistered = rhnreg.reserveUser(self.userNameEntry.value(), self.passwordEntry.value())
        except up2dateErrors.ValidationError, e:
            snack.ButtonChoiceWindow(self.screen, _("Error"), _("The server indicated an error:\n") + e.errmsg, buttons = [_("OK")])
            self.g.setCurrent(self.userNameEntry)
            return 0
        except up2dateErrors.CommunicationError,e:
            FatalErrorWindow(self.screen, _("There was an error communicating with the registration server:\n") + e.errmsg)
        return 1


    def saveResults(self):
        self.tui.userName = self.userNameEntry.value()
        self.tui.password = self.passwordEntry.value()
        
    def run(self):
        log.log_debug("Running %s" % self.__class__.__name__)
        self.screen.refresh()
        valid = 0
        while not valid:
            result = self.g.run()
            button = self.bb.buttonPressed(result)

            if result == "F12":
                button = "next"

            if button == "next":

                valid = self.validateFields()
                if valid == 0:
                    continue
                
            else:
                break

        self.screen.popWindow()
        return button
    
class OSReleaseWindow:

    def __init__(self, screen, tui):

        if not rhnreg.server_supports_eus():
            log.log_debug("Server does not support EUS, skipping OSReleaseWindow")
            raise WindowSkipException()

        self.available_channels = rhnreg.getAvailableChannels(
	                tui.userName, tui.password)
        if len(self.available_channels['channels']) < 1:
            log.log_debug("No available EUS channels, skipping OSReleaseWindow")
            raise WindowSkipException()

        self.name = "OSReleaseWindow"
        self.screen = screen
        self.tui = tui
        self.size = snack._snack.size()          

        self.selectChannel = False
 
        toplevel = snack.GridForm(self.screen, 
	                 _("Select Operating System Release"), 1, 10)
        self.g = toplevel

        self.ostext = snack.TextboxReflowed(self.size[0]-10, 
	                    _("Operating System version:"))
        toplevel.add(self.ostext, 0, 1, anchorLeft = 1)
        optiontext1 = _("Limited Updates Only")

        if self.tui.limited_updates_button:
            self.limited_updates_button = snack.SingleRadioButton(optiontext1,
                                                None, isOn = 1)
        else:
            self.limited_updates_button = snack.SingleRadioButton(optiontext1,
                                                None)

        toplevel.add(self.limited_updates_button, 0, 2, padding = (0, 1, 0, 1),
                     anchorLeft = 1)

        self.sublabel = snack.Label(_(" Minor Release: "))
        toplevel.add(self.sublabel, 0, 4, anchorLeft = 1)

        self.channelList = snack.Listbox(self.size[1]-22, 1, 
	                         width = self.size[0]-10)
        toplevel.add(self.channelList, 0, 5)

        for key, value in self.available_channels['channels'].items():
            if key in self.available_channels['receiving_updates']:
                value = value + "*"
            self.channelList.append(" " + value, key)

        self.tip = snack.TextboxReflowed(self.size[0]-10, CHANNEL_PAGE_TIP)
        toplevel.add(self.tip, 0, 6, anchorLeft = 1)

        optiontext2 = _("All available updates")

        if self.tui.all_updates_button:
            self.all_updates_button = snack.SingleRadioButton(optiontext2, 
                                            self.limited_updates_button, isOn=1)
        else:
            self.all_updates_button = snack.SingleRadioButton(optiontext2, 
                                            self.limited_updates_button)
            
        toplevel.add(self.all_updates_button, 0, 7, padding = (0, 0, 0, 1),
                     anchorLeft = 1)

        #self.warning = snack.TextboxReflowed(self.size[0]-10, 
        #                     CHANNEL_PAGE_WARNING)
        #toplevel.add(self.warning, 0, 9, anchorLeft = 1)


        self.bb = snack.ButtonBar(screen,
                          [(NEXT, "next"),
                           (BACK, "back"),
                           (CANCEL, "cancel")])
        toplevel.add(self.bb, 0, 9, growx = 1)

        self.screen.refresh()

        

    def run(self):
        log.log_debug("Running %s" % self.__class__.__name__)
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
         
        title = _("Confirm operating system release selection")
        if later_release:
            msgbox = snack.ButtonChoiceWindow(self.screen, title,
                           CONFIRM_OS_WARNING % self.channelList.current(),
			   buttons =[OK, CANCEL])
            return msgbox

        if self.all_updates_button.selected() or later_release:
	    CONFIRM_OS_ALL = _("Your system will be subscribed to the base"
                               " software channel to receive all available"
                               " updates.")
            msgbox = snack.ButtonChoiceWindow(self.screen, title,
                                  CONFIRM_OS_ALL, buttons =[OK, CANCEL])
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

    def __init__(self, screen, tui):
        self.name = "HardwareWindow"
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
        
        toplevel = snack.GridForm(screen, _("Register a System Profile - Hardware"),
                                  1, 8)

        text = snack.TextboxReflowed(70, _("A Profile Name is a descriptive name that you choose to identify this System Profile on the Red Hat Network web pages. Optionally, include a computer serial or identification number."))

        toplevel.add(text, 0, 0, anchorLeft = 1)

        grid = snack.Grid(2, 2)

        label = snack.Label(_("Profile name:"))
        grid.setField(label, 0, 0, padding = (0, 0, 1, 0), anchorRight = 1)

        self.profileEntry = snack.Entry(40)
        grid.setField(self.profileEntry, 1, 0, anchorLeft = 1)

        toplevel.add(grid, 0, 1, anchorLeft = 1)
        
        if tui.includeHardware:
            self.hardwareButton = snack.Checkbox(_("Include the following information about hardware and network:"), isOn = 1)
        else:
            self.hardwareButton = snack.Checkbox(_("Include the following information about hardware and network:"))
            
        toplevel.add(self.hardwareButton, 0, 2, padding = (0, 1, 0, 0),
                     anchorLeft = 1)

        label = snack.Label(DESELECT)
        toplevel.add(label, 0, 3, anchorLeft = 1, padding = (0, 0, 0, 1))

        grid = snack.Grid(4, 3)
        hardware_text = ''

        hardware_text += _("Version: ") + up2dateUtils.getVersion() + "  "
        self.versionLabel = snack.Label(_("Version: "))
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
                hardware_text += hw['hostname'] + "\n"

                if tui.profileName != "":
                    self.profileEntry.set(tui.profileName)
                else:
                    self.profileEntry.set(hw['hostname'])

        hardware_text += _("CPU speed: ")

        for hw in tui.hardware:            
            if hw['class'] == 'CPU':
                hardware_text += _("%d MHz") % hw['speed'] + "  "

        hardware_text += _("IP Address: ")

        for hw in tui.hardware:
            if hw['class'] == 'NETINFO':
                hardware_text += hw['ipaddr'] + "  "

        hardware_text += _("Memory: ")

        for hw in tui.hardware:
            if hw['class'] == 'MEMORY':
                hardware_text += _("%s megabytes") % hw['ram']

        tb = snack.TextboxReflowed(80, hardware_text)
        toplevel.add(tb, 0, 4)

        self.additionalHWLabel = snack.TextboxReflowed(size[0]-10, _("Additional hardware information including PCI devices, disk sizes and mount points will be included in the profile."))

        toplevel.add(self.additionalHWLabel, 0, 5, padding = (0, 1, 0, 0),
                     anchorLeft = 1)
        
        # BUTTON BAR
        self.bb = snack.ButtonBar(screen,
                                  [(NEXT, "next"),
                                   (BACK, "back"),
                                   (CANCEL, "cancel")])
        toplevel.add(self.bb, 0, 6, padding = (0, 1, 0, 0),
                     growx = 1)

        self.g = toplevel

        # self.screen.gridWrappedWindow(toplevel, 'HardwareWindow', 80, 14)

    def saveResults(self):
        self.tui.profileName = self.profileEntry.value()
        self.tui.includeHardware = self.hardwareButton.selected()

    def run(self):
        log.log_debug("Running %s" % self.__class__.__name__)
        result = self.g.runOnce()
        button = self.bb.buttonPressed(result)

        if result == "F12":
            return "next"
        return button

class PackagesWindow:

    def __init__(self, screen, tui):
        self.name = "PackagesWindow"
        self.screen = screen
        self.tui = tui
        size = snack._snack.size()
        toplevel = snack.GridForm(screen, _("Register a System Profile - Packages"),
                                  1, 7)
        self.g = toplevel


        text = snack.TextboxReflowed(size[0]-10, _("RPM information is important to determine what updated software packages are relevant to this system."))

        toplevel.add(text, 0, 1, anchorLeft = 1)

        self.packagesButton = snack.Checkbox(_("Include RPM packages installed on this system in my System Profile"), 1)
        toplevel.add(self.packagesButton, 0, 2, padding = (0, 1, 0, 1),
                     anchorLeft = 1)

        label = snack.Label(_("You may deselect individual packages by unchecking them below."))
        toplevel.add(label, 0, 3, anchorLeft = 1)

        #self.packageList = snack.Listbox(size[1]-18, 1, width = size[0]-10)
        self.packageList = snack.CheckboxTree(size[1]-18, 1)
        toplevel.add(self.packageList, 0, 4)

        # do we need to read the packages from disk?
        if tui.packageList == []:
            self.pwin = snack.GridForm(screen, _("Building Package List"),
                               1, 1)

            self.scale = snack.Scale(40, 100)
            self.pwin.add(self.scale, 0, 0)
            self.pwin.draw()
            self.screen.refresh()
            getArch = 0
            if rhnreg.cfg['supportsExtendedPackageProfile']:
                getArch = 1
            tui.packageList = rpmUtils.getInstalledPackageList(getArch=getArch)
            self.screen.popWindow()

        for package in tui.packageList:
            self.packageList.append("%s-%s-%s" % (package['name'],
                                                  package['version'],
                                                  package['release']),
                                                  item = package['name'],
                                                  selected = 1)
            
        # BUTTON BAR
        self.bb = snack.ButtonBar(screen,
                                  [(NEXT, "next"),
                                   (BACK, "back"),
                                   (CANCEL, "cancel")])
        toplevel.add(self.bb, 0, 5, padding = (0, 1, 0, 0),
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
        log.log_debug("Running %s" % self.__class__.__name__)
        result = self.g.runOnce()
        button = self.bb.buttonPressed(result)

        if result == "F12":
            return "next"
        return button

class SendWindow:

    def __init__(self, screen, tui):
        self.screen = screen
        self.tui = tui
        self.name = "SendWindow"
        size = snack._snack.size()
        
        toplevel = snack.GridForm(screen, _("Send Profile Information to Red Hat Network"),
                                  1, 2)

        text = snack.TextboxReflowed(size[0]-15, SEND_WINDOW)
        toplevel.add(text, 0, 0)

        # BUTTON BAR
        self.bb = snack.ButtonBar(screen,
                                  [(NEXT, "next"),
                                   (BACK, "back"),
                                   (CANCEL, "cancel")])
        toplevel.add(self.bb, 0, 1, padding = (0, 1, 0, 0),
                     growx = 1)

        self.g = toplevel

    def saveResults(self):
        pass


    def run(self):
        log.log_debug("Running %s" % self.__class__.__name__)
        result = self.g.runOnce()
        button = self.bb.buttonPressed(result)

        if result == "F12":
            return "next"
        return button

class FinishWindow:

    def __init__(self, screen, tui):
        self.name = "FinishWindow"
        self.screen = screen
        self.tui = tui
        size = snack._snack.size()
        
        toplevel = snack.GridForm(screen, FINISH_WINDOW,
                                  1, 2)

        text = snack.TextboxReflowed(size[0]-11, FINISH_WINDOW_TEXT_TUI)
        toplevel.add(text, 0, 0)
        
        # BUTTON BAR
        self.bb = snack.ButtonBar(screen,
                                  [(_("Finish"), "next")])
        toplevel.add(self.bb, 0, 1, padding = (0, 1, 0, 0),
                     growx = 1)

        self.g = toplevel

        self.pwin = snack.GridForm(screen, _("Sending Profile to Red Hat Network"),
                                   1, 1)

        self.scale = snack.Scale(40, 100)
        self.pwin.add(self.scale, 0, 0)
        self.pwin.draw()
        self.screen.refresh()

        reg_info = None
        try:
            if self.tui.serverType == 'hosted':
                self.tui._activate_hardware()

            # reg_info dict contains: 'system_id', 'channels', 
            # 'failed_channels', 'slots', 'failed_slots'
            log.log_debug('other is %s' % str(self.tui.other))

            reg_info = rhnreg.registerSystem2(tui.userName, tui.password,
                                             tui.profileName, 
                                             other = self.tui.other)
            reg_info = reg_info.rawDict
            
            if isinstance(reg_info['system_id'], unicode):
                systemId = unicode.encode(reg_info['system_id'], 'utf-8')
            else:
                systemId = reg_info['system_id']
                
        except up2dateErrors.CommunicationError, e:
            FatalErrorWindow(self.screen, 
                             _("Problem registering system:\n") + e.errmsg)
        except up2dateErrors.RhnUuidUniquenessError, e:
            FatalErrorWindow(self.screen, 
                             _("Problem registering system:\n") + e.errmsg)
        except up2dateErrors.InsuffMgmntEntsError, e:
            FatalErrorWindow(self.screen,
                             _("Problem registering system:\n") + e.errmsg)
        except up2dateErrors.ActivationKeyUsageLimitError, e:
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
        
        # dont send if already registered, do send if they have oemInfo
        if ( not self.tui.alreadyRegistered ) or ( len(self.oemInfo)):
            # send product registration information
            if rhnreg.cfg['supportsUpdateContactInfo']:
                try:
                    rhnreg.updateContactInfo(tui.userName, tui.password,  self.tui.productInfo)
                except up2dateErrors.CommunicationError, e:
                    FatalErrorWindow(self.screen, _("Problem registering personal information:\n") + e.errmsg)
                except:
                    print sys.exc_info()
                    print sys.exc_type
                    
                    FatalErrorWindow(self.screen, 
                                     _("Problem registering personal information"))
                    
            else:
                rhnreg.registerProduct(systemId, self.tui.productInfo,self.tui.oemInfo)
                try:
                    rhnreg.registerProduct(systemId, self.tui.productInfo,self.tui.oemInfo)
                except up2dateErrors.CommunicationError, e:
                    FatalErrorWindow(self.screen, 
                                     _("Problem registering personal information:\n") + 
                                     e.errmsg)
                except:
                    log.log_exception(*sys.exc_info())
                    FatalErrorWindow(self.screen, _("Problem registering personal information"))

        self.setScale(2, 4)

        # maybe upload hardware profile
        if tui.includeHardware:
            try:
                rhnreg.sendHardware(systemId, tui.hardware)
            except up2dateErrors.CommunicationError, e:
                FatalErrorWindow(self.screen,
                                 _("Problem sending hardware profile:\n") + e.errmsg)
            except:
                log.log_exception(*sys.exc_info())
                FatalErrorWindow(self.screen,
                                 _("Problem sending hardware profile."))

        self.setScale(3, 4)

        # build up package list if necessary
        if tui.includePackages:
            try:
                rhnreg.sendPackages(systemId, tui.selectedPackages)
            except up2dateErrors.CommunicationError, e:
                FatalErrorWindow(self.screen, _("Problem sending package list:\n") + e.errmsg)
            except:
                log.log_exception(*sys.exc_info())
                FatalErrorWindow(self.screen, _("Problem sending package list."))

        li = None
        try:
            li = up2dateAuth.updateLoginInfo()
        except up2dateErrors.InsuffMgmntEntsError, e:
            FatalErrorWindow(self.screen, e)

        rhnreg.spawnRhnCheckForUI() 
        self.setScale(4, 4)
        
        # Review Window
        rw = ReviewWindow(self.screen, self.tui, reg_info)
        rw_results = rw.run()

        # Pop the pwin (Progress bar window)
        self.screen.popWindow()

    def setScale(self, amount, total):
        self.scale.set(int(((amount * 1.0)/ total) * 100))
        self.pwin.draw()
        self.screen.refresh()


    def saveResults(self):
        pass


    def run(self):
        log.log_debug("Running %s" % self.__class__.__name__)
        result = self.g.runOnce()
        button = self.bb.buttonPressed(result)

        if result == "F12":
            return "next"
        return button

class ReviewWindow:

    def __init__(self, screen, tui, reg_info):
        self.name = "ReviewWindow"
        self.screen = screen
        self.tui = tui
        self.reg_info = reg_info
        size = snack._snack.size()
        
        toplevel = snack.GridForm(screen, REVIEW_WINDOW, 1, 2)
    
        # Build up the review_window_text based on the data in self.reg_info
        review_window_text = REVIEW_WINDOW_PROMPT + "\n\n"
        
        if self.tui.other['registration_number'] and \
           not self.tui.non_entitling_num_on_disk and \
           not self.tui.invalid_num_on_disk:
            review_window_text += SUBSCRIPTIONS + "\n"

            # Test if we successfully activated an installation number
            if self.tui.activate_result.getStatus() == \
               rhnreg.ActivationResult.ACTIVATED_NOW:
                
                # Say we activated the #, and what it activated.
                review_window_text += SUB_NUM % \
                                      self.tui.other['registration_number'] + "\n\n"

                channels = self.tui.activate_result.getChannelsActivated()
                system_slots = self.tui.activate_result.getSystemSlotsActivated()
                log.log_debug('channels is %s' % channels)
                log.log_debug('slots is %s' % system_slots)

                seen = 0
                text = ""
                for channel in channels.keys():
                    seen = 1
                    text += channel + _(", quantity:") + \
                            str(channels[channel]) + "\n"

                for system_slot in system_slots.keys():
                    seen = 1
                    text += system_slot + _(", quantity:") + \
                            str(system_slots[system_slot]) + "\n"

                if seen:
                    review_window_text += SUB_NUM_RESULT + "\n\n"
                    review_window_text += text + "\n\n"

            # This is the case where we read the num from disk and it was
            # already activated.
            elif self.tui.activate_result.getStatus() == \
                 rhnreg.ActivationResult.ALREADY_USED and \
                 self.tui.read_reg_num:
                  review_window_text += INST_NUM_ON_DISK + "\n\n"

        elif self.tui.read_reg_num and len(self.tui.read_reg_num) > 0 and \
             not self.tui.non_entitling_num_on_disk and \
             not self.tui.invalid_num_on_disk:
            # If we get here, it means we read a # off disk, but it wasn't a
            # valid num
            review_window_text += INST_NUM_ON_DISK_NA + "\n\n"
            
        # Create and add the text for what channels the system was
        # subscribed to.
        if len(self.reg_info['channels']) > 0:
            channel_list = ""
            for channel in self.reg_info['channels']:
                channel_list += channel + "\n"

            channels = CHANNELS_TITLE + "\n" + \
                       OK_CHANNELS + "\n" + \
                       "%s\n" 

            # If it's hosted, reference the hosted url,
            # otherwise, we don't know the url for their sat.
            log.log_debug("server type is %s " % self.tui.serverType)
            if self.tui.serverType == 'hosted':
                channels += CHANNELS_HOSTED_WARNING
            else:
                channels += CHANNELS_SAT_WARNING

            review_window_text += channels % channel_list + "\n\n"
            
        if len(self.reg_info['system_slots']) > 0:
            slot_list = ""
            for slot in self.reg_info['system_slots']:
                if slot == 'enterprise_entitled':
                    slot_list += MANAGEMENT + "\n"
                elif slot == 'provisioning_entitled':
                    slot_list += PROVISIONING + "\n"
                elif slot == 'sw_mgr_entitled':
                    slot_list += UPDATES + "\n"
                elif slot == 'monitoring_entitled':
                    slot_list += MONITORING + "\n"
                elif slot == 'virtualization_host':
                    slot_list += VIRT + "\n"
                elif slot == 'virtualization_host_platform':
                    slot_list += VIRT_PLATFORM + "\n"
                else:
                    slot_list += slot + "\n"
            review_window_text += SLOTS % slot_list + "\n\n"
            
        if len(self.reg_info['universal_activation_key']) > 0:
            act_key_list = ""
            for act_key in self.reg_info['universal_activation_key']:
                act_key_list += act_key
            review_window_text += ACTIVATION_KEY % (act_key_list)
            
        self.review_window = snack.Textbox(size[0]-10, size[1]-14, review_window_text, 1, 1)
    
        toplevel.add(self.review_window, 0, 0, padding = (0, 1, 0, 0))
        
        # BUTTON BAR
        self.bb = snack.ButtonBar(screen, [(OK, "ok")])
        toplevel.add(self.bb, 0, 1, padding = (0, 1, 0, 0),
                     growx = 1)

        self.g = toplevel

    def saveResults(self):
        return 1

    def run(self):
        log.log_debug("Running %s" % self.__class__.__name__)
        result = self.g.runOnce()
        button = self.bb.buttonPressed(result)

        if result == "F12":
            return "ok"
            
        return button    
    
class Tui:

    def __init__(self, screen):
        self.screen = screen
        self.size = snack._snack.size()
        self.drawFrame()
        self.alreadyRegistered = 0
        try:
            self.serverType = rhnreg.getServerType()
        except up2dateErrors.InvalidProtocolError:
            FatalErrorWindow(screen, _("You specified an invalid protocol." +
                                     "Only https and http are allowed."))

        self.windows = [
            ConnectWindow,
            StartWindow,
            InfoWindow,
            OSReleaseWindow,
            HardwareWindow,
            PackagesWindow,
            SendWindow,
            FinishWindow
            ]

        # if serverUrl is a list in the config, only reference the first one
        # when we need it
        if type(cfg['serverURL']) == type([]):
            self.serverURL = cfg['serverURL'][0]
        else:
            self.serverURL = cfg['serverURL']
        
        if not cfg['sslCACert']:
            # Always use the path from the cert if available, else set to 
            # default location
            if self.serverType == "hosted":
                cfg.set('sslCACert', '/usr/share/rhn/RHNS-CA-CERT')
            else:
                cfg.set('sslCACert', '/usr/share/rhn/RHN-ORG-TRUSTED-SSL-CERT') 
       
    def __del__(self):
        self.screen.finish()


    def drawFrame(self):
        self.welcomeText = COPYRIGHT_TEXT
        self.screen.drawRootText(0, 0, self.welcomeText)
        self.screen.pushHelpLine(_("  <Tab>/<Alt-Tab> between elements  |  <Space> selects  |  <F12> next screen"))


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

        self.activate_result = {}           
        self.invalid_num_on_disk = 0
        self.other = {} 
        self.other['registration_number'] = ''
        
        self.profileName = ""
        self.includeHardware = 1
        self.hostname = ""
        self.ip = ""
        self.cpu = ""
        self.speed = 0
        self.ram = ""
        self.os_release = ""
        self.activated_now = 0
        self.non_entitling_num_on_disk = 0
        
        self.limited_updates_button = 1
        self.all_updates_button = 0
        self.includePackages = 0
        self.packageList = []
        self.selectedPackages = []
        self.read_reg_num = None

        self.saw_sub_window = 0

    def _activate_IN_on_disk(self, inst_num):
        # Activate the #
        # Only send up org_id if it exists.
        try:
            if self.other.has_key('org_id'):
                self.activate_result = \
                             rhnreg.activateRegistrationNumber(
                             self.userName, self.password, 
                             inst_num,
                             self.other['org_id'])
            else:
                self.activate_result = \
                             rhnreg.activateRegistrationNumber(
                             self.userName, self.password, 
                             inst_num)

            if self.activate_result.getStatus() == \
               rhnreg.ActivationResult.ACTIVATED_NOW:
                self.activated_now = 1

        except up2dateErrors.InvalidRegistrationNumberError:
            self.invalid_num_on_disk = 1
        except up2dateErrors.NotEntitlingError:
            self.non_entitling_num_on_disk = 1
 
    def _activate_hardware(self):

        # Read the asset code from the hardware.
        activateHWResult = None
        hardwareInfo = None
        try:
            hardwareInfo = hardware.get_hal_system_and_smbios()
        except:
            log.log_me("There was an error while reading the hardware "
                       "info from the bios. Traceback:\n")
            log.log_exception(*sys.exc_info())

        if hardwareInfo is not None:
            try:
                # Only send up org_id if it exists.
                if self.other.has_key('org_id'):
                    activateHWResult = rhnreg.activateHardwareInfo(
                                           self.userName, self.password, 
                                           hardwareInfo, self.other['org_id'])
                else:
                    activateHWResult = rhnreg.activateHardwareInfo(
                                           self.userName, self.password, 
                                           hardwareInfo)
                if activateHWResult.getStatus() == \
                   rhnreg.ActivationResult.ACTIVATED_NOW:
                    self.other['registration_number'] = \
                        activateHWResult.getRegistrationNumber()
                    rhnreg.writeRegNum(self.other['registration_number'])
                    self.activated_now = 1
            except up2dateErrors.NotEntitlingError:
                log.log_debug('There are are no entitlements associated '
                              'with this hardware.')
            except up2dateErrors.InvalidRegistrationNumberError:
                log.log_debug('The hardware id was not recognized as valid.')

    def run(self):
        log.log_debug("Running %s" % self.__class__.__name__)
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

                if result == "back":
                    if index > 0:
                        index = index - 1

                    direction = "backward"

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


    if rhnreg.registered() and not test:


        systemIdXml = rpclib.xmlrpclib.loads(up2dateAuth.getSystemId())
        oldUsername = systemIdXml[0][0]['username']
        oldsystemId = systemIdXml[0][0]['system_id']
        if type(cfg['serverURL']) == type([]):
            oldserver = cfg['serverURL'][0]
        else:
            oldserver = cfg['serverURL']

        if snack.ButtonChoiceWindow(screen, 
                                    _("System software updates already set up"),
                                    SYSTEM_ALREADY_REGISTERED + "\n\n"
                                    + _("Red Hat Network Location:") + " " + oldserver + "\n"
                                    + _("Login:") + " " + oldUsername + "\n"
                                    + _("System ID:") + " " + oldsystemId + "\n\n"
                                    + SYSTEM_ALREADY_REGISTERED_CONT + "\n",
                                    buttons = [YES_CONT, NO_CANCEL],
                                    width = 75,
                                    ) == string.lower(NO_CANCEL):
            
            screen.finish()
            sys.exit(1)
        
    tui = Tui(screen)
    tui.run()

    
if __name__ == "__main__":
    main()
