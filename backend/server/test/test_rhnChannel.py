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
import time
from spacewalk.common import rhnFlags
from spacewalk.common.rhnConfig import initCFG
from spacewalk.server import rhnSQL, rhnChannel, rhnServer, rhnUser


def test_server_search(use_key=0):
    if use_key:
        user = None
    else:
        user = 'mibanescu-plain'
    u = rhnUser.search(user)
    s = rhnServer.Server(u, arch="athlon")
    s.server["release"] = "2.1AS"
    s.server["name"] = "test 1"
    if use_key:
        rhnFlags.set("registration_token", 'a02487cf77e72f86338f44212d23140d')
    s.save()
    print(s.server["id"])


if __name__ == "__main__":
    initCFG("server.xmlrpc")
    rhnSQL.initDB('rhnuser/rhnuser@webdev')

    if 1:
        test_server_search(use_key=1)
        sys.exit(1)

    print(rhnChannel.get_server_channel_mappings(1000102174, release='2.1AS'))
    print(rhnChannel.get_server_channel_mappings(1000102174, release='2.1AS',
                                                 user_id=2825619, none_ok=1))

    print(rhnChannel.channels_for_release_arch('2.1AS', 'athlon-redhat-linux'))
    print(rhnChannel.channels_for_release_arch('2.1AS', 'athlon-redhat-linux', user_id=575937))
    print(rhnChannel.channels_for_release_arch('2.1AS', 'XXXX-redhat-linux', user_id=575937))
    # mibanescu-2
#    print rhnChannel.channels_for_release_arch('9', 'i386-redhat-linux', user_id=2012148)
    # mibanescu-plain
    print(rhnChannel.channels_for_release_arch('2.1AS', 'athlon-redhat-linux', user_id=2825619))
    sys.exit(1)

    channel = "redhat-linux-i386-7.1"

    start = time.time()
    ret = rhnChannel.list_packages(channel)
    print("Took %.2f seconds to list %d packages in %s" % (
        time.time() - start, len(ret), channel))
    # pprint.pprint(ret)

    start = time.time()
    ret = rhnChannel.list_obsoletes(channel)
    print("Took %.2f seconds to list %d obsoletes in %s" % (
        time.time() - start, len(ret), channel))
    # pprint.pprint(ret)

    server_id = 1002156837
    channels = rhnChannel.channels_for_server(server_id)

    s = rhnServer.search(server_id)
    s.change_base_channel("2.1AS-foobar")
    print([x['label'] for x in channels])
    print([x['label'] for x in rhnChannel.channels_for_server(server_id)])
    rhnSQL.commit()
