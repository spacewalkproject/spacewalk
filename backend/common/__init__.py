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
# Initialization file for the common module
#


# classes we make publicly available
from UserDictCase import UserDictCase
from RPC_Base import RPC_Base
from rhnException import rhnFault, rhnException, xmlrpclib, redirectException
from rhnTB import Traceback, fetchTraceback, add_to_seclist, check_with_seclist, get_seclist
from rhnConfig import CFG, initCFG

# try to figure out if we're running under Apache or not
try:
    from rhnApache import rhnApache
    import _apache
except ImportError:
    # no _apache available, not running under apache/mod_python
    pass

# functions we want exposed
from rhnLog import log_debug, log_error, log_clean, log_setreq, initLOG

__all__ = []
