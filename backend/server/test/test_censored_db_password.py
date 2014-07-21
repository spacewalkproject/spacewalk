#!/usr/bin/python
#
# Copyright (c) 2008--2013 Red Hat, Inc.
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
# This test tries to make a connection to a database that doesn't exist.
# It catches the exception and sends the traceback, but the DB password should
# be censored.
# Run the test and look into the email.

from spacewalk.server import rhnSQL
from spacewalk.common.rhnConfig import initCFG
from spacewalk.common.rhnTB import Traceback

initCFG('server.xmlrpc')

try:
    rhnSQL.initDB("rhnuser/rhnuser@webde")
except:
    Traceback('test_censored_db_password', mail=1)
