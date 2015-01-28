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
from smart.const import INSTALL, REMOVE
from smart import *
import gobject, gtk

class PixbufCellRenderer(gtk.GenericCellRenderer):

    __gproperties__ = {
        "pixbuf":   (gobject.TYPE_OBJECT, "Pixbuf",
                     "Pixbuf to be shown",
                     gobject.PARAM_READWRITE),
        "activate": (gobject.TYPE_PYOBJECT, "Activate function",
                     "Function to call on activation",
                     gobject.PARAM_READWRITE),
    }

    def __init__(self):
        self.__gobject_init__()
        self.pixbuf = None
        self.activate = None

    def on_activate(self, event, widget, path, background_area,
                    cell_area, flags):
        if event and self.activate:
            width = self.pixbuf.get_width()
            height = self.pixbuf.get_height()
            xpad = self.get_property("xpad")
            ypad = self.get_property("ypad")
            if (cell_area.x+xpad < event.x < cell_area.x+xpad+width and
                cell_area.y+ypad < event.y < cell_area.y+ypad+height):
                self.activate(path)

    def do_set_property(self, pspec, value):
        setattr(self, pspec.name, value)

    def do_get_property(self, pspec):
        return getattr(self, pspec.name)

    def on_render(self, window, widget, background_area,
                  cell_area, expose_area, flags):
        if not self.pixbuf: return
        x_offset, y_offset, width, height = self.on_get_size(widget, cell_area)
        xpad = self.get_property("xpad")
        ypad = self.get_property("ypad")
        window.draw_pixbuf(widget.style.black_gc,
                           self.pixbuf, 0, 0,
                           cell_area.x+x_offset, cell_area.y+y_offset,
                           width-2*xpad, height-2*ypad,
                           gtk.gdk.RGB_DITHER_NORMAL, 0, 0)

    def on_get_size(self, widget, cell_area):
        if not self.pixbuf:
            return 0, 0, 0, 0
        xpad = self.get_property("xpad")
        ypad = self.get_property("ypad")
        if cell_area:
            width = self.pixbuf.get_width()+2*xpad
            height = self.pixbuf.get_height()+2*ypad
            xalign = self.get_property("xalign")
            x_offset = int(xalign*(cell_area.width-width-2*xpad))
            x_offset = max(x_offset, 0) + xpad
            yalign = self.get_property("yalign")
            y_offset = int(yalign*(cell_area.height-height-2*ypad))
            y_offset = max(y_offset, 0) + ypad
        else:
            width = self.pixbuf.get_width()+2*xpad
            height = self.pixbuf.get_height()+2*ypad
            x_offset = 0
            y_offset = 0
        return x_offset, y_offset, width, height

gobject.type_register(PixbufCellRenderer)

class GtkPackageView(gtk.Alignment):

    __gsignals__ = {
        "package_selected":  (gobject.SIGNAL_RUN_FIRST, gobject.TYPE_NONE,
                              (gobject.TYPE_PYOBJECT,)),
        "package_activated": (gobject.SIGNAL_RUN_FIRST, gobject.TYPE_NONE,
                              (gobject.TYPE_PYOBJECT,)),
        "package_popup":     (gobject.SIGNAL_RUN_FIRST, gobject.TYPE_NONE,
                              (gobject.TYPE_PYOBJECT, gobject.TYPE_PYOBJECT)),
    }

    def __init__(self):
        gtk.Alignment.__init__(self)
        self.__gobject_init__()

        self._expandpackage = False

        self._changeset = {}

        self._scrollwin = gtk.ScrolledWindow()
        self._scrollwin.set_policy(gtk.POLICY_AUTOMATIC, gtk.POLICY_ALWAYS)
        self._scrollwin.set_shadow_type(gtk.SHADOW_IN)
        self._scrollwin.show()
        self.add(self._scrollwin)

        self._treeview = gtk.TreeView()
        self._treeview.set_rules_hint(True)
        self._treeview.connect("button_press_event", self._buttonPress)
        self._treeview.connect("select_cursor_row", self._selectCursor)
        self._treeview.connect("cursor_changed", self._cursorChanged)
        self._treeview.show()
        self._scrollwin.add(self._treeview)

        selection = self._treeview.get_selection()
        selection.set_mode(gtk.SELECTION_MULTIPLE)

        column = gtk.TreeViewColumn(_("Package"))
        renderer = PixbufCellRenderer()
        renderer.set_property("activate", self._pixbufClicked)
        renderer.set_property("xpad", 3)
        renderer.set_property("mode", gtk.CELL_RENDERER_MODE_ACTIVATABLE)
        column.pack_start(renderer, False)
        column.set_cell_data_func(renderer, self._setPixbuf)
        renderer = gtk.CellRendererText()
        column.pack_start(renderer, True)
        column.set_cell_data_func(renderer, self._setName)
        self._treeview.append_column(column)

        renderer = gtk.CellRendererText()
        self._treeview.insert_column_with_data_func(-1, _("Version"), renderer,
                                                    self._setVersion)

        self._ipixbuf = getPixbuf("package-installed")
        self._ilpixbuf = getPixbuf("package-installed-locked")
        self._apixbuf = getPixbuf("package-available")
        self._alpixbuf = getPixbuf("package-available-locked")
        self._npixbuf = getPixbuf("package-new")
        self._nlpixbuf = getPixbuf("package-new-locked")
        self._fpixbuf = getPixbuf("folder")
        self._Ipixbuf = getPixbuf("package-install")
        self._Rpixbuf = getPixbuf("package-remove")
        self._rpixbuf = getPixbuf("package-reinstall")

    def _setPixbuf(self, treeview, cell, model, iter):
        value = model.get_value(iter, 0)
        if not hasattr(value, "name"):
            cell.set_property("pixbuf", self._fpixbuf)
            return
        pkg = value
        if pkg.installed:
            if self._changeset.get(pkg) is REMOVE:
                cell.set_property("pixbuf", self._Rpixbuf)
            elif self._changeset.get(pkg) is INSTALL:
                cell.set_property("pixbuf", self._rpixbuf)
            elif pkgconf.testFlag("lock", pkg):
                cell.set_property("pixbuf", self._ilpixbuf)
            else:
                cell.set_property("pixbuf", self._ipixbuf)
        else:
            if self._changeset.get(pkg) is INSTALL:
                cell.set_property("pixbuf", self._Ipixbuf)
            elif pkgconf.testFlag("lock", pkg):
                if pkgconf.testFlag("new", pkg):
                    cell.set_property("pixbuf", self._nlpixbuf)
                else:
                    cell.set_property("pixbuf", self._alpixbuf)
            elif pkgconf.testFlag("new", pkg):
                cell.set_property("pixbuf", self._npixbuf)
            else:
                cell.set_property("pixbuf", self._apixbuf)

    def _setName(self, treeview, cell, model, iter):
        value = model.get_value(iter, 0)
        if hasattr(value, "name"):
            cell.set_property("text", value.name)
        else:
            cell.set_property("text", str(value))

    def _setVersion(self, treeview, cell, model, iter):
        value = model.get_value(iter, 0)
        if hasattr(value, "version"):
            cell.set_property("text", str(value.version))
        else:
            cell.set_property("text", "")

    def getTreeView(self):
        return self._treeview

    def getSelectedPkgs(self):
        selection = self._treeview.get_selection()
        model, paths = selection.get_selected_rows()
        lst = []
        for path in paths:
            iter = model.get_iter(path)
            value = model.get_value(iter, 0)
            if hasattr(value, "name"):
                lst.append(value)
        return lst

    def setExpandPackage(self, flag):
        self._expandpackage = flag

    def getCursor(self):
        treeview = self._treeview
        model = treeview.get_model()
        path = treeview.get_cursor()[0]
        if not path:
            return None
        cursor = [None]*len(path)
        for i in range(len(path)):
            iter = model.get_iter(path[:i+1])
            cursor[i] = model.get_value(iter, 0)
        return cursor

    def setCursor(self, cursor):
        if not cursor:
            return
        treeview = self._treeview
        model = treeview.get_model()
        iter = None
        bestiter = None
        for i in range(len(cursor)):
            cursori = cursor[i]
            iter = model.iter_children(iter)
            while iter:
                value = model.get_value(iter, 0)
                if value == cursori:
                    bestiter = iter
                    break
                # Convert to str to protect against comparing
                # packages and strings.
                if str(value) < str(cursori):
                    bestiter = iter
                iter = model.iter_next(iter)
            else:
                break
        if bestiter:
            path = model.get_path(bestiter)
            treeview.set_cursor(path)
            treeview.scroll_to_cell(path)

    def getExpanded(self):
        expanded = []
        treeview = self._treeview
        model = treeview.get_model()
        def set(treeview, path, data):
            item = [None]*len(path)
            for i in range(len(path)):
                iter = model.get_iter(path[:i+1])
                item[i] = model.get_value(iter, 0)
            expanded.append(tuple(item))
        treeview.map_expanded_rows(set, None)
        return expanded

    def setExpanded(self, expanded):
        if not expanded:
            return
        treeview = self._treeview
        model = treeview.get_model()
        cache = {}
        for item in expanded:
            item = tuple(item)
            iter = None
            for i in range(len(item)):
                cached = cache.get(item[:i+1])
                if cached:
                    iter = cached
                    continue
                itemi = item[i]
                iter = model.iter_children(iter)
                while iter:
                    value = model.get_value(iter, 0)
                    if value == itemi:
                        cache[item[:i+1]] = iter
                        treeview.expand_row(model.get_path(iter), False)
                        break
                    iter = model.iter_next(iter)
                else:
                    break

    def setChangeSet(self, changeset):
        if changeset is None:
            self._changeset = {}
        else:
            self._changeset = changeset

    def setPackages(self, packages, changeset=None, keepstate=False):
        treeview = self._treeview
        if not packages:
            model = treeview.get_model()
            if model:
                model.clear()
                treeview.queue_draw()
            return
        self.setChangeSet(changeset)
        if keepstate:
            if treeview.get_model():
                expanded = self.getExpanded()
                cursor = self.getCursor()
            else:
                keepstate = False
        if isinstance(packages, list):
            model = gtk.ListStore(gobject.TYPE_PYOBJECT)
        elif isinstance(packages, dict):
            model = gtk.TreeStore(gobject.TYPE_PYOBJECT)
        self._setPackage(None, model, None, packages)
        treeview.set_model(model)
        if keepstate:
            self.setExpanded(expanded)
            self.setCursor(cursor)
        treeview.queue_draw()

    def _setPackage(self, report, model, parent, item):
        if type(item) is list:
            item.sort()
            for subitem in item:
                self._setPackage(report, model, parent, subitem)
        elif type(item) is dict:
            keys = item.keys()
            keys.sort()
            for key in keys:
                iter = self._setPackage(report, model, parent, key)
                self._setPackage(report, model, iter, item[key])
        else:
            # On lists, first argument is the row itself, but since
            # in these cases parent must be None, this works.
            iter = model.append(parent)
            model.set(iter, 0, item)
            return iter

    def _buttonPress(self, treeview, event):
        if event.window != treeview.get_bin_window():
            return
        try:
            path, column, cellx, celly = treeview.get_path_at_pos(int(event.x),
                                                                  int(event.y))
        except TypeError:
            return
        model = treeview.get_model()
        iter = model.get_iter(path)
        value = model.get_value(iter, 0)
        if event.type == gtk.gdk._2BUTTON_PRESS:
            if not self._expandpackage and hasattr(value, "name"):
                pkgs = self.getSelectedPkgs()
                if len(pkgs) > 1:
                    self.emit("package_activated", pkgs)
                else:
                    self.emit("package_activated", [value])
            elif treeview.row_expanded(path):
                treeview.collapse_row(path)
            else:
                treeview.expand_row(path, False)
        elif event.type == gtk.gdk.BUTTON_PRESS and event.button == 3:
            pkgs = self.getSelectedPkgs()
            if len(pkgs) > 1:
                self.emit("package_popup", pkgs, event)
            elif hasattr(value, "name"):
                self.emit("package_popup", [value], event)

    def _selectCursor(self, treeview, start_editing=False):
        pkgs = self.getSelectedPkgs()
        if not self._expandpackage and pkgs:
            self.emit("package_activated", pkgs)
        else:
            model = treeview.get_model()
            path = treeview.get_cursor()[0]
            if path:
                iter = model.get_iter(path)
                value = model.get_value(iter, 0)
                if not self._expandpackage and hasattr(value, "name"):
                    self.emit("package_activated", [value])
                else:
                    if treeview.row_expanded(path):
                        treeview.collapse_row(path)
                    else:
                        treeview.expand_row(path, False)

    def _pixbufClicked(self, path):
        model = self._treeview.get_model()
        iter = model.get_iter(path)
        value = model.get_value(iter, 0)
        if hasattr(value, "name"):
            self.emit("package_activated", [value])

    def _cursorChanged(self, treeview):
        treeview = self._treeview
        model = treeview.get_model()
        path = treeview.get_cursor()[0]
        if path:
            iter = model.get_iter(path)
            value = model.get_value(iter, 0)
            if hasattr(value, "name"):
                self.emit("package_selected", value)
            else:
                self.emit("package_selected", None)
            path = model.get_path(iter)
        else:
            self.emit("package_selected", None)

gobject.type_register(GtkPackageView)
