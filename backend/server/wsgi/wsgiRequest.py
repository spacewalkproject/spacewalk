#
# Copyright (c) 2010 Red Hat, Inc.
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
#



import socket
from common import log_debug

class WsgiRequest:

    def __init__(self, env, start_response):
        self.method = env['REQUEST_METHOD']
        self.headers_in = env
        self.path_info = env['PATH_INFO']
        self.start_response = start_response
        self.unparsed_uri = env['REQUEST_URI']
        self.server = WsgiServer(env['SERVER_NAME'], env['SERVER_PORT'])
        self.connection = WsgiConnection(env['REMOTE_ADDR'])
        self.options = {}
        self.main = 0
        self.proto_num = float(env['SERVER_PROTOCOL'].split('/')[1])
        self.headers_out = WsgiDict()
        self.sent_header = 0
        self.content_type = ""
        self.the_request = env['REQUEST_METHOD'] + " " + env['SCRIPT_NAME'] + " "  + env['SERVER_PROTOCOL']
        self.output = []
        self.err_headers_out = WsgiDict() 
        self.status = ""
        self.sent_bodyct = 0
        self.sent_header = 0

    def set_option(self, key, value):
        self.options[key] = value

    def get_options(self):
        return self.options

    def get_config(self):
        return ""  #FIXME

    def write(self, str):
        self.output.append(str)

    def send_http_header(self, status=None):
        self.sent_header = 1

        if len(self.status) == 0 or self.status == None:
            self.status = "200 OK"
        if status is not None:
            self.status = str(status)

        if len(self.content_type) > 0:
           self.headers_out['Content-Type'] = self.content_type
        #default to text/xml
        if not self.headers_out.has_key('Content-Type'):
            self.headers_out['Content-Type'] = 'text/xml'

        self.start_response(self.status, self.headers_out.items())
        return

    def get_remote_host(self, rev=""):
        host = self.headers_in['REMOTE_ADDR']
        try:
            host = socket.gethostbyaddr(host)[0]
        except:
            pass
        return host

    def read(self, buffer=-1):
        return self.headers_in['wsgi.input'].read(buffer)


class WsgiServer:
    def __init__(self, hostname, port):
        self.server_hostname = hostname
        self.port = int(port)

class WsgiConnection:
    def __init__(self, remote_ip):
        self.remote_ip = remote_ip

class WsgiDict(dict):
    def add(self, key, value):
        self[key] = value;
