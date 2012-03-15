# -*- coding: utf-8 -*-
#
# Copyright (c) 2011 Novell
#
# This software is licensed to you under the GNU General Public License,
# version 2 (GPLv2). There is NO WARRANTY for this software, express or
# implied, including the implied warranties of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
# along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
#

from spacewalk.common.rhnLog import log_debug
from spacewalk.server import rhnSQL
from spacewalk.server.rhnLib import InvalidAction

# the "exposed" functions
__rhnexport__ = ['deploy']

# returns the values for deploying a virtual machine with an image
#
# file_name, checksum, mem_kb, vcpus, imageType
#
def deploy(serverId, actionId, dry_run=0):
    log_debug(3)
    statement = """
        select aid.mem_kb, aid.vcpus, aid.bridge_device,aid.download_url,
               aid.proxy_server, aid.proxy_user, aid.proxy_pass
          from rhnActionImageDeploy aid
	   where aid.action_id = :action_id"""
    h = rhnSQL.prepare(statement)
    h.execute(action_id = actionId)
    row = h.fetchone_dict()
    if not row:
        # No image for this action
        raise InvalidAction("image.deploy: No image found for action id "
            "%s and server %s" % (actionId, serverId))

    for key in [ 'download_url', 'proxy_server', 'proxy_user', 'proxy_pass', 'bridge_device' ]:
        if row[key] == None:
            row[key] = ""

    params = {
        "downloadURL"   : row['download_url'],
        "proxySettings" : { "proxyURL" : row['proxy_server'], "proxyUser" : row['proxy_user'], "proxyPass" : row['proxy_pass'] },
        "memKB"         : row['mem_kb'],
        "vCPUs"         : row['vcpus'],
        "domainName"    : "",
        "virtBridge"    : row['bridge_device'] }
    return (params)
