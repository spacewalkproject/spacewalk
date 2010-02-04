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
#
# This file defines the classes available for the XMLRPC receiver
#

__all__ = []

import registration
import up2date
import queue
import errata
import proxy
import get_handler

rpcClasses = {
    "registration"      : registration.Registration,
    "up2date"           : up2date.Up2date,
    "queue"		: queue.Queue,
    "errata"            : errata.Errata,
    "proxy"             : proxy.Proxy,
    "servers"           : up2date.Servers,
    }

getHandler = get_handler.GetHandler
