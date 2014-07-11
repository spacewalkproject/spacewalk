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

import sys

import test_lib

class SimpleDispatcherClient(test_lib.SimpleClient):
    pass

class SimpleDispatcherRunner(test_lib.SimpleRunner):
    client_factory = SimpleDispatcherClient
    _resource = 'DISPATCHER'

    def fix_connection(self, client):
        client.retrieve_roster()
        client.send_presence()

def main():

    d = SimpleDispatcherRunner('username1', 'password1', "DISPATCHER")
    d.main()

if __name__ == '__main__':
    sys.exit(main() or 0)
