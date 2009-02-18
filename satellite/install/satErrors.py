""" single placeholder for the satellite installer exceptions

    Copyright (c) 2002-2005, Red Hat, Inc.
    All rights reserved.
"""
# $Id: satErrors.py,v 1.41 2005-07-05 17:50:13 wregglej Exp $

PRODUCT_NAME = "RHN Satellite"

import sys
import time
import socket
import traceback

from satLog import log_me
from translate import _
from cStringIO import StringIO

# XXX Warning! Do not try to use this rhn_rpm for any exceptions
# things; there is code that uses common/rhn_rpm
# Even though the classes would have the same name, they would be different
# objects; try/except would not work correctly
import rhn_rpm

def print_req(req, fd = sys.stderr):
    """ get some debugging information about the current exception for sending
        out when we raise an exception
    """

    fd.write("Request object information:\n")
    fd.write("URI: %s\n" % req.unparsed_uri)
    fd.write("Remote Host: %s\nServer Name: %s:%d\n" % (
        req.get_remote_host(), req.server.server_hostname, req.server.port))
    fd.write("Headers passed in:\n")
    kl = req.headers_in.keys()
    kl.sort()
    for k in kl:
        fd.write("\t%s: %s\n" % (k, req.headers_in[k]))
    return 0

hostname = socket.gethostname()

def Traceback(method = None, req = None, mail = 1, ostream = sys.stderr,
              extra = None, severity="notification"):
    """ Reports an traceback error and optionally sends mail about it.
        NOTE:  extra = extra text information.
        NOTE2: adapted from common.rhnTB.py
               (can't import from common because this module may be imported
                before common exists)
    """

    e_type, e_value = sys.exc_info()[:2]
    t = time.ctime(time.time())
    exc = StringIO()
   
    exc.write("Exception reported from %s\nTime: %s\n" % (hostname, t))
    exc.write("Exception type %s\n" % (e_type,))
    if method:
        exc.write("Exception while handling function %s\n" % method)

    # print information about the request being served
    if req:
        print_req(req, exc)
    if extra:
        exc.write("Extra information about this error:\n%s\n" % extra)
        
    # Print the traceback
    exc.write("\nException Handler Information\n")
    traceback.print_exc(None, exc)

    # we always log it somewhere
    if ostream:
        ostream.write("%s\n" % exc.getvalue())

    ret = 0                             # default return value
    if mail:
        pass
    exc.close()   
    return ret

def fetchTraceback(method=None, req=None, extra=None):
    #""" a cheat for snagging just the string value of a Traceback """
    exc = StringIO()
    Traceback(method=method, req=req, mail=0, ostream=exc, extra=extra,
              severity=None)
    return exc.getvalue()


def repr_str(e):
    """return a repr(e), str(e) string safely
    
    Will return something like:
        '''
        ...repr(e)...
        ...str(e)...'''
    """

    s = ''
    try:
        s = 'EXCEPTION: %s' % e.__class__.__name__
    except:
        s = 'EXCEPTION: <unable to determine>'
    try:
        if e.__repr__ == e.__str__:
            s = s + '\n%s' % repr(e)
    except:
        try:
            s = s + '\n%s' % repr(e)
        except:
            pass
        try:
            s = s + '\n%s' % str(e)
        except:
            pass
    return s


class Error(Exception):
    "base class for errors"
    def __init__(self, errmsg):
        Exception.__init__(self)
        self.errmsg = str(errmsg)

    def __repr__(self):
        log_me(self.errmsg)
        return self.errmsg


class SatelliteConfigDeploymentError(Error):
    "Indicates there was a problem deploying the satellite config files"
    def __repr__(self):
        msg =  _("Error deploying %s config files. "
                 "The message was:\n" % PRODUCT_NAME) + self.errmsg
        log_me(msg)
        return msg


class InvalidUsernamePassword(Error):
    "Invalid RHN username and password were provided"
    def __repr__(self):
        msg =  _("The username and password provided do not "
                 "match an existing RHN account:\n") + self.errmsg
        log_me(msg)
        return msg


class SatelliteCertVerifyError(Error):
    "RHN product Entitlement Certificate failed to validate"
    def __repr__(self):
        msg =  _("The %s Entitlement Certificate "
                 "failed to validate:\n" % PRODUCT_NAME) + self.errmsg
        log_me(msg)
        return msg


class RhnEntitlementError(Error):
    "System could not register to Red Hat Network"
    def __repr__(self):
        msg =  _("The system was unable to register to "
                 "the Red Hat Network:\n") + self.errmsg
        log_me(msg)
        return msg


class UpdateError(Error):
    "Raise when an up2date failed"
    def __repr__(self):
        msg =  _("There was an error while trying to "
                 "update this system:\n") + self.errmsg
        log_me(msg)
        return msg


class RpmError(Error):
    "RPM raised an error condition"
    def __repr__(self):
        msg = _("RPM error while handling  The message was:\n") + self.errmsg
        log_me(msg)
        return msg


def rpm_flags(flags):
    """a helper function to help translate the rpm flags on
       dependency issues"""

    flags = flags & 0xFF
    s = ""
    if flags != 0:
        if flags & rhn_rpm.RPMSENSE_LESS:
            s = s + "<"
        if flags & rhn_rpm.RPMSENSE_GREATER:
            s = s + ">"
        if flags & rhn_rpm.RPMSENSE_EQUAL:
            s = s + "="
        if flags & rhn_rpm.RPMSENSE_SERIAL:
            s = s + "S"
    return s


def deps_as_text(deps):
    "stringifies/text-ifies rpm dependency infomation"

    s = _("Unresolved rpm dependencies:\n\n")
    sense_map = ["requires", "conflicts with"]
    
    for d in deps:
        ((name, version, release), (needsName, needsVersion),
         flags, suggested, sense) = d
        s = s + "Package "
        if needsVersion:
            s = s + _("%s %s %s\n") % (
                "%s-%s-%s" % (name, version, release),
                sense_map[sense],
                "%s %s %s" % (needsName, rpm_flags(flags), needsVersion))
        else:
            s = s + _("%s %s %s\n") % (
                "%s %s %s-%s" % (name, rpm_flags(flags), version, release),
                sense_map[sense],
                needsName)
    return s


class DependencyError(Error):

    "RPM transaction raised a dependency error"

    def __init__(self, msg, deps=None):
        self.errmsg = str(msg)
        # just tag on the whole deps tuple, so we have plenty of info
        # to play with
        self.deps = deps

    def __repr__(self):
        msg = _("RPM dependency error.  The message was:\n") + self.errmsg
        if self.deps:
            msg = "%s\n%s" % (msg, deps_as_text(self.deps))
        log_me(msg)
        return msg


class genPublicCaCertError(Error):

    "Raise when we fail to properly generate a CA cert"

    def __repr__(self):
        msg =  _("There was an error while generating a "
                 "Certificate Authority Cert:\n") + self.errmsg
        log_me(msg)
        return msg


class genPrivateCaKeyError(Error):
    "Raise when we fail to properly generate a CA Key"
    def __repr__(self):
        msg =  _("There was an error while generating a "
                 "Certificate Authority Key:\n") + self.errmsg
        log_me(msg)
        return msg


class genServerKeyError(Error):
    "Raise when we fail to properly generate a httpd server key"
    def __repr__(self):
        msg =  _("Error while generating a httpd "
                 "server key:\n") + self.errmsg
        log_me(msg)
        return msg


class genServerCertReqError(Error):
    """ Raise when we fail to properly generate a httpd server certificate
        request
    """
    def __repr__(self):
        msg = _("Error while generating a httpd server certificate "
                "request:\n") + self.errmsg
        log_me(msg)
        return msg

class genServerCertError(Error):
    "Raise when we fail to properly generate a httpd server certificate"
    def __repr__(self):
        msg = _("Error while generating a httpd server "
                "certificate:\n") + self.errmsg
        log_me(msg)
        return msg

#class CaCertInsertionError(Exception):
#    "raise when fail to insert CA cert into the local database"
#XXX: now in satellite_tools.satCerts


class InvalidDbCharsetsError(Exception):
    "databases are only allowed the UF8 charset, else raise this!"


class dbVersionIncorrectError(Error):
    "Raise when we detect the database is not he proper version"
    def __repr__(self):
        msg =  _("The database is not the proper "
                 "version:\n") + self.errmsg
        log_me(msg)
        return msg


class SchemaImportError(Error):
    "Raise when we fail to import the database schema"
    def __repr__(self):
        msg =  _("Database schema import failed:\n") + self.errmsg
        log_me(msg)
        return msg


class dbIncorrectPermissionsError(Error):
    "Database user does not have the approriate permissions"
    def __init__(self, msg, missingPrivs=None):
        self.errmsg = str(msg)
        # just tag on the whole deps tuple, so we have plenty of info
        # to play with
        self.missingPrivs = missingPrivs

    def __repr__(self):
        msg = _("Database Permissions error: The message "
                "was:\n") + self.errmsg
        log_me(msg)
        log_me("The database reported the following "
               "permissions were incorrect:\n %s" % self.missingPrivs)
        return msg


class dbTableSpaceError(Error):
    "Database user doesnt have the approriate permissions"
    def __init__(self, msg, errs=None):
        Error.__init__(self, msg)
        # just tag on the whole deps tuple, so we have plenty of info
        # to play with
        self.errs = errs

    def __repr__(self):
        msg = _("Database Permissions error: The message "
                "was:\n") + self.errmsg
        log_me(msg)
        log_me("The database reported the following "
               "permissions were incorrect:\n %s" % self.errs)
        return msg

class MissingCaCertError(Exception):
    "raised if ssl ca cert is missing at that location"

class DirectoryNotFoundError(Exception):
    "missing directory"

class ArgumentError(Exception):
    "raised whenever there is any issues with the options in the commandline."

class UnhandledXmlrpcError(Exception):
    "generic exception, but for XMLRPC failures"


# Exception classes mainly for the activation portion of the install.
class MissingSystemidError(Exception):
    "raised if systemid is missing/inaccessible at that location"

class MissingRhnCertError(Exception):
    "raised if RHN cert is missing/inaccessible at that location"

class InvalidRhnCertError(Exception):
    "raised if RHN Entitlement Certificate is invalid"

class ChannelFamilyPopulationError(Error):
    "Indicates there was a problem populating the channel families"
    def __repr__(self):
        msg =  _("Error populating channel families to the local DB. "
                 "The message was:\n") + self.errmsg
        log_me(msg)
        return msg

class RhnsdRestartError(Error):
    "Raised if rhnsd refused to restart"

