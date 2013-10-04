#!/usr/bin/python

#
# Copyright (c) 2008--2010 Red Hat, Inc.
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

"""
Non-pure tests requiring connectivity to a PostgreSQL server configured below.
"""

import os
import sys
import unittest

from ConfigParser import ConfigParser
from spacewalk.server import rhnSQL

# Import all test modules here:
sys.path.insert(
    0,
    os.path.abspath(os.path.dirname(os.path.abspath(__file__) + "/../non-unit/server/rhnSQL/"))
)
import dbtests

config = ConfigParser()
config.read(os.path.dirname(os.path.abspath(__file__)) + "/db_settings.ini")

PG_HOST = config.get('postgresql', 'host')
PG_USER = config.get('postgresql', 'user')
PG_PASSWORD= config.get('postgresql', 'password')
PG_DATABASE = config.get('postgresql', 'database')

rhnSQL.initDB(backend="postgresql", host=PG_HOST, username=PG_USER,
        password=PG_PASSWORD, database=PG_DATABASE)

# Re-initialize to test re-use of connections:
rhnSQL.initDB(backend="postgresql", host=PG_HOST, username=PG_USER,
        password=PG_PASSWORD, database=PG_DATABASE)

def suite():
    # Append all test suites here:
    return unittest.TestSuite((
        dbtests.postgresql_suite(),
   ))

if __name__ == "__main__":
    try:
        import testoob
        testoob.main(defaultTest="suite")
    except ImportError:
        print "These tests would run prettier if you installed testoob. :)"
        unittest.main(defaultTest="suite")
