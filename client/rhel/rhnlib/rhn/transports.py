#
# Helper transport objects
#
# Copyright (c) 2002-2005 Red Hat, Inc.
#
# Author: Mihai Ibanescu <misa@redhat.com>
# Based on what was previously shipped as cgiwrap:
#   - Cristian Gafton <gafton@redhat.com> 
#   - Erik Troan <ewt@redhat.com>

# $Id$

# Transport objects
import os
import sys
import time
from types import IntType, StringType, ListType
from SmartIO import SmartIO

from UserDictCase import UserDictCase

import connections
import xmlrpclib

__version__ = "$Revision$"

# XXX
COMPRESS_LEVEL = 6

# Exceptions
class NotProcessed(Exception):
    pass

class Transport(xmlrpclib.Transport):
    user_agent = "rhn.rpclib.py/%s" % __version__

    def __init__(self, transfer=0, encoding=0, refreshCallback=None,
            progressCallback=None, use_datetime=None):
        self._transport_flags = {'transfer' : 0, 'encoding' : 0}
        self.set_transport_flags(transfer=transfer, encoding=encoding)
        self._headers = UserDictCase()
        self.verbose = 0
        self.connection = None
        self.method = "POST"
        self._lang = None
        self.refreshCallback = refreshCallback
        self.progressCallback = progressCallback
        self.bufferSize = 16384
        self.headers_in = None
        self.response_status = None
        self.response_reason = None
        self._redirected = None
        self._use_datetime = use_datetime

    # set the progress callback
    def set_progress_callback(self, progressCallback, bufferSize=16384):
        self.progressCallback = progressCallback
        self.bufferSize = bufferSize

    # set the refresh callback
    def set_refresh_callback(self, refreshCallback):
        self.refreshCallback = refreshCallback

    # set the buffer size
    # The bigger this is, the faster the read is, but the more seldom is the 
    # progress callback called
    def set_buffer_size(self, bufferSize):
        if bufferSize is None:
            # No buffer size specified; go with 16k
            bufferSize = 16384

        self.bufferSize = bufferSize

    # set the request method
    def set_method(self, method):
        if method not in ("GET", "POST"):
            raise IOError, "Unknown request method %s" % method
        self.method = method
    
    # reset the transport options
    def set_transport_flags(self, transfer=None, encoding=None, **kwargs):
        # For backwards compatibility, we keep transfer and encoding as
        # positional parameters (they could come in as kwargs easily)

        self._transport_flags.update(kwargs)
        if transfer is not None:
            self._transport_flags['transfer'] = transfer
        if encoding is not None:
            self._transport_flags['encoding'] = encoding
        self.validate_transport_flags()

    def get_transport_flags(self):
        return self._transport_flags.copy()

    def validate_transport_flags(self):
        # Transfer and encoding are guaranteed to be there
        transfer = self._transport_flags.get('transfer')
        transfer = lookupTransfer(transfer, strict=1)
        self._transport_flags['transfer'] = transfer

        encoding = self._transport_flags.get('encoding')
        encoding = lookupEncoding(encoding, strict=1)
        self._transport_flags['encoding'] = encoding

    # Add arbitrary additional headers.
    def set_header(self, name, arg):
        if type(arg) in [ type([]), type(()) ]:
            # Multivalued header
            self._headers[name] = map(str, arg)
        else:
            self._headers[name] = str(arg)

    def add_header(self, name, arg):
        if self._headers.has_key(name):
            vlist = self._headers[name]
            if not isinstance(vlist, ListType):
                vlist = [ vlist ]
        else:
            vlist = self._headers[name] = []
        vlist.append(str(arg))

    def clear_headers(self):
        self._headers.clear()

    def get_connection(self, host):
        if self.verbose:
            print "Connecting via http to %s" % (host, )
        return connections.HTTPConnection(host)
        
    def request(self, host, handler, request_body, verbose=0):
        # issue XML-RPC request
        # XXX: automatically compute how to send depending on how much data
        #      you want to send
        
        # XXX Deal with HTTP/1.1 if necessary
        self.verbose = verbose
        
        # implement BASIC HTTP AUTHENTICATION
        host, extra_headers, x509 = self.get_host_info(host)
        if not extra_headers:
            extra_headers = []
        # Establish the connection
        connection = self.get_connection(host)
        # Setting the user agent. Only interesting for SSL tunnels, in any
        # other case the general headers are good enough.
        connection.set_user_agent(self.user_agent)
        if self.verbose:
            connection.set_debuglevel(self.verbose - 1)
        # Get the output object to push data with
        req = Output(connection=connection, method=self.method)
        apply(req.set_transport_flags, (), self._transport_flags)

        # Add the extra headers
        req.set_header('User-Agent', self.user_agent)
        for header, value in self._headers.items() + extra_headers:
            # Output.set_header correctly deals with multivalued headers now
            req.set_header(header, value)

        # Content-Type
        req.set_header("Content-Type", "text/xml")
        req.process(request_body)

        # Host and Content-Length are set by HTTP*Connection
        for h in ['Content-Length', 'Host']:
            req.clear_header(h)
        
        headers, fd = req.send_http(host, handler)
        
        if self.verbose:
            print "Incoming headers:"
            for header, value in headers.items():
                print "\t%s : %s" % (header, value)

        if fd.status in (301, 302):
            self._redirected = headers["Location"]
            self.response_status = fd.status
            return None

        # Save the headers
        self.headers_in = headers
        self.response_status = fd.status
        self.response_reason = fd.reason

        return self._process_response(fd, connection)

    def _process_response(self, fd, connection):
        # Now use the Input class in case we get an enhanced response
        resp = Input(self.headers_in, progressCallback=self.progressCallback,
                bufferSize=self.bufferSize)
        
        fd = resp.decode(fd)
        
        if isinstance(fd, InputStream):
            # When the File object goes out of scope, so will the InputStream;
            # that will eventually call the connection's close() method and
            # cleanly reap it
            f = File(fd.fd, fd.length, fd.name, bufferSize=self.bufferSize,
                progressCallback=self.progressCallback)
            # Set the File's close method to the connection's
            # Note that calling the HTTPResponse's close() is not enough,
            # since the main socket would remain open, and this is
            # particularily bad with SSL
            f.close = connection.close
            return f

        # We can safely close the connection now; if we had an
        # application/octet/stream (for which Input.read passes the original
        # socket object), Input.decode would return an InputStream,
        # so we wouldn't reach this point
        connection.close()

        return self.parse_response(fd)

    # Give back the new URL if redirected
    def redirected(self):
        return self._redirected

    # Rewrite parse_response to provide refresh callbacks
    def parse_response(self, f):
        # read response from input file, and parse it

        p, u = self.getparser()

        while 1:
            response = f.read(1024)
            if not response:
                break
            if self.refreshCallback:
                self.refreshCallback()
            if self.verbose:
                print "body:", repr(response)
            p.feed(response)

        f.close()
        p.close()
        return u.close()

        
    def setlang(self, lang):
        self._lang = lang

class SafeTransport(Transport):
    def __init__(self, transfer=0, encoding=0, refreshCallback=None,
                progressCallback=None, trusted_certs=None):
        Transport.__init__(self, transfer, encoding, 
            refreshCallback=refreshCallback, progressCallback=progressCallback)
        self.trusted_certs = []
        for certfile in (trusted_certs or []):
            self.add_trusted_cert(certfile)

    def add_trusted_cert(self, certfile):
        if not os.access(certfile, os.R_OK):
            raise ValueError, "Certificate file %s is not accessible" % certfile
        self.trusted_certs.append(certfile)

    def get_connection(self, host):
        # implement BASIC HTTP AUTHENTICATION
        host, extra_headers, x509 = self.get_host_info(host)
        if self.verbose:
            print "Connecting via https to %s" % (host, )
        return connections.HTTPSConnection(host, trusted_certs=self.trusted_certs)


class ProxyTransport(Transport):
    def __init__(self, proxy, proxyUsername=None, proxyPassword=None,
            transfer=0, encoding=0, refreshCallback=None, progressCallback=None):
        Transport.__init__(self, transfer, encoding,
            refreshCallback=refreshCallback, progressCallback=progressCallback)
        self._proxy = proxy
        self._proxy_username = proxyUsername
        self._proxy_password = proxyPassword

    def get_connection(self, host):
        if self.verbose:
            print "Connecting via http to %s proxy %s, username %s, pass %s" % (
                host, self._proxy, self._proxy_username, self._proxy_password)
        return connections.HTTPProxyConnection(self._proxy, host, 
            username=self._proxy_username, password=self._proxy_password)

class SafeProxyTransport(ProxyTransport):
    def __init__(self, proxy, proxyUsername=None, proxyPassword=None,
            transfer=0, encoding=0, refreshCallback=None,
            progressCallback=None, trusted_certs=None):
        ProxyTransport.__init__(self, proxy, 
            proxyUsername=proxyUsername, proxyPassword=proxyPassword,
            transfer=transfer, encoding=encoding, 
            refreshCallback=refreshCallback,
            progressCallback=progressCallback)
        self.trusted_certs = []
        for certfile in (trusted_certs or []):
            self.add_trusted_cert(certfile)

    def add_trusted_cert(self, certfile):
        if not os.access(certfile, os.R_OK):
            raise ValueError, "Certificate file %s is not accessible" % certfile
        self.trusted_certs.append(certfile)

    def get_connection(self, host):
        if self.verbose:
            print "Connecting via https to %s proxy %s, username %s, pass %s" % (
                host, self._proxy, self._proxy_username, self._proxy_password)
        return connections.HTTPSProxyConnection(self._proxy, host, 
            username=self._proxy_username, password=self._proxy_password, 
            trusted_certs=self.trusted_certs)

# ============================================================================
# Extended capabilities for transport
#
# We allow for the following possible headers:
#
# Content-Transfer-Encoding:
#       This header tells us how the POST data is encoded in what we read.
#       If it is not set, we assume plain text that can be passed along
#       without any other modification. If set, valid values are:
#       - binary : straight binary data
#       - base64 : will pass through base64 decoder to get the binary data
#
# Content-Encoding:
#       This header tells us what should we do with the binary data obtained
#       after acting on the Content-Transfer-Encoding header. Valid values:
#       - x-gzip : will need to pass through GNU gunzip-like to get plain
#                  text out
#       - x-zlib : this denotes the Python's own zlib bindings which are a
#                  datastream based on gzip, but not quite
#       - x-gpg : will need to pass through GPG to get out the text we want

# ============================================================================
# Input class to automate reading the posting from the network
# Having to work with environment variables blows, though
class Input:
    def __init__(self, headers=None, progressCallback=None, bufferSize=1024,
            max_mem_size=16384):
        self.transfer = None
        self.encoding = None
        self.type = None
        self.length = 0
        self.lang = "C"
        self.name = ""
        self.progressCallback = progressCallback
        self.bufferSize = bufferSize
        self.max_mem_size = max_mem_size
        
        if not headers:
            # we need to get them from environment
            if os.environ.has_key("HTTP_CONTENT_TRANSFER_ENCODING"):
                self.transfer = os.environ["HTTP_CONTENT_TRANSFER_ENCODING"].lower()
            if os.environ.has_key("HTTP_CONTENT_ENCODING"):
                self.encoding = os.environ["HTTP_CONTENT_ENCODING"].lower()
            if os.environ.has_key("CONTENT-TYPE"):
                self.type = os.environ["CONTENT-TYPE"].lower()
            if os.environ.has_key("CONTENT_LENGTH"):
                self.length = int(os.environ["CONTENT_LENGTH"])
            if os.environ.has_key("HTTP_ACCEPT_LANGUAGE"):
                self.lang = os.environ["HTTP_ACCEPT_LANGUAGE"]
            if os.environ.has_key("HTTP_X_PACKAGE_FILENAME"):
                self.name = os.environ["HTTP_X_PACKAGE_FILENAME"]
        else:
            # The stupid httplib screws up the headers from the HTTP repsonse
            # and converts them to lowercase. This means that we have to
            # convert to lowercase all the dictionary keys in case somebody calls
            # us with sane values --gaftonc (actually mimetools is the culprit)
            for header in headers.keys():
                value = headers[header]
                h = header.lower()
                if h == "content-length":
                    try:
                        self.length = int(value)
                    except ValueError:
                        self.length = 0
                elif h == "content-transfer-encoding":
                    # RFC 2045 #6.1: case insensitive
                    self.transfer = value.lower()
                elif h == "content-encoding":
                    # RFC 2616 #3.5: case insensitive
                    self.encoding = value.lower()
                elif h == "content-type":
                    # RFC 2616 #3.7: case insensitive
                    self.type = value.lower()
                elif h == "accept-language":
                    # RFC 2616 #3.10: case insensitive
                    self.lang = value.lower()
                elif h == "x-package-filename":
                    self.name = value
            
        self.io = None
   
    def read(self, fd = sys.stdin):
        # The octet-streams are passed right back
        if self.type == "application/octet-stream":
            return
        
        if self.length:
            # Read exactly the amount of data we were told
            self.io = _smart_read(fd, self.length, 
                bufferSize=self.bufferSize,
                progressCallback=self.progressCallback,
                max_mem_size=self.max_mem_size)
        else:
            # Oh well, no clue; read until EOF (hopefully)
            self.io = _smart_total_read(fd)

        if not self.transfer or self.transfer == "binary":
            return
        elif self.transfer == "base64":
            import base64
            old_io = self.io
            old_io.seek(0, 0)
            self.io = SmartIO(max_mem_size=self.max_mem_size)
            base64.decode(old_io, self.io)
        else:
            raise NotImplementedError(self.transfer)

    def decode(self, fd = sys.stdin):
        # The octet-stream data are passed right back
        if self.type == "application/octet-stream":
            return InputStream(fd, self.length, self.name, close=fd.close)
        
        if not self.io:
            self.read(fd)

        # At this point self.io exists (the only case when self.read() does
        # not initialize self.io is when content-type is
        # "application/octet-stream" - and we already dealt with that case

        # We can now close the file descriptor
        if hasattr(fd, "close"):
            fd.close()

        # Now we have the binary goo
        if not self.encoding or self.encoding == "__plain":
            # all is fine.
            pass
        elif self.encoding in ("x-zlib", "deflate"):
            import zlib
            obj = zlib.decompressobj()
            self.io.seek(0, 0)
            data = obj.decompress(self.io.read()) + obj.flush()
            del obj
            self.length = len(data)
            self.io = SmartIO(max_mem_size=self.max_mem_size)
            self.io.write(data)
        elif self.encoding in ("x-gzip", "gzip"):
            import gzip
            self.io.seek(0, 0)
            gz = gzip.GzipFile(mode="rb", compresslevel = COMPRESS_LEVEL,
                               fileobj=self.io)
            data = gz.read()
            self.length = len(data)
            self.io = SmartIO(max_mem_size=self.max_mem_size)
            self.io.write(data)
        elif self.encoding == "x-gpg":           
            # XXX: should be written
            raise NotImplementedError(self.transfer, self.encoding)
        else:
            raise NotImplementedError(self.transfer, self.encoding)

        # Play nicely and rewind the file descriptor
        self.io.seek(0, 0)
        return self.io
    
    def getlang(self):
        return self.lang

# Utility functions 

def _smart_total_read(fd, bufferSize=1024, max_mem_size=16384):
    """
    Tries to read data from the supplied stream, and puts the results into a
    StmartIO object. The data will be in memory or in a temporary file,
    depending on how much it's been read
    Returns a SmartIO object
    """
    io = SmartIO(max_mem_size=max_mem_size)
    while 1:
        chunk = fd.read(bufferSize)
        if not chunk:
            # EOF reached
            break
        io.write(chunk)

    return io

def _smart_read(fd, amt, bufferSize=1024, progressCallback=None,
        max_mem_size=16384):
    # Reads amt bytes from fd, or until the end of file, whichever
    # occurs first
    # The function will read in memory if the amout to be read is smaller than
    # max_mem_size, or to a temporary file otherwise
    #
    # Unlike read(), _smart_read tries to return exactly the requested amount
    # (whereas read will return _up_to_ that amount). Reads from sockets will
    # usually reaturn less data, or the read can be interrupted
    # 
    # Inspired by Greg Stein's httplib.py (the standard in python 2.x)
    #
    # support for progress callbacks added
    startTime = time.time()
    lastTime = startTime
    buf = SmartIO(max_mem_size=max_mem_size)
    
    origsize = amt
    while amt > 0:
        curTime = time.time()
        l = min(bufferSize, amt)
        chunk = fd.read(l)
        # read guarantees that len(chunk) <= l
        l = len(chunk)
        if not l:
            # Oops. Most likely EOF
            break

        # And since the original l was smaller than amt, we know amt >= 0
        amt = amt - l
        buf.write(chunk)
        if progressCallback is None:
            # No progress callback, so don't do fancy computations
            continue
        # We update the progress callback if:
        #  we haven't updated it for more than a secord, or
        #  it's the last read (amt == 0)
        if curTime - lastTime >= 1 or amt == 0:
            lastTime = curTime
            # use float() so that we force float division in the next step
            bytesRead = float(origsize - amt)
            # if amt == 0, on a fast machine it is possible to have 
            # curTime - lastTime == 0, so add an epsilon to prevent a division
            # by zero
            speed = bytesRead / ((curTime - startTime) + .000001)
            if origsize == 0:
                secs = 0
            else:
                # speed != 0 because bytesRead > 0
                # (if bytesRead == 0 then origsize == amt, which means a read
                # of 0 length; but that's impossible since we already checked
                # that l is non-null
                secs = amt / speed
            progressCallback(bytesRead, origsize, speed, secs) 

    # Now rewind the SmartIO
    buf.seek(0, 0)
    return buf

class InputStream:
    def __init__(self, fd, length, name = "<unknown>", close=None):
        self.fd = fd
        self.length = int(length)
        self.name = name
        # Close function
        self.close = close
    def __repr__(self):
        return "Input data is a stream of %d bytes for file %s.\n" % (self.length, self.name)


# ============================================================================
# Output class that will be used to build the temporary output string
class BaseOutput:
    # DEFINES for instances use   
    # Content-Encoding
    ENCODE_NONE = 0
    ENCODE_GZIP = 1
    ENCODE_ZLIB = 2
    ENCODE_GPG  = 3
    
    # Content-Transfer-Encoding
    TRANSFER_NONE   = 0
    TRANSFER_BINARY = 1
    TRANSFER_BASE64 = 2

     # Mappings to make things easy
    encodings = [
         [None, "__plain"],     # ENCODE_NONE
         ["x-gzip", "gzip"],    # ENCODE_GZIP
         ["x-zlib", "deflate"], # ENCODE_ZLIB
         ["x-gpg"],             # ENCODE_GPG
    ]
    transfers = [
         None,          # TRANSFER_NONE
         "binary",      # TRANSFRE_BINARY
         "base64",      # TRANSFER_BASE64
    ]

    def __init__(self, transfer=0, encoding=0, connection=None, method="POST"):
        # Assumes connection is an instance of HTTPConnection
        if connection:
            if not isinstance(connection, connections.HTTPConnection):
                raise Exception("Expected an HTTPConnection type object")

        self.method = method

        # Store the connection
        self._connection = connection

        self.data = None
        self.headers = UserDictCase()
        self.encoding = 0
        self.transfer = 0
        self.transport_flags = {}
        # for authenticated proxies
        self.username = None
        self.password = None
        # Fields to keep the information about the server
        self._host = None
        self._handler = None
        self._http_type = None
        self._protocol = None
        # Initialize self.transfer and self.encoding
        self.set_transport_flags(transfer=transfer, encoding=encoding)

        # internal flags
        self.__processed = 0
        
    def set_header(self, name, arg):
        if type(arg) in [ type([]), type(()) ]:
            # Multi-valued header
            #
            # Per RFC 2616, section 4.2 (Message Headers):
            # Multiple message-header fields with the same field-name MAY be
            # present in a message if and only if the entire field-value for
            # the header field is defined as a comma-separated list [i.e.
            # #(values)]. It MUST be possible to combine the multiple header
            # fields into one "field-name: field-value" pair, without
            # changing the semantics of the message, by appending each
            # subsequent field-value to the first, each separated by a comma.
            self.headers[name] = ','.join(map(str, arg))
        else:
            self.headers[name] = str(arg)

    def clear_header(self, name):
        if self.headers.has_key(name):
            del self.headers[name]

    def process(self, data):
        # Assume straight text/xml
        self.data = data

        # Content-Encoding header
        if self.encoding == self.ENCODE_GZIP:
            import gzip
            encoding_name = self.encodings[self.ENCODE_GZIP][0]
            self.set_header("Content-Encoding", encoding_name)
            f = SmartIO(force_mem=1)
            gz = gzip.GzipFile(mode="wb", compresslevel=COMPRESS_LEVEL,
                               fileobj = f)
            gz.write(data)
            gz.close()
            self.data = f.getvalue()
            f.close()
        elif self.encoding == self.ENCODE_ZLIB:
            import zlib
            encoding_name = self.encodings[self.ENCODE_ZLIB][0]
            self.set_header("Content-Encoding", encoding_name)
            obj = zlib.compressobj(COMPRESS_LEVEL)
            self.data = obj.compress(data) + obj.flush()
        elif self.encoding == self.ENCODE_GPG:
            # XXX: fix me.
            raise NotImplementedError(self.transfer, self.encoding)
            encoding_name = self.encodings[self.ENCODE_GPG][0]
            self.set_header("Content-Encoding", encoding_name)

        # Content-Transfer-Encoding header
        if self.transfer == self.TRANSFER_BINARY:
            transfer_name = self.transfers[self.TRANSFER_BINARY]
            self.set_header("Content-Transfer-Encoding", transfer_name)
            self.set_header("Content-Type", "application/binary")
        elif self.transfer == self.TRANSFER_BASE64:
            import base64
            transfer_name = self.transfers[self.TRANSFER_BASE64]
            self.set_header("Content-Transfer-Encoding", transfer_name)
            self.set_header("Content-Type", "text/base64")
            self.data = base64.encodestring(self.data)
            
        self.set_header("Content-Length", len(self.data))

        rpc_version = __version__
        if len(__version__.split()) > 1:
            rpc_version = __version__.split()[1]

        # other headers
        self.set_header("X-Transport-Info",
            'Extended Capabilities Transport (C) Red Hat, Inc (version %s)' % 
            rpc_version)
        self.__processed = 1
        
    # reset the transport options
    def set_transport_flags(self, transfer=0, encoding=0, **kwargs):
        self.transfer = transfer
        self.encoding = encoding
        self.transport_flags.update(kwargs)

    def send_http(self, host, handler="/RPC2"):
        if not self.__processed:
            raise NotProcessed

        self._host = host

        if self._connection is None:
            raise Exception("No connection object found")
        self._connection.connect()
        self._connection.request(self.method, handler, body=self.data, 
            headers=self.headers)
        
        response = self._connection.getresponse()

        if not self.response_acceptable(response):
            raise xmlrpclib.ProtocolError("%s %s" % 
                (self._host, handler),
                response.status, response.reason, response.msg)
                
        # A response object has read() and close() methods, so we can safely
        # pass the whole object back
        return response.msg, response

    def response_acceptable(self, response):
        """Returns true if the response is acceptable"""
        if response.status == 200:
            return 1
        if response.status in (301, 302):
            return 1
        if response.status != 206:
            return 0
        # If the flag is not set, it's unacceptable
        if not self.transport_flags.get('allow_partial_content'):
            return 0
        if response.msg['Content-Type'] != 'application/octet-stream':
            # Don't allow anything else to be requested as a range, it could
            # break the XML parser
            return 0
        return 1

    def close(self):
        if self._connection:
            self._connection.close()
            self._connection = None

def lookupTransfer(transfer, strict=0):
    """Given a string or numeric representation of a transfer, return the
    transfer code"""
    if transfer is None:
        # Plain
        return 0
    if isinstance(transfer, IntType) and 0 <= transfer < len(Output.transfers):
        return transfer
    if isinstance(transfer, StringType):
        for i in range(len(Output.transfers)):
            if Output.transfers[i] == transfer.lower():
                return i
    if strict:
        raise ValueError("Unsupported transfer %s" % transfer)
    # Return default
    return 0

def lookupEncoding(encoding, strict=0):
    """Given a string or numeric representation of an encoding, return the
    encoding code"""
    if encoding is None:
        # Plain
        return 0
    if isinstance(encoding, IntType) and 0 <= encoding < len(Output.encodings):
        return encoding
    if isinstance(encoding, StringType):
        for i in range(len(Output.encodings)):
            if encoding.lower() in Output.encodings[i]:
                return i
    if strict:
        raise ValueError("Unsupported encoding %s" % encoding)
    # Return default
    return 0

Output = BaseOutput

# File object
class File:
    def __init__(self, file_obj, length = 0, name = None,
            progressCallback=None, bufferSize=16384):
        self.length = length
        self.file_obj = file_obj
        self.close = file_obj.close
        self.bufferSize=bufferSize
        self.name = ""
        if name:
            self.name = name[name.rfind("/")+1:]
        self.progressCallback = progressCallback

    def __len__(self):
        return self.length

    def read(self, amt=None):
        # If they want to read everything, use _smart_read
        if amt is None:
            fd = self._get_file()
            return fd.read()

        return self.file_obj.read(amt)

    def read_to_file(self, file):
        """Copies the contents of this File object into another file
        object"""
        fd = self._get_file()
        while 1:
            buf = fd.read(self.bufferSize)
            if not buf:
                break
            file.write(buf)
        return file
        
    def _get_file(self):
        """Read everything into a temporary file and call the progress
        callbacks if the file length is defined, or just reads till EOF"""
        if self.length:
            io = _smart_read(self.file_obj, self.length,
                bufferSize=self.bufferSize, 
                progressCallback=self.progressCallback)
            io.seek(0, 0)
        else:
            # Read everuthing - no callbacks involved
            io = _smart_total_read(self.file_obj, bufferSize=self.bufferSize)
        io.seek(0, 0)
        return io

    def __del__(self):
        if self.close:
            self.close()
            self.close = None
