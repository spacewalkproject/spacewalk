#!/usr/bin/env python
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


import sys

def get_database_module(driver=None):
    """Loads the database driver module, performing autodetection if needed"""
    
    if driver is None:
        # Driver not specified, best guess
        if hasattr(sys, 'version_info'):
            # Version of python is modern enough
            driver = "cx_Oracle"
        else:
            driver = "DCOracle"

    driver_dir = "server.rhnSQL"
    driver_mod = "driver_" + driver
    try:
        module = __import__(driver_dir, globals(), locals(), [driver_mod])
        module = getattr(module, driver_mod)
    except ImportError:
        raise

    return module

def get_database_class(driver=None):
    """Returns the database class"""
    module = get_database_module(driver=driver)
    return module.Database
