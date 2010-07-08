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
# Module for storing client route through proxies
#

import string

from common import rhnFlags, log_debug
from server import rhnSQL, apacheAuth

def store_client_route(server_id):
    """ Stores the route the client took to get to hosted or the Satellite """

    log_debug(5, server_id)

    # get the old routing information for this server_id
    # oldRoute in this format: [(id0, hostname0),  (id1, hostname1),  ...]
    #                           closest to client, ..., closest to server
    h = rhnSQL.prepare("""
        select position,
               proxy_server_id,
               hostname
          from rhnServerPath
         where server_id = :server_id
        order by position
        """)
    h.execute(server_id=server_id)
    oldRoute = h.fetchall_dict() or []
    newRoute = []


    # code block if there *is* routing info in the headers
    # NOTE: X-RHN-Proxy-Auth described in proxy/broker/rhnProxyAuth.py
    if rhnFlags.test('X-RHN-Proxy-Auth'):
        tokens = string.split(rhnFlags.get('X-RHN-Proxy-Auth'), ',')
        tokens = filter(lambda token: token, tokens)

        log_debug(4, "route tokens", tokens)
        # newRoute in this format: [(id0, hostname0),  (id1, hostname1),  ...]
        #                           closest to client, ..., closest to server
        for token in tokens:
            token, hostname = apacheAuth.splitProxyAuthToken(token)
            if hostname is None:
                log_debug(3, "NOTE: RHN Proxy v1.1 detected - route tracking is unsupported")
                newRoute = []
                break
            newRoute.append((token[0], hostname))

        log_debug(4, "newRoute", newRoute)

    if oldRoute == newRoute:
        # Nothing to do here
        # This also catches the case of no routes at all
        return
        
    if oldRoute:
        # blow away table rhnServerPath entries for server_id
        log_debug(8, 'blow away route-info for %s' % server_id)
        h = rhnSQL.prepare("""
            delete from rhnServerPath where server_id = :server_id
        """)
        h.execute(server_id=server_id)

    if not newRoute:
        log_debug(3, "No new route to add")
        rhnSQL.commit()
        return

    log_debug(8, 'adding route-info entries: %s - %s' % (server_id, newRoute))

    h = rhnSQL.prepare("""
        insert into rhnServerPath 
               (server_id, proxy_server_id, position, hostname)
        values (:server_id, :proxy_server_id, :position, :hostname)
    """)
    server_ids = []
    proxy_ids = []
    proxy_hostnames = []
    positions = []
    counter = 0 
    for p in newRoute:
        proxy_id, proxy_hostname = p[:2]
        proxy_ids.append(proxy_id)
        proxy_hostnames.append(proxy_hostname)
        server_ids.append(server_id)
        positions.append(counter)
        counter = counter + 1

    log_debug(5, server_ids, proxy_ids, positions,
        proxy_hostnames)
    h.executemany(server_id=server_ids, proxy_server_id=proxy_ids,
        position=positions, hostname=proxy_hostnames)
    
    rhnSQL.commit()
