#
# Copyright (c) 2004 Conectiva, Inc.
#
# Written by Gustavo Niemeyer <niemeyer@conectiva.com>
#
# This file is part of Smart Package Manager.
#
# Smart Package Manager is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as published
# by the Free Software Foundation; either version 2 of the License, or (at
# your option) any later version.
#
# Smart Package Manager is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Smart Package Manager; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#
from smart.interfaces.gtk.interface import GtkInterface
from smart.interfaces.gtk import getPixbuf
from smart import *
import time
import gtk

class GtkCommandInterface(GtkInterface):

    def __init__(self, ctrl):
        GtkInterface.__init__(self, ctrl)
        self._status = GtkStatus()

    def showStatus(self, msg):
        self._status.show(msg)
        while gtk.events_pending():
            gtk.main_iteration()

    def hideStatus(self):
        self._status.hide()
        while gtk.events_pending():
            gtk.main_iteration()

    def run(self, command=None, argv=None):
        result = GtkInterface.run(self, command, argv)        
        self._status.wait()
        while self._log.isVisible():
            time.sleep(0.1)
            while gtk.events_pending():
                gtk.main_iteration()
        return result

class GtkStatus(object):

    def __init__(self):
        self._window = gtk.Window()
        self._window.set_icon(getPixbuf("smart"))
        self._window.set_title(_("Status"))
        self._window.set_modal(True)
        self._window.set_position(gtk.WIN_POS_CENTER)
        self._window.set_border_width(20)

        self._label = gtk.Label()
        self._label.show()
        self._window.add(self._label)

        self._lastshown = 0

    def show(self, msg):
        self._label.set_text(msg)
        self._window.show()
        self._lastshown = time.time()
        while gtk.events_pending():
            gtk.main_iteration()

    def hide(self):
        self._window.hide()

    def isVisible(self):
        return self._window.get_property("visible")

    def wait(self):
        while self.isVisible() and self._lastshown+3 > time.time():
            time.sleep(0.3)
            while gtk.events_pending():
                gtk.main_iteration()

# vim:ts=4:sw=4:et
