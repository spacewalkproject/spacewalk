#
# Code that drops files on the filesystem (/PKG-UPLOAD)
#
#
# Copyright (c) 2008--2012 Red Hat, Inc.
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
# $Id$

import os
import base64
from rhn import rpclib

from spacewalk.common import apache, rhnFlags
from spacewalk.common.rhnLog import log_debug, log_error
from spacewalk.common.rhnConfig import CFG
from spacewalk.common.rhnException import rhnFault
from spacewalk.server import rhnPackageUpload, rhnSQL, basePackageUpload
from spacewalk.common.checksum import getFileChecksum

class PackagePush(basePackageUpload.BasePackageUpload):
    def __init__(self, req):
        basePackageUpload.BasePackageUpload.__init__(self, req)
        self.required_fields.extend([
            'Auth',
            'Force',
        ])
        self.null_org = None
        # Default packaging is rpm
        self.packaging = 'rpm'
        self.username = None
        self.password = None
        self.force = None
        
    def headerParserHandler(self, req):
        ret = basePackageUpload.BasePackageUpload.headerParserHandler(self, req)
        # Optional headers
        maps = [['Null-Org', 'null_org'], ['Packaging', 'packaging']]
        for hn, sn in maps:
            header_name = "%s-%s" % (self.header_prefix, hn)
            if req.headers_in.has_key(header_name):
                setattr(self, sn, req.headers_in[header_name])

        if ret != apache.OK:
            return ret

        if CFG.SEND_MESSAGE_TO_ALL:
            rhnSQL.closeDB()
            log_debug(1, "send_message_to_all is set")
        
            rhnFlags.set("apache-return-code", apache.HTTP_NOT_FOUND)
            try:
                outage_message = open(CFG.MESSAGE_TO_ALL).read()
            except IOError:
                log_error("Missing outage message file")
                outage_message = "Outage mode"
            raise rhnFault(20001, outage_message, explain=0)

        # Init the database connection
        rhnSQL.initDB()
        use_session = 0
        if self.field_data.has_key('Auth-Session'):
            session_token = self.field_data['Auth-Session']
            use_session = 1
        else:
            encoded_auth_token = self.field_data['Auth']
        
        if not use_session:
            auth_token = self.get_auth_token(encoded_auth_token)

            if len(auth_token) < 2:
                log_debug(3, auth_token)
                raise rhnFault(105, "Unable to autenticate")

            self.username, self.password = auth_token[:2]
        
        force = self.field_data['Force']
        force = int(force)
        log_debug(1, "Username", self.username, "Force", force)
        
        if use_session:
            self.org_id, self.force = rhnPackageUpload.authenticate_session(session_token,
                force=force, null_org=self.null_org)
        else:
            # We don't push to any channels
            self.org_id, self.force = rhnPackageUpload.authenticate(self.username,
                self.password, force=force, null_org=self.null_org)

        nevra = [self.package_name, "", self.package_version, 
            self.package_release, self.package_arch]

        return apache.OK


    def handler(self, req):
        ret = basePackageUpload.BasePackageUpload.handler(self, req)
        if ret != apache.OK:
            return ret

        a_pkg = rhnPackageUpload.save_uploaded_package(req,
                        (self.package_name, None, self.package_version,
                         self.package_release, self.package_arch),
                        str(self.org_id),
                        self.packaging,
                        self.file_checksum_type, self.file_checksum)

        self.rel_package_path = rhnPackageUpload.relative_path_from_header(
            a_pkg.header, org_id=self.org_id,
            checksum_type=a_pkg.checksum_type, checksum=a_pkg.checksum)
        self.package_path = os.path.join(CFG.MOUNT_POINT,
            self.rel_package_path)
        
        package_dict, diff_level = rhnPackageUpload.push_package(a_pkg,
            force=self.force,
            relative_path=self.rel_package_path, org_id=self.org_id)

        if diff_level:
            return self._send_package_diff(req, diff_level, package_dict)

        # Everything went fine
        rhnSQL.commit()
        reply = "All OK"
        req.headers_out['Content-Length'] = str(len(reply))
        req.send_http_header()
        req.write(reply)
        log_debug(2, "Returning with OK")
        
        return apache.OK

    def _send_package_diff(self, req, diff_level, diff):
        dict = {
            'level' : diff_level,
            'diff'  : diff,
        }
        reply = rpclib.xmlrpclib.dumps((dict, ))
        ret_stat = apache.HTTP_BAD_REQUEST
        req.status = ret_stat
        req.err_headers_out['Content-Length'] = str(len(reply))
        req.send_http_header()
        req.write(reply)
        return apache.OK

    def get_auth_token(self, value):
        s = ''.join(map(lambda x: x.strip(), value.split('')))
        arr = map(base64.decodestring, s.split(':'))
        return arr

