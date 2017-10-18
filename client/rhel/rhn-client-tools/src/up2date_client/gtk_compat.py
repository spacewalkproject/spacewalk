#
# Gtk 2/3 compat package
# Copyright (c) 2017 Red Hat, Inc.  Distributed under GPLv2.
#

try: # python2 / gtk2 / pygtk
    import gtk
    import gtk.glade
    import gobject

    gtk.glade.bindtextdomain("rhn-client-tools", "/usr/share/locale")
    GTK3 = False
except ImportError: # python3 /gtk3 / gi
    import gi
    gi.require_version("Gtk", "3.0")
    from gi.repository import Gtk as gtk
    from gi.repository import GObject as gobject
    GTK3 = True
