
import string

import gtk
import gettext
_ = gettext.gettext

# wrap a long line...
def wrap_line(line, max_line_size = 100):
    if len(line) < max_line_size:
        return line
    ret = []
    l = ""
    for w in string.split(line):
        if not len(l):
            l = w
            continue
        if len(l) > max_line_size:
            ret.append(l)
            l = w
        else:
            l = "%s %s" % (l, w)
    if len(l):
        ret.append(l)
    return string.join(ret, '\n')

# wrap an entire piece of text
def wrap_text(txt):
    return string.join(map(wrap_line, string.split(txt, '\n')), '\n')

def addFrame(dialog):
    contents = dialog.get_children()[0]
    dialog.remove(contents)
    frame = gtk.Frame()
    frame.set_shadow_type(gtk.SHADOW_OUT)
    frame.add(contents)
    dialog.add(frame)

class MessageWindow:
    def getrc (self):
        return self.rc

    def hide(self):
        self.dialog.hide()
        self.dialog.destroy()
        gtk.main_iteration()

    def __init__ (self, title, text, type="ok", default=None, parent=None):
        self.rc = None
        if type == 'ok':
            buttons = gtk.BUTTONS_OK
            style = gtk.MESSAGE_INFO
        elif type == 'warning':
            buttons = gtk.BUTTONS_OK
            style = gtk.MESSAGE_WARNING
        elif type == 'okcancel':
            buttons = gtk.BUTTONS_OK_CANCEL
            style = gtk.MESSAGE_WARNING
        elif type == 'yesno':
            buttons = gtk.BUTTONS_YES_NO
            style = gtk.MESSAGE_QUESTION
        elif type == "error":
            buttons = gtk.BUTTONS_OK
            style = gtk.MESSAGE_ERROR
        elif type == "question":
            buttons = gtk.BUTTONS_YES_NO
            style = gtk.MESSAGE_QUESTION

        # this seems to be wordwrapping text passed to
        # it, which is making for ugly error messages
        self.dialog = gtk.MessageDialog(parent, 0, style, buttons, text)
        self.dialog.label.set_line_wrap(False)
        self.dialog.label.set_use_markup(True)
        if default == "no":
            self.dialog.set_default_response(0)
        elif default == "yes" or default == "ok":
            self.dialog.set_default_response(1)
        else:
            self.dialog.set_default_response(0)

        addFrame(self.dialog)
        self.dialog.set_position (gtk.WIN_POS_CENTER)
        self.dialog.show_all ()
        rc = self.dialog.run()
        if rc == gtk.RESPONSE_OK or rc == gtk.RESPONSE_YES:
            self.rc = 1
        elif (rc == gtk.RESPONSE_CANCEL or rc == gtk.RESPONSE_NO
            or rc == gtk.RESPONSE_CLOSE):
            self.rc = 0
        self.dialog.destroy()

class ErrorDialog(MessageWindow):
    def __init__ (self, text, parent=None):
        MessageWindow.__init__(self,_("Error:"),
                               text,
                               type="error",
                               parent=parent)

class WarningDialog(MessageWindow):
    def __init__ (self, text, parent=None):
        MessageWindow.__init__(self, _("Warning:"),
                               text,
                               type="warning",
                               parent=parent)

class OkDialog(MessageWindow):
    def __init__ (self, text, parent=None):
        MessageWindow.__init__(self, _("OK dialog:"),
                               text,
                               type="ok",
                               parent=parent)

    
class YesNoDialog(MessageWindow):
    def __init__ (self, text, parent=None):
        MessageWindow.__init__(self,_("Yes/No dialog:"),
                               text,
                               type="yesno",
                               parent=parent)

class QuestionDialog(MessageWindow):
    def __init__ (self, text, parent=None):
        MessageWindow.__init__(self,_("Question dialog:"),
                               text,
                               type="question",
                               parent=parent)


class BulletedOkDialog:
    """A dialog box that can have one more sections of text. Each section can
    be standard blob of text or a bulleted item.
    
    """
    def __init__ (self, title=None, parent=None):
        self.rc = None
        self.dialog = gtk.Dialog(title, parent, 0, ("Close", 1))
        self.dialog.set_has_separator(False)
        # Vbox to contain just the stuff that will be add to the dialog with 
        # addtext
        self.vbox = gtk.VBox(spacing=15)
        self.vbox.set_border_width(15)
        # Put our vbox into the top part of the dialog
        self.dialog.get_children()[0].pack_start(self.vbox, expand=False)
    
    def add_text(self, text):
        label = gtk.Label(text)
        label.set_alignment(0, 0)
        label.set_line_wrap(True)
        self.vbox.pack_start(label, expand=False)
    
    def add_bullet(self, text):
        label = gtk.Label(text)
        label.set_alignment(0, 0)
        label.set_line_wrap(True)
        hbox = gtk.HBox(spacing=5)
        bullet = gtk.Label(u'\u2022')
        bullet.set_alignment(0, 0)
        hbox.pack_start(bullet, expand=False)
        hbox.pack_start(label, expand=False)
        self.vbox.pack_start(hbox, expand=False)
    
    def run(self):
        # addFrame(self.dialog) # Need to do this differently if we want it
        self.dialog.set_position(gtk.WIN_POS_CENTER)
        self.dialog.show_all()
        rc = self.dialog.run()
        if (rc == gtk.RESPONSE_CANCEL or rc == gtk.RESPONSE_NO
            or rc == gtk.RESPONSE_CLOSE):
            self.rc = 0
        self.dialog.destroy()
        gtk.main_iteration()
    
    def getrc (self):
        return self.rc
