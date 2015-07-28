#
# Copyright (c) 2008--2014 Red Hat, Inc.
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

import re
import sys
import time
import types
import string
from rhn import rpclib
import random
import socket

from up2date_client.config import initUp2dateConfig
from up2date_client import config

from rhn_log import set_debug_level, log_debug, die, set_logfile

import jabber_lib
import osad_config
import osad_client

def main():
    return Runner().main()

class Runner(jabber_lib.Runner):
    client_factory = osad_client.Client

    # How often will we try to reconnect. We want this randomized, so not all
    # clients hit the server at the same time
    _min_sleep = 60
    _max_sleep = 120

    def __init__(self):
        jabber_lib.Runner.__init__(self)
        self._up2date_config = None
        self._config = None
        self._xmlrpc_server = None
        self._systemid_file = None
        self._time_drift = 0
        self.options_table.extend([
            self.option('--cfg',                action="store",
                help="Use this configuration file for defaults"),
            self.option('--jabber-server',      action="store",
                help="Primary jabber server to connect to"),
        ])
        self._config_options = {}
        # Counter for the number of config setups we had
        self._config_setup_counter = 0
        # How often to re-setup the config (i.e. make xmlrpc requests to get
        # the config from the server)
        self._config_setup_interval = random.randint(50, 100)
        self._use_proxy = 1

    def setup_config(self, config, force=0):
        # We don't want to slam the server with lots of XMLRPC requests at the
        # same time, especially if jabberd goes down - in that case all
        # clients are slamming the server at the same time
        try:
            if (self._config_setup_counter % self._config_setup_interval == 0) or \
               force:
                # This will catch the first pass too
                self._setup_config(config, force)
            else:
                log_debug(4, "Skipping config setup; counter=%s; interval=%s" %
                    (self._config_setup_counter, self._config_setup_interval))
        except:
            self._config_setup_counter = 0
            raise

        # Update the counter for the next time
        self._config_setup_counter = self._config_setup_counter + 1

    def _setup_config(self, config, force=0):
        logfile = self.options.logfile
        if logfile is None or logfile == '':
            logfile = config['logfile']

        debug_level = self.options.verbose
        if debug_level is None:
            dl = config['debug_level']
            if dl is not None:
                debug_level = int(dl)
            else:
                dl = 0

        set_logfile(logfile)
        self.debug_level = debug_level
        set_debug_level(debug_level)

        self._tcp_keepalive_timeout = config['tcp_keepalive_timeout']
        self._tcp_keepalive_count = config['tcp_keepalive_count']

        log_debug(3, "Updating configuration")

        client_ssl_cert = config['ssl_ca_cert']
        osa_ssl_cert = config['osa_ssl_cert'] or client_ssl_cert
        if osa_ssl_cert is None:
            die("No SSL cert supplied")

        self.ssl_cert = osa_ssl_cert

        auth_info = self.read_auth_info(force)

        self._username = auth_info['username']
        self._password = auth_info['password']
        self._resource = auth_info['resource']

        params = self.build_rpclib_params(config)
        server_url = params.get('uri')

        self._jabber_servers = []
        if self.options.jabber_server:
            self._jabber_servers.append(self.options.jabber_server)

        if type(server_url) == type([]):
            for su in server_url:
                a_su = self._parse_url(su)[1]
                self._jabber_servers.append(a_su)
        else:
            upstream_jabber_server = self._parse_url(server_url)[1]
            if upstream_jabber_server not in self._jabber_servers:
                self._jabber_servers.append(upstream_jabber_server)

        if type(server_url) != type([]):
            server_url = [server_url]

        for su in server_url:
            try:
                params['uri'] = su
                self._xmlrpc_server = s = apply(rpclib.Server, (), params)
                if osa_ssl_cert:
                    s.add_trusted_cert(osa_ssl_cert)
                s.registration.welcome_message()

                server_capabilities = get_server_capability(s)
                if not server_capabilities.has_key('registration.register_osad'):
                    die("Server does not support OSAD registration")

                self._systemid_file = systemid_file = config['systemid']
                self._systemid = systemid = open(systemid_file).read()

                current_timestamp = int(time.time())
                ret = s.registration.register_osad(systemid, {'client-timestamp' :
                    current_timestamp})
                break
            except:
                continue
        else: #for
            ret = {}

        #Bugzilla: 142067
        #If the server doesn't have push support. 'ret' won't have anything in it.
        if len(ret.keys()) < 1:
            raise jabber_lib.JabberConnectionError

        server_timestamp = ret.get('server-timestamp')
        # Compute the time drift between the client and the server
        self._time_drift = server_timestamp - current_timestamp
        log_debug(2, "Time drift", self._time_drift)

        js = ret.get('jabber-server')
        if js not in self._jabber_servers:
            self._jabber_servers.append(js)

        if not self._jabber_servers:
            die("Missing jabber server")

        if not config.has_key('enable_failover') or config['enable_failover'] != '1':
            self._jabber_servers = [self._jabber_servers[0]]

        self._dispatchers = ret.get('dispatchers')

        self._client_name = ret.get('client-name')
        self._shared_key = ret.get('shared-key')
        log_debug(2, "Client name", self._client_name)
        log_debug(2, "Shared key", self._shared_key)

        # Load the config
        self._config_options.clear()
        self._config_options.update(config)
        # No reason to expose these at the Client level - but if we have to,
        # uncommment some of the values below
        self._config_options.update({
        #    'jabber-servers'    : self._jabber_servers,
        #    'dispatchers'       : self._dispatchers,
        #    'client_name'       : self._client_name,
        #    'shared_key'        : self._shared_key,
        })


    def _parse_url(self, url, scheme="http"):
        import urlparse
        sch, netloc, path, params, query, fragment = urlparse.urlparse(url)
        if not netloc:
            # No schema - trying to patch it up ourselves?
            url = scheme + "://" + url
            sch, netloc, path, params, query, fragment = urlparse.urlparse(url)
        return sch, netloc, path, params, query, fragment

    def fix_connection(self, c):
        "After setting up the connection, do whatever else is necessary"
        c.set_config_options(self._config_options)
        c.client_id = self._client_name
        c.shared_key = self._shared_key
        c.time_drift = self._time_drift
        c._sock.setsockopt(socket.SOL_SOCKET, socket.SO_KEEPALIVE, 1)
        c._sock.setsockopt(socket.SOL_TCP, socket.TCP_KEEPIDLE, self._tcp_keepalive_timeout)
        c._sock.setsockopt(socket.SOL_TCP, socket.TCP_KEEPCNT, self._tcp_keepalive_count)

        # Update the jabber ID
        systemid = open(self._systemid_file).read()
        args = {
            'jabber-id' : str(c.jid),
        }
        ret = self._xmlrpc_server.registration.register_osad_jid(systemid,
            args)

        c.set_dispatchers(self._dispatchers)

        c.subscribe_to_presence(self._dispatchers)
        # Signal presence to the jabber server
        c.send_presence()
        return c

    def process_once(self, client):

        # Re-read the systemid file.  If it's changed from the
        # previous version re-setup the config.  This will create a new
        # key on the satellite server tied to this new system id.
        # This change prevents having to restart osad after a system
        # re-registration.
        systemid = open(self._systemid_file).read()
        if systemid != self._systemid:
            log_debug(4, "System re-registration detected. systemid file has changed.")
            config = self.read_config()
            raise jabber_lib.NeedRestart

        # make sure that dispatchers are not stuck in state [none + ask] or [from + ask]
        # for too long. This can happen, for example, if a "subscribe" presence stanza
        # gets lost - in that case re-send it
        client.unstick_contacts(self._dispatchers)

        # if rhn_check is running or the last one failed, check more often
        if (client._rhn_check_process is None) and (client._rhn_check_fail_count < 1):
            client.process(timeout=180)
        else:
            client.process(timeout=5)

    def read_config(self):
        ret = {}
        # Read from the global config first
        config_file = self.options.cfg
        self._config = osad_config.init('osad', config_file=config_file)
        config_keys = ['debug_level', 'osa_ssl_cert', 'logfile', 'run_rhn_check',
            'rhn_check_command', 'enable_failover']
        for key in config_keys:
            ret[key] = osad_config.get(key)

        try:
            server_url = osad_config.get('server_url')
        except osad_config.InterpolationError, e:
            server_url = config.getServerlURL()[0]
        else:
            if server_url is None:
                server_url = config.getServerlURL()[0]

        ret['server_url'] = server_url

        #8/23/05 wregglej 165775 added the run_rhn_check option.
        run_rhn_check = osad_config.get('run_rhn_check')
        if run_rhn_check is None:
            log_debug(3, "Forcing run_rhn_check")
            run_rhn_check = 1
        ret['run_rhn_check'] = int(run_rhn_check)

        ret['tcp_keepalive_timeout'] = int(osad_config.get('tcp_keepalive_timeout', defval=1800))
        ret['tcp_keepalive_count'] = int(osad_config.get('tcp_keepalive_count', defval=3))

        systemid = osad_config.get('systemid')
        if systemid is None:
            systemid = self.get_up2date_config()['systemIdPath']
        ret['systemid'] = systemid

        enable_proxy = self._config.get_option('enableProxy')
        if enable_proxy is None:
            enable_proxy = self.get_up2date_config()['enableProxy']

        if enable_proxy:
            ret['enable_proxy'] = 1

            ret['proxy_url'] = self._config.get_option('httpProxy')
            if ret['proxy_url'] is None:
                ret['proxy_url'] = str(config.getProxySetting())

            ret['enable_proxy_auth'] = 0
            enable_proxy_auth = self._config.get_option('enableProxyAuth')
            if enable_proxy_auth is None:
                enable_proxy_auth = self.get_up2date_config()['enableProxyAuth']

            if enable_proxy_auth:
                ret['enable_proxy_auth'] = 1
                proxy_user = self._config.get_option('proxyUser')
                if proxy_user is None:
                    proxy_user = self.get_up2date_config()['proxyUser']
                ret['proxy_user'] = proxy_user

                proxy_password = self._config.get_option('proxyPassword')
                if proxy_password is None:
                    proxy_password = self.get_up2date_config()['proxyPassword']
                ret['proxy_password'] = proxy_password

        if not server_url:
            die("Unable to retrieve server URL")

        # SSL cert for Jabber's TLS, it can potentially be different than the
        # client's
        osa_ssl_cert = self._config.get_option('osa_ssl_cert')
        # The up2date ssl cert - we get it from up2daate's config file
        client_ca_cert = self.get_up2date_config()['sslCACert']
        if isinstance(client_ca_cert, types.ListType):
            if client_ca_cert:
                client_ca_cert = client_ca_cert[0]
            else:
                client_ca_cert = None
        if osa_ssl_cert is None:
            # No setting, use up2date's
            osa_ssl_cert = client_ca_cert

        if client_ca_cert is not None:
            ret['ssl_ca_cert'] = client_ca_cert
        if osa_ssl_cert is not None:
            ret['osa_ssl_cert'] = osa_ssl_cert

        return ret

    def get_up2date_config(self):
        if self._up2date_config is None:
            self._up2date_config = initUp2dateConfig()
        return self._up2date_config

    def build_rpclib_params(self, config):
        ret = {}
        kmap = {
            'server_url'        : 'uri',
            'proxy_user'        : 'username',
            'proxy_password'    : 'password',
            'proxy_url'         : 'proxy',
        }
        for k, v in kmap.items():
            if config.has_key(k):
                val = config[k]
                if val is not None:
                    ret[v] = val
        return ret

    def read_auth_info(self, force):
        # generate some defaults
        resource = 'osad'
        username = 'osad-' + jabber_lib.generate_random_string(10)
        password = jabber_lib.generate_random_string(20)

        # Get the path to the auth info file - may be None
        auth_info_file = self._config.get_option('auth_file')
        auth_info = osad_config.get_auth_info(auth_info_file, 'osad-auth', force,
            username=username, password=password, resource=resource)
        return auth_info

def get_server_capability(s):
    headers = s.get_response_headers()
    if headers is None:
        # No request done yet
        return {}
    cap_headers = headers.getallmatchingheaders("X-RHN-Server-Capability")
    if not cap_headers:
        return {}
    regexp = re.compile(
            r"^(?P<name>[^(]*)\((?P<version>[^)]*)\)\s*=\s*(?P<value>.*)$")
    vals = {}
    for h in cap_headers:
        arr = string.split(h, ':', 1)
        assert len(arr) == 2
        val = string.strip(arr[1])
        if not val:
            continue

        mo = regexp.match(val)
        if not mo:
            # XXX Just ignoring it, for now
            continue
        vdict = mo.groupdict()
        for k, v in vdict.items():
            vdict[k] = string.strip(v)

        vals[vdict['name']] = vdict
    return vals

if __name__ == '__main__':
    sys.exit(main() or 0)
