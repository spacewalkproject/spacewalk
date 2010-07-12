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

# global module imports
from common import apache

# common module imports
from common import CFG, initCFG, log_setreq, initLOG, Traceback

from apacheHandler import apacheHandler
apache_server       = apacheHandler()
HeaderParserHandler = apache_server.headerParserHandler
Handler             = apache_server.handler
CleanupHandler      = apache_server.cleanupHandler
LogHandler          = apache_server.logHandler


### Instantiate external entry points:
#HeaderParserHandler = HandlerWrap("headerParserHandler", init=1)
#Handler             = HandlerWrap("handler")
#CleanupHandler      = HandlerWrap("cleanupHandler")
#LogHandler          = HandlerWrap("logHandler")


