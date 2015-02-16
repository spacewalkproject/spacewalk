#
# Client code for Update Agent
# Copyright (c) 1999--2012 Red Hat, Inc.  Distributed under GPLv2.
#
# Author: Preston Brown <pbrown@redhat.com>
#         Adrian Likins <alikins@redhat.com
#         Cristian Gafton <gafton@redhat.com>
#
#
# In addition, as a special exception, the copyright holders give
# permission to link the code of portions of this program with the
# OpenSSL library under certain conditions as described in each
# individual source file, and distribute linked combinations
# including the two.
# You must obey the GNU General Public License in all respects
# for all of the code used other than OpenSSL.  If you modify
# file(s) with this exception, you may extend this exception to your
# version of the file(s), but you are not obligated to do so.  If you
# do not wish to do so, delete this exception statement from your
# version.  If you delete this exception statement from all source
# files in the program, then also delete it here.

import up2dateLog
import gettext
t = gettext.translation('rhn-client-tools', fallback=True)
_ = t.ugettext
import OpenSSL
import config
from pkgplatform import getPlatform
from platform import dist
import sys
sys.path = sys.path[1:] + sys.path[:1]

if getPlatform() == 'deb' or dist()[0] == 'SuSE':
    class YumBaseError(Exception):
        def __init__(self, errmsg):
            self.value = errmsg
        def __getattr__(self, name):
            raise AttributeError(_("class %s has no attribute '%s'") % (self.__class__.__name__, name))
        def __setattr__(self, name, value):
            if name in ['errmsg', 'value']:
                self.__dict__['value'] = value
            else:
                self.__dict__[name] = value
else:
    from yum.Errors import YumBaseError

class Error(YumBaseError):
    """base class for errors"""
    premsg = ''
    def __init__(self, errmsg):
        if not isinstance(errmsg, unicode):
            errmsg = unicode(errmsg, 'utf-8')
        YumBaseError.__init__(self, errmsg)
        self.value = 'rhn-plugin: ' + self.premsg + errmsg
        self.log = up2dateLog.initLog()

    def __repr__(self):
        self.log.log_me(self.value)
        return self.value

    def __getattr__(self, name):
        """ Spacewalk backend still use errmsg, let have errmsg as alias to value """
        if name == 'errmsg':
            return self.value
        else:
            if hasattr(YumBaseError, '__getattr__'):
                # rhel5 has no __getattribute__()
                return YumBaseError.__getattr__(self, name)
            else:
                if name in self.__dict__:
                    return self.__dict__[name]
                else:
                    raise AttributeError(_("class %s has no attribute '%s'") % (self.__class__.__name__, name))

    def __setattr__(self, name, value):
        """ Spacewalk backend still use errmsg, let have errmsg as alias to value """
        if name == 'errmsg':
            self.__dict__['value'] = value
        else:
            if hasattr(YumBaseError, '__setattr__'):
                # rhel5 has no __setattr__()
                YumBaseError.__setattr__(self, name, value)
            else:
                self.__dict__[name] = value

class DebAndSuseRepoError(Error):
   pass

if getPlatform() == 'deb' or dist()[0] == 'SuSE':
    RepoError = DebAndSuseRepoError
else:
    from yum.Errors import RepoError

class RpmError(Error):
    """rpm itself raised an error condition"""
    premsg = _("RPM error.  The message was:\n")

class RhnServerException(Error):
    pass

class PasswordError(RhnServerException):
    """Raise when the server responds with that a password is incorrect"""
    premsg = _("Password error. The message was:\n")

class DependencyError(Error):
    """Raise when a rpm transaction set has a dependency error"""
    premsg = _("RPM dependency error. The message was:\n")
    def __init__(self, msg, deps=None):
        Error.__init__(self, msg)
        # just tag on the whole deps tuple, so we have plenty of info
        # to play with
        self.deps = deps


class CommunicationError(RhnServerException):
    """Indicates a problem doing xml-rpc http communication with the server"""
    premsg = _("Error communicating with server. "\
                 "The message was:\n")

class FileNotFoundError(Error):
    """
    Raise when a package or header that is requested returns
    a 404 error code"""
    premsg =  _("File Not Found: \n")


class DelayError(RhnServerException):
    """
    Raise when the expected response from a xml-rpc call
    exceeds a timeout"""
    premsg =  _("Delay error from server.  The message was:\n")

class RpmRemoveError(Error):
    """
    Raise when we can't remove a package for some reason
    (failed deps, etc)"""
    def __init__(self, args):
        Error.__init__(self, "")
        self.args = args
        for key in self.args.keys():
            if not isinstance(self.args[key], unicode):
                self.args[key] = unicode(self.args[key], 'utf-8')
            self.value = self.value + "%s failed because of %s\n" % (
                key, self.args[key])
        self.data = self.args
    def __repr__(self):
        return self.value

class NoLogError(Error):
    def __init__(self, msg):
        if not isinstance(msg, unicode):
            msg = unicode(msg, 'utf-8')
        self.value = self.premsg + msg

    def __repr__(self):
        return self.value

class AbuseError(Error):
    pass

class AuthenticationTicketError(NoLogError, RhnServerException):
    pass

class AuthenticationError(NoLogError):
    pass

class ValidationError(NoLogError, RhnServerException):
    """indicates an error during server input validation"""
    premsg = _("Error validating data at server:\n")

class InvalidRegistrationNumberError(ValidationError):
    pass

class RegistrationDeniedError(RhnServerException):
    def __init__(self):
        RhnServerException.__init__(self, self.changeExplanation())

    def __repr__(self):
        return self.value

    def changeExplanation(self):
        return _("""
Red Hat Network Classic is not supported.
To register with Red Hat Subscription Management please run:

    subscription-manager register --auto-attach

Get more information at access.redhat.com/knowledge
    """)

class InvalidProductRegistrationError(NoLogError):
    """indicates an error during server input validation"""
    premsg = _("The installation number is invalid")

class OemInfoFileError(NoLogError):
    premsg = _("Error parsing the oemInfo file at field:\n")

class NoBaseChannelError(NoLogError, RhnServerException):
    """No valid base channel was found for this system"""
    pass

class UnknownMethodException(NoLogError, RhnServerException):
    pass

class RhnUuidUniquenessError(NoLogError, RhnServerException):
    pass

class ServerCapabilityError(Error):
    def __init__(self, msg, errorlist=None):
        Error.__init__(self, msg)
        self.errorlist = []
        if errorlist:
            self.errorlist=errorlist

    def __repr__(self):
        return self.value

class NoChannelsError(NoLogError):
    pass

class NetworkError(Error):
    """ some generic network error occurred, e.g. connection reset by peer """
    premsg = _("Network error: ")

class SSLCertificateVerifyFailedError(RepoError, Error):
    def __init__(self):
        # Need to override __init__ because the base class requires a message arg
        # and this exception shouldn't.
        up2dateConfig = config.initUp2dateConfig()
        certFile = up2dateConfig['sslCACert']
        f = open(certFile, "r")
        buf = f.read()
        f.close()
        tempCert = OpenSSL.crypto.load_certificate(OpenSSL.crypto.FILETYPE_PEM, buf)
        if tempCert.has_expired():
            RepoError.__init__(self ,"The certificate %s is expired. Please ensure you have the correct"
                           " certificate and your system time is correct." % certFile)
        else:
            RepoError.__init__(self, "The SSL certificate failed verification.")

    __getattr__ = Error.__getattr__

class SSLCertificateFileNotFound(Error):
    pass


class AuthenticationOrAccountCreationError(ValidationError):
    """Class that can represent different things depending on context:
    While logging in with an existing user it represents a username or password
    being incorrect.
    While creating a new account, it represents the username already being
    taken or the user not being allowed to create an account.
    Optimally these different things would be different exceptions, but there
    are single fault codes the server can return to the client that can mean
    more than one of them so we have no way of knowing which is actually
    intended.

    """
    pass

class NotEntitlingError(Error):
    pass

class InvalidProtocolError(Error):
    pass

class UnableToCreateUser(NoLogError):
     pass

class ActivationKeyUsageLimitError(NoLogError):
    pass

class LoginMinLengthError(NoLogError):
    pass

class PasswordMinLengthError(NoLogError):
    pass

class PasswordMaxLengthError(NoLogError):
    pass


class InsuffMgmntEntsError(RhnServerException):
    def __init__(self, msg ):
        RhnServerException.__init__(self, self.changeExplanation(msg))

    def __repr__(self):
        return self.value

    def changeExplanation(self, msg):
        newExpln = _("""
    Your organization does not have enough Management entitlements to register this
    system to Red Hat Satellite. Please notify your organization administrator of this error.
    You should be able to register this system after your organization frees existing
    or purchases additional entitlements. Additional entitlements may be purchased by your
    organization administrator by logging into Red Hat Network Classic and visiting
    the 'Subscription Management' page in the 'Your RHN' section of RHN.

    A common cause of this error code is due to having mistakenly setup an
    Activation Key which is set as the universal default.  If an activation key is set
    on the account as a universal default, you can disable this key and retry to avoid
    requiring a Management entitlement.""")
        term = "Explanation:"
        loc = msg.rindex(term) + len(term)
        return msg[:loc] + newExpln

class NoSystemIdError(NoLogError):
    pass

class InvalidRedirectionError(NoLogError):
    """ Raise when redirect requests could'nt return a package"""
    pass
