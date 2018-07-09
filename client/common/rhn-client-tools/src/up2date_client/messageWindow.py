

import gettext
t = gettext.translation('rhn-client-tools', fallback=True)
# Python 3 translations don't have a ugettext method
if not hasattr(t, 'ugettext'):
    t.ugettext = t.gettext
_ = t.ugettext

from up2date_client.gtk_compat import gtk, GTK3

if GTK3:
    DIALOG_LABEL = 0
else:
    DIALOG_LABEL = 1

# wrap a long line...
def wrap_line(line, max_line_size = 100):
    if len(line) < max_line_size:
        return line
    ret = []
    l = ""
    for w in line.split():
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
    return '\n'.join(ret)

# wrap an entire piece of text
def wrap_text(txt):
    return '\n'.join(map(wrap_line, txt.split('\n')))

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
        gtk.main_iteration_do(True)

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

        self.dialog = gtk.MessageDialog(parent, 0, style, buttons)
        # Work around for bug #602609
        try:
            self.dialog.vbox.get_children()[0].get_children()[DIALOG_LABEL].\
                get_children()[0].set_line_wrap(False)
        except:
            self.dialog.label.set_line_wrap(False)
        self.dialog.set_markup(text)
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

class YesNoDialog(MessageWindow):
    def __init__ (self, text, parent=None):
        MessageWindow.__init__(self,_("Yes/No dialog:"),
                               text,
                               type="yesno",
                               parent=parent)

class BulletedOkDialog:
    """A dialog box that can have one more sections of text. Each section can
    be standard blob of text or a bulleted item.

    """
    def __init__ (self, title=None, parent=None):
        self.rc = None
        self.dialog = gtk.Dialog(title, parent, 0, ("Close", 1))
        if hasattr(self.dialog, 'set_has_separator'):
            self.dialog.set_has_separator(False)
        # Vbox to contain just the stuff that will be add to the dialog with
        # addtext
        self.vbox = gtk.VBox(spacing=15)
        self.vbox.set_border_width(15)
        # Put our vbox into the top part of the dialog
        self.dialog.get_children()[0].pack_start(self.vbox, expand=False, fill=True, padding=0)

    def add_text(self, text):
        label = gtk.Label(text)
        label.set_alignment(0, 0)
        label.set_line_wrap(True)
        self.vbox.pack_start(label, expand=False, fill=True, padding=0)

    def add_bullet(self, text):
        label = gtk.Label(text)
        label.set_alignment(0, 0)
        label.set_line_wrap(True)
        hbox = gtk.HBox(spacing=5)
        bullet = gtk.Label(u'\u2022')
        bullet.set_alignment(0, 0)
        hbox.pack_start(bullet, expand=False, fill=True, padding=0)
        hbox.pack_start(label, expand=False, fill=True, padding=0)
        self.vbox.pack_start(hbox, expand=False, fill=True, padding=0)

    def run(self):
        # addFrame(self.dialog) # Need to do this differently if we want it
        self.dialog.set_position(gtk.WIN_POS_CENTER)
        self.dialog.show_all()
        rc = self.dialog.run()
        if (rc == gtk.RESPONSE_CANCEL or rc == gtk.RESPONSE_NO
            or rc == gtk.RESPONSE_CLOSE):
            self.rc = 0
        self.dialog.destroy()
        gtk.main_iteration_do(True)

    def getrc (self):
        return self.rc
