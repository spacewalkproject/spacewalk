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

from up2date_client import rhnreg
from up2date_client import rhnregGui
from rhn_register_firstboot_gui_window import RhnRegisterFirstbootGuiWindow

import gtk
from gtk import glade
import gettext
t = gettext.translation('rhn-client-tools', fallback=True)
_ = t.ugettext
gtk.glade.bindtextdomain("rhn-client-tools")


class RhnReviewWindow(RhnRegisterFirstbootGuiWindow, rhnregGui.ReviewSubscriptionPage):
    runPriority=108.9
    moduleName = _("Review Subscription")
    windowTitle = moduleName
    shortMessage = _("Connect to Red Hat Satellite")
    needsparent = 1
    needsnetwork = 1
    noSidebar = True

    def __init__(self):
        RhnRegisterFirstbootGuiWindow.__init__(self)
        rhnregGui.ReviewSubscriptionPage.__init__(self)
        if rhnreg.registered():
            self.skipme = True

    def _getVbox(self):
        return self.reviewSubscriptionPageVbox()

    def updatePage(self):
        self.reviewSubscriptionPagePrepare()

    def apply(self, *args):
        """Returns None to stay on the same page. Anything else will cause
        firstboot to advance but True is generally used. This is different from
        the gnome druid in rhn_register.

        """
        return True


childWindow = RhnReviewWindow
