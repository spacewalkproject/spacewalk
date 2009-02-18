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

import time
from common import log_debug, log_error
from server import rhnSQL

import jabber_lib


class Client(jabber_lib.JabberClient):
    def __init__(self, *args, **kwargs):
        apply(jabber_lib.JabberClient.__init__, (self, ) + args, kwargs)
        self.username = None
        self.resource = None
        #self.DEBUG = jabber_lib.my_debug

    def start(self, username, password, resource):
        # XXX find a better name for this function
        log_debug(2)
        self.auth(username, password, resource)
        log_debug(3, "Authenticated")
        self.username = username
        self.resource = resource
        self.jid = "%s@%s/%s" % (self.username, self._host, self.resource)

        self.username = username
        self.resource = resource

    def _add_jid_resource(self, jid, resource):
        if not isinstance(jid, jabber_lib.jabber.JID) or jid.resource:
            return jid
        return jabber_lib.jabber.JID(str(jid) + '/' + resource)

    def _fix_jid(self, jid):
        return self._add_jid_resource(jid, 'osad')

    def _check_signature(self, stanza, actions=None):
        # Do we have this client in the table?
        jid = stanza.getFrom()
        if jid is None:
            log_debug(3, 'no from')
            return None
        jid = str(self._fix_jid(jid))
        # Look for a <x> child that has our namespace
        xes = stanza.getTags('x')
        for x in xes:
            if x.getNamespace() != jabber_lib.NS_RHN_SIGNED:
                continue
            break
        else: #for
            log_debug(1, "No signature node found in stanza")
            return None
        # We now have our signature node
        x_client_id = x.getAttr('client-id')

        row = lookup_client_by_name(x_client_id)
        if not row:
            log_debug(3, 'no client found', x_client_id)
            if self.debug_level > 5:
                raise Exception(1)
            return None
        shared_key = row['shared_key']
        timestamp = x.getAttr('timestap')
        serial = x.getAttr('serial')
        action = x.getAttr('action')

        if actions and action not in actions:
            log_debug(1, "action %s not allowed" % action)
            return None
        
        attrs = {
            'client-id'     : x_client_id,
            'timestamp'     : x.getAttr('timestamp'),
            'serial'        : x.getAttr('serial'),
            'action'        : x.getAttr('action'),
            'jid'           : jid,
        }
        signing_comps = ['client-id', 'timestamp', 'serial', 'action', 'jid']
        args = [shared_key, self.jid]
        for sc in signing_comps:
            args.append(attrs[sc])

        log_debug(4, "Signature args", args)
        signature = apply(jabber_lib.sign, args)
        x_signature = x.getAttr('signature')
        if signature != x_signature:
            log_debug(1, "Signatures do not match", signature, x_signature)
            if self.debug_level > 5:
                raise Exception(1)
            return None
        # Happy joy
        return x

    def _create_signature(self, jid, action):
        row = lookup_client_by_jid(jid)
        if not row:
            log_debug(3, 'no client found for jid', jid)
            if self.debug_level > 5:
                raise Exception(1)
            return None
        full_jid = row['jabber_id']
        shared_key = row['shared_key']
        attrs = {
            'timestamp'     : int(time.time()),
            'serial'        : self.get_unique_id(),
            'action'        : action,
            'jid'           : self.jid,
        }
        signing_comps = ['timestamp', 'serial', 'action', 'jid']
        args = [shared_key, full_jid]
        for sc in signing_comps:
            args.append(attrs[sc])

        log_debug(4, "Signature args", args)
        attrs['signature'] = apply(jabber_lib.sign, args)

        x = jabber_lib.jabber.xmlstream.Node('x')
        x.setNamespace(jabber_lib.NS_RHN_SIGNED)
        for k, v in attrs.items():
            x.putAttr(k, v)
        return x

    def _message_callback(self, client, stanza):
        log_debug(4)
        assert stanza.getName() == 'message'

        # Actions we know how to react to
        actions = [
            jabber_lib.NS_RHN_MESSAGE_RESPONSE_CHECKIN, 
            jabber_lib.NS_RHN_MESSAGE_RESPONSE_PING,
        ]
        sig = self._check_signature_from_message(stanza, actions)
        if not sig:
            return

        self.update_client_message_received(stanza.getFrom())

        action = sig.getAttr('action')
        if action == jabber_lib.NS_RHN_MESSAGE_RESPONSE_PING:
            log_debug(1, 'Ping response')
            # XXX
            return

    def ping_clients(self, clients):
        for client in clients:
            jid = client['jabber_id']
            if jid is None:
                continue
            self.send_message(jid, jabber_lib.NS_RHN_MESSAGE_REQUEST_PING)
        
    def set_jid_available(self, jid):
        jabber_lib.JabberClient.set_jid_available(self, jid)
        self._set_state(jid, self._get_push_state_id('online'))

    def set_jid_unavailable(self, jid):
        jabber_lib.JabberClient.set_jid_unavailable(self, jid)
        self._set_state(jid, self._get_push_state_id('offline'))

    _query_set_state = rhnSQL.Statement("""
        update rhnPushClient
           set state_id = :state_id,
               last_ping_time = NULL,
               next_action_time = NULL
         where jabber_id = :jid
    """)
    def _set_state(self, jid, state_id):
        h = rhnSQL.prepare(self._query_set_state)
        h.execute(state_id=state_id, jid=str(jid))
        rhnSQL.commit()

    def _get_push_state_id(self, state):
        t = rhnSQL.Table('rhnPushClientState', 'label')
        row = t[state]
        assert row is not None
        return row['id']

    _query_update_client_message_received = rhnSQL.Statement("""
        update rhnPushClient
           set state_id = :state_id,
               last_message_time = sysdate,
               last_ping_time = NULL,
               next_action_time = NULL
         where jabber_id = :jid
    """)
    def update_client_message_received(self, jid):
        jid = str(jid)
        state_id = self._get_push_state_id('online')
        h = rhnSQL.prepare(self._query_update_client_message_received)
        ret = h.execute(jid=jid, state_id=state_id)
        if ret:
            rhnSQL.commit()

    _query_update_client_message_sent = rhnSQL.Statement("""
        update rhnPushClient
           set next_action_time = sysdate + :delta / 86400
         where jabber_id = :jid
    """)
    def update_client_message_sent(self, jid):
        jid = str(jid)
        h = rhnSQL.prepare(self._query_update_client_message_sent)
        delta = 10
        ret = h.execute(delta=delta, jid=jid)
        if ret:
            rhnSQL.commit()

class InvalidClientError(Exception):
    pass

def lookup_client_by_name(client_name):
    client_name = str(client_name)
    t = rhnSQL.Table('rhnPushClient', 'name')
    row = t[client_name]
    if row is None:
        raise InvalidClientError(client_name)
    return row

def lookup_client_by_jid(jid):
    if not isinstance(jid, jabber_lib.jabber.JID):
        jid = jabber_lib.jabber.JID(jid)

    if not jid.getResource():
        # add the resource so we can find the guy in our table
        jid.setResource('osad')

    jid = str(jid)
    t = rhnSQL.Table('rhnPushClient', 'jabber_id')
    row = t[jid]
    if row is None:
        raise InvalidClientError(jid)
    return row
