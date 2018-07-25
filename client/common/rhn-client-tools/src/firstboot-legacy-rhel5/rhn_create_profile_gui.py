# rhn_register.py - GUI front end code for firstboot screen resolution
#
# Copyright 2003 Red Hat, Inc.
# Copyright 2003 Brent Fox <bfox@redhat.com>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; version 2 of the License.
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
import os
import functions

import gnome, gnome.ui
from gtk import glade

from rhn_register_firstboot_gui_window import RhnRegisterFirstbootGuiWindow
from up2date_client import rhnreg
from up2date_client import rhnregGui
from up2date_client import up2dateErrors
from up2date_client import messageWindow

import gettext
t = gettext.translation('rhn-client-tools', fallback=True)
_ = t.ugettext
gtk.glade.bindtextdomain("rhn-client-tools")


class RhnCreateProfileWindow(RhnRegisterFirstbootGuiWindow, rhnregGui.CreateProfilePage):
    #You must specify a runPriority for the order in which you wish your module to run
    runPriority = 108.7
    moduleName = _("Create Profile")
    windowTitle =  moduleName
    shortMessage = _("Connect to Red Hat Satellite")
    needsparent = 1
    needsnetwork = 1
    noSidebar = True

    def __init__(self):
        RhnRegisterFirstbootGuiWindow.__init__(self)
        rhnregGui.CreateProfilePage.__init__(self)
        if rhnreg.registered():
            self.skipme = True

    def updatePage(self):
        self.createProfilePagePrepare()

    def _getVbox(self):
        return self.createProfilePageVbox()

    def apply(self, *args):

        ret =  self.createProfilePageVerify()
        if ret:
            return None

        ret = self.createProfilePageApply()
        if ret:
            return None

        return True

childWindow = RhnCreateProfileWindow
