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

import test_lib

class SimpleClientClient(test_lib.SimpleClient):
    pass

class SimpleClientRunner(test_lib.SimpleRunner):
    client_factory = SimpleClientClient
    _resource = 'client'

    def __init__(self, *args, **kwargs):
        test_lib.SimpleRunner.__init__(self, *args, **kwargs)

        self.options_table.extend([
            self.option('--dispatcher',           action="store",
                help="Dispatcher"),
            self.option('--exit',                 action="store_true",
                help="Exit after registering"),
            ])

    def setup_config(self, config):
        test_lib.SimpleRunner.setup_config(self, config)
        self.dispatcher = self.options.dispatcher
        self._should_exit = self.options.exit
        if not self.dispatcher:
            print("Missing dispatcher")
            sys.exit(0)

    def fix_connection(self, client):
        # First, retrieve the roster
        client.retrieve_roster()

        # If not subscribed already, subscribe to the dispatcher
        dest = str(jabber_lib.strip_resource(self.dispatcher))
        client.subscribe_to_presence([dest])
        client._roster._subscribed_to[dest] = {
            'jid'           : dest,
            'subscription'  : "to",
        }
        client.send_presence()

    def process_once(self, client):
        ret = test_lib.SimpleRunner.process_once(self, client)
        if not self._should_exit:
            return ret

        # Wait for a presence subscription request
        djid = str(jabber_lib.strip_resource(self.dispatcher))

        if djid in client._roster.get_subscribed_both():
            client.disconnect()
            sys.exit(0)

        return ret

def main():

    d = SimpleClientRunner('username1', 'password1', "client")
    d.main()

if __name__ == '__main__':
    sys.exit(main() or 0)

