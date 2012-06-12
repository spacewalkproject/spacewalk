#
# Copyright (c) 2008--2010 Red Hat, Inc.
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
# Package uploading tool
#
# $Id$

import base64

import connection

class PackageUpload(connection.PackageUpload):
    user_agent = "rhnpush"
    def set_auth(self, username, password):
        auth_vals = self.encode_values([username, password])
        self.headers["%s-%s" % (self.header_prefix, "Auth")] = auth_vals

    def set_session(self, session_string):
        self.headers["%s-%s" % (self.header_prefix, "Auth-Session")] = session_string

    def set_force(self, force):
        if force:
            force = 1
        else:
            force = 0
        self.headers["%s-%s" % (self.header_prefix, "Force")] = str(force)

    def set_null_org(self, null_org):
        if null_org:
            self.headers["%s-%s" % (self.header_prefix, "Null-Org")] = "1"

    # Encodes an array of variables into Base64 (column-separated)
    def encode_values(self, arr):
        val = ':'.join(map(lambda x: x.strip(), map(base64.encodestring, arr)))
        # Get rid of the newlines
        val = val.replace('\n', '')
        # And split the result into lines of fixed size
        line_len = 80
        result = []
        start = 0
        while 1:
            if start >= len(val):
                break
            result.append(val[start:start + line_len])
            start = start + line_len
        return result

class PingPackageUpload(connection.PackageUpload):
    user_agent = "rhnpush-ping"

    def ping(self):
        self.send_http("GET")
        #return the header info as well to check for capabilities.
        return self._response.status, self._response.reason, self._response.msg
