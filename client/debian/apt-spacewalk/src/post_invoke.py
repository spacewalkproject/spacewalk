#!/usr/bin/python
#
# DPkg::Post-Invoke hook for updating Debian package profile
#
# Author:  Simon Lukasik
# Date:    2011-03-14
# License: GPLv2
#
# Copyright (c) 1999--2012 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public License,
# version 2 (GPLv2). There is NO WARRANTY for this software, express or
# implied, including the implied warranties of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
# along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.


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
from up2date_client import pkgUtils


if __name__ == '__main__':
    systemid = up2dateAuth.getSystemId()
    if systemid:
        try:
            print "Apt-Spacewalk: Updating package profile"
            s = rhnserver.RhnServer()
            s.registration.update_packages(systemid,
                pkgUtils.getInstalledPackageList(getArch=1))
        except up2dateErrors.RhnServerException, e:
            print "Package profile information could not be sent."
            print str(e)
