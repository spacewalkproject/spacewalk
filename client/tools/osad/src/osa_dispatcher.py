#
# Copyright (c) 2008--2011 Red Hat, Inc.
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

import sys
import select
import socket
import string
import SocketServer
from random import choice
from rhn.connections import idn_ascii_to_pune
from spacewalk.common.rhnLog import initLOG, log_debug, log_error
from spacewalk.common.rhnConfig import initCFG, CFG
from spacewalk.server import rhnSQL

import jabber_lib
import dispatcher_client

# Override the log functions
jabber_lib.log_debug = log_debug
jabber_lib.log_error = log_error

def main():
    return Runner().main()

class Runner(jabber_lib.Runner):
    client_factory = dispatcher_client.Client
    
    # We want the dispatcher to check in quite often in case the jabberd
    # connection drops
    _min_sleep = 10
    _max_sleep = 10
    
    def __init__(self):
        jabber_lib.Runner.__init__(self)
        initCFG("osa-dispatcher")
        self._tcp_server = None
        self._poll_interval = None
        self._next_poll_interval = None
        # Cache states
        self._state_ids = {}

    def read_config(self):
        ret = {
            'jabber_server' : CFG.jabber_server,
        }
        return ret

    _query_get_dispatcher_password = """
    select id, password
      from rhnPushDispatcher
     where jabber_id like :jabber_id
    """

    _update_dispatcher_password = """
    update rhnPushDispatcher
       set password = :password_in
     where id = :id_in
    """

    def get_dispatcher_password(self, username):
        h = rhnSQL.prepare(self._query_get_dispatcher_password)
        h.execute(jabber_id = username + "%")
        ret = h.fetchall_dict()

        if ret and len(ret) == 1:
            if ret[0]['password']:
                return ret[0]['password']
            else:
                # Upgrade Spacewalk 1.5 -> 1.6: the dispatcher row exists,
                # we just need to generate and save the password.
                self._password = self.create_dispatcher_password(32)
                u = rhnSQL.prepare(self._update_dispatcher_password)
                u.execute(password_in = self._password, id_in = ret[0]['id'])
                return self._password
        else:
            return None

    def create_dispatcher_password(self, length):
        chars = string.ascii_letters + string.digits
        return "".join(choice(chars) for x in range(length))

    def setup_config(self, config):
        # Figure out the log level
        debug_level = self.options.verbose
        if debug_level is None:
            debug_level = CFG.debug
        self.debug_level = debug_level
        initLOG(level=debug_level, log_file=CFG.log_file)

        # Get the ssl cert
        ssl_cert = CFG.osa_ssl_cert
        try:
            self.check_cert(ssl_cert)
        except jabber_lib.InvalidCertError, e:
            log_error("Invalid SSL certificate:", e)
            return 1

        self.ssl_cert = ssl_cert

        rhnSQL.initDB()

        self._username = 'rhn-dispatcher-sat'
        self._password = self.get_dispatcher_password(self._username)
        if not self._password:
            self._password = self.create_dispatcher_password(32)
        self._resource = 'superclient'
        js = config.get('jabber_server')
        self._jabber_servers = [ idn_ascii_to_pune(js) ]

    def fix_connection(self, c):
        "After setting up the connection, do whatever else is necessary"
        if not self._tcp_server:
            # Bind to a port
            self._tcp_server = bind_server(1290)

        port = self._tcp_server.get_server_port()
        # XXX Update the server's tables with our port
        log_debug(1, "Upstream notification server started on port", port)

        self._tcp_server.set_jabber_connection(c)

        self._poll_interval = CFG.poll_interval
        self._next_poll_interval = self._poll_interval

        if self._jabber_servers and self._jabber_servers[0]:
            hostname = self._jabber_servers[0]
        else:
            hostname = socket.gethostname()

        self._register_dispatcher(c.jid, hostname, port)

        c.retrieve_roster()
        log_debug(4, "Subscribed to",   c._roster.get_subscribed_to())
        log_debug(4, "Subscribed from", c._roster.get_subscribed_from())
        log_debug(4, "Subscribed both", c._roster.get_subscribed_both())

        client_jids = self._get_client_jids()
        client_jids = map(lambda x: x[0], client_jids)
        # Unsubscribe the dispatcher from any client jid that no longer exists
        self.cleanup_roster(c, client_jids)
        
        c.send_presence()
        return c

    def cleanup_roster(self, client, active_jids):
        roster = client._roster
        active_stripped_jids = {}
        for jid in active_jids:
            stripped_jid = jabber_lib.strip_resource(jid)
            stripped_jid = str(stripped_jid)
            active_stripped_jids[stripped_jid] = None

        roster_jids = roster.get_subscribed_to()
        roster_jids.update(roster.get_subscribed_from())
        roster_jids.update(roster.get_subscribed_both())

        to_remove = []
        for jid in roster_jids.keys():
            stripped_jid = jabber_lib.strip_resource(jid)
            stripped_jid = str(stripped_jid)
            if not active_stripped_jids.has_key(stripped_jid):
                to_remove.append(stripped_jid)
        
        client.cancel_subscription(to_remove)

    def process_once(self, client):
        log_debug(3)
        # First, clean up the nodes that have been pinged and have not
        # responded
        client.retrieve_roster()
        self.reap_pinged_clients()
        need_pinging = self._fetch_clients_to_be_pinged()
        log_debug(4, "Clients to be pinged:", need_pinging)
        if need_pinging:
            client.ping_clients(need_pinging)
        npi = self._next_poll_interval

        rfds, wfds, efds = select.select([client, self._tcp_server], [], [], npi)
        # Reset the next poll interval
        npi = self._next_poll_interval = self._poll_interval
        if client in rfds:
            log_debug(5, "before process")
            client.process(timeout=None)
            log_debug(5, "after process")
        if self._tcp_server in rfds:
            # we were tickled
            self._tcp_server.handle_request()
            npi = self._tcp_server.get_next_poll_interval() or self._poll_interval
        if not rfds:
            # Timeout
            log_debug(5,"Notifying jabber nodes")
            self._tcp_server.notify_jabber_nodes()
        else:
            log_debug(5,"Not notifying jabber nodes")
        

    _query_reap_pinged_clients = rhnSQL.Statement("""
        update rhnPushClient
           set state_id = :offline_id
         where state_id = :online_id
           and last_ping_time is not null
           and current_timestamp > next_action_time
    """)
    def reap_pinged_clients(self):
        # Get the online and offline ids
        online_id = self._get_push_state_id('online')
        offline_id = self._get_push_state_id('offline')

        h = rhnSQL.prepare(self._query_reap_pinged_clients)
        ret = h.execute(online_id=online_id, offline_id=offline_id)
        if ret:
            # We have changed something
            rhnSQL.commit()

    _query_fetch_clients_to_be_pinged = rhnSQL.Statement("""
        select id, name, shared_key, jabber_id
          from rhnPushClient
         where state_id = :online_id
           and last_ping_time is not null
           and next_action_time is null
           and jabber_id is not null
    """)
    _query_update_clients_to_be_pinged = rhnSQL.Statement("""
        update rhnPushClient
           set next_action_time = current_timestamp + numtodsinterval(:delta, 'second')
         where id = :client_id
    """)
    def _fetch_clients_to_be_pinged(self):
        online_id = self._get_push_state_id('online')
        h = rhnSQL.prepare(self._query_fetch_clients_to_be_pinged)
        h.execute(online_id=online_id)
        clients = h.fetchall_dict() or []
        rhnSQL.commit()
        if not clients:
            # Nothing to do
            return

        # XXX Need config option
        delta = 20
        
        client_ids = map(lambda x: x['id'], clients)
        deltas = [ delta ] * len(client_ids)
        h = rhnSQL.prepare(self._query_update_clients_to_be_pinged)
        h.executemany(client_id=client_ids, delta=deltas)
        rhnSQL.commit()
        return clients

    def _get_push_state_id(self, state):
        if self._state_ids.has_key(state):
            return self._state_ids[state]

        t = rhnSQL.Table('rhnPushClientState', 'label')
        row = t[state]
        assert row is not None
        self._state_ids[state] = row['id']
        return row['id']
    

    _query_register_dispatcher = rhnSQL.Statement("""
        declare
            i numeric;
        begin
            update rhnPushDispatcher
               set last_checkin = current_timestamp,
                   hostname = :hostname_in,
                   port = :port_in
             where jabber_id = :jabber_id_in
            returning id into i;
            if i is null then
                -- Have to insert the row
                insert into rhnPushDispatcher 
                       (id, jabber_id, last_checkin, hostname, port, password)
                values (sequence_nextval('rhn_pushdispatch_id_seq'), :jabber_id_in, current_timestamp,
                       :hostname_in, :port_in, :password_in);
            end if;
        end;
    """)

    def _register_dispatcher(self, jabber_id, hostname, port):
        h = rhnSQL.prepare(self._query_register_dispatcher, params = ( 'hostname_in varchar', 'port_in numeric', 'jabber_id_in varchar', 'password_in varchar' ))
        h.execute(jabber_id_in=jabber_id, hostname_in=hostname, port_in=port, password_in=self._password)
        rhnSQL.commit()

    _query_get_client_jids = rhnSQL.Statement("""
        select jabber_id, TO_CHAR(modified, 'YYYY-MM-DD HH24:MI:SS') modified
          from rhnPushClient
         where jabber_id is not null
    """)
    def _get_client_jids(self):
        h = rhnSQL.prepare(self._query_get_client_jids)
        h.execute()
        ret = []
        while 1:
            row = h.fetchone_dict()
            if not row:
                break
            # Save the modified time too - we don't want to mark as offline
            # clients that just checked in
            ret.append((row['jabber_id'], row['modified']))
        return ret
        

class UpstreamServer(SocketServer.TCPServer):
    def __init__(self, server_address):
        SocketServer.TCPServer.__init__(self, server_address, None)
        self._next_poll_interval = None
    
    def get_server_port(self):
        return self.server_address[1]

    def get_next_poll_interval(self):
        return self._next_poll_interval

    def set_jabber_connection(self, jabber_connection):
        self.jabber_connection = jabber_connection

    def finish_request(self, request, client_address):
        log_debug(2, client_address)
        log_debug(2,"###about to notify jabber nodes from finish request")
        self.notify_jabber_nodes()

    def notify_jabber_nodes(self):
        log_debug(3)
        h = rhnSQL.prepare(self._query_get_pending_clients)
        h.execute()
        self._next_poll_interval = None

        while 1:
            row = h.fetchone_dict()
            if not row:
                # End of loop
                break

            delta = row['delta']
            if delta > 0:
                # Set the next poll interval to something large if it was not
                # previously set before; this way min() will pick up this
                # delta, but we don't have to special-case the first delta we
                # find
                npi = self._next_poll_interval or 86400
                self._next_poll_interval = min(delta, npi)
                log_debug(4, "Next poll interval", delta)
                continue
            
            jabber_id = row['jabber_id']
            if jabber_id is None:
                # Not even online
                continue
            
            if not self.jabber_connection.jid_available(jabber_id):
                log_debug(4, "Node %s not available for notifications" %
                    jabber_id)
                # iterate further, in case there are other clients that 
                # CAN be notified.
                continue

            log_debug(4, "Notifying", jabber_id, row['server_id'])
            self.jabber_connection.send_message(jabber_id,
                jabber_lib.NS_RHN_MESSAGE_REQUEST_CHECKIN)
        rhnSQL.commit()

    # We need to drive this query by rhnPushClient since it's substantially
    # smaller than rhnAction
    _query_get_pending_clients = rhnSQL.Statement("""
        select a.id, sa.server_id, pc.jabber_id,
               date_diff_in_days(current_timestamp, earliest_action) * 86400 delta
          from
               rhnServerAction sa,
               rhnAction a,
               rhnPushClient pc
         where pc.server_id = sa.server_id
           and sa.action_id = a.id
           and sa.status in (0, 1) -- Queued or picked up
           and not exists (
               -- This is like saying 'this action has no
               -- prerequisite or has a prerequisite that has completed
               -- (status = 2)
               select 1
                 from rhnServerAction sap
                where sap.server_id = sa.server_id
                  and sap.action_id = a.prerequisite
                  and sap.status != 2
            )
         order by earliest_action
    """)


def bind_server(start_port=1290):
    port = start_port
    while 1:
        server_addr = ('', port)
        try:
            return UpstreamServer(server_addr)
        except SocketServer.socket.error, e:
            if e[0] != 98:
                # address already in use
                raise
            port = port + 1
    return None

if __name__ == '__main__':
    sys.exit(main() or 0)
