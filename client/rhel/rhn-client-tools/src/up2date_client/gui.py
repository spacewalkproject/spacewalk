#
# GUI for Update Agent
# Copyright (c) 1999-2010 Red Hat, Inc.  Distributed under GPL.
#
# Authors:
#    Preston Brown <pbrown@redhat.com>
#    Adrian Likins <alikins@redhat.com>
#    Daniel Benamy <dbenamy@redhat.com>

import os
import sys

import gtk
import gtk.glade

gtk.glade.bindtextdomain("rhn-client-tools", "/usr/share/locale")

# We have to import gnome.ui before using glade for our GnomeUi widgets.
# ie the druid. Get rid of these widgets, and we won't need this import.
# see http://www.async.com.br/faq/pygtk/index.py?req=show&file=faq22.005.htp
import gnome.ui

import signal
from rhn import rpclib

import gettext
_ = gettext.gettext

import up2dateErrors
import config
import rhnreg
import messageWindow

import rhnregGui



class Gui(rhnregGui.StartPage, rhnregGui.ChooseServerPage, rhnregGui.LoginPage,
                rhnregGui.ActivateSubscriptionPage,
                rhnregGui.ReviewSubscriptionPage, rhnregGui.CreateProfilePage,
                rhnregGui.ProvideCertificatePage, rhnregGui.FinishPage,
                rhnregGui.ChooseChannelPage):

    def __init__(self):
        self.cfg = config.initUp2dateConfig()

        gladeFile = "/usr/share/rhn/up2date_client/gui.glade"
        self.xml = gtk.glade.XML(gladeFile, "mainWin", domain="rhn-client-tools")
        self.xml.signal_autoconnect (
            { "onDruidCancel" : self.onDruidCancel,
              "onStartPagePrepare" : self.onStartPagePrepare,
              "onStartPageNext" : self.onStartPageNext,
              "onChooseServerPagePrepare" : self.onChooseServerPagePrepare,
              "onChooseServerPageNext" : self.onChooseServerPageNext,
              "onLoginPagePrepare" : self.onLoginPagePrepare,
              "onLoginPageNext" : self.onLoginPageNext,
              "onActivateSubscriptionPagePrepare" : self.onActivateSubscriptionPagePrepare,
              "onActivateSubscriptionPageBack" : self.onActivateSubscriptionPageBack,
              "onActivateSubscriptionPageNext" : self.onActivateSubscriptionPageNext,
              "onChooseChannelPageNext" : self.onChooseChannelPageNext,
              "onChooseChannelPageBack" : self.onChooseChannelPageBack,
              "onChooseChannelPagePrepare" : self.onChooseChannelPagePrepare,
              "onCreateProfilePagePrepare" : self.onCreateProfilePagePrepare,
              "onCreateProfilePageNext" : self.onCreateProfilePageNext,
              "onReviewSubscriptionPagePrepare" : self.onReviewSubscriptionPagePrepare,
              "onReviewSubscriptionPageNext" : self.onReviewSubscriptionPageNext,
##              "onRegFinishPagePrepare" : self.onRegFinishPagePrepare,
##              "onRegFinishPageFinish" : self.onFinishPageFinish,
              "onProvideCertificatePageBack" : self.onProvideCertificatePageBack,
              "onProvideCertificatePageNext" : self.onProvideCertificatePageNext,
              "onFinishPagePrepare" : self.onFinishPagePrepare,
              "onFinishPageFinish" : self.onFinishPageFinish,
        } )

        rhnregGui.StartPage.__init__(self)
        rhnregGui.ChooseServerPage.__init__(self)
        rhnregGui.LoginPage.__init__(self)
        rhnregGui.ActivateSubscriptionPage.__init__(self)
        rhnregGui.ChooseChannelPage.__init__(self)
        rhnregGui.CreateProfilePage.__init__(self)
        rhnregGui.ReviewSubscriptionPage.__init__(self)
        rhnregGui.ProvideCertificatePage.__init__(self)
        rhnregGui.FinishPage.__init__(self)

        # Pack all the pages into the empty druid screens
        contents = self.startPageVbox()
        container = self.xml.get_widget("startPageVbox")
        container.pack_start(contents, True)
        contents = self.chooseServerPageVbox()
        container = self.xml.get_widget("chooseServerPageVbox")
        container.pack_start(contents, True)
        contents = self.loginPageVbox()
        container = self.xml.get_widget("loginPageVbox")
        container.pack_start(contents, True)
        contents = self.activateSubscriptionPageVbox()
        container = self.xml.get_widget("linkToSubscriptionPageVbox")
        container.pack_start(contents, True)
        contents = self.chooseChannelPageVbox()
        container = self.xml.get_widget("chooseChannelPageVbox")
        container.pack_start(contents, True)
        contents = self.createProfilePageVbox()
        container = self.xml.get_widget("createProfilePageVbox")
        container.pack_start(contents, True)
        contents = self.reviewSubscriptionPageVbox()
        container = self.xml.get_widget("reviewSubscriptionPageVbox")
        container.pack_start(contents, True)
        contents = self.provideCertificatePageVbox()
        container = self.xml.get_widget("provideCertificatePageVbox")
        container.pack_start(contents, True)
        contents = self.finishPageVbox()
        container = self.xml.get_widget("finishPageVbox")
        container.pack_start(contents, True)

        self.initProfile = False
        self.oemInfo = {}
        self.productInfo = {}
        self.showedActivateSubscriptionPage = False
        self.already_registered_already_shown = False

        self.druid = self.xml.get_widget("druid")
        self.mainWin = self.xml.get_widget("mainWin")
        self.mainWin.connect("delete-event", gtk.main_quit)
        self.mainWin.connect("hide", gtk.main_quit)

        # It's better to get widgets in advance so bugs don't hide in get_widget
        # calls that only get executed periodically.
        self.startPage = self.xml.get_widget("startPage")
        self.chooseServerPage = self.xml.get_widget("chooseServerPage")
        self.provideCertificatePage = self.xml.get_widget("provideCertificatePage")
        self.activateSubscriptionPage = \
                                self.xml.get_widget("activateSubscriptionPage")
        self.loginPage = self.xml.get_widget("loginPage")
        self.chooseChannelPage = self.xml.get_widget("chooseChannelPage")
        self.createProfilePage = self.xml.get_widget("createProfilePage")
        self.reviewSubscriptionPage = \
            self.xml.get_widget("reviewSubscriptionPage")
        self.finishPage = self.xml.get_widget("finishPage")

        # Set up cursor changing functions. Overriding functions that aren't in
        # classes like this could be called a hack, but I think it's the best
        # we can do with the current overall setup and isn't too bad.
        def mySetBusyCursor():
            cursor = gtk.gdk.Cursor(gtk.gdk.WATCH)
            self.mainWin.window.set_cursor(cursor)
            while gtk.events_pending():
                gtk.main_iteration(False)
        def mySetArrowCursor():
            cursor = gtk.gdk.Cursor(gtk.gdk.LEFT_PTR)
            self.mainWin.window.set_cursor(cursor)
            while gtk.events_pending():
                gtk.main_iteration(False)
        rhnregGui.setBusyCursor = mySetBusyCursor
        rhnregGui.setArrowCursor = mySetArrowCursor

        self.mainWin.show_all()
        # Druid doesn't signal prepare to the first page when starting up
        self.onStartPagePrepare(None, None, manualPrepare=True)


    def onDruidCancel(self, dummy):
        dialog = rhnregGui.ConfirmQuitDialog()
        if dialog.rc == 1:
            self.druid.set_page(self.finishPage)
        else:
            return True


    def fatalError(self, error, wrap=1):
        rhnregGui.setArrowCursor()
        # FIXME
        if wrap:
            text = messageWindow.wrap_text(error)
        else:
            text = error

        dlg = messageWindow.ErrorDialog(text,self.mainWin)
        gtk.main_quit()
        sys.exit(1)


    def onStartPagePrepare(self, page, dummy, manualPrepare=False):
        if not manualPrepare:
            self.startPage.emit_stop_by_name("prepare")
        self.mainWin.set_title(_("Registering for software updates"))
        self.druid.set_buttons_sensitive(False, True, True, False)
        if rhnreg.registered() and not self.already_registered_already_shown:
            # Dialog constructor returns when dialog closes
            dialog = rhnregGui.AlreadyRegisteredDialog()
            if dialog.rc == 0:
                sys.exit(0)
            self.already_registered_already_shown = True

    def onStartPageNext(self, page, dummy):
        self.druid.set_buttons_sensitive(True, True, True, False)


    def onChooseServerPagePrepare(self, page, dummy):
        self.chooseServerPage.emit_stop_by_name("prepare")
        self.mainWin.set_title(_("Registering for software updates"))
        self.chooseServerPagePrepare()

    def onChooseServerPageNext(self, page, dummy):
        try:
            ret = self.chooseServerPageApply()
            if ret is False: # Everything is ok
                self.druid.set_page(self.loginPage)
        except (up2dateErrors.SSLCertificateVerifyFailedError,\
                up2dateErrors.SSLCertificateFileNotFound):
            self.setUrlInWidget()
            self.druid.set_page(self.provideCertificatePage)
        return True


    def onLoginPagePrepare(self, page, dummy):
        self.loginPage.emit_stop_by_name("prepare")
        self.loginXml.get_widget("loginUserEntry").grab_focus()
        self.loginPagePrepare()

    def onLoginPageNext(self, page, dummy):
        """This must manually switch pages because another function calls it to
        advance the druid. It returns True to inform the druid of this.
        """
        ret = self.loginPageVerify()
        if ret:
            return ret

        ret = self.loginPageApply()
        if ret:
            return ret

        self.goToPageAfterLogin()
        return True


    def goToPageAfterLogin(self):
        """This function is used by the create new account dialog so it doesn't
        need to have any knowledge of the screen mechanism or order.
        """
        self.showedActivateSubscriptionPage = False
        if rhnregGui.activateSubscriptionShouldBeShown():
            self.druid.set_page(self.activateSubscriptionPage)
        elif rhnregGui.chooseChannelShouldBeShown():
            self.druid.set_page(self.chooseChannelPage)
        else:
            self.druid.set_page(self.createProfilePage)


    def onActivateSubscriptionPagePrepare(self, page, dummy):
        self.showedActivateSubscriptionPage = True
        self.activateSubscriptionPagePrepare()

    def onActivateSubscriptionPageBack(self, page, dummy):
        self.druid.set_page(self.loginPage)
        return True

    def onActivateSubscriptionPageNext(self, page, dummy):
        status = self.activateSubscriptionPageVerify()
        if rhnregGui.chooseChannelShouldBeShown():
            self.druid.set_page(self.chooseChannelPage)
        if status is True:
            return True
        status = self.activateSubscriptionPageApply()
        if status is True:
            return True

    def onChooseChannelPageBack(self, page, dummy):
        if self.showedActivateSubscriptionPage == True:
            self.druid.set_page(self.activateSubscriptionPage)
        else:
            self.druid.set_page(self.loginPage)

        return True

    def onChooseChannelPageNext(self, page, dummy):
        self.chooseChannelPageApply()
        if self.chose_all_updates or \
           self.chose_default_channel is False:
            dialog = rhnregGui.ConfirmAllUpdatesDialog()
            if dialog.rc == 0:
                self.druid.set_page(self.chooseChannelPage)
                return True
        else:
            self.druid.set_page(self.createProfilePage)
            return True

    def onChooseChannelPagePrepare(self, page, dummy):
        self.chooseChannelPagePrepare()
        self.chooseChannelPage.emit_stop_by_name("prepare")

    def onCreateProfilePagePrepare(self, page, dummy):
        self.createProfilePagePrepare()
        self.createProfilePage.emit_stop_by_name("prepare")

    def onCreateProfilePageNext(self, page, dummy):
        ret = self.createProfilePageVerify()
        if ret:
            return ret
        ret = self.createProfilePageApply()
        if ret:
            return ret


    def onReviewSubscriptionPagePrepare(self, page, dummy):
        self.reviewSubscriptionPagePrepare()
        self.druid.set_buttons_sensitive(False, True, False, False)
        self.reviewSubscriptionPage.emit_stop_by_name("prepare")

    def onReviewSubscriptionPageNext(self, page, dummy):
        self.druid.set_page(self.finishPage)
        return True


##    def onRegFinishPagePrepare(self, page, dummy):
##        # Disable the next button and enable the finish one
##        self.druid.set_buttons_sensitive(False, False, False, False)
##        self.druid.set_show_finish(True)
##        self.druid.finish.set_label (_("_Finish"))
##        self.xml.get_widget("regFinishPage").emit_stop_by_name("prepare")
##        self.xml.get_widget("mainWin").set_title(_("Finish registering for software updates"))
##        try:
##            ret = rhnreg.finishMessage(self.systemId)
##        except up2dateErrors.Error:
##            ret = (0, "", "")
##        (returnCode, titleText, messageText) = ret[:3]
##
##        textArea = self.xml.get_widget("regFinishTextView")
##        page = self.xml.get_widget("regFinishPage")
##
##        page.set_title(titleText)
##        # TODO These cases used to be different when this wasn't the end of the
##        # druid (I think only one changed the buttons). Figure out if we still
##        # need to do something different based on returnCode
##        if returnCode == 1:
##            buffer = gtk.TextBuffer(None)
##            buffer.set_text(messageText)
##            textArea.set_buffer(buffer)
##        if returnCode == -1:
##            buffer = gtk.TextBuffer(None)
##            buffer.set_text(messageText)
##            textArea.set_buffer(buffer)
##
##    def onFinishPageFinish(self, page, dummy=None):
##        gtk.main_quit()

    def onProvideCertificatePageBack(self, page=None, dummy=None):
        self.druid.set_page(self.chooseServerPage)
        return True

    def onProvideCertificatePageNext(self, page=None, dummy=None):
        status = self.provideCertificatePageApply()
        if status == 0:
            self.druid.set_page(self.loginPage)
        elif status == 1:
            self.druid.set_page(self.finishPage)
        elif status == 3:
            self.druid.set_page(self.chooseServerPage)
        else:
            assert status == 2
            pass
        return True


    def onFinishPagePrepare(self, page=None, dummy=None):
        self.druid.set_buttons_sensitive(False, False, False, False)
        self.druid.set_show_finish(True)
        # Stopping the signal is needed to make the druid buttons change the way
        # I want. I have no idea why.
        self.finishPage.emit_stop_by_name("prepare")
        if rhnregGui.hasBaseChannelAndUpdates():
            self.druid.finish.set_label(_("_Finish"))
            title = _("Finish setting up software updates")
        else:
            self.druid.finish.set_label(_("_Exit software update setup"))
            title = _("software updates setup unsuccessful")
        self.finishPagePrepare()
        self.mainWin.set_title(title)
        self.finishPage.set_title(title)

    def onFinishPageFinish(self, page, dummy=None):
        gtk.main_quit()


def rootWarning():
    dlg = messageWindow.ErrorDialog(_("You must run rhn_register as root."))
#    dlg.run_and_close()

def errorWindow(msg):
    dlg = messageWindow.ErrorDialog(messageWindow.wrap_text(msg))
#    dlg.run_and_close()

def main():
    signal.signal(signal.SIGINT, signal.SIG_DFL)

    if os.geteuid() != 0:
        rootWarning()
        sys.exit(1)

    gui = Gui()
    gtk.main()


if __name__ == "__main__":
    try:
        main()
    except rpclib.ResponseError, e:
        print e
    except IOError, e:
        print _("There was some sort of I/O error: %s") % e.errmsg
