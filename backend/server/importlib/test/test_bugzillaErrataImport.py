#!/usr/bin/python
#
# Copyright (c) 2008 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public License,
# version 2 (GPLv2). There is NO WARRANTY for this software, express or
# implied, including the implied warranties of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
# along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
# 
# Red Hat trademarks are not licensed under GPLv2. No permission is
# granted to use or replicate Red Hat trademarks that are incorporated
# in this software or its documentation. 
#
#
# Silly test script for the bugzilla erratum import
# 
# $Id: test_bugzillaErrataImport.py 62609 2005-07-28 01:59:33Z misa $


import sys
from common import initCFG

from server import rhnSQL
from bugzillaErrataSource import BugzillaErratum
from bugzillaErrataImport import BugzillaErrataImport

def main():
    initCFG("server.bugzilla")
    from sample_erratum import err

    rhnSQL.initDB('rhnuser/rhnuser@webdev')
    e = BugzillaErratum()
    e.populate(err)
    ber = BugzillaErrataImport(e)
    ber.run()
    ber.check()

if __name__ == '__main__':
    sys.exit(main() or 0)
