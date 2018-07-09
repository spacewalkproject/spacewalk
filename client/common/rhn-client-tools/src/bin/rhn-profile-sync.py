#!/usr/bin/python
#
# Spacewalk registration tool
# Adapted from wrapper.py
# Copyright (c) 1999--2016 Red Hat, Inc.  Distributed under GPLv2.
#
# Authors:
#       Adrian Likins <alikins@redhat.com>
#       Preston Brown <pbrown@redhat.com>
#       James Bowes <jbowes@redhat.com>

import sys

import gettext
t = gettext.translation('rhn-client-tools', fallback=True)
# Python 3 translations don't have a ugettext method
if not hasattr(t, 'ugettext'):
    t.ugettext = t.gettext
_ = t.ugettext


from up2date_client import up2dateAuth
from up2date_client import rhncli
from up2date_client import rhnPackageInfo
from up2date_client import rhnHardware

try:
    from virtualization import support
except ImportError:
    support = None

class ProfileCli(rhncli.RhnCli):

    def main(self):
        if not up2dateAuth.getSystemId():
            needToRegister = \
                _("You need to register this system by running " \
                "`rhn_register` before using this option")
            print(needToRegister)
            sys.exit(1)

        if not self._testRhnLogin():
            sys.exit(1)

        print(_("Updating package profile..."))
        rhnPackageInfo.updatePackageProfile()

        print(_("Updating hardware profile..."))
        rhnHardware.updateHardware()

        if support is not None:
            print(_("Updating virtualization profile..."))
            support.refresh(True)


if __name__ == "__main__":
    cli = ProfileCli()
    cli.run()
