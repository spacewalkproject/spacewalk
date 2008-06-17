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
from smart.interfaces.gtk import getPixbuf
from smart import *
import gobject, gtk

class GtkMirrors(object):

    def __init__(self, parent=None):

        self._window = gtk.Window()
        self._window.set_icon(getPixbuf("smart"))
        self._window.set_title(_("Mirrors"))
        self._window.set_modal(True)
        self._window.set_transient_for(parent)
        self._window.set_position(gtk.WIN_POS_CENTER)
        self._window.set_geometry_hints(min_width=600, min_height=400)
        def delete(widget, event):
            gtk.main_quit()
            return True
        self._window.connect("delete-event", delete)

        vbox = gtk.VBox()
        vbox.set_border_width(10)
        vbox.set_spacing(10)
        vbox.show()
        self._window.add(vbox)

        sw = gtk.ScrolledWindow()
        sw.set_policy(gtk.POLICY_AUTOMATIC, gtk.POLICY_ALWAYS)
        sw.set_shadow_type(gtk.SHADOW_IN)
        sw.show()
        vbox.add(sw)

        self._treemodel = gtk.TreeStore(gobject.TYPE_STRING)
        self._treeview = gtk.TreeView(self._treemodel)
        self._treeview.set_rules_hint(True)
        self._treeview.set_headers_visible(False)
        self._treeview.show()
        sw.add(self._treeview)

        renderer = gtk.CellRendererText()
        renderer.set_property("xpad", 3)
        renderer.set_property("editable", True)
        renderer.connect("edited", self.rowEdited)
        self._treeview.insert_column_with_attributes(-1, _("Mirror"), renderer,
                                                     text=0)

        bbox = gtk.HButtonBox()
        bbox.set_spacing(10)
        bbox.set_layout(gtk.BUTTONBOX_END)
        bbox.show()
        vbox.pack_start(bbox, expand=False)

        button = gtk.Button(stock="gtk-new")
        button.show()
        button.connect("clicked", lambda x: self.newMirror())
        bbox.pack_start(button)

        button = gtk.Button(stock="gtk-delete")
        button.show()
        button.connect("clicked", lambda x: self.delMirror())
        bbox.pack_start(button)

        button = gtk.Button(stock="gtk-close")
        button.show()
        button.connect("clicked", lambda x: gtk.main_quit())
        bbox.pack_start(button)

    def fill(self):
        self._treemodel.clear()
        mirrors = sysconf.get("mirrors", {})
        for origin in mirrors:
            parent = self._treemodel.append(None, (origin,))
            for mirror in mirrors[origin]:
                iter = self._treemodel.append(parent, (mirror,))
        self._treeview.expand_all()
            
    def show(self):
        self.fill()
        self._window.show()
        gtk.main()
        self._window.hide()

    def newMirror(self):
        selection = self._treeview.get_selection()
        model, iter = selection.get_selected()
        if iter:
            path = model.get_path(iter)
            if len(path) == 2:
                iter = model.get_iter(path[:1])
            origin = model.get_value(iter, 0)
        else:
            origin = ""
        origin, mirror = MirrorCreator().show(origin)
        if origin and mirror:
            sysconf.add(("mirrors", origin), mirror, unique=True)
        self.fill()


    def delMirror(self):
        selection = self._treeview.get_selection()
        model, iter = selection.get_selected()
        if not iter:
            return
        path = model.get_path(iter)
        if len(path) == 1:
            origin = model.get_value(iter, 0)
            sysconf.remove(("mirrors", origin))
        else:
            mirror = model.get_value(iter, 0)
            iter = model.get_iter(path[:1])
            origin = model.get_value(iter, 0)
            sysconf.remove(("mirrors", origin), mirror)
        self.fill()

    def rowEdited(self, cell, row, newtext):
        model = self._treemodel
        iter = model.get_iter_from_string(row)
        path = model.get_path(iter)
        oldtext = model.get_value(iter, 0)
        if newtext == oldtext:
            return
        if len(path) == 1:
            if sysconf.has(("mirrors", newtext)):
                iface.error(_("Origin already exists!"))
            else:
                sysconf.move(("mirrors", oldtext), ("mirrors", newtext))
                model.set_value(iter, 0, newtext)
        else:
            origin = model.get_value(model.get_iter(path[1:]), 0)
            if sysconf.has(("mirrors", origin), newtext):
                iface.error(_("Mirror already exists!"))
            else:
                sysconf.remove(("mirrors", origin), oldtext)
                sysconf.add(("mirrors", origin), newtext, unique=True)
                model.set_value(iter, 0, newtext)

class MirrorCreator(object):

    def __init__(self):

        self._window = gtk.Window()
        self._window.set_icon(getPixbuf("smart"))
        self._window.set_title(_("New Mirror"))
        self._window.set_modal(True)
        self._window.set_position(gtk.WIN_POS_CENTER)
        #self._window.set_geometry_hints(min_width=600, min_height=400)
        def delete(widget, event):
            gtk.main_quit()
            return True
        self._window.connect("delete-event", delete)

        vbox = gtk.VBox()
        vbox.set_border_width(10)
        vbox.set_spacing(10)
        vbox.show()
        self._window.add(vbox)

        table = gtk.Table()
        table.set_row_spacings(10)
        table.set_col_spacings(10)
        table.show()
        vbox.pack_start(table)
        
        label = gtk.Label(_("Origin URL:"))
        label.set_alignment(1.0, 0.5)
        label.show()
        table.attach(label, 0, 1, 0, 1, gtk.FILL, gtk.FILL)

        self._origin = gtk.Entry()
        self._origin.set_width_chars(40)
        self._origin.show()
        table.attach(self._origin, 1, 2, 0, 1, gtk.EXPAND|gtk.FILL, gtk.FILL)

        label = gtk.Label(_("Mirror URL:"))
        label.set_alignment(1.0, 0.5)
        label.show()
        table.attach(label, 0, 1, 1, 2, gtk.FILL, gtk.FILL)

        self._mirror = gtk.Entry()
        self._mirror.set_width_chars(40)
        self._mirror.show()
        table.attach(self._mirror, 1, 2, 1, 2, gtk.EXPAND|gtk.FILL, gtk.FILL)

        sep = gtk.HSeparator()
        sep.show()
        vbox.pack_start(sep, expand=False)

        bbox = gtk.HButtonBox()
        bbox.set_spacing(10)
        bbox.set_layout(gtk.BUTTONBOX_END)
        bbox.show()
        vbox.pack_start(bbox, expand=False)

        self._okbutton = gtk.Button(stock="gtk-ok")
        self._okbutton.show()
        def clicked(x):
            self._result = True
            gtk.main_quit()
        self._okbutton.connect("clicked", clicked)
        bbox.pack_start(self._okbutton)

        self._cancelbutton = gtk.Button(stock="gtk-cancel")
        self._cancelbutton.show()
        self._cancelbutton.connect("clicked", lambda x: gtk.main_quit())
        bbox.pack_start(self._cancelbutton)

    def show(self, origin="", mirror=""):

        self._origin.set_text(origin)
        self._mirror.set_text(mirror)
        origin = mirror = None

        self._window.show()

        self._result = False
        while True:
            gtk.main()
            if self._result:
                self._result = False
                origin = self._origin.get_text().strip()
                if not origin:
                    iface.error(_("No origin provided!"))
                    continue
                mirror = self._mirror.get_text().strip()
                if not mirror:
                    iface.error(_("No mirror provided!"))
                    continue
                break
            origin = mirror = None
            break

        self._window.hide()

        return origin, mirror

# vim:ts=4:sw=4:et
