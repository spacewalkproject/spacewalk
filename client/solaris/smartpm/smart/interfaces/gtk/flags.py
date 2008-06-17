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
import re

TARGETRE = re.compile(r"^\s*(\S+?)\s*(?:([<>=]+)\s*(\S+))?\s*$")

class GtkFlags(object):

    def __init__(self, parent=None):

        self._window = gtk.Window()
        self._window.set_icon(getPixbuf("smart"))
        self._window.set_title(_("Flags"))
        self._window.set_modal(True)
        self._window.set_transient_for(parent)
        self._window.set_position(gtk.WIN_POS_CENTER)
        self._window.set_geometry_hints(min_width=600, min_height=400)
        def delete(widget, event):
            gtk.main_quit()
            return True
        self._window.connect("delete-event", delete)

        topvbox = gtk.VBox()
        topvbox.set_border_width(10)
        topvbox.set_spacing(10)
        topvbox.show()
        self._window.add(topvbox)

        tophbox = gtk.HBox()
        tophbox.set_spacing(20)
        tophbox.show()
        topvbox.add(tophbox)

        # Left side
        vbox = gtk.VBox()
        tophbox.set_spacing(10)
        vbox.show()
        tophbox.pack_start(vbox)

        sw = gtk.ScrolledWindow()
        sw.set_policy(gtk.POLICY_AUTOMATIC, gtk.POLICY_ALWAYS)
        sw.set_shadow_type(gtk.SHADOW_IN)
        sw.show()
        vbox.add(sw)

        self._flagsmodel = gtk.ListStore(gobject.TYPE_STRING)
        self._flagsview = gtk.TreeView(self._flagsmodel)
        self._flagsview.set_rules_hint(True)
        self._flagsview.show()
        sw.add(self._flagsview)

        selection = self._flagsview.get_selection()
        selection.connect("changed", self.flagSelectionChanged)

        renderer = gtk.CellRendererText()
        renderer.set_property("xpad", 3)
        renderer.set_property("editable", True)
        renderer.connect("edited", self.flagEdited)
        self._flagsview.insert_column_with_attributes(-1, _("Flags"), renderer,
                                                      text=0)

        bbox = gtk.HButtonBox()
        bbox.set_border_width(5)
        bbox.set_spacing(10)
        bbox.set_layout(gtk.BUTTONBOX_SPREAD)
        bbox.show()
        vbox.pack_start(bbox, expand=False)

        button = gtk.Button(stock="gtk-new")
        button.connect("clicked", lambda x: self.newFlag())
        button.show()
        bbox.pack_start(button)

        button = gtk.Button(stock="gtk-delete")
        button.connect("clicked", lambda x: self.delFlag())
        button.show()
        bbox.pack_start(button)
        self._delflag = button

        # Right side
        vbox = gtk.VBox()
        tophbox.set_spacing(10)
        vbox.show()
        tophbox.pack_start(vbox)

        sw = gtk.ScrolledWindow()
        sw.set_policy(gtk.POLICY_AUTOMATIC, gtk.POLICY_ALWAYS)
        sw.set_shadow_type(gtk.SHADOW_IN)
        sw.show()
        vbox.add(sw)

        self._targetsmodel = gtk.ListStore(gobject.TYPE_STRING)
        self._targetsview = gtk.TreeView(self._targetsmodel)
        self._targetsview.set_rules_hint(True)
        self._targetsview.show()
        sw.add(self._targetsview)

        selection = self._targetsview.get_selection()
        selection.connect("changed", self.targetSelectionChanged)

        renderer = gtk.CellRendererText()
        renderer.set_property("xpad", 3)
        renderer.set_property("editable", True)
        renderer.connect("edited", self.targetEdited)
        self._targetsview.insert_column_with_attributes(-1, _("Targets"),
                                                        renderer, text=0)

        bbox = gtk.HButtonBox()
        bbox.set_border_width(5)
        bbox.set_spacing(10)
        bbox.set_layout(gtk.BUTTONBOX_SPREAD)
        bbox.show()
        vbox.pack_start(bbox, expand=False)

        button = gtk.Button(stock="gtk-new")
        button.set_property("sensitive", False)
        button.connect("clicked", lambda x: self.newTarget())
        button.show()
        bbox.pack_start(button)
        self._newtarget = button

        button = gtk.Button(stock="gtk-delete")
        button.set_property("sensitive", False)
        button.connect("clicked", lambda x: self.delTarget())
        button.show()
        bbox.pack_start(button)
        self._deltarget = button


        # Bottom
        sep = gtk.HSeparator()
        sep.show()
        topvbox.pack_start(sep, expand=False)

        bbox = gtk.HButtonBox()
        bbox.set_spacing(10)
        bbox.set_layout(gtk.BUTTONBOX_END)
        bbox.show()
        topvbox.pack_start(bbox, expand=False)

        button = gtk.Button(stock="gtk-close")
        button.connect("clicked", lambda x: gtk.main_quit())
        button.show()
        bbox.pack_start(button)

    def fillFlags(self):
        self._flagsmodel.clear()
        flaglst = pkgconf.getFlagNames()
        flaglst.sort()
        for flag in flaglst:
            self._flagsmodel.append((flag,))
    
    def fillTargets(self):
        self._targetsmodel.clear()
        if self._flag:
            names = pkgconf.getFlagTargets(self._flag)
            namelst = names.keys()
            namelst.sort()
            for name in namelst:
                for relation, version in names[name]:
                    if relation and version:
                        self._targetsmodel.append(("%s %s %s" %
                                                   (name, relation, version),))
                    else:
                        self._targetsmodel.append((name,))

    def show(self):
        self.fillFlags()
        self._window.show()
        gtk.main()
        self._window.hide()

    def newFlag(self):
        flag = FlagCreator().show()
        if flag:
            if pkgconf.flagExists(flag):
                iface.error(_("Flag already exists!"))
            else:
                pkgconf.createFlag(flag)
                self.fillFlags()

    def newTarget(self):
        target = TargetCreator().show()
        if target:
            m = TARGETRE.match(target)
            if m:
                name, relation, version = m.groups()
                pkgconf.setFlag(self._flag, name, relation, version)
            self.fillTargets()

    def delFlag(self):
        selection = self._flagsview.get_selection()
        model, iter = selection.get_selected()
        if iter:
            pkgconf.clearFlag(self._flag)
            self.fillFlags()
            self.fillTargets()

    def delTarget(self):
        selection = self._targetsview.get_selection()
        model, iter = selection.get_selected()
        if iter:
            target = model.get_value(iter, 0)
            m = TARGETRE.match(target)
            if not m:
                iface.error(_("Invalid target!"))
            else:
                name, relation, version = m.groups()
                pkgconf.clearFlag(self._flag, name, relation, version)
                if not pkgconf.flagExists(self._flag):
                    self.fillFlags()
                else:
                    self.fillTargets()

    def flagEdited(self, cell, row, newtext):
        model = self._flagsmodel
        iter = model.get_iter_from_string(row)
        oldtext = model.get_value(iter, 0)
        if newtext != oldtext:
            if pkgconf.flagExists(newtext):
                iface.error(_("Flag already exists!"))
            else:
                pkgconf.renameFlag(oldtext, newtext)
                model.set_value(iter, 0, newtext)

    def targetEdited(self, cell, row, newtext):
        model = self._targetsmodel
        iter = model.get_iter_from_string(row)
        oldtext = model.get_value(iter, 0)
        if newtext != oldtext:
            m = TARGETRE.match(oldtext)
            if not m:
                iface.error(_("Invalid target!"))
            else:
                oldname, oldrelation, oldversion = m.groups()
                m = TARGETRE.match(newtext)
                if not m:
                    iface.error(_("Invalid target!"))
                else:
                    newname, newrelation, newversion = m.groups()
                    pkgconf.clearFlag(self._flag, oldname,
                                      oldrelation, oldversion)
                    pkgconf.setFlag(self._flag, newname,
                                    newrelation, newversion)
                    if newrelation and newversion:
                        model.set_value(iter, 0, "%s %s %s" %
                                        (newname, newrelation, newversion))
                    else:
                        model.set_value(iter, 0, newname)

    def flagSelectionChanged(self, selection):
        model, iter = selection.get_selected()
        self._delflag.set_property("sensitive", bool(iter))
        self._newtarget.set_property("sensitive", bool(iter))
        if iter:
            self._flag = model.get_value(iter, 0)
        else:
            self._flag = None
        self.fillTargets()

    def targetSelectionChanged(self, selection):
        model, iter = selection.get_selected()
        self._deltarget.set_property("sensitive", bool(iter))

class FlagCreator(object):

    def __init__(self):

        self._window = gtk.Window()
        self._window.set_icon(getPixbuf("smart"))
        self._window.set_title(_("New Flag"))
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
        
        label = gtk.Label(_("Name:"))
        label.set_alignment(1.0, 0.5)
        label.show()
        table.attach(label, 0, 1, 0, 1, gtk.FILL, gtk.FILL)

        self._flag = gtk.Entry()
        self._flag.set_width_chars(20)
        self._flag.show()
        table.attach(self._flag, 1, 2, 0, 1, gtk.EXPAND|gtk.FILL, gtk.FILL)

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
                flag = self._flag.get_text().strip()
                if not flag:
                    iface.error(_("No flag name provided!"))
                    continue
                break
            flag = None
            break

        self._window.hide()

        return flag

class TargetCreator(object):

    def __init__(self):

        self._window = gtk.Window()
        self._window.set_icon(getPixbuf("smart"))
        self._window.set_title(_("New Target"))
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
        
        label = gtk.Label(_("Target:"))
        label.set_alignment(1.0, 0.5)
        label.show()
        table.attach(label, 0, 1, 0, 1, gtk.FILL, gtk.FILL)

        self._target = gtk.Entry()
        self._target.set_width_chars(40)
        self._target.show()
        table.attach(self._target, 1, 2, 0, 1, gtk.EXPAND|gtk.FILL, gtk.FILL)

        label = gtk.Label(_("Examples: \"pkgname\", \"pkgname = 1.0\" or "
                            "\"pkgname <= 1.0\""))
        label.set_alignment(1.0, 0.5)
        label.show()
        table.attach(label, 1, 2, 1, 2, gtk.FILL, gtk.FILL)

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
                target = self._target.get_text().strip()
                if not target:
                    iface.error(_("No target provided!"))
                    continue
                if ('"' in target or ',' in target or
                    not TARGETRE.match(target)):
                    iface.error(_("Invalid target!"))
                    continue
                break
            target = None
            break

        self._window.hide()

        return target

# vim:ts=4:sw=4:et
