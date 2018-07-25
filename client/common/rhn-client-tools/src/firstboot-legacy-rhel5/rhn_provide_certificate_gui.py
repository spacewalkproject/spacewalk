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


class RhnProvideCertificateWindow(RhnRegisterFirstbootGuiWindow, rhnregGui.ProvideCertificatePage):
    runPriority=107
    moduleName = _("Provide Certificate")
    windowTitle = moduleName
    shortMessage = _("Provide a certificate for this Red Hat Satellite server")
    needsparent = 1
    needsnetwork = 1
    noSidebar = True

    def __init__(self):
        RhnRegisterFirstbootGuiWindow.__init__(self)
        rhnregGui.ProvideCertificatePage.__init__(self)
        if rhnreg.registered():
            self.skipme = True

    def _getVbox(self):
        return self.provideCertificatePageVbox()

    def apply(self, *args):
        """Returns True to change the page or None to stay on the same page."""
        status = self.provideCertificatePageApply()
        if status == 0: # cert was installed
            return True
        elif status == 1: # the user doesn't want to provide a cert right now
            # TODO write a message to disk like the other cases? need to decide
            # how we want to do error handling in general.
            self.parent.setPage("rhn_finish_gui")
            return True
        else: # an error occurred and the user was notified
            assert status == 2
            return None


childWindow = RhnProvideCertificateWindow
