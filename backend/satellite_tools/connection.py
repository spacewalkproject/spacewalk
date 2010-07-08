#
# Module that provides the client-side functionality for an XML importer
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

import urllib
import string
import gzipstream

from rhn import rpclib
from satellite_tools import constants

__version__ = "0.1"

class Transport(rpclib.transports.Transport):
    user_agent = "satellite-sync/%s" % __version__
    def __init__(self):
        rpclib.transports.Transport.__init__(self)
        self.add_header("Accept-Encoding", "gzip")

    def _process_response(self, fd, connection):
        # Content-Type defaults to txt/xml
        content_type = self.headers_in.get('Content-Type', 'text/xml')
        content_encoding = self.headers_in.get('Content-Encoding')

        if content_encoding == 'gzip':
            # Un-gzipstream it
            # NOTE: if data expected to get bigger than ~2.5Gb in size
            #       then use GzipStreamXL instead (it's slower though)
            fd = CompressedStream(fd)

        if content_type == 'text/xml':
            # XML-RPC error
            # Catch exceptions so we can properly close file descriptors
            try:
                ret = self.parse_response(fd)
            except:
                fd.close()
                connection.close()
                raise
            fd.close()
            connection.close()
            return ret
            
        # XXX application/octet-stream should go away
        if content_type in ('application/xml', 'application/octet-stream', 
                'application/x-rpm'):
            f = rpclib.File(fd)
            # Explanation copied from the base class' method (rhn.transports):
            # Set the File's close method to the connection's
            # Note that calling the HTTPResponse's close() is not enough,
            # since the main socket would remain open, and this is
            # particularily bad with SSL
            f.close = connection.close
            return f

        connection.close()
        raise Exception, "Unknown response type", content_type

class SafeTransport(rpclib.transports.SafeTransport, Transport):
    _process_response = Transport._process_response

class ProxyTransport(rpclib.transports.ProxyTransport, Transport):
    _process_response = Transport._process_response

class SafeProxyTransport(rpclib.transports.SafeProxyTransport, Transport):
    _process_response = Transport._process_response


class _Server(rpclib.Server):
    _transport_class = Transport
    _transport_class_https = SafeTransport
    _transport_class_proxy = ProxyTransport
    _transport_class_https_proxy = SafeProxyTransport


class StreamConnection(_Server):
    def __init__(self, uri, proxy=None, username=None, password=None, 
                refreshCallback=None, xml_dump_version=constants.PROTOCOL_VERSION):
        _Server.__init__(self, uri, proxy=proxy, username=username,
                password=password, refreshCallback=refreshCallback)
        self.add_header("X-RHN-Satellite-XML-Dump-Version", xml_dump_version)

class GETServer(rpclib.GETServer):
    """ class rpclib.GETServer with overriden default transports classes """
    _transport_class = Transport
    _transport_class_https = SafeTransport
    _transport_class_proxy = ProxyTransport
    _transport_class_https_proxy = SafeProxyTransport

def parse_url(url):
    url_type, rest = urllib.splittype(url)
    if url_type is None:
        url_type = 'http'
        rest = '//' + rest

    url_type = string.lower(url_type)

    hostport, path = urllib.splithost(rest)
    host, port = urllib.splitport(hostport)
    return url_type, host, port, path

class CompressedStream:
    """
    GzipStream will not close the connection by itself, so we have to keep the
    underlying stream around
    """
    def __init__(self, stream):
        def noop():
            pass
        self._real_stream = stream
        # gzipstream tries to flush stuff; add a noop function
        self._real_stream.flush = noop
        self.stream = self._real_stream
        if not isinstance(self._real_stream, gzipstream.GzipStream):
            self.stream = gzipstream.GzipStream(stream=self._real_stream, mode="r")

    def close(self):
        if self.stream:
            self.stream.close()
            self.stream = None
        if self._real_stream:
            self._real_stream.close()
            self._real_stream = None

    def __getattr__(self, name):
        return getattr(self.stream, name)

    def __repr__(self):
        return "<_CompressedStream at %s>" % id(self)

if __name__ == '__main__':
    pass
