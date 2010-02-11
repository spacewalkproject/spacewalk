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

import os
import hashlib
import sys
import time
import types
import select
import socket
import jabber
import random
import string
try:
    from optparse import OptionParser, Option
except ImportError:
    from optik import OptionParser, Option
import traceback
from cStringIO import StringIO
from rhn import SSL

from rhn_log import log_debug, log_error

try:
    True, False
except NameError:
    True, False = 1, 0

NS_RHN = "http://jabber.rhn.redhat.com/jabber"
NS_RHN_SIGNED = "%s/signed" % NS_RHN
NS_RHN_PRESENCE_SUBSCRIBE = "%s/presence/subscribe" % NS_RHN
NS_RHN_PRESENCE_SUBSCRIBED = "%s/presence/subscribed" % NS_RHN
NS_RHN_PRESENCE_UNSUBSCRIBE = "%s/presence/unsubscribe" % NS_RHN
NS_RHN_MESSAGE_REQUEST_CHECKIN = "%s/message/request/checkin" % NS_RHN
NS_RHN_MESSAGE_RESPONSE_CHECKIN = "%s/message/response/checkin" % NS_RHN
NS_RHN_MESSAGE_REQUEST_PING = "%s/message/request/ping" % NS_RHN
NS_RHN_MESSAGE_RESPONSE_PING = "%s/message/response/ping" % NS_RHN

NS_STARTTLS = 'urn:ietf:params:xml:ns:xmpp-tls'
NS_STANZAS = "urn:ietf:params:xml:ns:xmpp-stanzas"

# The class that starts everything
class Runner:
    option_parser = OptionParser
    option = Option

    client_factory = None

    # How often will we try to reconnect. We want this randomized, so not all
    # clients hit the server at the same time
    _min_sleep = 60
    _max_sleep = 90

    def __init__(self):
        self.options_table = [
            self.option("-v", "--verbose",       action="count",
                help="Increase verbosity"),
            self.option('-N', "--nodetach",      action="store_true",
                help="Suppress backgrounding and detachment of the process"),
            self.option('--pid-file',            action="store",
                help="Write to this PID file"),
            self.option('--logfile',             action="store",
                help="Write log information to this file"),
        ]

        self.ssl_cert = None
        self.debug_level = 0
        self._jabber_servers = []
        self._username = None
        self._password = None
        self._resource = None
        self._in_background = 0

    def process_cli_options(self):
        "Process command line options"
        self._parser = self.option_parser(option_list=self.options_table)
        self.options, self.args = self._parser.parse_args()

    def main(self):
        """Method that starts up everything
        - processes command line options
        - big loop to reconnect if necessary
            - read config
            - setup config
            - setup jabber connection
            - process requests
        """
        self.process_cli_options()
        force_setup = 0
        no_fork = None
        while 1:
            # First time around?
            if no_fork is None:
                # Yes, we may be forking
                no_fork=0
            else:
                # Been here before, no need to fork anymore
                no_fork=1
            
            try:
                config = self.read_config()
                if force_setup:
                    log_debug(2,"###Forcing setup")
                    self.setup_config(config, 1)
                    force_setup = 0
                else:
                    self.setup_config(config)
                c = self.setup_connection(no_fork=no_fork)
                self.fix_connection(c)
                self.process_forever(c)
            except KeyboardInterrupt:
                try:
                    c.disconnect()
                except:
                    pass
                sys.exit(0)
            except SystemExit:
                raise
            except RestartRequested, e:
                log_error("Restart requested", e)
                if not self.is_in_background():
                    self.push_to_background()
                continue
            except NeedRestart, e:
                log_debug(3, "Need Restart")
                force_setup = 1
                continue
            except JabberConnectionError:
                time_to_sleep = random.randint(self._min_sleep, self._max_sleep)
                log_debug(0, "Unable to connect to jabber servers, sleeping" 
                    " %s seconds" % time_to_sleep)
                if not self.is_in_background():
                    self.push_to_background()
                try:
                    time.sleep(time_to_sleep)
                except KeyboardInterrupt:
                    sys.exit(0)
            except InvalidCertError, e:
                log_error("Invalid Cert Error:")
                raise
            except:
                # Print traceback
                log_error("Error caught:")
                log_error(extract_traceback())
                time_to_sleep = random.randint(self._min_sleep, self._max_sleep)
                log_debug(3, "Sleeping", time_to_sleep, "seconds")
                if not self.is_in_background():
                    self.push_to_background()
                try:
                    time.sleep(time_to_sleep)
                except KeyboardInterrupt:
                    sys.exit(0)

    def fix_connection(self, client):
        "After setting up the connection, do whatever else is necessary"
        return client

    def preprocess_once(self, client):
        return client

    def process_forever(self, client):
        """Big loop to process requests
        """
        log_debug(1)
        self.preprocess_once(client)
        while 1:
            try:
                self.process_once(client)
                # random sleep so we don't kill CPU performance, bz 222988
                time_to_sleep = random.randint(6, 10)
                time.sleep(time_to_sleep)
            except KeyboardInterrupt:
                # CTRL+C
                client.disconnect()
                sys.exit(0)
            except:
                # XXX to be refined later
                raise

    def process_once(self, client):
        "To be overridden in a client class"
        raise NotImplementedError

    def setup_config(self, config):
        pass

    def read_config(self):
        return {}

    def is_in_background(self):
        return self._in_background

    def push_to_background(self):
        if not self.options.nodetach:
            # Detach and push to the background
            push_to_background()
            self._in_background = 1

        pid_file = self.options.pid_file
        if pid_file:
            try:
                os.unlink(pid_file)
            except OSError, e:
                if e.errno != 2:
                    raise
            try:
                # Make sure we don't create the file world-writable (#162619)
                fd = os.open(pid_file, os.O_WRONLY| os.O_APPEND | os.O_CREAT, 0644)
                os.write(fd, str(os.getpid()))
                os.write(fd, "\n")
                os.close(fd)
            except OSError:
                pass

    def check_cert(self, cert):
        return check_cert(cert)

    def print_message(self, js, e):
        log_debug(1, e)
        log_debug(1, "Could not connect to jabber server", js)

    def setup_connection(self, no_fork=0):
        """
        - initializes a Jabber connection (by instantiating a Jabber client)
        - if necessary, pushes to background
        - authentication and resource binding (by calling start())

        Possible causes for this function to return None:
        - jabber server is not started
        - jabber server is started but did not initialize SSL just yet

        This function will kill the process with exit code 1 if the SSL
        handshake failed (an indication of a mismatching CA cert). We do this
        so starting the program as a daemon to fail if this happens. Of
        course, if the server is down and the CA cert is bad, then the daemon
        will start but will silently fail afterwards; the error log should
        have a traceback though.
        """
        for js in self._jabber_servers:
            log_debug(3, "Connecting to", js)
            try:
                c = self._get_jabber_client(js)
                log_debug(1, "Connected to jabber server", js)
                break
            except SSLHandshakeError:
                # Error doing the handshake - this is a permanent error
                sys.exit(1)
            except socket.error, e:
                self.print_message(js, "socket error")
                log_error(extract_traceback())
                continue
            except JabberError, e:
                self.print_message(js, "JabberError")
                log_error(extract_traceback())
                continue 
            except SSLError, e:
                self.print_message(js, "SSLError")
                log_error(extract_traceback())
                continue
        else:
            # Ran out of Jabber servers to try
            # Could not connect to any servers
            log_debug(1, "Could not connect to any jabber server")
            # Make sure we push to background at this point, we don't want the
            # service to block at startup
            if not no_fork:
                self.push_to_background()
            raise JabberConnectionError

        # If we got to this point, we have a connection set up
        if not no_fork:
            self.push_to_background()

        # Autentication and resource binding
        c.start(username=self._username, password=self._password, 
            resource=self._resource)

        # Register callbacks
        c.custom_handler.register_callback(c._presence_callback, 'presence')
        c.custom_handler.register_callback(c._message_callback, 'message')
        return c
    
    def _get_jabber_client(self, jabber_server):
        """Returns a connected Jabber client, or raises an exception if it was
        unable to connect"""
        log_debug(3)
        arr = string.split(jabber_server, ':', 1)
        jabber_server = arr[0]
        if len(arr) == 2:
            jabber_port = int(arr[1])
            log_debug(2, "Connecting to", jabber_server, jabber_port)
            c = self.client_factory(jabber_server, jabber_port)
        else:
            log_debug(2, "Connecting to", jabber_server)
            c = self.client_factory(jabber_server)

        c.debug_level = self.debug_level
        c.add_trusted_cert(self.ssl_cert)
        c.connect()
        return c

class InvalidCertError(SSL.SSL.Error):
    def __str__(self):
        return string.join(self.args, " ")
    __repr__ = __str__

def check_cert(cert_path):
    if cert_path is None:
        raise InvalidCertError("Cannot pass None as a certificate path")
    try:
        cert = open(cert_path).read()
    except IOError:
        raise InvalidCertError("Unable to read file", cert_path)
    try:
        x509 = SSL.crypto.load_certificate(SSL.crypto.FILETYPE_PEM, cert)
    except SSL.crypto.Error:
        raise InvalidCertError("Unable to open certificate", cert_path)
    log_debug(4, "Loading cert", x509.get_subject())
    if x509.has_expired():
        raise InvalidCertError("Expired certificate", cert_path)

def sign(secret_key, *values):
    h = hashlib.new('sha1', secret_key).hexdigest()
    for v in values:
        h = hashlib.new('sha1', h + str(v)).hexdigest()
    return h

class JabberCallback:
    def __init__(self, stanza_id=None, stanza_ns=None):
        log_debug(4, stanza_id, stanza_ns)
        self.stanza_id = stanza_id
        self.stanza_ns = stanza_ns

    def callback(self, client, stanza):
        pass

# getAttr is braindead, rewrite it
class JabberProtocolNode(jabber.Protocol):
    def getAttr(self, key):
        return self.attrs.get(key, None)

class JabberIqNode(jabber.Iq, JabberProtocolNode):
    getAttr = JabberProtocolNode.getAttr

class JabberMessageNode(jabber.Message, JabberProtocolNode):
    getAttr = JabberProtocolNode.getAttr

class JabberPresenceNode(jabber.Presence, JabberProtocolNode):
    getAttr = JabberProtocolNode.getAttr

class Handlers:
    def __init__(self):
        log_debug(3)
        self._handlers = {}


    def dispatch(self, client, stanza):
        log_debug(5, stanza)

        self.cleanup_expired_callbacks()
        
        callbacks = self._get_callbacks(stanza)
        if not callbacks:
            log_debug(4, "Unhandled stanza", stanza)
            return
        for callback in callbacks:
            log_debug(6, "Calling callback", callback, stanza)
            callback(client, stanza)

    def _get_callbacks(self, stanza):
        log_debug(5, stanza)
        stanza_name = stanza.getName()
        if not self._handlers.has_key(stanza_name):
            return []
        stanza_id = stanza.getID()
        stanza_ns = stanza.getNamespace()
        result = {}
        (h_idns, h_id, h_ns, l_def) = self._handlers[stanza_name]

        if stanza_id is not None and stanza_ns:
            cbs = h_idns.get((stanza_id, stanza_ns), [])
            self._get_callbacks_from_list(cbs, result)
        if stanza_id is not None:
            cbs = h_id.get(stanza_id, [])
            self._get_callbacks_from_list(cbs, result)
        if stanza_ns:
            cbs = h_ns.get(stanza_ns, [])
            self._get_callbacks_from_list(cbs, result)
        self._get_callbacks_from_list(l_def, result)
        return result.keys()

    def _get_callbacks_from_list(self, l, result_hash):
        for ent in l:
            (callback, expiry, usage_count) = ent[:3]
            if usage_count is None or usage_count >= 1:
                result_hash[callback] = None
                if usage_count is None:
                    # We're done here
                    continue

            usage_count = usage_count - 1
            if usage_count <= 0:
                # Expired
                l.remove(ent)
                continue
            # Update the usage count
            ent[2] = usage_count - 1
                
    def register_callback(self, callback, stanza_name, stanza_id=None, 
            stanza_ns=None, timeout=None, usage_count=None):
        log_debug(3, callback, stanza_name, stanza_id, stanza_ns, timeout,
            usage_count)
        if timeout:
            expiry = time.time() + timeout
        else:
            expiry = None
        callback_entry = [callback, expiry, usage_count]
        h_idns, h_id, h_ns, l_def = self._get_from_hash(self._handlers, 
            stanza_name, default_value=({}, {}, {}, []))
        # h_id is for all the callbacks we should call for a particular stanza
        # id; h_ns is for namespaces
        if stanza_id is not None and stanza_ns:
            l = self._get_from_hash(h_idns, (stanza_id, stanza_ns), [])
            l.append(callback_entry)
            return

        if stanza_id is not None:
            l = self._get_from_hash(h_id, stanza_id, [])
            l.append(callback_entry)
            return

        if stanza_ns:
            l = self._get_from_hash(h_ns, stanza_ns, [])
            l.append(callback_entry)
            return

        # Default callback
        l_def.append(callback_entry)
        
    def _get_from_hash(self, h, key, default_value):
        if h.has_key(key):
            val = h[key]
        else:
            val = h[key] = default_value
        return val

    def cleanup_expired_callbacks(self):
        log_debug(5)
        now = time.time()
        for stanza_name, vals in self._handlers.items():
            h_idns, h_id, h_ns, l_def = vals
            for h in (h_idns, h_id, h_ns):
                self._expire_callbacks_hash(h, now)
            self._expire_callbacks_list(l_def, now)

    def _expire_callbacks_hash(self, h, now):
        log_debug(6, now)
        for key, vals in h.items():
            self._expire_callbacks_list(vals, now)

    def _expire_callbacks_list(self, vals, now):
        log_debug(7, vals, now)
        for val in vals:
            (callback, expiry, usage_count) = val
            if not expiry:
                continue
            if now <= expiry:
                # Fresh
                continue
            # Callback is stale
            vals.remove(val)
                    
def my_debug(*args):
    print "Debugging:", args

class RestartRequested(Exception):
    pass

class JabberError(Exception):
    pass
    
class NeedRestart(Exception):
    pass

class TimeoutError(JabberError):
    pass

class SSLError(Exception):
    "Raised when a lower-level SSL error is caught"
    pass

class SSLHandshakeError(SSLError):
    "Raised when the SSL handshake failed"
    pass

class SSLDisabledError(SSLError):
    "Raised if the server does not support SSL"
    pass

class JabberConnectionError(Exception):
    "Raised when we were unable to make a jabber connection"
    pass

class JabberQualifiedError(JabberError):
    def __init__(self, errcode, err, *args):
        self.errcode = errcode
        self.err = err
        apply(JabberError.__init__, (self, ) + args)

    def __repr__(self):
        return "<%s instance at %s; errcode=%s; err=%s>" % (
            self.__class__.__name__, id(self), self.errcode, self.err)

    __str__ = __repr__

class JabberClient(jabber.Client):
    _seq = 0
    BLOCK_SIZE = jabber.xmlstream.BLOCK_SIZE

    def __init__(self, *args, **kwargs):
        log_debug(1)
        apply(jabber.Client.__init__, (self, ) + args, kwargs)
        self.jid = None
        # Lots of magic to add the nodes into a queue
        self._incoming_node_queue = []

        self.debug_level = 0
        self.trusted_certs = []
        
        self.registerProtocol('unknown', JabberProtocolNode)
        self.registerProtocol('iq', JabberIqNode)
        self.registerProtocol('message', JabberMessageNode)
        self.registerProtocol('presence', JabberPresenceNode)

        self.registerHandler('iq', self._expectedIqHandler, system=True)
        self.registerHandler('iq', self._IqRegisterResult, 'result',
            jabber.NS_REGISTER, system=True)

        h = Handlers()
        self.custom_handler = h
        self.registerHandler('presence', h.dispatch)
        self.registerHandler('iq', h.dispatch)
        self.registerHandler('message', h.dispatch)

        self._non_ssl_sock = None
        self._roster = Roster()
    
        self._uniq_client_string = generate_random_string(6)

    def add_trusted_cert(self, trusted_cert):
        check_cert(trusted_cert)
        self.trusted_certs.append(trusted_cert)

    def connect(self):
        log_debug(2)
        if not self.trusted_certs:
            raise SSLVerifyError("No trusted certs added")

        # Use our own dispatcher - we need to be able to read one stanza at
        # the time
        self.dispatch = self._auth_dispatch

        log_debug(5, "Attempting to connect")

        jabber.Client.connect(self)

        log_debug(5, "Connected")

        # From the XMPP Core Internet Draft:
        # server advertises <features><starttls /></features>
        # client sends back <starttls />
        # server responds with <proceed />

        # Wait for a stanza
        stanza = self.get_one_stanza()

        log_debug(5, "Expecting features stanza, got:", stanza)
        if stanza.getName() != 'features':
            log_error("Server did not return a <features /> stanza")
            self.disconnect()
            raise SSLDisabledError

        starttls_node = stanza.getTag('starttls')
        log_debug(5, "starttls node", starttls_node)
        if starttls_node is None:
            log_error("Server does not support TLS - <starttls /> "
                "not in <features /> stanza")
            self.disconnect()
            raise SSLDisabledError

        # Initiate the TLS stream
        self.write("<starttls xmlns='%s' />" % NS_STARTTLS)

        stanza = self.get_one_stanza()
        log_debug(5, "Expecting proceed stanza, got:", stanza)
        if stanza.getName() != 'proceed':
            log_error("Server broke TLS negociation - <proceed /> not sent")
            self.disconnect()
            raise SSLDisabledError

        log_debug(4, "Preparing for TLS handshake")
        ssl = SSLSocket(self._sock, trusted_certs=self.trusted_certs)
        ssl._ssl_method = SSL.SSL.TLSv1_METHOD
        ssl.ssl_verify_callback = self.ssl_verify_callback
        ssl.init_ssl()
        # Explicitly perform the SSL handshake
        try:
            ssl.do_handshake()
            self.verify_peer(ssl)
        except SSL.SSL.Error:
            # Error in the SSL handshake - most likely mismatching CA cert
            log_error("Traceback caught:")
            log_error(extract_traceback())
            raise SSLHandshakeError

        # Re-init the parsers
        jabber.xmlstream.Stream.connect(self)

        # Now replace the socket with the ssl object's connection
        self._non_ssl_sock = self._sock
        self._sock = ssl._connection

        # jabber.py has copies of _read, _write, _reader - those have to
        # be re-initialized as well
        self._setupComms()

        # Send the header again
        self.send(self._header_string())

        # Read the server's open stream tag
        self.process()

        stanza = self.get_one_stanza()

        if stanza.getName() != 'features':
            self.disconnect()
            raise Exception("Server did not pass any features?")

        # Now replace the dispatcher
        self.dispatch = self._orig_dispatch
        log_debug(5, "connect returning")

    def disconnect(self):
        try:
            jabber.Client.disconnect(self)
        except SSL.SSL.Error:
            pass

    def _setupComms(self):
        # We pretty much only support TCP connections
        self._read = self._sock.recv
        if hasattr(self._sock, 'sendall'):
            self._write = self._sock.sendall
        else:
            self._write = Sendall(self._sock).sendall
        self._reader = self._sock

    def ssl_verify_callback(self, conn, cert, errnum, depth, ok):
        log_debug(4, "Called", errnum, depth, ok)
        if not ok:
            log_error("SSL certificate verification failed")
            self.write("</stream:stream>")
            conn.close()
            self._sock.close()
            return ok

        return ok

    def verify_peer(self, ssl):
        cert = ssl.get_peer_certificate()
        if cert is None:
            raise SSLVerifyError("Unable to retrieve peer cert")
        
        subject = cert.get_subject()
        if not hasattr(subject, 'CN'):
            raise SSLVerifyError("Certificate has no Common Name")

        common_name = subject.CN

        # Add a trailing . since foo.example.com. is equal to foo.example.com
        # This also catches non-FQDNs
        if common_name[-1] != '.':
            common_name = common_name + '.'
        hdot = self._host
        if hdot[-1] != '.':
            hdot = hdot + '.'
        
        if common_name != hdot:
            raise SSLVerifyError("Mismatch: peer name: %s; common name: %s" %
                (self._host, common_name))
            
    def retrieve_roster(self):
        """Request the roster. Will register the roster callback, 
        but the call will wait for the roster to be properly populated"""
        # Register the roster callback
        self.custom_handler.register_callback(self._roster_callback, 'iq')
        iq_node_id = 'iq-request-%s' % self.get_unique_id()
        iq_node = JabberIqNode(type="get")
        iq_node.setQuery(jabber.NS_ROSTER)
        iq_node.setID(iq_node_id)
        self.send(iq_node)
        
        stanza = None
        # Wait for an IQ stanza with the same ID as the one we sent
        while 1:
            stanza = self.get_one_stanza()
            node_id = stanza.getAttr('id')
            if node_id == iq_node_id:
                # This is the response
                break
        # We now have the roster populated

        # All entries of type "from" and ask="subscribe" should be answered to
        for k, v in self._roster.get_subscribed_from().items():
            if v.has_key('ask') and v['ask'] == 'subscribe':
                self.send_presence(k, type="subscribed")
            else:
                # Ask for a subscription
                self.send_presence(k, type="subscribe")

    def _roster_callback(self, client, stanza):
        log_debug(3, "Updating the roster", stanza)
        
        # Extract the <query> node
        qnode = stanza.getTag('query')
        if qnode is None or qnode.getNamespace() != jabber.NS_ROSTER:
            # No query
            log_debug(5, "Query node not found, skipping")
            return

        # This gets called any time a roster event is received
        node_type = stanza.getAttr('type')
        if node_type not in ('result', 'set'):
            log_debug(5, "Not a result or a set, skipping")
            return
        
        # Now extract the <item> nodes
        for node in qnode.getTags('item'):
            self._roster.add_item(node)

    def cancel_subscription(self, jids):
        if not jids:
            return

        qnode = JabberProtocolNode("query")
        qnode.setNamespace(jabber.NS_ROSTER)

        for jid in jids:
            attrs = {
                'jid'           : jid,
                'subscription'  : 'remove',
            }
            inode = JabberProtocolNode("item", attrs=attrs)
            qnode.insertNode(inode)

        node = JabberIqNode(type="set")
        remove_iq_id = "remove-%s" % self.get_unique_id()
        node.setID(remove_iq_id)
        node.insertNode(qnode)

        self.send(node)
        
    def get_one_stanza(self, timeout=None):
        """Returns one stanza (or None if timeout is set)"""
        if timeout:
            start = time.time()
        while not self._incoming_node_queue:
            if timeout:
                now = time.time()
                if now >= start + timeout:
                    # Timed out
                    log_debug(4, "timed out", now, start, timeout)
                    return None
                tm = start + timeout - now
            else:
                tm = None
            # No nodes in the queue, read some data
            self.process(timeout=tm)
            
        # Now we have nodes in the queue
        node = self._incoming_node_queue[0]
        del self._incoming_node_queue[0]
        return node

    def _build_stanza(self, stanza):
        """Builds one stanza according to the handlers we have registered via
        registerHandler or registerProtocol"""
        name = stanza.getName()
        if not self.handlers.has_key(name):
            name = 'unknown'
        # XXX This is weird - why is jabbberpy using type which is a type?
        stanza = self.handlers[name][type](node=stanza)
        return stanza

    def _orig_dispatch(self, stanza):
        log_debug(6, stanza)
        if self.debug_level > 5:
            # Even more verbosity
            sys.stderr.write("<-- ")
            sys.stderr.write(str(stanza))
            sys.stderr.write("\n\n")
        # Even though Client.dispatch does build a stanza properly, we have to
        # do it ourselves too since dispatch doesn't return the modified
        # stanza, so it was always of type Node (i.e. the top-level class)
        stanza = self._build_stanza(stanza)
        jabber.Client.dispatch(self, stanza)
        self._incoming_node_queue.append(stanza)

    def _auth_dispatch(self, stanza):
        log_debug(6, stanza)
        if self.debug_level > 5:
            # Even more verbosity
            sys.stderr.write("<-- ")
            sys.stderr.write(str(stanza))
            sys.stderr.write("\n\n")
        # Create the stanza of the proper type
        stanza = self._build_stanza(stanza)
        self._incoming_node_queue.append(stanza)

    def auth(self, username, password, resource, register=1):
        """Try to authenticate the username with the specified password
        If the authentication fails, try to register the user.
        If that fails as well, then JabberQualifiedError is raised
        """
        log_debug(2, username, password, resource, register)
        auth_iq_id = "auth-get-%s" % self.get_unique_id()
        auth_get_iq = jabber.Iq(type='get')
        auth_get_iq.setID(auth_iq_id)
        q = auth_get_iq.setQuery(jabber.NS_AUTH)
        q.insertTag('username').insertData(username)
        self.send(auth_get_iq)
        log_debug(4, "Sending auth request", auth_get_iq)

        try:
            auth_response = self.waitForResponse(auth_iq_id, timeout=60)
        except JabberQualifiedError, e:
            if not register:
                raise
            if e.errcode == '401':
                # Need to register the user if possible
                log_debug(4, "Need to register")
                self.register(username, password)
                return self.auth(username, password, resource, register=0)

            raise

        log_debug(4, "Auth response", auth_response)
        auth_ret_query = auth_response.getTag('query')
        auth_set_id = "auth-set-%s" % self.get_unique_id()
        auth_set_iq = jabber.Iq(type="set")
        auth_set_iq.setID(auth_set_id)

        q = auth_set_iq.setQuery(jabber.NS_AUTH)
        q.insertTag('username').insertData(username)
        q.insertTag('resource').insertData(resource)

        if auth_ret_query.getTag('token'):
            token = auth_ret_query.getTag('token').getData() 
            seq = auth_ret_query.getTag('sequence').getData()

            h = hashlib.new('sha1', hashlib.new('sha1', password).hexdigest() + token).hexdigest()
            for i in range(int(seq)):
                h = hashlib.new('sha1', h).hexdigest()
            q.insertTag('hash').insertData(h)
        elif auth_ret_query.getTag('digest'):
            digest = q.insertTag('digest')
            digest.insertData(hashlib.new('sha1',
                self.getIncomingID() + password).hexdigest() )
        else:
            q.insertTag('password').insertData(password)

        log_debug(4, "Sending auth info", auth_set_iq)
        try:
            self.SendAndWaitForResponse(auth_set_iq)
        except JabberQualifiedError, e:
            if e.errcode == '401':
                # Need to reserve the user if possible
                log_debug(4, "Need to register")
                return self.register(username, password)
            raise
        
        log_debug(4, "Authenticated")
        return True

    def send(self, stanza):
        if self.debug_level > 5:
            sys.stderr.write("--> ")
            sys.stderr.write(str(stanza))
            sys.stderr.write("\n\n")
        return jabber.Client.send(self, stanza)


    def subscribe_to_presence(self, jids):
        """Subscribe to these nodes' presence
        The subscription in jabber works like this:

        Contact 1    State Contact 1     State Contact 2   Contact 2
        ----------+-------------------+------------------+----------
        subscribe  -> [ none + ask ]
                                         [ from ]       <- subscribed
                      [ to ]
                                         [ from + ask ] <- subscribe
        subscribed -> [ both ]
                                         [ both ]
        ----------+-------------------+------------------+----------
        
        Enclosed in square brackets is the state when the communication took
        place.
        """
        subscribed_to = self._roster.get_subscribed_to()
        log_debug(4, "Subscribed to", subscribed_to)
        subscribed_both = self._roster.get_subscribed_both()
        log_debug(4, "Subscribed both", subscribed_both)
        subscribed_none = self._roster.get_subscribed_none()
        log_debug(4, "Subscribed none", subscribed_none)
        subscribed_from = self._roster.get_subscribed_from()
        log_debug(4, "Subscribed from", subscribed_from)
        for full_jid in jids:
            jid = self._strip_resource(full_jid)
            jid = str(jid)
            if subscribed_both.has_key(jid):
                log_debug(4, "Already subscribed to the presence of node", jid)
                del subscribed_both[jid]
                continue
            # If to or from subscription for this node, we still send the
            # subscription request, but we shouldn't drop the subscription, so
            # we take the jid out of the respective hash
            if subscribed_to.has_key(jid):
                log_debug(4, "Subscribed to")
                del subscribed_to[jid]
                continue
            if subscribed_none.has_key(jid):
                ent = subscribed_none[jid]
                if ent.has_key('ask') and ent['ask'] == 'subscribe':
                    log_debug(4, "Subscribed none + ask=subscribe")
                    # We already asked for a subscription
                    del subscribed_none[jid]
                    continue
            if subscribed_from.has_key(jid):
                ent = subscribed_from[jid]
                if ent.has_key('ask') and ent['ask'] == 'subscribe':
                    log_debug(4, "Subscribed from + ask=subscribe")
                    # We already asked for a subscription
                    del subscribed_from[jid]
                    continue

            # Make sure we update the roster ourselves, to avoid sending
            # presence subscriptions twice
            # At this point we should only have 2 cases left: either from or
            # none.
            if self._roster._subscribed_from.has_key(jid):
                subscription = "from"
                hashd = self._roster._subscribed_from
            else:
                subscription = "none"
                hashd = self._roster._subscribed_none

            hashd[jid] = {
                'jid'           : jid,
                'subscription'  : subscription,
                'ask'           : 'subscribe',
            }
            self._subscribe_to_presence(jid)

        # XXX Here we should clean up everybody that is no longer online, but
        # this is more difficult

    def send_presence(self, jid=None, type=None, xid=None):
        log_debug(3, jid, type)
        if jid is None:
            node = JabberPresenceNode()
        else:
            node = JabberPresenceNode(to=jid)

        if type:
            node.setType(type)

        if xid:
            node.setID(xid)

        self.send(node)

    def fileno(self):
        return self._reader.fileno()

    def read(self):
        received = ''
        while 1:
            rfds, wfds, exfds = select.select([self.fileno()], [], [], 0)
            if not rfds:
                # No input
                break
            buff = self._read(self.BLOCK_SIZE)
            if not buff:
                break
            received = received + buff
        if not received:
            # EOF reached
            self.disconnected(self)
        return received

    def process(self, timeout=None):
        log_debug(3, timeout)
        self._incoming_node_queue = []
        fileno = self.fileno()
        # Wait for a node or until we hit the timeout
        start = time.time()
        while 1:
            now = time.time()
            if timeout:
                if now >= start + timeout:
                    # Timed out
                    return 0
                tm = start + timeout - now
            else:
                tm = None
            
            # tm is the number of seconds we have to wait (or None)
            log_debug(5, "before select(); timeout", tm)
            rfds, wfds, exfds = select.select([fileno], [], [], tm)
            log_debug(5, "select() returned")
            if not rfds:
                # Timed out
                return 0
            # Try to read as much data as possible
            if hasattr(self._sock, 'pending'):
                # This is on the SSL case - select() will use the native
                # socket's file descriptor. SSL may decode more data than we
                # are willing to read - so just read what's available
                log_debug(5, "Reading %s bytes from ssl socket" % self.BLOCK_SIZE)
                try:
                    data = self._read(self.BLOCK_SIZE)
                except SSL.SSL.SysCallError, e:
                    log_debug(5, "Closing socket")
                    self._non_ssl_sock.close()
                    raise SSLError("OpenSSL error; will retry", str(e))
                log_debug(5, "Read %s bytes" % len(data))
                if not data:
                    raise JabberError("Premature EOF")
                self._parser.Parse(data)
                pending = self._sock.pending()
                if pending:
                    # More bytes to read from the SSL socket
                    data = self._read(pending)
                    self._parser.Parse(data)
            else:
                # Normal socket - select will figure out correctly if the read
                # will block
                data = self._read(self.BLOCK_SIZE)
                if not data:
                    raise JabberError("Premature EOF")
                self._parser.Parse(data)
                    
            # We may not have read enough data to be able to produce a node
            if not self._incoming_node_queue:
                # Go back and read some more
                if timeout:
                    # Trying to wait some more before giving up in this call
                    continue
                # No reason to block again, return into the higher-level
                # select()
                return 0
            return len(self._incoming_node_queue)
        return 0
        

    def register(self, username, password):
        log_debug(2, username, password)
        self.requestRegInfo()
        d = self.getRegInfo()
        if d.has_key('username'):
            self.setRegInfo('username', username)
        if d.has_key('password'):
            self.setRegInfo('password', password)
        try:
            self.sendRegInfo()
        except JabberQualifiedError, e:
            if e.errcode == '409':
                # Need to register the user if possible
                log_error("Invalid password")
                self.disconnect()
                sys.exit(0)
            raise
        return True

    def _waitForResponse(self, ID, timeout=jabber.timeout):
        log_debug(5, ID, timeout)
        # jabberpy's function waits when it shouldn't so have to rebuild it
        ID = jabber.ustr(ID)

        self.lastErr = ''
        self.lastErrCode = 0

        if timeout is not None:
            abort_time = time.time() + timeout
            self.DEBUG("waiting with timeout:%s for %s" % (timeout, ID),
                jabber.DBG_NODE_IQ)
        else:
            self.DEBUG("waiting for %s" % ID, jabber.DBG_NODE_IQ)

        while 1:
            if timeout is None:
                tmout = None
            else:
                tmout = abort_time - time.time()
                if tmout <= 0:
                    # Timed out
                    break
            log_debug(5, "before get_one_stanza")
            stanza = self.get_one_stanza(tmout)
            log_debug(5, "after get_one_stanza")
            if not stanza:
                # get_one_stanza should only return None for a timeout
                assert timeout is not None
                break
                
            error_code = stanza.getErrorCode()
            if error_code:
                # Error
                self.lastErr = stanza.getError()
                self.lastErrCode = error_code
                return None

            # Is it the proper stanza ID?
            tid = jabber.ustr(stanza.getID())
            if ID == tid:
                # This is the node
                return stanza
            
            # Keep looking for stanzas until we time out (if a timeout was
            # passed)

        # Timed out
        self.lastErr = "Timeout"
        return None

    def waitForResponse(self, ID, timeout=jabber.timeout):
        result = self._waitForResponse(ID, timeout=timeout)
        if result is not None:
            return result
        if self.lastErr == 'Timeout':
            raise TimeoutError()

        if self.lastErrCode:
            raise JabberQualifiedError(self.lastErrCode, self.lastErr)

        raise JabberError("Unknown error", self.lastErr)
            

    def get_unique_id(self):
        seq = self._seq
        JabberClient._seq = seq + 1
        return "%s-%s" % (self._uniq_client_string, seq)

    def disconnectHandler(self, conn):
        pass

    # Need to add the version tothe XML stream
    def _header_string(self):
        self.DEBUG("jabber_lib.JabberClient.header: sending initial header",
            jabber.DBG_INIT)
        templ = "<?xml version='1.0' encoding='UTF-8'?><stream:stream %s>"
        attrs = {
            'to'            : self._host,
            'xmlns'         : self._namespace,
            'xmlns:stream'  : "http://etherx.jabber.org/streams",
            'version'   : '1.0',
        }
        if self._outgoingID:
            attrs['id'] = self._outgoingID
        # XXX Add more custom attributes here
        addition = []
        for k, v in attrs.items():
            addition.append("%s='%s'" % (k, v))
        addition = string.join(addition, " ")
        return templ % addition

    def header(self):
        header = self._header_string()
        self.send(header)
        self.process(jabber.timeout)

    def _fix_jid(self, jid):
        return jid

    def _presence_callback(self, client, stanza):
        """
        If the roster is enabled, presence stanzas with type="subscribed"
        should never be received - the server will initiate a roster push
        instead
        """
        jid = stanza.getFrom()
        presence_type = stanza.getType()
        log_debug(3, self.jid, jid, presence_type)
        stanza_id = stanza.getID()

        assert(stanza.getName() == 'presence')

        # We may not get the full JID here
        if presence_type is None or presence_type == 'subscribed':
            log_debug(4, "Node is available", jid, presence_type)
            self.set_jid_available(jid)

            # Now subscribe this node to the other node's presence, just in
            # case
            self.subscribe_to_presence([jid])
            return
        
        if presence_type in ('unsubscribed', 'unavailable'):
            log_debug(4, "Node is unavailable", jid, presence_type) 
            self.set_jid_unavailable(jid)
            return
        
        if presence_type == 'subscribe':
            # XXX misa 20051111: don't check signatures for presence anymore,
            # the fact they expire makes them unreliable

            #sig = self._check_signature(stanza)
            #if not sig:
            #    print "KKKKKK", stanza
            #    log_debug(1, "Invalid signature", jid)
            #    return

            log_debug(4, "Subscription request approved", jid)
            self.send_presence(jid, type="subscribed", xid=stanza_id)
            # Now subscribe this node to the other node's presence
            self.subscribe_to_presence([jid])
            return
        if presence_type == 'probe':
            log_debug(4, "Presence probe", jid)
            self.send(JabberPresenceNode(to=jid))

    def _check_signature(self, stanza, actions=None):
        return 1

    def _strip_resource(self, jid):
        return strip_resource(jid)

    def _subscribe_to_presence(self, full_jid):
        """Subscribes this node to the jid's presence"""
        log_debug(4, full_jid)
        jid = self._strip_resource(full_jid)
        presence_node = JabberPresenceNode(to=jid, type="subscribe")
        presence_node.setID("presence-%s" % self.get_unique_id())
        sig = self._create_signature(full_jid, NS_RHN_PRESENCE_SUBSCRIBE)
        if sig:
            presence_node.insertNode(sig)
        log_debug(5, "Sending presence subscription request", presence_node)
        self.send(presence_node)

    def _create_signature(self, jid, action):
        return None

    def send_message(self, jid, action):
        node = JabberMessageNode(to=jid, type='normal')
        sig = self._create_signature(jid, action)
        if sig:
            node.insertNode(sig)
        self.send(node)

    def jid_available(self, jid):
        return self._roster.jid_available(jid)

    def set_jid_available(self, jid):
        return self._roster.set_available(jid)

    def set_jid_unavailable(self, jid):
        return self._roster.set_unavailable(jid)

    def match_stanza_tags(self, stanza, tag_name, namespace=None):
        """Get the matching (child) tags of this stanza, possibly with the
        specified namespace"""
        tags = stanza.getTags(tag_name)
        if not tags:
            return []
        if namespace is None:
            # Nothing more to look for
            return tags
        return filter(lambda x, ns=namespace: x.getNamespace() == ns,
            tags)

    def _check_signature_from_message(self, stanza, actions):
        log_debug(4, stanza)
        assert stanza.getName() == 'message'

        message_from = stanza.getFrom()
        message_type = stanza.getType()
        if message_type == 'error':
            log_debug(1, 'Received error from %s: %s' % (message_from, stanza))
            return None

        if message_type != 'normal':
            log_debug(1, 'Unsupported message type %s ignored' % message_type)
            return None

        x_delayed_nodes = self.match_stanza_tags(stanza, 'x', 
            namespace=jabber.NS_DELAY)
        if x_delayed_nodes:
            log_debug(1, 'Ignoring delayed stanza')
            return None

        sig = self._check_signature(stanza, actions=actions)
        if not sig:
            if self.debug_level > 5:
                raise Exception(1)
            log_debug(1, "Mismatching signatures")
            return None

        return sig


class SSLSocket(SSL.SSLSocket):
    pass

class SSLVerifyError(SSL.SSL.Error):
    pass

def generate_random_string(length=20):
    if not length:
        return ''
    random_bytes = 16
    length = int(length)
    s = hashlib.new('sha1')
    s.update("%.8f" % time.time())
    s.update(str(os.getpid()))
    devrandom = open('/dev/urandom')
    result = []
    cur_length = 0
    while 1:
        s.update(devrandom.read(random_bytes))
        buf = s.hexdigest()
        result.append(buf)
        cur_length = cur_length + len(buf)
        if cur_length >= length:
            break
 
    devrandom.close()
 
    result = string.join(result, '')[:length]
    return string.lower(result)

def push_to_background():
    log_debug(3, "Pushing process into background")
    # Push this process into background
    pid = os.fork() 
    if pid > 0:
        # Terminate parent process
        os._exit(0)

    # Child process becomes a process group leader (and detaches from
    # terminal)
    os.setpgrp()

    # Change working directory
    os.chdir('/')
    
    # Set umask
    #7/7/05 wregglej 162619 set the umask to 0 so the remote scripts can run
    os.umask(0)

    #redirect stdin, stdout, and stderr.
    for f in sys.stdout, sys.stderr:
        f.flush()
        
    #files we want stdin,stdout and stderr to point to.
    si = open("/dev/null", 'r')
    so = open("/dev/null", 'a+')
    se = open("/dev/null", 'a+', 0)

    os.dup2(si.fileno(), sys.stdin.fileno())
    os.dup2(so.fileno(), sys.stdout.fileno())
    os.dup2(se.fileno(), sys.stderr.fileno())


    # close file descriptors
    # from subprocess import MAXFD
    #for i in range(3, MAXFD):
    #    try:
    #        os.close(i)
    #    except:
    #        pass


class Roster:
    def __init__(self):
        self._subscribed_to = {}
        self._subscribed_from = {}
        self._subscribed_both = {}
        self._subscribed_none = {}
        self._available_nodes = {}

    def add_item(self, item):
        subscr = item.getAttr('subscription')
        jid = item.getAttr('jid')
        jid = strip_resource(jid)
        jid = str(jid)
        entry = {
            'jid'           : jid,
            'subscription'  : subscr,
        }
        ask = item.getAttr('ask')
        if ask:
            entry['ask'] = ask

        actions = ['to', 'from', 'both', 'none']
        if subscr in actions:
            for a in actions:
                d = getattr(self, '_subscribed_' + a)
                if subscr == a:
                    # Set it
                    d[jid] = entry
                elif d.has_key(jid):
                    # Remove it
                    del d[jid]

    def get_subscribed_from(self):
        return self._subscribed_from.copy()

    def get_subscribed_to(self):
        return self._subscribed_to.copy()

    def get_subscribed_both(self):
        return self._subscribed_both.copy()

    def get_subscribed_none(self):
        return self._subscribed_none.copy()

    def get_subscribed_to_jids(self):
        ret = self._subscribed_to.copy()
        ret.update(self._subscribed_both)
        return ret

    def get_subscribed_from_jids(self):
        ret = self._subscribed_from.copy()
        ret.update(self._subscribed_both)
        return ret

    def get_available_nodes(self):
        return self._available_nodes.copy()

    def set_available(self, jid):
        jid = str(jid)
        self._available_nodes[jid] = 1

    def set_unavailable(self, jid):
        jid = str(jid)
        if self._available_nodes.has_key(jid):
            del self._available_nodes[jid]

    def jid_available(self, jid):
        return self._available_nodes.has_key(jid)

    def clear(self):
        self._subscribed_to.clear()
        self._subscribed_from.clear()
        self._subscribed_both.clear()
        self._subscribed_none.clear()

    def __repr__(self):
        return "Roster:\n\tto: %s\n\tfrom: %s\n\tboth: %s\n\tnone: %s" % (
            self._subscribed_to.keys(), 
            self._subscribed_from.keys(), 
            self._subscribed_both.keys(), 
            self._subscribed_none.keys(),
        )


def strip_resource(jid):
    # One doesn't subscribe to a specific resource
    if not isinstance(jid, jabber.JID): 
        jid = jabber.JID(jid)
    return jid.getStripped()

def extract_traceback():
    sio = StringIO()
    traceback.print_exc(None, sio)
    return sio.getvalue()

class Sendall:
    """This class exists here because python 1.5.2 does not support a
    sendall() method for sockets"""
    def __init__(self, sock):
        self.sock = sock

    def sendall(self, data, flags=0):
        to_send = len(data)
        if not to_send:
            # No data
            return 0
        bytes_sent = 0
        while 1:
            ret = self.sock.send(data[bytes_sent:], flags)
            if bytes_sent + ret == to_send:
                # We're done
                break
            bytes_sent = bytes_sent + ret
        return to_send
