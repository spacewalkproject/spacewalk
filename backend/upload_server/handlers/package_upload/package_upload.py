#!/usr/bin/python
#
# Code that drops files on the filesystem (/PKG-UPLOAD)
#
#
# Copyright (c) 2008 Red Hat, Inc.
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
from mod_python import apache

from common import CFG, log_debug, log_error, rhnFault, rhnFlags, rhnLib
from server import rhnPackageUpload, basePackageUpload
from server.rhnLib import get_package_path

class PackageUpload(basePackageUpload.BasePackageUpload):
    def headerParserHandler(self, req):
        ret = basePackageUpload.BasePackageUpload.headerParserHandler(self, req)
        if ret != apache.OK:
            return ret

        nevra = [self.package_name, "", self.package_version, 
            self.package_release, self.package_arch]
        log_debug(5, "nevra", nevra, "org_id", self.org_id, "prepend",
            self.prefix, "source", self.is_source)
        self.rel_package_path = get_package_path(nevra, org_id=self.org_id, 
            prepend=self.prefix, omit_epoch=1, source=self.is_source)
        self.package_path = os.path.normpath(
            os.path.join(CFG.MOUNT_POINT, self.rel_package_path))

        log_debug(5, "Package path", self.package_path)

        try:
            rhnPackageUpload.check_package_exists(self.package_path,
            self.file_md5sum, force=0)
        except rhnPackageUpload.AlreadyUploadedError:
            log_debug(2, "Already exists", self.rel_package_path)
            return apache.HTTP_CREATED
        except rhnPackageUpload.PackageConflictError, e:
            log_error("Different md5sums", self.package_path)
            rhnFlags.set("apache-return-code", apache.HTTP_CONFLICT)
            raise rhnFault(104, 
                "Package %s (%s) already exists, with checksum %s " % 
                    (os.path.basename(self.package_path), 
                    self.file_md5sum, e.args[1]))

        return apache.OK
            
    def handler(self, req):
        ret = basePackageUpload.BasePackageUpload.handler(self, req)
        if ret != apache.OK:
            return ret

        buffer_size = 16384
        for i in req.headers_in.keys():
            log_debug(5, "Header %s: %s" % (i, req.headers_in[i]))
        log_debug(4, "Header length", len(req.headers_in[i]))

        temp_stream = rhnPackageUpload.write_temp_file(req, buffer_size)
        header, payload_stream, header_start, header_end = \
            rhnPackageUpload.load_package(temp_stream)
        md5sum = rhnLib.getFileMD5(file=temp_stream)
        temp_stream.close()

        if self.file_md5sum != md5sum:
            raise rhnFault(501, "Uploaded: %s; filesystem: %s" %
                (self.file_md5sum, md5sum))

        if not rhnPackageUpload.source_match(self.is_source, header.is_source):
            # Unexpected rpm package type
            raise rhnFault(505, "Mismatching source/binary rpm: %s-%s-%s.%s.rpm"
                % (self.package_name, self.package_version,
                    self.package_release, self.package_arch)) 

        n, v, r = header['name'], header['version'], header['release']
        if self.is_source:
            #4/18/05 wregglej. if 1051 is in the header's keys, it should be nosrc.
            if 1051 in header.keys():
                a = 'nosrc'
            else:
                a = 'src'
        else:
            a = header['arch']
        
        if n != self.package_name:
            raise rhnFault(502, "name")
        if v != self.package_version:
            raise rhnFault(502, "version")
        if r != self.package_release:
            raise rhnFault(502, "release")
        if a != self.package_arch:
            raise rhnFault(502, "arch")

        # XXX
        if not header.is_signed:
            rhnFlags.set("apache-return-code", apache.HTTP_CONFLICT)
            raise rhnFault(103, "Package %s (%s) is not signed" % 
                    (os.path.basename(self.package_path), self.file_md5sum))

        payload_stream.seek(0, 0)
        dirname = os.path.dirname(self.package_path)
        if not os.path.isdir(dirname):
            os.makedirs(dirname, 0755)
        destfd = os.open(self.package_path, os.O_CREAT | os.O_WRONLY, 0644)
        while 1:
            buf = payload_stream.read(buffer_size)
            if not buf:
                break
            os.write(destfd, buf)
        os.close(destfd)
        payload_stream.close()

        req.content_type = "text/plain"
        for k in req.headers_in.keys():
            req.headers_out.add(k, req.headers_in[k])
        reply = "All OK"
        req.headers_out['Content-Length'] = str(len(reply))
        req.send_http_header()
        req.write(reply)
        return apache.OK


    def cleanupHandler(self, req):
        return apache.OK

    def logHandler(self, req):
        return apache.OK
