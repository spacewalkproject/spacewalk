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
    from gi.repository import Gdk as gdk
    from gi.repository import GObject as gobject
    GTK3 = True


if GTK3:
    class GladeBuilder(object):
        def __init__(self):
            self.builder = gtk.Builder()
            self.builder.get_widget = self.builder.get_object
            self.builder.signal_autoconnect = self.builder.connect_signals
            self.translation_domain = None

        def XML(self, gladefile, widget, domain):
            self.builder.add_objects_from_file(gladefile, (widget,))
            if not self.translation_domain:
                self.builder.set_translation_domain(domain)
            return self.builder

    gtk.glade = GladeBuilder()
    gtk.RESPONSE_NONE = gtk.ResponseType.NONE
    gtk.RESPONSE_OK = gtk.ResponseType.OK
    gtk.RESPONSE_YES = gtk.ResponseType.YES
    gtk.RESPONSE_CANCEL = gtk.ResponseType.CANCEL
    gtk.RESPONSE_NO = gtk.ResponseType.NO
    gtk.RESPONSE_CLOSE = gtk.ResponseType.CLOSE
    gtk.BUTTONS_OK = gtk.ButtonsType.OK
    gtk.BUTTONS_OK_CANCEL = gtk.ButtonsType.OK_CANCEL
    gtk.BUTTONS_YES_NO = gtk.ButtonsType.YES_NO
    gtk.MESSAGE_INFO = gtk.MessageType.INFO
    gtk.MESSAGE_WARNING = gtk.MessageType.WARNING
    gtk.MESSAGE_QUESTION = gtk.MessageType.QUESTION
    gtk.MESSAGE_ERROR = gtk.MessageType.ERROR
    gtk.WIN_POS_CENTER = gtk.WindowPosition.CENTER
    gtk.SORT_ASCENDING = gtk.SortType.ASCENDING
    gtk.SHADOW_OUT = gtk.ShadowType.OUT

    def setCursor(widget, ctype):
        cursor = gdk.Cursor(ctype)
        widget.get_root_window().set_cursor(cursor)
        while gtk.events_pending():
            gtk.main_iteration_do(False)
    gtk.CURSOR_WATCH = gdk.CursorType.WATCH
    gtk.CURSOR_LEFT_PTR = gdk.CursorType.LEFT_PTR

    def getWidgetName(widget):
        return gtk.Buildable.get_name(widget)

else:
    def setCursor(widget, ctype):
        cursor = gtk.gdk.Cursor(ctype)
        widget.window.set_cursor(cursor)
        while gtk.events_pending():
            gtk.main_iteration_do(False)

    gtk.CURSOR_WATCH = gtk.gdk.WATCH
    gtk.CURSOR_LEFT_PTR = gtk.gdk.LEFT_PTR

    def getWidgetName(widget):
        return widget.name
