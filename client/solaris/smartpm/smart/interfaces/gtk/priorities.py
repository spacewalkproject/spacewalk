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
from smart.channel import getChannelInfo
from smart import *
import gobject, gtk

class GtkPriorities(object):

    def __init__(self, parent=None):

        self._window = gtk.Window()
        self._window.set_icon(getPixbuf("smart"))
        self._window.set_title(_("Priorities"))
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

        self._treemodel = gtk.ListStore(gobject.TYPE_STRING,
                                        gobject.TYPE_STRING,
                                        gobject.TYPE_STRING)
        self._treeview = gtk.TreeView(self._treemodel)
        self._treeview.set_rules_hint(True)
        self._treeview.show()
        sw.add(self._treeview)

        self._namerenderer = gtk.CellRendererText()
        self._namerenderer.set_property("xpad", 3)
        self._namerenderer.set_property("editable", True)
        self._namerenderer.connect("edited", self.rowEdited)
        self._treeview.insert_column_with_attributes(-1, _("Package Name"),
                                                     self._namerenderer,
                                                     text=0)

        self._aliasrenderer = gtk.CellRendererText()
        self._aliasrenderer.set_property("xpad", 3)
        self._aliasrenderer.set_property("editable", True)
        self._aliasrenderer.connect("edited", self.rowEdited)
        self._treeview.insert_column_with_attributes(-1, _("Channel Alias"),
                                                     self._aliasrenderer,
                                                     text=1)

        self._priorityrenderer = gtk.CellRendererText()
        self._priorityrenderer.set_property("xpad", 3)
        self._priorityrenderer.set_property("editable", True)
        self._priorityrenderer.connect("edited", self.rowEdited)
        self._treeview.insert_column_with_attributes(-1, _("Priority"),
                                                     self._priorityrenderer,
                                                     text=2)

        bbox = gtk.HButtonBox()
        bbox.set_spacing(10)
        bbox.set_layout(gtk.BUTTONBOX_END)
        bbox.show()
        vbox.pack_start(bbox, expand=False)

        button = gtk.Button(stock="gtk-new")
        button.show()
        button.connect("clicked", lambda x: self.newPriority())
        bbox.pack_start(button)

        button = gtk.Button(stock="gtk-delete")
        button.show()
        button.connect("clicked", lambda x: self.delPriority())
        bbox.pack_start(button)

        button = gtk.Button(stock="gtk-close")
        button.show()
        button.connect("clicked", lambda x: gtk.main_quit())
        bbox.pack_start(button)

    def fill(self):
        self._treemodel.clear()
        priorities = sysconf.get("package-priorities", {})
        prioritieslst = priorities.items()
        prioritieslst.sort()
        for name, pkgpriorities in prioritieslst:
            aliaslst = pkgpriorities.items()
            aliaslst.sort()
            for alias, priority in aliaslst:
                self._treemodel.append((name, alias or "*", str(priority)))

    def show(self):
        self.fill()
        self._window.show()
        gtk.main()
        self._window.hide()

    def newPriority(self):
        name, alias, priority = PriorityCreator().show()
        if name:
            if sysconf.has(("package-priorities", name, alias)):
                iface.error(_("Name/alias pair already exists!"))
            else:
                sysconf.set(("package-priorities", name, alias), int(priority))
                self.fill()

    def delPriority(self):
        selection = self._treeview.get_selection()
        model, iter = selection.get_selected()
        if iter:
            name = model.get_value(iter, 0)
            alias = model.get_value(iter, 1)
            if alias == "*":
                alias = None
            sysconf.remove(("package-priorities", name, alias))
            self.fill()

    def rowEdited(self, cell, row, newtext):
        newtext = newtext.strip()
        if cell is self._namerenderer:
            col = 0
        elif cell is self._aliasrenderer:
            col = 1
            if newtext == "*":
                newtext = ""
        else:
            col = 2
        model = self._treemodel
        iter = model.get_iter_from_string(row)
        oldtext = model.get_value(iter, col)
        if newtext != oldtext:
            if col == 0:
                alias = model.get_value(iter, 1)
                if alias == "*":
                    alias = None
                priority = model.get_value(iter, 2)
                if not newtext:
                    pass
                elif sysconf.has(("package-priorities", newtext, alias)):
                    iface.error(_("Name/alias pair already exists!"))
                else:
                    sysconf.set(("package-priorities", newtext, alias),
                                int(priority))
                    sysconf.remove(("package-priorities", oldtext, alias))
                    model.set_value(iter, col, newtext)
            elif col == 1:
                name = model.get_value(iter, 0)
                priority = model.get_value(iter, 2)
                if sysconf.has(("package-priorities", name, newtext)):
                    iface.error(_("Name/alias pair already exists!"))
                else:
                    sysconf.move(("package-priorities", name, oldtext),
                                 ("package-priorities", name, newtext))
                    model.set_value(iter, col, newtext or "*")
            elif col == 2:
                if newtext:
                    name = model.get_value(iter, 0)
                    alias = model.get_value(iter, 1)
                    if alias == "*":
                        alias = None
                    try:
                        sysconf.set(("package-priorities", name, alias),
                                    int(newtext))
                    except ValueError:
                        iface.error(_("Invalid priority!"))
                    else:
                        model.set_value(iter, col, newtext)

class PriorityCreator(object):

    def __init__(self):

        self._window = gtk.Window()
        self._window.set_icon(getPixbuf("smart"))
        self._window.set_title(_("New Package Priority"))
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

        label = gtk.Label(_("Package Name:"))
        label.set_alignment(1.0, 0.5)
        label.show()
        table.attach(label, 0, 1, 0, 1, gtk.FILL, gtk.FILL)

        self._name = gtk.Entry()
        self._name.show()
        table.attach(self._name, 1, 2, 0, 1, gtk.EXPAND|gtk.FILL, gtk.FILL)

        label = gtk.Label(_("Channel Alias:"))
        label.set_alignment(1.0, 0.0)
        label.show()
        table.attach(label, 0, 1, 1, 2, gtk.FILL, gtk.FILL)

        self._alias = gtk.Entry()
        self._alias.set_text("*")
        self._alias.show()
        table.attach(self._alias, 1, 2, 1, 2, gtk.EXPAND|gtk.FILL, gtk.FILL)

        label = gtk.Label(_("Priority:"))
        label.set_alignment(1.0, 0.0)
        label.show()
        table.attach(label, 0, 1, 2, 3, gtk.FILL, gtk.FILL)

        self._priority = gtk.SpinButton()
        self._priority.set_width_chars(8)
        self._priority.set_increments(1, 10)
        self._priority.set_numeric(True)
        self._priority.set_range(-100000,+100000)
        self._priority.show()
        align = gtk.Alignment(0.0, 0.5)
        align.show()
        align.add(self._priority)
        table.attach(align, 1, 2, 2, 3, gtk.EXPAND|gtk.FILL, gtk.FILL)

        sep = gtk.HSeparator()
        sep.show()
        vbox.pack_start(sep, expand=False)

        bbox = gtk.HButtonBox()
        bbox.set_spacing(10)
        bbox.set_layout(gtk.BUTTONBOX_END)
        bbox.show()
        vbox.pack_start(bbox, expand=False)

        button = gtk.Button(stock="gtk-ok")
        button.show()
        def clicked(x):
            self._result = True
            gtk.main_quit()
        button.connect("clicked", clicked)
        bbox.pack_start(button)

        button = gtk.Button(stock="gtk-cancel")
        button.show()
        button.connect("clicked", lambda x: gtk.main_quit())
        bbox.pack_start(button)

    def show(self):

        self._window.show()

        self._result = False
        while True:
            gtk.main()
            if self._result:
                self._result = False
                name = self._name.get_text().strip()
                if not name:
                    iface.error(_("No name provided!"))
                    continue
                alias = self._alias.get_text().strip()
                if alias == "*":
                    alias = None
                priority = self._priority.get_value()
                break
            name = alias = priority = None
            break

        self._window.hide()

        return name, alias, priority

class GtkSinglePriority(object):

    def __init__(self, parent=None):

        self._window = gtk.Window()
        self._window.set_icon(getPixbuf("smart"))
        self._window.set_title(_("Package Priority"))
        self._window.set_modal(True)
        self._window.set_transient_for(parent)
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

        self._table = gtk.Table()
        self._table.set_row_spacings(10)
        self._table.set_col_spacings(10)
        self._table.show()
        vbox.pack_start(self._table)

        bbox = gtk.HButtonBox()
        bbox.set_spacing(10)
        bbox.set_layout(gtk.BUTTONBOX_END)
        bbox.show()
        vbox.pack_start(bbox, expand=False)

        button = gtk.Button(stock="gtk-close")
        button.show()
        button.connect("clicked", lambda x: gtk.main_quit())
        bbox.pack_start(button)

    def show(self, pkg):

        priority = sysconf.get(("package-priorities", pkg.name), {})

        table = self._table
        table.foreach(table.remove)

        label = gtk.Label(_("Package:"))
        label.set_alignment(1.0, 0.5)
        label.show()
        table.attach(label, 0, 1, 0, 1, gtk.FILL, gtk.FILL)

        label = gtk.Label()
        label.set_markup("<b>%s</b>" % pkg.name)
        label.set_alignment(0.0, 0.5)
        label.show()
        table.attach(label, 1, 2, 0, 1, gtk.FILL, gtk.FILL)

        def toggled(check, spin, alias):
            if check.get_active():
                priority[alias] = int(spin.get_value())
                spin.set_sensitive(True)
            else:
                if alias in priority:
                    del priority[alias]
                spin.set_sensitive(False)

        def value_changed(spin, alias):
            priority[alias] = int(spin.get_value())

        label = gtk.Label(_("Default priority:"))
        label.set_alignment(1.0, 0.5)
        label.show()
        table.attach(label, 0, 1, 1, 2, gtk.FILL, gtk.FILL)

        hbox = gtk.HBox()
        hbox.set_spacing(10)
        hbox.show()
        table.attach(hbox, 1, 2, 1, 2, gtk.FILL, gtk.FILL)

        radio = gtk.RadioButton(None, _("Channel default"))
        radio.set_active(None not in priority)
        radio.show()
        hbox.pack_start(radio, expand=False)

        radio = gtk.RadioButton(radio, _("Set to"))
        radio.set_active(None in priority)
        radio.show()
        hbox.pack_start(radio, expand=False)
        spin = gtk.SpinButton()
        if None not in priority:
            spin.set_sensitive(False)
        spin.set_increments(1, 10)
        spin.set_numeric(True)
        spin.set_range(-100000,+100000)
        spin.set_value(priority.get(None, 0))
        spin.connect("value-changed", value_changed, None)
        radio.connect("toggled", toggled, spin, None)
        spin.show()
        hbox.pack_start(spin, expand=False)

        label = gtk.Label(_("Channel priority:"))
        label.set_alignment(1.0, 0.0)
        label.show()
        table.attach(label, 0, 1, 2, 3, gtk.FILL, gtk.FILL)

        chantable = gtk.Table()
        chantable.set_row_spacings(10)
        chantable.set_col_spacings(10)
        chantable.show()
        table.attach(chantable, 1, 2, 2, 3, gtk.FILL, gtk.FILL)

        pos = 0
        channels = sysconf.get("channels")
        for alias in channels:
            channel = channels[alias]
            if not getChannelInfo(channel.get("type")).kind == "package":
                continue
            name = channel.get("name")
            if not name:
                name = alias
            check = gtk.CheckButton(name)
            check.set_active(alias in priority)
            check.show()
            chantable.attach(check, 0, 1, pos, pos+1, gtk.FILL, gtk.FILL)
            spin = gtk.SpinButton()
            if alias not in priority:
                spin.set_sensitive(False)
            spin.set_increments(1, 10)
            spin.set_numeric(True)
            spin.set_range(-100000,+100000)
            spin.set_value(int(priority.get(alias, 0)))
            spin.connect("value_changed", value_changed, alias)
            check.connect("toggled", toggled, spin, alias)
            spin.show()
            chantable.attach(spin, 1, 2, pos, pos+1, gtk.FILL, gtk.FILL)
            pos += 1

        self._window.show()
        gtk.main()
        self._window.hide()

        if not priority:
            sysconf.remove(("package-priorities", pkg.name))
        else:
            sysconf.set(("package-priorities", pkg.name), priority)
