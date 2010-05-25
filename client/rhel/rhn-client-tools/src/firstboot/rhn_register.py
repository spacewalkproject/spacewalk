# Copyright 2010 Red Hat, Inc.
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

from firstboot.moduleset import *

import gettext
_ = lambda x: gettext.ldgettext("rhn-client-tools", x)

class moduleClass(ModuleSet):
    def __init__(self):
        ModuleSet.__init__(self)
        self.priority = 2
        self.sidebarTitle = _("Set Up Software Updates")
        self.title = _("Set Up Software Updates")
        self.path = "/usr/share/rhn/up2date_client/firstboot"

