# rhn_register.py - GUI front end code for firstboot screen resolution
#
# Copyright 2003 Red Hat, Inc.
# Copyright 2003 Brent Fox <bfox@redhat.com>
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

import gtk
import gobject
import sys
import os
import functions

import gnome, gnome.ui
from gtk import glade

from rhn_register_firstboot_gui_window import RhnRegisterFirstbootGuiWindow
sys.path.insert(0, "/usr/share/rhn/up2date_client/")
sys.path.insert(1,"/usr/share/rhn")

import rhnreg
import rhnregGui
import up2dateErrors
import messageWindow

import gettext
_ = gettext.gettext

gettext.textdomain("rhn-client-tools")
gtk.glade.bindtextdomain("rhn-client-tools")


class RhnActivateWindow(RhnRegisterFirstbootGuiWindow, rhnregGui.ActivateSubscriptionPage):
    #You must specify a runPriority for the order in which you wish your module to run
    runPriority = 108.5
    moduleName = _("Access Subscription")
    windowTitle =  moduleName
    shortMessage = _("Connect to Red Hat Network")
    needsparent = 1
    needsnetwork = 1
    noSidebar = True

    def __init__(self):
        RhnRegisterFirstbootGuiWindow.__init__(self)
        rhnregGui.ActivateSubscriptionPage.__init__(self)
        if rhnreg.registered():
            self.skipme = True

    def updatePage(self):
        self.activateSubscriptionPagePrepare()
    
    def _getVbox(self):
        return self.activateSubscriptionPageVbox()

    def apply(self, *args):
        """Returns None if the page shouldn't be advanced."""
        ret =  self.activateSubscriptionPageVerify()
        if ret:
            return None
        return True

childWindow = RhnActivateWindow
