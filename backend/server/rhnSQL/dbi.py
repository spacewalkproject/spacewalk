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
#

from .const import ORACLE, POSTGRESQL

# Map supported backend constants to a specific Python driver:
BACKEND_DRIVERS = {
    ORACLE: "cx_Oracle",
    POSTGRESQL: "postgresql",
}


def get_database_module(backend=None):
    """Loads the database driver module, performing autodetection if needed"""

    # Assume Oracle if no backend is specified:
    if backend is None:
        driver = BACKEND_DRIVERS[ORACLE]
    else:
        driver = BACKEND_DRIVERS[backend]

    driver_dir = "spacewalk.server.rhnSQL"
    driver_mod = "driver_" + driver
    try:
        module = __import__(driver_dir, globals(), locals(), [driver_mod])
        module = getattr(module, driver_mod)
    except ImportError:
        raise

    return module


def get_database_class(backend=None):
    """Returns the database class"""
    module = get_database_module(backend=backend)
    return module.Database
