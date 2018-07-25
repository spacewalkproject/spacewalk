#!/usr/bin/python
#
# Spacewalk / Red Hat Network Classic registration tool
# Adapted from wrapper.py
# Copyright (c) 1999--2016 Red Hat, Inc.  Distributed under GPLv2.
#
# Authors:
#       Adrian Likins <alikins@redhat.com>
#       Preston Brown <pbrown@redhat.com>
#       James Bowes <jbowes@redhat.com>
#       Daniel Benamy <dbenamy@redhat.com>

import sys
import os

import gettext
t = gettext.translation('rhn-client-tools', fallback=True)
# Python 3 translations don't have a ugettext method
if not hasattr(t, 'ugettext'):
    t.ugettext = t.gettext
_ = t.ugettext

from up2date_client import up2dateLog
up2dateLog.initLog().set_app_name('rhn_register')
from up2date_client import up2dateAuth
from up2date_client import rhncli
from up2date_client import tui
from up2date_client import up2dateErrors

class RhnRegister(rhncli.RhnCli):
    """Runs rhn_register. Can run it in gui or tui mode depending on
    availablility of gui, DISPLAY environment variable, and --nox switch.

    """
    def __init__(self):
        super(RhnRegister, self).__init__()
        self.optparser.add_option("--nox", action="store_true", default=False,
            help=_("Do not attempt to use X"))

    def _get_ui(self):
        try:
            if os.environ["DISPLAY"] != "" and \
               not self.options.nox:
                from up2date_client import gui
                self.hasGui = True # Used by base class. Yech.
                return gui
        except:
            pass

        return tui

    def main(self):
        """RhnCli (the base class) just sets stuff up and then calls this to run
        the rest of the program.

        """
        ui = self._get_ui()
        ui.main()

        # Check to see if the registration worked.
        try:
            if not up2dateAuth.getLoginInfo():
                if not self._testRhnLogin():
                    sys.exit(1)
        except up2dateErrors.RhnServerException:
            sys.exit(1)

        # Assuming registration worked, remember to save info (proxy setup,etc)
        # from rhncli
        self.saveConfig()
        sys.exit(0)


if __name__ == "__main__":
    app = RhnRegister()
    app.run()
