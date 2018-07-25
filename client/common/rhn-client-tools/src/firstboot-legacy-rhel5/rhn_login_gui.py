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

import gettext
t = gettext.translation('rhn-client-tools', fallback=True)
_ = t.ugettext
gtk.glade.bindtextdomain("rhn-client-tools", "/usr/share/locale")



class RhnLoginWindow(RhnRegisterFirstbootGuiWindow, rhnregGui.LoginPage):
    #You must specify a runPriority for the order in which you wish your module to run
    runPriority = 108
    moduleName = _("Red Hat Login")
    windowTitle = moduleName
    shortMessage = _("Register with Red Hat Satellite")
    needsparent = 1
    needsnetwork = 1
    noSidebar = True

    def __init__(self):
        RhnRegisterFirstbootGuiWindow.__init__(self)
        rhnregGui.LoginPage.__init__(self)
        if rhnreg.registered():
            self.skipme = True

    def updatePage(self):
#        self.getCaps()
        self.loginPagePrepare()
        self.goingNextFromNewAccountDialog = False

    def grabFocus(self):
        # We must set focus where we want it here. Setting it in updatePage
        # doesn't work.
        self.loginXml.get_widget("loginUserEntry").grab_focus()

    def _getVbox(self):
        return self.loginPageVbox()

    def apply(self, *args):
        """Returns None to stay on the same page. Anything else will cause
        firstboot to advance but True is generally used. This is different from
        the gnome druid in rhn_register.

        """
        if self.doDebug:
            print("applying rhn_login_gui")

        # This is a hack. This function will get called if they click next on
        # the login page (the else) or when they create an account (the if). In
        # that case we don't want to do the normal logging in stuff.
        if self.goingNextFromNewAccountDialog:
            assert rhnregGui.newAccount is True
        else:
            if self.loginPageVerify():
                return None

            assert rhnregGui.newAccount is False

            if self.loginPageApply():
                return None

        # We should try to activate hardware, even if no EUS in firstboot
        rhnregGui.try_to_activate_hardware()

        self.parent.setPage('rhn_create_profile_gui')
        return True

    def goToPageAfterLogin(self):
        # This is a hack. More info above.
        self.goingNextFromNewAccountDialog = True
        self.parent.nextClicked()

    def onLoginPageNext(self, dummy=None, dummy2=None):
        # This is a hackish way to support enter advancing
        self.parent.nextClicked()

childWindow = RhnLoginWindow
