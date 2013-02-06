#
# Progress bar for Update Agent
# Copyright (c) 1999-2010 Red Hat, Inc.
#
# Author: Preston Brown <pbrown@redhat.com>

import gtk

class Progress:
    def __init__(self):
        glade_prefix = "/usr/share/rhn/up2date_client/"

        self.xml = gtk.glade.XML(glade_prefix + "progress.glade", "progressWindow")
        self.progressWindow = self.xml.get_widget("progressWindow")
        self.progressWindow.connect("delete-event", self.progressWindow.hide)
        #self.progressWindow.connect("hide", self.progressWindow.hide)
        cursor = gtk.gdk.Cursor(gtk.gdk.WATCH)
        self.progressWindow.window.set_cursor(cursor)
        while gtk.events_pending():
            gtk.main_iteration(False)

        self.lastProgress = 0.0

    def hide(self):
        self.progressWindow.hide()
        while gtk.events_pending():
            gtk.main_iteration(False)
            
        del self

    def setLabel(self, text):
        label = self.xml.get_widget("progressLabel")
        label.set_text(text)
        while gtk.events_pending():
            gtk.main_iteration(False)
        
    # the xmlrpc callbacks only use the first three
    # the GET style use all 4, so pass em but dont use them
    def setProgress(self, amount, total, speed = 0, secs = 0):
        if total:
            i = float(amount) / total
        else: 
            i = 1
        
        if i > 1:
            i = 1
        if i > self.lastProgress + .01 or i == 1:
            self.xml.get_widget("progressBar").set_fraction(i)
            if i == 1:
                # reset
                i = 0
#            gtk.gdk_flush()
            while gtk.events_pending():
                gtk.main_iteration(False)
            self.lastProgress = i

    def setStatusLabel(self, text):
        self.xml.get_widget("statusLabel").set_text(text)
        while gtk.events_pending():
            gtk.main_iteration(False)

    def destroy(self):
        while gtk.events_pending():
            gtk.main_iteration(False)

        self.progressWindow.destroy()
 
    def noop(self, win, event):
        return True

