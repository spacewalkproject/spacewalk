""" installer general error lib
"""
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
#------------------------------------------------------------------------------
# $Id: pi_errors.py,v 1.12 2004/03/16 21:05:21 taw Exp $

## language imports
import rpm

## local imports
from pi_log import log_me
from translate import _


class Error:
    """base class for errors
    """
    def __init__(self, errmsg):
        self.errmsg = errmsg

    def __repr__(self):
        log_me(self.errmsg)
        return self.errmsg


class ProxyConfigDeploymentError(Error):
    """Indicates there was a problem deploying the RHN Proxy Server
       config files
    """
    def __init__(self, errmsg):
        Error.__init__(self, errmsg)

    def __repr__(self):
        msg =  _("Error deploying RHN Proxy Server config files. "
                 "The message was:\n") + self.errmsg
        log_me(msg)
        return msg


class ChkconfigError(Error):
    """Indicates there was a problem configuring with chkconfig
    """
    def __init__(self, errmsg):
        Error.__init__(self, errmsg)

    def __repr__(self):
        msg =  _("Error configuring chkconfig. "
                 "The message was:\n") + self.errmsg
        log_me(msg)
        return msg


class ServiceRestartError(Error):
    """Indicates there was a problem restarting X service
    """
    def __init__(self, errmsg):
        Error.__init__(self, errmsg)

    def __repr__(self):
        msg =  _("Error restarting service. "
                 "The message was:\n") + self.errmsg
        log_me(msg)
        return msg


class InvalidUsernamePassword(Error):
    """Indicates there a invalide RHN username and password were provided
    """
    def __init__(self, errmsg):
        Error.__init__(self, errmsg)

    def __repr__(self):
        msg =  _("The username and password provided do not match an "
                 "existing RHN account:\n") + self.errmsg
        log_me(msg)
        return msg


class ProxyCertVerifyError(Error):
    """Indicates that the RHN Proxy Server Entitlement Certificate
       failed to validate
    """
    def __init__(self, errmsg):
        Error.__init__(self, errmsg)

    def __repr__(self):
        msg =  _("The RHN Proxy Server Entitlement Certificate "
                 "failed to validate:\n") + self.errmsg
        log_me(msg)
        return msg


class RhnEntitlementError(Error):
    """Indicated that the system could not register to Red Hat Network
    """
    def __init__(self, errmsg):
        Error.__init__(self, errmsg)

    def __repr__(self):
        msg =  _("The system was unable to register to the "
                 "Red Hat Network:\n") + self.errmsg
        log_me(msg)
        return msg


class UpdateError(Error):
    """Raise when an up2date failed
    """
    def __init__(self, errmsg):
        Error.__init__(self, errmsg)

    def __repr__(self):
        msg =  _("There was an error while trying to update "
                 "this system:\n") + self.errmsg
        log_me(msg)
        return msg


class RpmError(Error):
    """rpm itself raised an error condition
    """
    def __init__(self, errmsg):
        Error.__init__(self, errmsg)

    def __repr__(self):
        msg = _("RPM error.  The message was:\n") + self.errmsg
        log_me(msg)
        return msg


def _rpmFlags(flags):
    """a helper function to help translate the rpm flags on
       dependency issues """

    flags = flags & 0xFF
    str = ""
    if flags != 0:
        if flags & rpm.RPMSENSE_LESS:
            str = str + "<"
        if flags & rpm.RPMSENSE_GREATER:
            str = str + ">"
        if flags & rpm.RPMSENSE_EQUAL:
            str = str + "="
        if flags & rpm.RPMSENSE_SERIAL:
            str = str + "S"
    return str


def _depsAsText(deps):
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
                "%s %s %s" % (needsName, _rpmFlags(flags), needsVersion))
        else:
            s = s + _("%s %s %s\n") % (
                "%s %s %s-%s" % (name, _rpmFlags(flags), version, release),
                sense_map[sense],
                needsName)
    return s


class DependencyError(Error):
    """Raise when a rpm transaction set has a dependency error
    """
    def __init__(self, msg, deps=None):
        self.errmsg = msg
        Error.__init__(self, msg)
        # just tag on the whole deps tuple, so we have plenty of info
        # to play with
        self.deps = deps

    def __repr__(self):
        msg = _("RPM dependency error.  The message was:\n") + self.errmsg
        if self.deps:
            msg = "%s\n%s" % (msg, _depsAsText(self.deps))
        log_me(msg)
        return msg


# XXX: deprecated SSL exceptions
class genCACertError(Error):
    """Raise when we fail to properly generate a CA cert
    """
    def __init__(self, errmsg):
        Error.__init__(self, errmsg)

    def __repr__(self):
        msg =  _("There was an error while generating a "
                 "Certificate Authority Cert:\n") + self.errmsg
        log_me(msg)
        return msg


class genCAKeyError(Error):
    """Raise when we fail to properly generate a CA Key
    """
    def __init__(self, errmsg):
        Error.__init__(self, errmsg)

    def __repr__(self):
        msg =  _("There was an error while generating a "
                 "Certificate Authority Key:\n") + self.errmsg
        log_me(msg)
        return msg


# XXX NEW SSL exceptions
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
        msg =  _("Error while generating a httpd server key:\n") + self.errmsg
        log_me(msg)
        return msg


class genServerCertError(Error):
    "Raise when we fail to properly generate a httpd server certificate"
    def __repr__(self):
        msg = _("Error while generating a httpd server certificate:\n") + self.errmsg
        log_me(msg)
        return msg



