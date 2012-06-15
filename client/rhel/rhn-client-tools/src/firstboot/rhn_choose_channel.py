# Copyright 2011 Red Hat, Inc.
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
# Authors:
#     Miroslav Suchy <msuchy@redhat.com>

import sys
sys.path.append("/usr/share/rhn")
from up2date_client import rhnreg, rhnregGui, rhnserver

import gtk

import gettext
_ = lambda x: gettext.ldgettext("rhn-client-tools", x)

gtk.glade.bindtextdomain("rhn-client-tools")

from firstboot.module import Module
from firstboot.constants import RESULT_SUCCESS, RESULT_FAILURE, RESULT_JUMP

class moduleClass(Module):
    def __init__(self):
        Module.__init__(self)
        self.priority = 108.6
        self.sidebarTitle = _("Select operating system release")
        self.title = _("Select operating system release")
        self.chooseChannel = FirstbootChooseChannelPage()

    def needsNetwork(self):
        return True

    def apply(self, interface, testing=False):
        if testing:
            return RESULT_SUCCESS

        self.chooseChannel.chooseChannelPageApply()
        return RESULT_SUCCESS

    def createScreen(self):
        self.vbox = gtk.VBox(spacing=5)
        self.vbox.pack_start(self.chooseChannel.chooseChannelPageVbox(), True, True)

    def initializeUI(self):
        # populate capability - needef for EUSsupported
        s = rhnserver.RhnServer()
        s.capabilities.validate()

        # this populate zstream channels as side effect
        self.chooseChannel.chooseChannelShouldBeShown()

        self.chooseChannel.chooseChannelPagePrepare()

    def shouldAppear(self):
        return not rhnreg.registered()

class FirstbootChooseChannelPage(rhnregGui.ChooseChannelPage):
    pass
