#
# Copyright (c) 2008--2015 Red Hat, Inc.
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

import os
import time
import string
from subprocess import Popen
import jabber_lib
from rhn_log import log_debug

class Client(jabber_lib.JabberClient):

    RHN_CHECK_CMD = '/usr/sbin/rhn_check'

    def __init__(self, *args, **kwargs):
        apply(jabber_lib.JabberClient.__init__, (self, ) + args, kwargs)
        self.username = None
        self.resource = None
        self.client_id = None
        self.shared_key = None
        self.debug_level = 0
        self.time_drift = 0
        self._dispatchers = []
        self._config = {}
        self._rhn_check_process = None
        self._rhn_check_fail_count = 0
        self._stuck_subscription_timestamp = time.time()

    def set_config_options(self, config):
        self._config = config

    def set_debug_level(self, debug_level):
        self.debug_level = debug_level

    def set_dispatchers(self, dispatchers):
        self._dispatchers = dispatchers

    def start(self, username, password, resource):
        log_debug(3, username, password, resource)
        # XXX find a better name for this function
        self.auth(username, password, resource)
        self.username = username
        self.resource = resource
        self.jid = "%s@%s/%s" % (self.username, self._host, self.resource)

        # Retrieve roster
        self.retrieve_roster()

    def _create_signature(self, jid, action):
        log_debug(4, jid, action)
        attrs = {
            'client-id'     : self.client_id,
            'timestamp'     : int(time.time()),
            'serial'        : self.get_unique_id(),
            'action'        : action,
            'jid'           : self.jid,
        }
        signing_comps = ['client-id', 'timestamp', 'serial', 'action', 'jid']
        args = [self.shared_key, jid]
        for sc in signing_comps:
            args.append(attrs[sc])

        log_debug(4, "Signature args", args)
        attrs['signature'] = apply(jabber_lib.sign, args)

        x = jabber_lib.jabber.xmlstream.Node('x')
        x.setNamespace(jabber_lib.NS_RHN_SIGNED)
        for k, v in attrs.items():
            x.putAttr(k, v)
        return x

    def _lookup_dispatcher(self, jid):
        # presence may not send a resource in the JID
        if not isinstance(jid, jabber_lib.jabber.JID) or jid.resource:
            return str(jid)
        jid = str(jid)
        jid_len = len(jid)
        for d in self._dispatchers:
            if d[:jid_len] != jid:
                continue
            assert len(d) > jid_len
            if d[jid_len] == '/':
                # This is it
                return d
        return None

    def _fix_jid(self, jid):
        return self._lookup_dispatcher(jid)

    def _check_signature(self, stanza, actions=None):
        # Do we have this client in the table?
        jid = stanza.getFrom()
        if jid is None:
            log_debug(3, 'no from')
            return None
        # Look for a <x> child that has our namespace
        xes = stanza.getTags('x')
        for x in xes:
            if x.getNamespace() != jabber_lib.NS_RHN_SIGNED:
                continue
            break
        else: #for
            log_debug(1, "No signature node found in stanza")
            return None

        timestamp = x.getAttr('timestamp')
        try:
            timestamp = int(timestamp)
        except ValueError:
            log_debug(1, "Invalid message timestamp", timestamp)
            return None
        now = time.time()

        current_drift = timestamp - now
        # Allow for a 120 seconds drift
        max_drift = 120
        abs_drift = abs(current_drift - self.time_drift)
        if abs_drift > max_drift:
            log_debug(1, "Dropping message, drift is too big", abs_drift)

        action = x.getAttr('action')

        if actions and action not in actions:
            log_debug(1, "action %s not allowed" % action)
            return None

        # We need the fully qualified JID here too
        full_jid = x.getAttr('jid')
        if not full_jid:
            log_debug(3, "Full JID not found in signature stanza")
            return None

        attrs = {
            'timestamp'     : x.getAttr('timestamp'),
            'serial'        : x.getAttr('serial'),
            'action'        : x.getAttr('action'),
            'jid'           : full_jid,
        }
        signing_comps = ['timestamp', 'serial', 'action', 'jid']
        args = [self.shared_key, self.jid]
        for sc in signing_comps:
            args.append(attrs[sc])

        log_debug(4, "Signature args", args)
        signature = apply(jabber_lib.sign, args)
        x_signature = x.getAttr('signature')
        if signature != x_signature:
            log_debug(1, "Signatures do not match", signature, x_signature)
            return None
        # Happy joy
        return x

    def _message_callback(self, client, stanza):
        log_debug(4)
        assert stanza.getName() == 'message'

        # Actions we know how to react to
        actions = [
            jabber_lib.NS_RHN_MESSAGE_REQUEST_CHECKIN,
            jabber_lib.NS_RHN_MESSAGE_REQUEST_PING,
        ]
        sig = self._check_signature_from_message(stanza, actions)
        if not sig:
            return

        action = sig.getAttr('action')
        if action == jabber_lib.NS_RHN_MESSAGE_REQUEST_PING:
            log_debug(1, 'Ping request')
            self.send_message(stanza.getFrom(),
                jabber_lib.NS_RHN_MESSAGE_RESPONSE_PING)
            return

        # Send confirmation
        self.send_message(stanza.getFrom(),
            jabber_lib.NS_RHN_MESSAGE_RESPONSE_CHECKIN)

        # Checkin
        run_check = self._config.get('run_rhn_check')
        log_debug(3, "run_rhn_check:", run_check)

        if not self._config.get('run_rhn_check'):
            log_debug(0, "Pretend that command just ran")
        else:
            self.run_rhn_check_async()

    def process_loop_hook(self):
        # if rhn_check process exists, check it last
        # status
        if self._rhn_check_process is not None:
            retcode = self._rhn_check_process.poll()
            if retcode is not None:
                log_debug(3, "rhn_check exited with status %d" % retcode)
                if retcode != 0:
                    self._rhn_check_fail_count += 1
                else:
                    self._rhn_check_fail_count = 0
                self._rhn_check_process = None
            else:
                log_debug(3, "rhn_check is still running...")
        else:
            # rhn_check is not running but last one failed
            # we force a check even if the server does not
            # contact us. The idea is to exhaust the number of
            # times we can pick up the action until the server fails
            # it.
            if self._rhn_check_fail_count > 0:
                log_debug(3, "rhn_check failed last time, " \
                          "force retry (fail count %d)" % self._rhn_check_fail_count)
                self.run_rhn_check_async()

    def run_rhn_check_async(self):
        """Runs rhn_check and keeps a handle that it is monitored
        during the event loop
        """
        command = self._config.get('rhn_check_command')
        # rhn_check now checks for multiple instances,
        # lets use that directly
        if command is None:
            args = [self.RHN_CHECK_CMD]
        else:
            # XXX should find a better way to get the list of args
            args = string.split(command)

        # if rhn_check process already exists
        if self._rhn_check_process is not None:
            retcode = self._rhn_check_process.poll()
            if retcode is None:
                log_debug(3, "rhn_check is still running, not running again...")
                return

        if self._rhn_check_fail_count > 0:
            log_debug(3, "rhn_check failed last time (fail count %d)" % self._rhn_check_fail_count)

        log_debug(3, "About to execute:", args)
        oldumask = os.umask(0077)
        os.umask(oldumask | 0022)
        self._rhn_check_process = Popen(args)
        os.umask(oldumask)
        log_debug(0, "executed %s with pid %d" % (args[0], self._rhn_check_process.pid))

    def unstick_contacts(self, jids):
        """If we are waiting for 'subscribed' presence stanzas for too long, ask again"""
        if time.time() - self._stuck_subscription_timestamp > 60:
            for jid in jids:
                stripped_jid = self._strip_resource(jid)
                if self.needs_unsticking(stripped_jid):
                    presence_node = jabber_lib.JabberPresenceNode(to=stripped_jid, type="subscribe")
                    presence_node.setID("presence-%s" % self.get_unique_id())
                    log_debug(4, "Re-sending presence subscription request", presence_node)
                    self.send(presence_node)
            self._stuck_subscription_timestamp = time.time()

    def needs_unsticking(self, jid):
        """Returns True if jid is in state [none + ask] or [from + ask]"""
        contact = None

        subscribed_none = self._roster.get_subscribed_none()
        if subscribed_none.has_key(jid):
            contact = subscribed_none[jid]

        subscribed_from = self._roster.get_subscribed_from()
        if subscribed_from.has_key(jid):
            contact = subscribed_from[jid]

        if contact is not None:
            return contact.has_key('ask') and contact['ask'] == 'subscribe'

        return False
