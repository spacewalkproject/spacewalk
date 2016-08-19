#
# Copyright (c) 2008--2016 Red Hat, Inc.
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
import jabber_lib
import time
import rhn_log

class SimpleClient(jabber_lib.JabberClient):
    def start(self, username, password, resource):
        t0 = time.time()
        self.auth(username, password, resource)
        t1 = time.time()
        print("TIMING: auth: %.3f" % (t1 - t0))
        self.username = username
        self.resource = resource
        self.jid = "%s@%s/%s" % (self.username, self._host, self.resource)
        rhn_log.log_debug(0, "Authenticated", self.jid)

    def _message_callback(self, client, stanza):
        pass

class SimpleRunner(jabber_lib.Runner):

    def __init__(self, username, password, resource):
        jabber_lib.Runner.__init__(self)
        self._username = username
        self._password = password
        self._resource = resource
        self.log_file = '/tmp/simple-dispatcher.log'

        self.options_table.extend([
            self.option('--jabberd',              action="append",
                help="Use this jabber server"),
            self.option('--trusted-cert',         action="store",
                help="Use this trusted CA cert"),
            self.option('--username',             action="store",
                help="Username"),
            self.option('--password',             action="store",
                help="Password"),
            self.option('--resource',             action="store",
                help="Resource"),
            ])


    def set_log_file(self, log_file):
        self.log_file = log_file

    def set_trusted_cert(self, trusted_cert):
        self.ssl_cert = trusted_cert

    def read_config(self):
        return {
            'logfile'       : self.log_file,
        }

    def setup_config(self, config):
        self.options.nodetach = 1
        self.debug_level = self.options.verbose
        rhn_log.set_logfile(config.get('logfile') or "/dev/null")

        self._username = self.options.username
        self._password = self.options.password
        if not self._username:
            print("Missing username")
            sys.exit(0)
        if not self._password:
            print("Missing password")
            sys.exit(0)
        if self.options.resource:
            self._resource = self.options.resource

        if not self.options.jabberd:
            print("Missing jabber servers")
            sys.exit(0)

        if not self.options.trusted_cert:
            print("Missing trusted cert")
            sys.exit(0)
        self.ssl_cert = self.options.trusted_cert

        self._jabber_servers.extend(self.options.jabberd)

    def process_once(self, client):
        client.process(timeout=None)
