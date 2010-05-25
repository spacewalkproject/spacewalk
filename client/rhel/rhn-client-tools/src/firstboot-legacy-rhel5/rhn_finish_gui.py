# Copyright 2006 Red Hat, Inc.
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
#     Daniel Benamy <dbenamy@redhat.com>

import sys
sys.path.append("/usr/share/rhn/up2date_client/")
sys.path.append("/usr/share/rhn")
import rhnreg
import rhnregGui
from rhn_register_firstboot_gui_window import RhnRegisterFirstbootGuiWindow
import config

import gtk
from gtk import glade
import gettext
_ = gettext.gettext

gettext.textdomain("rhn-client-tools")
gtk.glade.bindtextdomain("rhn-client-tools")


class RhnFinishWindow(RhnRegisterFirstbootGuiWindow, rhnregGui.FinishPage):
    runPriority=109
    moduleName = _("Finish Updates Setup")
    windowTitle = moduleName
    shortMessage = _("Connect to Red Hat Network")
    needsparent = 1
    needsnetwork = 1
    noSidebar = True
    
    def __init__(self):
        RhnRegisterFirstbootGuiWindow.__init__(self)
        rhnregGui.FinishPage.__init__(self)
        if rhnreg.registered():
            self.skipme = True
    
    def _getVbox(self):
        return self.finishPageVbox()
    
    def updatePage(self):
##        if rhnregGui.hasBaseChannelAndUpdates():
##            self.druid.finish.set_label(_("_Finish"))
##            title = _("Finish setting up software updates")
##        else:
##            self.druid.finish.set_label(_("_Exit registration process"))
##            title = _("Registration unsuccessful")
        self.finishPagePrepare()
##        self.mainWin.set_title(title)
##        self.finishPage.set_title(title)
    
    def apply(self, *args):
        """Returns None to stay on the same page. Anything else will cause 
        firstboot to advance but True is generally used. This is different from 
        the gnome druid in rhn_register.
        
        """
        up2DateConfig = config.initUp2dateConfig()
        up2DateConfig.save()
        return True


childWindow = RhnFinishWindow
