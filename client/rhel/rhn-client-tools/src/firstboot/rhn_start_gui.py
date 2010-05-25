# Copyright 2006--2010 Red Hat, Inc.
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
#     Jan Pazdziora jpazdziora at redhat dot com
#     Daniel Benamy <dbenamy@redhat.com>

import sys
sys.path.append("/usr/share/rhn")
from up2date_client import rhnreg
from up2date_client import rhnregGui

import gtk
from gtk import glade

import gettext
_ = lambda x: gettext.ldgettext("rhn-client-tools", x)

gtk.glade.bindtextdomain("rhn-client-tools")

from firstboot.module import Module
from firstboot.constants import *

from firstboot.loader import _haveNetwork

class moduleClass(Module):
    def __init__(self):
        Module.__init__(self)
        self.priority = 106
        self.sidebarTitle = _("Set Up Software Updates")
        self.title = _("Set Up Software Updates")

    def apply(self, interface, testing=False):
        if testing:
            return RESULT_SUCCESS

        if not self.start_page.startPageRegisterNow():
            dlg = rhnregGui.ConfirmQuitDialog()
            if dlg.rc == 0:
                return RESULT_FAILURE
            else:
                interface.moveToPage(moduleTitle=_("Finish Updates Setup"))
                return RESULT_JUMP
        return RESULT_SUCCESS

    def createScreen(self):
        self.vbox = gtk.VBox(spacing=5)
        self.vbox.pack_start(self._getVbox(), True, True)

    def initializeUI(self):
        pass

    def _getVbox(self):
        if rhnreg.registered():
            self.start_page = KsRegisteredPage()
            return self.start_page.startPageVbox()
        if _haveNetwork():
            self.start_page = rhnregGui.StartPage(firstboot=True)
        else:
            self.start_page = NoNetworkPage()
        return self.start_page.startPageVbox()
    
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

