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

import socket
import base64
import sys
# pylint: disable=F0401,E0611,W0632
if sys.version_info[0] == 3:
    from urllib.parse import splitport
    from urllib.parse import urlparse
else:
    from urllib import splitport
    from urlparse import urlparse

from spacewalk.common.usix import ListType, TupleType, IntType

from rhn import connections, rpclib

from spacewalk.common.rhn_pkg import InvalidPackageError, package_from_filename
from spacewalk.common.usix import raise_with_tb
from rhnpush.utils import tupleify_urlparse


class ConnectionError(Exception):
    pass

# pylint: disable=R0902


class BaseConnection:

    def __init__(self, uri, proxy=None):
        self._scheme, (self._host, self._port), self._path = parse_url(uri)[:3]

        if proxy:
            arr = rpclib.get_proxy_info(proxy)
            self._proxy_host = arr[0]
            self._proxy_port = arr[1]
            self._proxy_username = arr[2]
            self._proxy_password = arr[3]
        else:
            self._proxy_host = None

        self._trusted_certs = None
        self._connection = None
        self._timeout = None

    def set_timeout(self, timeout):
        self._timeout = timeout

    def get_connection(self):
        if self._scheme not in ['http', 'https']:
            raise ValueError("Unsupported scheme", self._scheme)
        params = {}
        if self._timeout is not None:
            params['timeout'] = self._timeout
        if self._proxy_host:
            params.update({
                'host': self._host,
                'port': self._port,
                'proxy': "%s:%s" % (self._proxy_host, self._proxy_port),
                'username': self._proxy_username,
                'password': self._proxy_password,
            })
            if self._scheme == 'http':
                return connections.HTTPProxyConnection(**params)
            params['trusted_certs'] = self._trusted_certs
            return connections.HTTPSProxyConnection(**params)
        else:
            if self._scheme == 'http':
                return connections.HTTPConnection(self._host, self._port, **params)
            params['trusted_certs'] = self._trusted_certs
            return connections.HTTPSConnection(self._host, self._port, **params)

    def connect(self):
        self._connection = self.get_connection()
        self._connection.connect()

    def putrequest(self, method, url=None, skip_host=0):
        if url is None:
            url = self._path
        return self._connection.putrequest(method, url=url,
                                           skip_host=skip_host)

    def __getattr__(self, name):
        return getattr(self._connection, name)


class PackageUpload:
    header_prefix = "X-RHN-Upload"
    user_agent = "rhn-package-upload"

    def __init__(self, url, proxy=None):
        self.connection = BaseConnection(url, proxy)
        self.headers = {}
        self.package_name = None
        self.package_epoch = None
        self.package_version = None
        self.package_release = None
        self.package_arch = None
        self.checksum = None
        self.checksum_type = None
        self.nvra = None
        self._resp_headers = None
        self.packaging = None
        self._response = None

    def set_header(self, name, value):
        if name not in self.headers:
            vlist = self.headers[name] = []
        else:
            vlist = self.headers[name]
            if not isinstance(vlist, (ListType, TupleType)):
                vlist = [vlist]
        vlist.append(value)

    def send_http_headers(self, method, content_length=None):
        try:
            self.connection.connect()
        except socket.error:
            e = sys.exc_info()[1]
            raise_with_tb(ConnectionError("Error connecting", str(e)), sys.exc_info()[2])

        # Add content_length
        if 'Content-Length' not in self.headers and \
                content_length is not None:
            self.set_header('Content-Length', content_length)
        self.connection.putrequest(method)

        # Additional headers
        for hname, hval in self.headers.items():
            if not isinstance(hval, (ListType, TupleType)):
                hval = [hval]

            for v in hval:
                self.connection.putheader(str(hname), str(v))

        self.connection.endheaders()

    def send_http_body(self, stream_body):
        if stream_body is None:
            return
        stream_body.seek(0, 0)
        buffer_size = 16384
        while 1:
            buf = stream_body.read(buffer_size)
            if not buf:
                break
            try:
                self.connection.send(buf)
            except IOError:
                e = sys.exc_info()[1]
                raise_with_tb(ConnectionError("Error sending body", str(e)), sys.exc_info()[2])

    def send_http(self, method, stream_body=None):
        if stream_body is None:
            content_length = 0
        else:
            stream_body.seek(0, 2)
            content_length = stream_body.tell()
        self.send_http_headers(method, content_length=content_length)
        self.send_http_body(stream_body)
        self._response = self.connection.getresponse()
        self._resp_headers = self._response.msg

        return self._response

    def upload(self, filename, fileChecksumType, fileChecksum):
        """
        Uploads a file.
        Returns (http_error_code, error_message)
        Sets:
            self.package_name
            self.package_epoch
            self.package_version
            self.package_release
            self.package_arch
        """
        try:
            a_pkg = package_from_filename(filename)
            a_pkg.read_header()
        except InvalidPackageError:
            return -1, "Not an RPM: %s" % filename

        # Set some package data members
        self.package_name = a_pkg.header['name']
        self.package_epoch = a_pkg.header['epoch']
        self.package_version = a_pkg.header['version']
        self.package_release = a_pkg.header['release']
        if a_pkg.header.is_source:
            if 1051 in a_pkg.header.keys():
                self.package_arch = 'nosrc'
            else:
                self.package_arch = 'src'
        else:
            self.package_arch = a_pkg.header['arch']
        self.packaging = a_pkg.header.packaging

        nvra = [self.package_name, self.package_version, self.package_release,
                self.package_arch]

        if isinstance(nvra[3], IntType):
            # Old rpm format
            return -1, "Deprecated RPM format: %s" % filename

        self.nvra = nvra

        # use the precomputed passed checksum
        self.checksum_type = fileChecksumType
        self.checksum = fileChecksum

        # Set headers
        self.set_header("Content-Type", "application/x-rpm")
        self.set_header("User-Agent", self.user_agent)
        # Custom RHN headers
        prefix = self.header_prefix
        self.set_header("%s-%s" % (prefix, "Package-Name"), nvra[0])
        self.set_header("%s-%s" % (prefix, "Package-Version"), nvra[1])
        self.set_header("%s-%s" % (prefix, "Package-Release"), nvra[2])
        self.set_header("%s-%s" % (prefix, "Package-Arch"), nvra[3])
        self.set_header("%s-%s" % (prefix, "Packaging"), self.packaging)
        if self.checksum_type == 'md5':
            self.set_header("%s-%s" % (prefix, "File-MD5sum"), self.checksum)
        else:
            self.set_header("%s-%s" % (prefix, "File-Checksum-Type"), self.checksum_type)
            self.set_header("%s-%s" % (prefix, "File-Checksum"), self.checksum)

        a_pkg.input_stream.seek(0, 0)
        self._response = self.send_http('POST', stream_body=a_pkg.input_stream)
        a_pkg.input_stream.close()

        retval = self.process_response()
        self.connection.close()
        return retval

    def process_response(self):
        status = self._response.status
        reason = self._response.reason
        if status == 200:
            # OK
            return status, "OK"
        if status == 201:
            # Created
            return (status, "%s %s: %s-%s-%s.%s.rpm already uploaded" % (
                self.checksum_type, self.checksum,
                self.nvra[0], self.nvra[1], self.nvra[2], self.nvra[3]))
        if status in (404, 409):
            # Conflict
            errstring = self.get_error_message(self._resp_headers)
            return status, errstring
        data = self._response.read()
        if status == 403:
            # In this case Authentication is no longer valid on server
            # client needs to re-authenticate itself.
            errstring = self.get_error_message(self._resp_headers)
            return status, errstring
        if status == 500:
            print("Internal server error", status, reason)
            errstring = self.get_error_message(self._resp_headers)
            return status, data + errstring

        return status, data

    def get_error_message(self, headers):
        prefix = self.header_prefix + '-Error'
        text = [x[1] for x in headers.getaddrlist(prefix + '-String')]
        # text is a list now, convert it to a string
        text = '\n'.join(text)
        text = base64.decodestring(text)
        return text


def parse_url(url, scheme="http", path='/'):
    _scheme, netloc, _path, params, query, fragment = tupleify_urlparse(
        urlparse(url))
    if not netloc:
        # No scheme - trying to patch it up ourselves?
        url = scheme + "://" + url
        _scheme, netloc, _path, params, query, fragment = tupleify_urlparse(
            urlparse(url))

    if not netloc:
        # XXX
        raise Exception()

    (host, port) = splitport(netloc)

    if not _path:
        _path = path

    return (_scheme, (host, port), _path, params, query, fragment)
