# Copyright 2006 Red Hat, Inc.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
#
# Authors:
#     Daniel Benamy <dbenamy@redhat.com>

import os
import sys
sys.path.append("/usr/share/rhn/up2date_client/")
sys.path.append("/usr/share/rhn")
import rhnreg
import rhnregGui
from rhn_register_firstboot_gui_window import RhnRegisterFirstbootGuiWindow

import gtk
from gtk import glade
import gettext
_ = gettext.gettext

gettext.textdomain("rhn-client-tools")
gtk.glade.bindtextdomain("rhn-client-tools")


class RhnStartWindow(RhnRegisterFirstbootGuiWindow):
    runPriority=106
    moduleName = _("Set Up Software Updates")
    windowTitle = moduleName
    shortMessage = _("Register with Red Hat Network")
    needsparent = 1
    
    def __init__(self):
        RhnRegisterFirstbootGuiWindow.__init__(self)
        self.start_page = None

    def _getVbox(self):
        if rhnreg.registered():
            self.start_page = KsRegisteredPage()
            return self.start_page.startPageVbox()
        if self.parent.checkNetwork():
            self.start_page = rhnregGui.StartPage(firstboot=True)
        else:
            self.start_page = NoNetworkPage()
        return self.start_page.startPageVbox()
    
    def apply(self, *args):
        """Returns True to change the page (to the one set)."""
        if not self.start_page.startPageRegisterNow():
            dlg = rhnregGui.ConfirmQuitDialog()
            if not dlg.rc:
                self.parent.setPage("rhn_start_gui") 
            else:
                self.parent.setPage("rhn_finish_gui")
        return True

class KsRegisteredPage:

    def __init__(self):
        gladefile = "/usr/share/rhn/up2date_client/rh_register.glade"
        ksRegisteredXml = gtk.glade.XML(gladefile, "ksRegisteredFirstbootVbox",
              domain="rhn-client-tools")
        self.vbox = ksRegisteredXml.get_widget('ksRegisteredFirstbootVbox')

    def startPageVbox(self):
        return self.vbox

    def startPageRegisterNow(self):
        return True


class NoNetworkPage:

    def __init__(self):
        gladefile = "/usr/share/rhn/up2date_client/rh_register.glade"
        noNetworkXml = gtk.glade.XML(gladefile, "noNetworkFirstbootVbox",
            domain="rhn-client-tools")
        self.vbox = noNetworkXml.get_widget('noNetworkFirstbootVbox')
        noNetworkXml.signal_autoconnect({
            "on_whyRegisterButton_clicked" : self.why_register_button_clicked,
        })

    def startPageVbox(self):
        return self.vbox

    def startPageRegisterNow(self):
        # Sure, we'll register now. heh heh heh
        # Just continue on past the rhn stuff.
        return True

    def why_register_button_clicked(self, button):
        rhnregGui.WhyRegisterDialog()

childWindow = RhnStartWindow
