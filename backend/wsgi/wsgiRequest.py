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
import httplib


class WsgiRequest:

    def __init__(self, env, start_response):
        self.method = env['REQUEST_METHOD']
        self.headers_in = env
        self.path_info = env['PATH_INFO']
        self.start_response = start_response
        self.uri = self.unparsed_uri = env['REQUEST_URI']
        self.server = WsgiServer(env['SERVER_NAME'], env['SERVER_PORT'])
        self.connection = WsgiConnection(env['REMOTE_ADDR'])
        self.options = {}
        self.main = 0
        self.proto_num = float(env['SERVER_PROTOCOL'].split('/')[1])
        self.headers_out = WsgiMPtable()
        self.sent_header = 0
        self.content_type = ""
        self.the_request = env['REQUEST_METHOD'] + " " + env['SCRIPT_NAME'] + " "  + env['SERVER_PROTOCOL']
        self.output = []
        self.err_headers_out = WsgiMPtable()
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
        self.status = str(self.status)
        if status is not None:
            self.status = str(status)
        if len(self.status) == 0 or self.status == None:
            self.status = "200"
        elif self.status.startswith("500"):
            for i in self.err_headers_out.items():
                self.headers_out.add(i[0], i[1])

        self.status = self.status + " " +  httplib.responses[int(self.status)]

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

class WsgiMPtable:
    """ This class emulates mod_python's mp_table. See
        http://www.modpython.org/live/current/doc-html/pyapi-mptable.html

        The table object is a wrapper around the Apache APR table. The table
        object behaves very much like a dictionary (including the Python 2.2
        features such as support of the in operator, etc.), with the following
        differences:

        ...
        - Duplicate keys are allowed (see add() below). When there is more
          than one value for a key, a subscript operation returns a list.

        Much of the information that Apache uses is stored in tables.
        For example, req.headers_in and req.headers_out.
    """
    def __init__(self):
        self.dict = {}

    def add(self, key, value):
        if self.dict.has_key(key):
            self.dict[key].append(str(value))
        else:
            self.dict[key] = [str(value)]

    def __getitem__(self, key):
        if len(self.dict[key]) == 1:
           return self.dict[key][0]
        return self.dict[key]

    def __setitem__(self, key, value):
        self.dict[key] = [str(value)]

    def items(self):
        list = []
        for k,v in self.dict.items():
            for vi in v:
                list.append((k,vi))
        return list

    def has_key(self, key):
        return self.dict.has_key(key)

    def keys(self):
        return self.dict.keys()

    def __str__(self):
        return str(self.items())

