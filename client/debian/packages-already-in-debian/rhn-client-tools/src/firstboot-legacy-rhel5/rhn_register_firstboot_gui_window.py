import functions # firstboot stuff
import os
import sys
import gtk

from firstboot_module_window import FirstbootModuleWindow

sys.path.append("/usr/share/rhn/up2date_client/")
sys.path.append("/usr/share/rhn")
import messageWindow
import rhnregGui

class RhnRegisterFirstbootGuiWindow(FirstbootModuleWindow):
    """This is a base class for our firstboot screens. It shouldn't be used
    directly.
    
    """
    needsparent = 1

    def __init__(self):
        FirstbootModuleWindow.__init__(self)
        self.doDebug = False
        # Variables that fb windows need to define
        assert hasattr(self, 'runPriority')
        assert hasattr(self, 'moduleName')
        assert hasattr(self, 'windowTitle')
        assert hasattr(self, 'shortMessage')
        assert hasattr(self, 'needsparent')
        # Method to provide the screen contents
        assert hasattr(self, '_getVbox')

    def passInParent(self,parent):
        self.parent = parent

    def getNext(self):
        pass

    def launch(self, doDebug=None):
        """Firstboot calls this to set up the screen. It will use the _getVbox
        method provided by the derived classes to get the contents of the 
        screen.
        
        """
        self.doDebug = doDebug
        if self.doDebug:
            print self.__class__.__name__, "launch called."

        self.icon = functions.imageFromPath("/usr/share/system-config-display/pixmaps/system-config-display.png")
        self.mainVBox = gtk.VBox()

        internalVBox = gtk.VBox(False, 10)
        internalVBox.set_border_width(10)

        vbox  = self._getVbox()

        internalVBox.pack_start(vbox, True)
        self.mainVBox.pack_start(internalVBox, True)
        
        # Set up cursor changing functions. Overriding functions that aren't in
        # classes like this could be called a hack, but I think it's the best 
        # we can do with the current overall setup and isn't too bad.
        # Having it here will cause this to get called once per module, but I'm 
        # not sure if it'll work to put it in the constructor.
        def mySetBusyCursor():
            cursor = gtk.gdk.Cursor(gtk.gdk.WATCH)
            # I think we have to set the cursor using firstboot's .window instead of
            # the one in our vboxes because the thing we use must be displayed when
            # we change the cursor and sometimes this gets called by a screen before
            # it's visible.
            # TODO See if we can add functions to firstboot to provide a nice way to
            # change the cursor.
            self.parent.win.window.set_cursor(cursor)
            while gtk.events_pending():
                gtk.main_iteration(False)
        def mySetArrowCursor():
            # I think we have to set the cursor using firstboot's .window instead of
            # the one in our vboxes because the thing we use must be displayed when
            # we change the cursor and sometimes this gets called by a screen before
            # it's visible.
            self.parent.win.window.set_cursor(None)
            while gtk.events_pending():
                gtk.main_iteration(False)
        rhnregGui.setBusyCursor = mySetBusyCursor
        rhnregGui.setArrowCursor = mySetArrowCursor
        
        return self.mainVBox, self.icon, self.windowTitle

    def grabFocus(self):
        if self.doDebug:
            print self.__class__.__name__, "grabFocus called."
        pass

    def fatalError(self, error, wrap=1):
        # FIXME
        if wrap:
            text = messageWindow.wrap_text(error)
        else:
            text = error
        dlg = messageWindow.ErrorDialog(text)
        self._goImmediatelyToFinish()
    
    def _goImmediatelyToFinish(self):
        self.parent.setPage("rhn_finish_gui")
        def dummyApply(self, *args):
            print "dummy"
            return True
        self.apply = dummyApply
        self.parent.nextClicked()
