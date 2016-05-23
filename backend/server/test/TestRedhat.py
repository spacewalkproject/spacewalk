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
# A class that makes testing stuff in backend/server/redhat_xmlrpc a little easier.
# It requires the rhn_server_redhat-xmlrpc.conf file in /etc/rhn/default.

# By default it uses the test-file-upload account in webdev.

# Change the value of the download_files_prefix option in rhn_server_redhat-xmlrpc.conf
# to some directory on your local machine.
#   Mine is set to wregglej, for instance.

# Change the value of the mount_point (or add the mount_point option) in /etc/rhn/rhn_server.conf on you local machine.
#   Mine is set to /home/devel, for instance.

# Place some tarballs in a directory on you machine that is under the path formed by joining the mount_point value
# with the download_files_prefix value.
#   I put them in /home/devel/wregglej/testing/tarballs/t1.

# Modify the values in data to reflect your set up.
import TestServer
import server.redhat_xmlrpc
try:
    #  python 2
    import SimpleXMLRPCServer
except ImportError:
    #  python3
    import xmlrpc.server as SimpleXMLRPCServer
from spacewalk.common import rhnConfig


class TestRedhat(TestServer.TestServer):

    def __init__(self):
        TestServer.TestServer.__init__(self)
        rhnConfig.initCFG("server.redhat-xmlrpc")
        self._init_xmlrpc()

    def _init_xmlrpc(self):
        self.rpc = server.redhat_xmlrpc

    def getXmlRpc(self):
        return self.rpc

    def getUsername(self):
        return "test-file-upload"

    def getPassword(self):
        return "password"

if __name__ == "__main__":
    server = TestRedhat()
    rpc = server.getXmlRpc()
    rpc_downloads = rpc.downloads.Downloads()

    category = "RHN Test Download"
    channel = 'rhn-test-download'
    data = [
        {
            'path': "testing/tarballs/t1/examplesT1.tar.gz",
            'name': "examples1",
            'channel': channel,
            'file_size': '162671',
            'md5sum': 'a39e4a3e8a5615b01b40598fd23d2abf',
            'category': category,
            'ordering': '1',
        },
        {
            'path': "testing/tarballs/t1/examplesT2.tar.gz",
            'name': "examples2",
            'channel': channel,
            'file_size': '162671',
            'md5sum': 'a39e4a3e8a5615b01b40598fd23d2abf',
            'category': category,
            'ordering': '2',
        },
    ]
    info = {
        'entries': data,
        'username': 'test-file-upload',
        'password': 'password',
        'channel': channel,
        'commit': 1,
        'force': 1
    }

    # DELETE THE DOWNLOADS
    # print rpc_downloads.delete_category_files(info)

    # ADD THE DOWNLOADS
#    print rpc_downloads.add_downloadable_files(info)
    server = SimpleXMLRPCServer.SimpleXMLRPCServer(addr=('', 8000))
    for func in rpc_downloads.functions:
        print(func)
        server.register_function(getattr(rpc_downloads, func), name="downloads.%s" % (func))
    server.serve_forever()
