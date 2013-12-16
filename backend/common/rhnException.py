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
#

import sys
import xmlrpclib

from spacewalk.common.rhnConfig import PRODUCT_NAME
from cStringIO import StringIO


# What other rhn modules we need
from rhnTranslate import _
import rhnFlags


# default template values for error messages
templateValues = {
    'hostname': 'rhn.redhat.com',
    }


# This array translates exception codes into meaningful messages
# for the eye of the beholder
# DOMAINS:
#   0-999:     Red Hat client/client-like interaction errors
#   1000-1999: Proxy specific interaction errors
#   2000-2999: Red Hat Satellite specific interation errors

FaultArray = {
     # 0-999: Red Hat client/client-like interaction errors:
     1: _("This does not appear to be a valid username."),
     2: _("Invalid username and password combination."),
     3: _("This login is already taken, or the password is incorrect."),
     4: _("Permission denied."),
     6: _("Object not found."),
     8: _("Invalid System Digital ID."),
     9: _("Invalid System Credentials."),
     10: _("Could not retrieve user data from database."),
     11: _("Valid username required."),
     12: _("Valid password required."),
     13: _("Minimum username length violation."),
     14: _("Minimum password length violation."),
     15: _("The username contains invalid characters."),
     17: _("File not found."),
     19: _("Architecture and OS version combination is not supported."),
     20: _("Could not retrieve system data from database."),
     21: _("Invalid arguments passed to function."),
     22: _("Unable to retrieve requested entry."),
     23: _("Could not update database entry."),
     24: _("Unsupported server architecture."),
     28: _("""
     The anonymous server functionality is no longer available.

     Please re-register this system by running rhn_register
     as root.
     Please visit https://%(hostname)s/rhn/systems/SystemEntitlements.do
     or login at https://%(hostname)s, and from the "Overview" tab,
     select "Subscription Management" to enable the service for this system.
     """),
     29: _("Record not available in the database."),
     30: _("Invalid value for entry."),
     31: _("""
     This system does not have a valid entitlement for Red Hat Satellite.
     Please visit https://%(hostname)s/rhn/systems/SystemEntitlements.do
     or login at https://%(hostname)s, and from the "Overview" tab,
     select "Subscription Management" to enable the service for this system.
     """),
     32: _("Channel error"),
     33: _("Client session token is invalid."),
     34: _("Client session token has expired."),
     35: _("You are not authorized to retrieve the requested object."),
     36: _("Invalid action"),
     37: _("You are not allowed to perform administrative tasks \
on this system."),
     38: _("The system is already subscribed to the specified channel."),
     39: _("The system is not currently subscribed to the specified channel."),
     40: _("The specified channel does not exist."),
     41: _("Invalid channel version."),
     43: _("""
     User group membership limits exceeded.

     The current settings for your account do not allow you to add another
     user account. Please check with the organization administrator for your
     account if the maximum number of users allowed to subscribe to server needs
     to be changed.
     """),
     44: _("""
     System group membership limits exceeded.

     The current settings for your account do not allow you to add another
     system profile. Please check with the organization administrator for your
     account for modifying the maximum number of system profiles that can be
     subscribed to your account.
     """),
     45: _("""
     Invalid architecture.

     The architecture of the package is not supported by
     """ + PRODUCT_NAME),
     47: _("""Invalid RPM header"""),
     # For the uploading tools
     50: _("Invalid information uploaded to the server"),
     53: _("Error uploading network interfaces configuration."),
     54: _("""
     Package Upload Failed due to uniqueness constraint violation.
     Make sure the package does not have any duplicate dependencies or
     does not already exists on the server
     """),
     55: _("""
     The --force rhnpush option is disabled on this server.
     Please contact your Satellite administrator for more help.
     """),

     # 60-70: token errors
     60: _("""
     The activation token specified could not be found on the server.
     Please retry with a valid key.
     """),
     61: _("Too many systems registered using this registration token"),
     62: _("Token contains invalid, obsoleted or insufficient settings"),
     63: _("Conflicting activation tokens"),

     # 70-80: channel subscription errors
     70: _("""
     All available subscriptions for the requested channel have been exhausted.
     Please contact a Red Hat Satellite Sales associate.
     """),
     71: _("""
     You do not have subscription permission to the designated channel.
     Please refer to your organization's channel or organization
     administrators for further details.
     """),
     72: _("""You can not unsubscribe from base channel."""),
     73: _("""Satellite or Proxy channel can not be subscribed."""),

     # 80-90: server group errors
     80: _("There was an error while trying to join the system to its groups"),

     # 90-100: entitlement errors
     90: _("Unable to entitle system"),
     91: _("Registration token unable to entitle system: \
maximum membership exceeded"),

     # 100-109: e-mail and uuid related faults
     100: _("Maximum e-mail length violation."),
     105: _("This system has been previously registered."),
     106: _("Invalid username"),

     # 140-159 applet errors
     140: _("Unable to look up server"),

     # 160-179: OSAD errors
     160: _("Required argument is missing"),

     # 600-699: RHEL5+ EN errors
     601: _("No entitlement information tied to hardware"),
     602: _("Installation number is not entitling"),

     # 700-799: Additional user input verification errors.
     700: _("Maximum username length violation"),
     701: _("Maximum password length violation"),

     800: _("System Name cannot be less than 1 character"),

     # 1000-1999: Proxy specific errors:
     # issued by a Proxy to the client
     1000: _("Spacewalk Proxy error."),
     1001: _("Spacewalk Proxy unable to login."),
     # issued by a Red Hat Server/Satellite to the proxy
     1002: _("""
     Spacewalk Proxy system ID does not match a Spacewalk Proxy Server
     in the database.
     """),
     1003: _("Spacewalk Proxy session token is invalid."),
     1004: _("Spacewalk Proxy session token has expired."),


     # 2000-2999: Red Hat Satellite specific errors:
     2001: _(PRODUCT_NAME + """
      user creation is not allowed via rhn_register;
     please contact your sysadmin to have your account created.
     """),
     2004: _("""
     This satellite server is not allowed to use Inter Satellite Sync on this satellite
     """),
     2005: _("""
     Inter Satellite Sync is disabled on this satellite.
     """),

     # 3000-3999: XML dumper errors:
     3000: _("Invalid datatype passed"),
     3001: _("Unable to retrieve channel"),
     3003: _("Unable to retrieve package"),
     3005: _("Unable to retrieve erratum"),
     3006: _("Invalid satellite certificate"),
     3007: _("File is missing"),
     3008: _("Function retrieval error"),
     3009: _("Function execution error"),
     3010: _("Missing version string"),
     3011: _("Invalid version string"),
     3012: _("Mismatching versions"),
     3013: _("Invalid channel version"),
     3015: _("No comps file for channel"),
     3016: _("Unable to retrieve comps file"),

     # 4000 - 4999: config management errors
     4002: _("Configuration action missing"),
     4003: _("File too large"),
     4004: _("File contains binary data"),
     4005: _("Configuration channel is not empty"),
     4006: _("Permission error"),
     4007: _("Content missing for configuration file"),
     4008: _("Template delimiters not specified"),
     4009: _("Configuration channel does not exist"),
     4010: _("Configuration channel already exists"),
     4011: _("File missing from configuration channel"),
     4012: _("Different revision of this file is uploaded"),
     4013: _("File already uploaded to configuration channel"),
     4014: _("File size exceeds remaining quota space"),
     4015: _("Full path of file must be specified"),
     4016: _("Invalid revision number"),
     4017: _("Cannot compare files of different file type"),

     # 5000 - 5999: client content uploading errors
     # 5000 - 5099: crash reporting errors
     5000: _("Crash information is invalid or incomplete"),
     5001: _("Crash file information is invalid or incomplete"),
     5002: _("Error composing crash directory path"),
     5003: _("Error composing crash file path"),
     5004: _("Invalid content encoding"),
     5005: _("Invalid crash name"),
     5006: _("Crash reporting is disabled for this organization"),
     # 5100 - 5199: scap results reporting error
     5101: _("SCAP results file transfer is invalid or incomplete"),
     5102: _("Error composing directory path for detailed SCAP results"),
     5103: _("Error composing file path for detailed SCAP results"),
     5104: _("Invalid content encoding"),
    }


class rhnException(Exception):
    """
    This is the generic exception class we raise in the code when we want to
    abort program execution and send a "500 Internal Server Error" message back
    to the client.
    """

    def __init__(self, *args):
        Exception.__init__(self, *args)
        self.args = args

    def __repr__(self):
        """
        String representation of this object.
        """
        s = StringIO()
        s.write("\nInternal code error. Information available:\n")
        for a in self.args:
            s.write("  %s\n" % (a, ))

        return s.getvalue()


class redirectException(Exception):
    """
    pkilambi:This is the exception class we raise when we decide to
    issue a redirect functions in apacheRequest will catch it and
    transform it into a redirect path string
    """

    def __init__(self, redirectpath = ""):
        Exception.__init__(self)
        self.path = redirectpath

    def __str__(self):
        """
        Object in string format.
        """
        return repr(self.path)


Explain = _("""
     An error has occurred while processing your request. If this problem
     persists please enter a bug report at bugzilla.redhat.com.
     If you choose to submit the bug report, please be sure to include
     details of what you were trying to do when this error occurred and
     details on how to reproduce this problem.
""")


class rhnFault(Exception):
    """
    This is a data exception class that is raised when we detect bad data.
    The higher level functions in apacheServer will catch it and transform it
    into an XMLRPC fault message that gets passed back to the client without
    aborting the current execution of the process (well, we abort, but we don't
    mail a traceback because this is the type of error we can handle - think
    user authentication).
    """

    def __init__(self, err_code = 0, err_text = "", explain = 1):
        self.code = err_code
        self.text = err_text
        self.explain = explain
        self.arrayText = ''
        if self.code and FaultArray.has_key(self.code):
            self.arrayText = FaultArray[self.code]
        Exception.__init__(self, self.code, self.text, self.arrayText)

    def __repr__(self):
        """
        String representation of this object.
        """
        return "<rhnFault class (code = %s, text = '%s')>" % (self.code,
                                                              self.text)

    def getxml(self):

        # see if there were any template strings loaded from the db,
        # {label:value}
        templateOverrides = rhnFlags.get('templateOverrides')

        # update the templateValues in the module
        if templateOverrides:
            for label in templateOverrides.keys():
                # only care about values we've defined defaults for...
                if templateValues.has_key(label):
                    templateValues[label] = templateOverrides[label]

        s = StringIO()
        s.write("\n")
        if self.text:
            s.write(_("Error Message:\n    %s\n") % self.text.strip())
        if self.code:
            s.write(_("Error Class Code: %s\n") % self.code)
        if self.arrayText:
            cinfo = self.arrayText % templateValues
            s.write(_("Error Class Info: %s\n") % cinfo.rstrip())
        if self.explain:
            s.write(_("Explanation: %s") % Explain)
        if not self.code:
            return xmlrpclib.Fault(1, s.getvalue())
        return xmlrpclib.Fault(-self.code, s.getvalue())

class rhnNotFound(Exception):
    """ Raised when we want return 404 Not Found """
    pass

if __name__ == "__main__":
    print "You can not run this module by itself"
    sys.exit(-1)
