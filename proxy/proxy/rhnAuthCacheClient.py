# rhnAuthCacheClient.py
#-------------------------------------------------------------------------------
# Implements a client-side 'remote shelf' caching object used for
# authentication token caching.
# (Client, meaning, a client to the authCache daemon)
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
#-------------------------------------------------------------------------------
# $Id: rhnAuthCacheClient.py,v 1.42 2004/09/20 15:21:25 misa Exp $

## language imports
import socket
import sys

## local imports
from spacewalk.common.rhnLog import log_debug, log_error
from spacewalk.common.rhnTB import Traceback
from spacewalk.common.rhnException import rhnFault
from spacewalk.common.rhnTranslate import _
from rhnAuthProtocol import CommunicationError, send, recv
from xmlrpclib import Fault

#
# Protocol description:
# 1. Send the size of the data as a long (4 bytes), in network order
# 2. Send the data
#

# Shamelessly stolen from xmlrpclib.xmlrpc
class _Method:

    """ Bind XML-RPC to an RPC Server

        Some magic to bind an XML-RPC method to an RPC server.
        Supports "nested" methods (e.g. examples.getStateName).
    """
    # pylint: disable=R0903

    def __init__(self, msend, name):
        self.__send = msend
        self.__name = name

    def __getattr__(self, name):
        return _Method(self.__send, "%s.%s" % (self.__name, name))

    def __call__(self, *args):
        return self.__send(self.__name, args)

    def __str__(self):
        return "<_Method instance at %s>" % id(self)

    __repr__ = __str__


class Shelf:

    """ Client authenication temp. db.

        Main class that the client side (client to the caching daemon) has to
        instantiate to expose the proper API. Basically, the API is a dictionary.
    """
    # pylint: disable=R0903

    def __init__(self, server_addr):
        log_debug(6, server_addr)
        self.serverAddr = server_addr

    def __request(self, methodname, params):
        # pylint: disable=R0915
        log_debug(6, methodname, params)
        # Init the socket
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

        try:
            sock.connect(self.serverAddr)
        except socket.error, e:
            sock.close()
            methodname = None
            log_error("Error connecting to the auth cache: %s" % str(e))
            Traceback("Shelf.__request", extra="""
              Error connecting to the the authentication cache daemon.
              Make sure it is started on %s""" % str(self.serverAddr))
            # FIXME: PROBLEM: this rhnFault will never reach the client
            raise rhnFault(1000,
              _("RHN Proxy error (issues connecting to auth cache). "
                "Please contact your system administrator")), None, sys.exc_info()[2]

        wfile = sock.makefile("w")

        try:
            send(wfile, methodname, None, *params)
        except CommunicationError:
            wfile.close()
            sock.close()
            Traceback("Shelf.__request",
                extra="Encountered a CommunicationError")
            raise
        except socket.error:
            wfile.close()
            sock.close()
            log_error("Error communicating to the auth cache: %s" % str(e))
            Traceback("Shelf.__request", extra="""\
                     Error sending to the authentication cache daemon.
                     Make sure the authentication cache daemon is started""")
            # FIXME: PROBLEM: this rhnFault will never reach the client
            raise rhnFault(1000,
              _("RHN Proxy error (issues connecting to auth cache). "
                "Please contact your system administrator")), None, sys.exc_info()[2]

        wfile.close()

        rfile = sock.makefile("r")
        try:
            params, methodname = recv(rfile)
        except CommunicationError, e:
            log_error(e.faultString)
            rfile.close()
            sock.close()
            log_error("Error communicating to the auth cache: %s" % str(e))
            Traceback("Shelf.__request", extra="""\
                      Error receiving from the authentication cache daemon.
                      Make sure the authentication cache daemon is started""")
            # FIXME: PROBLEM: this rhnFault will never reach the client
            raise rhnFault(1000,
              _("RHN Proxy error (issues communicating to auth cache). "
                "Please contact your system administrator")), None, sys.exc_info()[2]
        except Fault, e:
            rfile.close()
            sock.close()
            # If e.faultCode is 0, it's another exception
            if e.faultCode != 0:
                # Treat is as a regular xmlrpc fault
                raise

            _dict = e.faultString
            if not isinstance(_dict, type({})):
                # Not the expected type
                raise

            if not _dict.has_key('name'):
                # Doesn't look like a marshalled exception
                raise

            name = _dict['name']
            args = _dict.get('args')
            # Look up the exception
            if not hasattr(__builtins__, name):
                # Unknown exception name
                raise

            # Instantiate the exception object
            import new
            _dict = {'args' : args}
            raise new.instance(getattr(__builtins__, name), _dict), None, sys.exc_info()[2]

        return params[0]

    def __getattr__(self, name):
        log_debug(6, name)
        return _Method(self.__request, name)

    def __str__(self):
        return "<Remote-Shelf instance at %s>" % id(self)



#-------------------------------------------------------------------------------
# test code
if __name__ == '__main__':
    from spacewalk.common.rhnConfig import initCFG
    initCFG("proxy.broker")
    s = Shelf(('localhost', 9999))
    s['1234'] = [1, 2, 3, 4, None, None]
    s['blah'] = 'testing 1 2 3'
    print 'Cached object s["1234"] = %s' % str(s['1234'])
    print 'Cached object s["blah"] = %s' % str(s['blah'])
    print s.has_key("asdfrasdf")

#    print
#    print 'And this will bomb (attempt to get non-existant data:'
#    s["DOESN'T EXIST!!!"]
#-------------------------------------------------------------------------------


