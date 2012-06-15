
#   rhn-client-tools
#
# Copyright (c) 2006--2011 Red Hat, Inc.
#
#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; version 2 of the License.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program; if not, write to the Free Software
#   Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
#   02110-1301  USA

import rpcServer
import up2dateErrors
import capabilities
import sys
import xmlrpclib
import OpenSSL


class _DoCallWrapper(object):

    """
    A callable object that will handle multiple levels of attributes,
    and catch exceptions.
    """
    
    def __init__(self, server, method_name):
        self._server = server
        self._method_name = method_name

    def __getattr__(self, method_name):
        """ Recursively build up the method name to pass to the server. """
        return _DoCallWrapper(self._server,
            "%s.%s" % (self._method_name, method_name))

    def __call__(self, *args, **kwargs):
        """ Call the method. Catch faults and translate them. """
        method = getattr(self._server, self._method_name)

        try:
            return rpcServer.doCall(method, *args, **kwargs)
        except xmlrpclib.Fault, f:
            raise self.__exception_from_fault(f), None, sys.exc_info()[2]
        except OpenSSL.SSL.Error, e:
            # TODO This should probably be moved to rhnlib and raise an
            # exception that subclasses OpenSSL.SSL.Error
            # TODO Is there a better way to detect cert failures?
            error = str(e)
            error = error.strip("[()]")
            pieces = error.split(',')
            message = ""
            if len(pieces) > 2:
                message = pieces[2]
            elif len(pieces) == 2:
                message = pieces[1]
            message = message.strip(" '")
            if message == 'certificate verify failed':
                raise up2dateErrors.SSLCertificateVerifyFailedError(), None, sys.exc_info()[2]
            else:
                raise up2dateErrors.NetworkError(message), None, sys.exc_info()[2]
    
    def __exception_from_fault(self, fault):
            if fault.faultCode == -3:
                # This username is already taken, or the password is incorrect.
                exception = up2dateErrors.AuthenticationOrAccountCreationError(fault.faultString)
            elif fault.faultCode == -2:
                # Invalid username and password combination.
                exception = up2dateErrors.AuthenticationOrAccountCreationError(fault.faultString)
            elif fault.faultCode == -1:
                exception = up2dateErrors.UnknownMethodException(fault.faultString)
            elif fault.faultCode == -13:
                # Username is too short.
                exception = up2dateErrors.LoginMinLengthError(fault.faultString)
            elif fault.faultCode == -14:
                # too short password
                exception = up2dateErrors.PasswordMinLengthError(
                                          fault.faultString)
            elif fault.faultCode == -15:
                # bad chars in username
                exception = up2dateErrors.ValidationError(fault.faultString)
            elif fault.faultCode == -16:
                # Invalid product registration code.
                # TODO Should this really be a validation error?
                exception = up2dateErrors.ValidationError(fault.faultString)
            elif fault.faultCode == -19:
                # invalid
                exception = up2dateErrors.NoBaseChannelError(fault.faultString)
            elif fault.faultCode == -31:
                # No entitlement
                exception = up2dateErrors.InsuffMgmntEntsError(fault.faultString)
            elif fault.faultCode == -36:
                # rhnException.py says this means "Invalid action."
                # TODO find out which is right
                exception = up2dateErrors.PasswordError(fault.faultString)
            elif abs(fault.faultCode) == 49:
                exception = up2dateErrors.AbuseError(fault.faultString)
            elif abs(fault.faultCode) == 60:
                exception = up2dateErrors.AuthenticationTicketError(fault.faultString)
            elif abs(fault.faultCode) == 105:
                exception = up2dateErrors.RhnUuidUniquenessError(fault.faultString)
            elif fault.faultCode == 99:
                exception = up2dateErrors.DelayError(fault.faultString)
            elif abs(fault.faultCode) == 91:
                exception = up2dateErrors.InsuffMgmntEntsError(fault.faultString)
            elif fault.faultCode == -106:
                # Invalid username.
                exception = up2dateErrors.ValidationError(fault.faultString)
            elif fault.faultCode == -600:
                # Invalid username.
                exception = up2dateErrors.InvalidRegistrationNumberError(fault.faultString)
            elif fault.faultCode == -601:
                # No entitlements associated with given hardware info
                exception = up2dateErrors.NotEntitlingError(fault.faultString)
            elif fault.faultCode == -602:
                # No entitlements associated with reg num
                exception = up2dateErrors.NotEntitlingError(fault.faultString)
            elif fault.faultCode == -2001 or fault.faultCode == -700:
                exception = up2dateErrors.AuthenticationOrAccountCreationError(
                                          fault.faultString)
            elif fault.faultCode == -701:
                exception = up2dateErrors.PasswordMaxLengthError(
                                          fault.faultString)
            elif fault.faultCode == -61:
                exception = up2dateErrors.ActivationKeyUsageLimitError(
                                          fault.faultString)
            elif fault.faultCode == -5:
                exception = up2dateErrors.UnableToCreateUser(
                            fault.faultString)
            else:
                exception = up2dateErrors.CommunicationError(fault.faultString)

            return exception


class RhnServer(object):

    """ 
    An rpc server object that calls doCall for you, and catches lower 
    level exceptions
    """

    def __init__(self):
        self._server = rpcServer.getServer()
        self._capabilities = None

    def __get_capabilities(self):
        if self._capabilities is None:
            headers = self._server.get_response_headers()
            if headers is None:
                self.registration.welcome_message()
                headers = self._server.get_response_headers()
            self._capabilities = capabilities.Capabilities()
            self._capabilities.populate(headers)
        return self._capabilities

    capabilities = property(__get_capabilities)

    def add_header(self, key, value):
        self._server.add_header(key, value)

    def __getattr__(self, method_name):
        """ Return a callable object that will do the work for us. """
        return _DoCallWrapper(self._server, method_name)
