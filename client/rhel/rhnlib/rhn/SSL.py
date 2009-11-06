#
# Higher-level SSL objects used by rpclib
#
# Copyright (c) 2002-2005 Red Hat, Inc.
#
# Author: Mihai Ibanescu <misa@redhat.com>

# $Id$

"""
rhn.SSL builds an abstraction on top of the objects provided by pyOpenSSL
"""

from OpenSSL import SSL, crypto
import os
import time

import socket
import select

DEFAULT_TIMEOUT = 120


class SSLSocket:
    """
    Class that wraps a pyOpenSSL Connection object, adding more methods
    """
    def __init__(self, socket, trusted_certs=None):
        # SSL.Context object
        self._ctx = None
        # SSL.Connection object 
        self._connection = None
        self._sock = socket
        self._trusted_certs = []
        # convert None to empty list
        trusted_certs = trusted_certs or []
        for f in trusted_certs:
            self.add_trusted_cert(f)
        # SSL method to use
        self._ssl_method = SSL.SSLv23_METHOD
        # Flags to pass to the SSL layer
        self._ssl_verify_flags = SSL.VERIFY_PEER 

        # Buffer size for reads
        self._buffer_size = 8192

        # Position, for tell()
        self._pos = 0
        # Buffer
        self._buffer = ""

        # Flag to show if makefile() was called
        self._makefile_called = 0

        self._closed = None

    def add_trusted_cert(self, file):
        """
        Adds a trusted certificate to the certificate store of the SSL context
        object.
        """
        if not os.access(file, os.R_OK):
            raise ValueError, "Unable to read certificate file %s" % file
        self._trusted_certs.append(file)

    def init_ssl(self):
        """
        Initializes the SSL connection.
        """
        self._check_closed()
        # Get a context
        self._ctx = SSL.Context(self._ssl_method)
        if self._trusted_certs:
            # We have been supplied with trusted CA certs
            for f in self._trusted_certs:
                self._ctx.load_verify_locations(f)
        else:
            # Reset the verify flags
            self._ssl_verify_flags = 0

        self._ctx.set_verify(self._ssl_verify_flags, ssl_verify_callback)
        if hasattr(SSL, "OP_DONT_INSERT_EMPTY_FRAGMENTS"):
            # Certain SSL implementations break when empty fragments are
            # initially sent (even if sending them is compliant to 
            # SSL 3.0 and TLS 1.0 specs). Play it safe and disable this
            # feature (openssl 0.9.6e and later)
            self._ctx.set_options(SSL.OP_DONT_INSERT_EMPTY_FRAGMENTS)

        # Init the connection
        self._connection = SSL.Connection(self._ctx, self._sock)
        # Place the connection in client mode
        self._connection.set_connect_state()

    def makefile(self, mode, bufsize=None):
        """
        Returns self, since we are a file-like object already
        """
        if bufsize:
            self._buffer_size = bufsize

        # Increment the counter with the number of times we've called makefile
        # - we don't want close to actually close things until all the objects
        # that originally called makefile() are gone
        self._makefile_called = self._makefile_called + 1
        return self
    
    def close(self):
        """
        Closes the SSL connection
        """
        # XXX Normally sock.makefile does a dup() on the socket file
        # descriptor; httplib relies on this, but there is no dup for an ssl
        # connection; so we have to count how may times makefile() was called
        if self._closed:
            # Nothing to do
            return
        if not self._makefile_called:
            self._really_close()
            return
        self._makefile_called = self._makefile_called - 1

    def _really_close(self):
        self._connection.shutdown()
        self._connection.close()
        self._closed = 1

    def _check_closed(self):
        if self._closed:
            raise ValueError, "I/O operation on closed file"

    def __getattr__(self, name):
        if hasattr(self._connection, name):
            return getattr(self._connection, name)
        raise AttributeError, name

    # File methods
    def isatty(self):
        """
        Returns false always.
        """
        return 0

    def tell(self):
        return self._pos

    def seek(self, pos, mode=0):
        raise NotImplementedError, "seek"

    def read(self, amt=None):
        """
        Reads up to amt bytes from the SSL connection.
        """
        self._check_closed()
        # Initially, the buffer size is the default buffer size.
        # Unfortunately, pending() does not return meaningful data until
        # recv() is called, so we only adjust the buffer size after the
        # first read
        buffer_size = self._buffer_size

        buffer_length = len(self._buffer)
        # Read only the specified amount of data
        while amt is None or buffer_length < amt:
            # if amt is None (read till the end), fills in self._buffer
            if amt is not None:
                buffer_size = min(amt - buffer_length, buffer_size)

            try:
                data = self._connection.recv(buffer_size)
 
                self._buffer = self._buffer + data
                buffer_length = len(self._buffer)

                # More bytes to read?
                pending = self._connection.pending()
                if pending == 0:
                    # we're done here
                    break
            except SSL.ZeroReturnError:
                # Nothing more to be read
                break
            except SSL.SysCallError, e:
                print "SSL exception", e.args
                break
            except SSL.WantWriteError:
                self._poll(select.POLLOUT, 'read')
            except SSL.WantReadError:
                self._poll(select.POLLIN, 'read')

        if amt:
            ret = self._buffer[:amt]
            self._buffer = self._buffer[amt:]
        else:
            ret = self._buffer
            self._buffer = ""

        self._pos = self._pos + len(ret)
        return ret

    def _poll(self, filter_type, caller_name):
        poller = select.poll()
        poller.register(self._sock, filter_type)
        res = poller.poll(self._sock.gettimeout() * 1000)
        if res == []:
            raise TimeoutException, "Connection timed out on %s" % caller_name

    def write(self, data):
        """
        Writes to the SSL connection.
        """
        self._check_closed()
        
        # XXX Should use sendall 
        # sent = self._connection.sendall(data)
        origlen = len(data)
        while True:
            try:
                sent = self._connection.send(data)
                if sent == len(data):
                    break
                data = data[sent:]
            except SSL.WantWriteError:
                self._poll(select.POLLOUT, 'write')
            except SSL.WantReadError:
                self._poll(select.POLLIN, 'write')
                 
        return origlen

    def recv(self, amt):
        return self.read(amt)

    send = write

    sendall = write

    def readline(self, length=None):
        """
        Reads a single line (up to `length' characters long) from the SSL
        connection.
        """
        self._check_closed()
        while True:
            # charcount contains the number of chars to be outputted (or None
            # if none to be outputted at this time)
            charcount = None
            i = self._buffer.find('\n')
            if i >= 0:
                # Go one char past newline
                charcount = i + 1
            elif length and len(self._buffer) >= length:
                charcount = length

            if charcount is not None:
                ret = self._buffer[:charcount]
                self._buffer = self._buffer[charcount:]
                self._pos = self._pos + len(ret)
                return ret

            # Determine the number of chars to be read next
            bufsize = self._buffer_size
            if length:
                # we know length > len(self._buffer)
                bufsize = min(self._buffer_size, length - len(self._buffer))

            try:
                data = self._connection.recv(bufsize)
                self._buffer = self._buffer + data
            except SSL.ZeroReturnError:
                # Nothing more to be read
                break
            except SSL.WantWriteError:
                self._poll(select.POLLOUT, 'readline')
            except SSL.WantReadError:
                self._poll(select.POLLIN, 'readline')

        # We got here if we're done reading, so return everything
        ret = self._buffer
        self._buffer = ""
        self._pos = self._pos + len(ret)
        return ret


def ssl_verify_callback(conn, cert, errnum, depth, ok):
    """
    Verify callback, which will be called for each certificate in the
    certificate chain.
    """
    # Nothing by default
    return ok

class TimeoutException(SSL.Error, socket.timeout):
    
    def __init__(self, *args):
        self.args = args

    def __str__(self):
        return "Timeout Exception"
