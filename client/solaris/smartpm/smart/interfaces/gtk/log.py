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
from smart.const import ERROR, WARNING, DEBUG
from smart.interfaces.gtk import getPixbuf
from smart import *
import gtk, gobject
import locale

ENCODING = locale.getpreferredencoding()

class GtkLog(gtk.Window):

    def __init__(self):
        gtk.Window.__init__(self)
        self.__gobject_init__()

        self.set_icon(getPixbuf("smart"))
        self.set_title(_("Log"))
        self.set_geometry_hints(min_width=400, min_height=300)
        self.set_modal(True)

        self._vbox = gtk.VBox()
        self._vbox.set_border_width(10)
        self._vbox.set_spacing(10)
        self._vbox.show()
        self.add(self._vbox)

        self._scrollwin = gtk.ScrolledWindow()
        self._scrollwin.set_policy(gtk.POLICY_AUTOMATIC, gtk.POLICY_AUTOMATIC)
        self._scrollwin.set_shadow_type(gtk.SHADOW_IN)
        self._scrollwin.show()
        self._vbox.add(self._scrollwin)

        self._textview = gtk.TextView()
        self._textview.set_editable(False)
        self._textview.show()
        self._scrollwin.add(self._textview)

        self._buttonbox = gtk.HButtonBox()
        self._buttonbox.set_spacing(10)
        self._buttonbox.set_layout(gtk.BUTTONBOX_END)
        self._buttonbox.show()
        self._vbox.pack_start(self._buttonbox, expand=False, fill=False)

        self._clearbutton = gtk.Button(stock="gtk-clear")
        self._clearbutton.show()
        self._clearbutton.connect("clicked",
                                  lambda x: self._textview.get_buffer()
                                                         .set_text(""))
        self._buttonbox.pack_start(self._clearbutton)

        self._closebutton = gtk.Button(stock="gtk-close")
        self._closebutton.show()
        self._closebutton.connect("clicked", lambda x: self.hide())
        self._buttonbox.pack_start(self._closebutton)

    def isVisible(self):
        return self.get_property("visible")

    def message(self, level, msg):
        prefix = {ERROR: _("error"), WARNING: _("warning"),
                  DEBUG: _("debug")}.get(level)
        buffer = self._textview.get_buffer()
        iter = buffer.get_end_iter()
        if not isinstance(msg, unicode):
            msg = msg.decode(ENCODING)
        if prefix:
            for line in msg.split("\n"):
                buffer.insert(iter, "%s: %s\n" % (prefix, line))
        else:
            buffer.insert(iter, msg)
        buffer.insert(iter, "\n")

        if level == ERROR:
            dialog = gtk.MessageDialog(self, flags=gtk.DIALOG_MODAL,
                                       type=gtk.MESSAGE_ERROR,
                                       buttons=gtk.BUTTONS_OK,
                                       message_format=msg)
            dialog.run()
            dialog.hide()
            del dialog
        else:
            self.show()

gobject.type_register(GtkLog)

