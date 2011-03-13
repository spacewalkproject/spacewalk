#!/usr/bin/python
#
# DPkg::Post-Invoke hook for updating Debian package profile
#
# Author:  Simon Lukasik
# Date:    2011-03-14
# License: GPLv2
#
#

import sys

# Once we have the up2date stuff in a site-packages,
# we won't have to do path magic.
import warnings
warnings.filterwarnings("ignore",
    message='the md5 module is deprecated; use hashlib instead')
sys.path.append("/usr/share/rhn/")
from up2date_client import up2dateAuth
from up2date_client import up2dateErrors
from up2date_client import rhnserver
from up2date_client import rpmUtils


if __name__ == '__main__':
    systemid = up2dateAuth.getSystemId()
    if systemid:
        try:
            print "Apt-Spacewalk: Updating package profile"
            s = rhnserver.RhnServer()
            s.registration.update_packages(systemid,
                rpmUtils.getInstalledPackageList(getArch=1))
        except up2dateErrors.RhnServerException, e:
            print "Package profile information could not be sent."
            print str(e)
