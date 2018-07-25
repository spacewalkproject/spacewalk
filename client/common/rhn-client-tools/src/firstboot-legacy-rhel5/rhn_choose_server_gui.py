# Copyright 2006 Red Hat, Inc.
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
# Authors:
#     Daniel Benamy <dbenamy@redhat.com>

import os
from up2date_client import rhnreg
from up2date_client import rhnregGui
from up2date_client import up2dateErrors
from rhn_register_firstboot_gui_window import RhnRegisterFirstbootGuiWindow

import gtk
from gtk import glade
import gettext
t = gettext.translation('rhn-client-tools', fallback=True)
_ = t.ugettext

gtk.glade.bindtextdomain("rhn-client-tools")


class RhnChooseServerWindow(RhnRegisterFirstbootGuiWindow, rhnregGui.ChooseServerPage):
    runPriority=106.5
    moduleName = _("Choose Server")
    windowTitle = moduleName
    shortMessage = _("Choose a Red Hat Satellite server")
    needsparent = 1
    needsnetwork = 1
    noSidebar = True

    def __init__(self):
        RhnRegisterFirstbootGuiWindow.__init__(self)
        rhnregGui.ChooseServerPage.__init__(self)
        if rhnreg.registered():
            self.skipme = True

    def _getVbox(self):
        return self.chooseServerPageVbox()

    def updatePage(self):
        self.chooseServerPagePrepare()

    def apply(self, *args):
        """Returns True to change the page (to the one set)."""
        try:
            if self.chooseServerPageApply() is False:
                self.parent.setPage("rhn_login_gui")
                return True
            else:
                return None
        except up2dateErrors.SSLCertificateVerifyFailedError:
            self.parent.setPage("rhn_provide_certificate_gui")
            return True


childWindow = RhnChooseServerWindow
