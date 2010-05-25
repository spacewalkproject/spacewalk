# Copyright 2003--2010 Red Hat, Inc.
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
# Authors:
#     Jan Pazdziora jpazdziora at redhat dot com

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
        self.priority = 108.7
        self.sidebarTitle = _("Create Profile")
        self.title = _("Create Profile")

    def needsNetwork(self):
        return True

    def apply(self, interface, testing=False):
        if testing:
            return RESULT_SUCCESS

        ret = self.createProfilePage.createProfilePageVerify()
        if ret:
            return RESULT_FAILURE

        ret = self.createProfilePage.createProfilePageApply()
        if ret:
            return RESULT_FAILURE
        
        return RESULT_SUCCESS

    def createScreen(self):
        self.createProfilePage = rhnregGui.CreateProfilePage()
        self.vbox = gtk.VBox(spacing=5)
        self.vbox.pack_start(self.createProfilePage.createProfilePageVbox(), True, True)

    def initializeUI(self):
        self.createProfilePage.createProfilePagePrepare()

    def shouldAppear(self):
        if rhnreg.registered():
            return False
        return True

