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
from up2date_client import up2dateErrors

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
        self.priority = 106.5
        self.sidebarTitle = _("Choose Server")
        self.title = _("Choose Server")

    def needsNetwork(self):
        return True

    def apply(self, interface, testing=False):
        if testing:
            return RESULT_SUCCESS

        try:
            if self.chooseServerPage.chooseServerPageApply() is False:
                interface.moveToPage(moduleTitle=_("Red Hat Login"))
                return RESULT_JUMP
            else:
                return RESULT_FAILURE
        except up2dateErrors.SSLCertificateVerifyFailedError:
            interface.moveToPage(moduleTitle=_("Provide Certificate"))
            return RESULT_JUMP
            # return RESULT_SUCCESS should work just as well since the
            # certificate page with priority 107 is the next one anyway

    def createScreen(self):
        self.chooseServerPage = rhnregGui.ChooseServerPage()
        self.vbox = gtk.VBox(spacing=5)
        self.vbox.pack_start(self.chooseServerPage.chooseServerPageVbox(), True, True)

    def initializeUI(self):
        self.chooseServerPage.chooseServerPagePrepare()

    def shouldAppear(self):
        if rhnreg.registered():
            return False
        return True

