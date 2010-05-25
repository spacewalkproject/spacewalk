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

class moduleClass(Module):
    def __init__(self):
        Module.__init__(self)
        self.priority = 107.5
        self.sidebarTitle = _("Provide Certificate")
        self.title = _("Provide Certificate")

    def needsNetwork(self):
        return True

    def apply(self, interface, testing=False):
        if testing:
            return RESULT_SUCCESS

        status = self.provideCertificatePage.provideCertificatePageApply()
        if status == 0: # cert was installed
            return RESULT_SUCCESS
        elif status == 1: # the user doesn't want to provide a cert right now
            # TODO write a message to disk like the other cases? need to decide 
            # how we want to do error handling in general.
            interface.moveToPage(moduleTitle=_("Finish Updates Setup"))
            return RESULT_JUMP
        else: # an error occurred and the user was notified
            assert status == 2
            return RESULT_FAILURE

    def createScreen(self):
        self.provideCertificatePage = rhnregGui.ProvideCertificatePage()
        self.vbox = gtk.VBox(spacing=5)
        self.vbox.pack_start(self.provideCertificatePage.provideCertificatePageVbox(), True, True)

    def initializeUI(self):
        self.provideCertificatePage.setUrlInWidget()

    def shouldAppear(self):
        if rhnreg.registered():
            return False
        return True

