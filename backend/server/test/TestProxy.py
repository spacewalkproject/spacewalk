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
import TestServer
import server.redhat_xmlrpc.downloads


class TestProxy(TestServer.TestServer):

    def __init__(self):
        TestServer.TestServer.__init__(self)
        self._init_redhat_xmlrpc_downloads()

    def _init_redhat_xmlrpc_downloads(self):
        self.downloads = server.redhat_xmlrpc.downloads.Downloads()

    def getDownloads(self):
        return self.downloads

if __name__ == "__main__":
    server = TestProxy()
    downloads = server.getDownloads()
