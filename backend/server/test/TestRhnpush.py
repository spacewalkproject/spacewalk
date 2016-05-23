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
import TestServer
import server.app.packages
try:
    #  python 2
    import SimpleXMLRPCServer
except ImportError:
    #  python3
    import xmlrpc.server as SimpleXMLRPCServer


class TestRhnpush(TestServer.TestServer):

    def __init__(self):
        TestServer.TestServer.__init__(self)
        self._init_app()

    def _init_app(self):
        self.app = server.app.packages.Packages()

    def getApp(self):
        return self.app

if __name__ == "__main__":
    server = TestRhnpush()
    app = server.getApp()
    print(app.test_login(server.getUsername(), server.getPassword()))
    print(app.listChannel(['wregglej-test'], "wregglej", "bm8gv5z2"))
    print(app.listChannelSource(['wregglej-test'], "wregglej", "bm8gv5z2"))
    server = SimpleXMLRPCServer.SimpleXMLRPCServer(addr=('', 16000))
    for func in app.functions:
        print(func)
        server.register_function(getattr(app, func), name="app.%s" % (func))
    server.serve_forever()
