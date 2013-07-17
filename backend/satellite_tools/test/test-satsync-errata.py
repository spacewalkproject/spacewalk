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
from spacewalk.common.rhnLog import initLOG
from spacewalk.common.rhnConfig import CFG, initCFG
from spacewalk.server import rhnSQL
from syncCache import SyncCache
from syncContainerHandlers import processErrata


initCFG('server.satellite')
initLOG(CFG.LOG_FILE, CFG.DEBUG)
rhnSQL.initDB()

cache = SyncCache().init()
cache.addChannelsState(['redhat-linux-i386-8.0'])
cache.setChannelState('redhat-linux-i386-8.0')
#print cache.getCurrentChannelState()
#print cache.getChannelsState()
#print cache._sat_shtPkgCache.keys()
#print cache.getChnEids(cache.getCurrentChannelState())
processErrata()
