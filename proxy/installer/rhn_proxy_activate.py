#
# Copyright (c) 2008--2015 Red Hat, Inc.
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
""" Activate a Spacewalk Proxy 3.x ...not the executable
    (original script can activate a Spacewalk Proxy version 1.1 to 3.x)
    USAGE: ./rhn-proxy-activate

    Author: Todd Warner <taw@redhat.com>

    NOTE: this file is compatible with Spacewalk Proxies 4.0. It is not guaranteed to
    work with older Spacewalk Proxies.
"""

# pylint: disable=E1101

# core lang imports
import os
import sys
import socket
import urlparse
import xmlrpclib

# lib imports
from rhn import rpclib, SSL
from optparse import Option, OptionParser

sys.path.append('/usr/share/rhn')
from up2date_client import config

DEFAULT_WEBRPC_HANDLER_v3_x = '/rpc/api'


def getSystemId(cfg):
    """ returns content of systemid file """

    path = cfg['systemIdPath']
    if not os.access(path, os.R_OK):
        return None
    return open(path, "r").read()


def getServer(options, handler):
    """ get an rpclib.Server object. NOTE: proxy is an HTTP proxy """

    serverUrl = 'https://' + options.server + handler
    if options.no_ssl:
        serverUrl = 'http://' + options.server + handler

    s = None
    if options.http_proxy:
        s = rpclib.Server(serverUrl,
                          proxy=options.http_proxy,
                          username=options.http_proxy_username,
                          password=options.http_proxy_password)
    else:
        s = rpclib.Server(serverUrl)

    if not options.no_ssl and options.ca_cert:
        s.add_trusted_cert(options.ca_cert)

    return s


def _getProtocolError(e, hostname=''):
    """
        Based on error, returns couple:
        10      connection issues?
        44     host not found
        47     http proxy authentication failure
    """
    if hostname:
        hostname = ': %s' % hostname

    if e.errcode == 407:
        return 47, "ERROR: http proxy authentication required"
    elif e.errcode == 404:
        return 44, "ERROR: host not found%s" % hostname
    else:
        return 10, "ERROR: connection issues? %s" % repr(e)


def _getSocketError(e, hostname=''):
    """
        Based on error, returns couple:
        10     connection issues?
        11     hostname unresolvable
        12     connection refused
    """
    if hostname:
        hostname = ': %s' % hostname

    if 'host not found' in e.args:
        return 11, 'ERROR: hostname could not be resolved%s' % hostname
    elif 'connection refused' in e.args:
        return 12, 'ERROR: "connection refused"%s' % hostname
    else:
        return 10, "ERROR: connection issues? %s" % repr(e)


def _getActivationError(e):
    """ common error strings dependent upon faultString
        1      general
        2      proxy_invalid_systemid
        4      proxy_no_management_entitlements
        5      proxy_no_enterprise_entitlements
        6      proxy_no_channel_entitlements
        7      proxy_no_proxy_child_channel
        8      proxy_not_activated
    """

    errorString = ''
    errorCode = 1

    if e.faultString.find('proxy_invalid_systemid') != -1:
        errorString = ("this server does not seem to be registered or "
                       "/etc/sysconfig/rhn/systemid is corrupt.")
        errorCode = 2
    elif e.faultString.find('proxy_no_management_entitlements') != -1:
        errorString = ("no Management entitlements available. There must be "
                       "at least one free Management/Provisioning slot "
                       "available in your RHN account.")
        errorCode = 4
    elif e.faultString.find('proxy_no_enterprise_entitlements') != -1:
        # legacy error message
        errorString = ("no Management entitlements available. There must be "
                       "at least one free Management/Provisioning slot "
                       "available in your RHN account.")
        errorCode = 5
    elif e.faultString.find('proxy_no_channel_entitlements') != -1:
        errorString = ("no Spacewalk Proxy entitlements available. There must "
                       "be at least one free Spacewalk Proxy entitlement "
                       "available in your Red Hat Satellite account.")
        errorCode = 6
    elif e.faultString.find('proxy_no_proxy_child_channel') != -1:
        errorString = ("no Spacewalk Proxy entitlements available for this "
                       "server's version (or requested version) of Red Hat "
                       "Enterprise nux.")
        errorCode = 7
    elif e.faultString.find('proxy_not_activated') != -1:
        errorString = "this server not an activated Spacewalk Proxy yet."
        errorCode = 8
    else:
        errorString = "unknown error - %s" % str(e)
        errorCode = 1
    return errorCode, errorString


def _errorHandler(pre='', post=''):
    """
        NOTE: only currently called if within an exception block.

        1      general
        2      proxy_invalid_systemid
        4      proxy_no_management_entitlements
        5      proxy_no_enterprise_entitlements
        6      proxy_no_channel_entitlements
        7      proxy_no_proxy_child_channel
        8      proxy_not_activated

        10     connection issues?
        11     hostname unresolvable
        12     connection refused
        13     SSL connection failed

        44     host not found
        47     http proxy authentication failure
    """
    try:
        raise
    except (SystemExit, KeyboardInterrupt, NameError, TypeError,
            ValueError):
        raise
    except Exception:  # pylint: disable=E0012, W0703
        errorCode = 1
        errorString = pre
        try:
            raise
        except xmlrpclib.ProtocolError, e:
            errorCode, s = _getProtocolError(e)
            errorString = errorString + s
        except socket.error, e:
            errorCode, s = _getSocketError(e)
            errorString = errorString + s
        except xmlrpclib.Fault, e:
            errorCode, errorString = _getActivationError(e)
        except SSL.SSL.Error, e:
            errorCode = 13
            errorString = "ERROR: failed SSL connection - bad or expired cert?"
        except Exception, e:  # pylint: disable=E0012, W0703
            e0, e1 = str(e), repr(e)
            if e0:
                s = "(%s)" % e0
            if s and e1:
                s = s + ', '
            if e1:
                s = s + "(%s)" % e1
            errorString = errorString + "ERROR: unknown exception: %s" % s
        errorString = errorString + post
    return errorCode, errorString


def resolveHostnamePort(hostnamePort=''):
    """ hostname:port sanity check """

    hostname = urlparse.urlparse(hostnamePort)[1].split(':')
    port = ''
    if len(hostname) > 1:
        hostname, port = hostname[:2]
    else:
        hostname = hostname[0]

    if port:
        try:
            x = int(port)
            if str(x) != port:
                raise ValueError('should be an integer: %s' % port)
        except ValueError:
            sys.stderr.write("ERROR: the port setting is not an integer: %s\n" % port)
            sys.exit(1)

    if hostname:
        try:
            socket.getaddrinfo(hostname, None)
        except:  # pylint: disable=W0702
            errorCode, errorString = _errorHandler()
            sys.stderr.write(errorString + '\n')
            sys.exit(errorCode)


def activateProxy_api_v3_x(options, cfg):
    """ API version 3.*, 4.* - deactivate, then activate
    """

    (errorCode, errorString) = _deactivateProxy_api_v3_x(options, cfg)
    if errorCode == 0:
        (errorCode, errorString) = _activateProxy_api_v3_x(options, cfg)
    return (errorCode, errorString)


def _deactivateProxy_api_v3_x(options, cfg):
    """ Deactivate this machine as Proxy """

    s = getServer(options, DEFAULT_WEBRPC_HANDLER_v3_x)
    systemid = getSystemId(cfg)

    errorCode, errorString = 0, ''

    try:
        if not s.proxy.is_proxy(systemid):
            # if system is not proxy, we do not need to deactivate it
            return (errorCode, errorString)
    except:  # pylint: disable=W0702
        # api do not have proxy.is_proxy is implemented or it is hosted
        # ignore error and try to deactivate
        pass
    try:
        s.proxy.deactivate_proxy(systemid)       # proxy 3.0+ API
    except:  # pylint: disable=W0702
        errorCode, errorString = _errorHandler()
        try:
            raise
        except xmlrpclib.Fault:
            if errorCode == 8:
                # fine. We weren't activated yet.
                # noop and look like a success
                errorCode = 0
            else:
                errorString = "WARNING: upon deactivation attempt: %s" % errorString
                sys.stderr.write("%s\n" % errorString)
        except SSL.SSL.Error:
            sys.stderr.write(errorString + '\n')
            sys.exit(errorCode)
        except (xmlrpclib.ProtocolError, socket.error):
            sys.stderr.write(errorString + '\n')
            sys.exit(errorCode)
        except:
            errorString = "ERROR: upon deactivation attempt (something unexpected): %s" % errorString
            return errorCode, errorString
    else:
        errorCode = 0
        if not options.quiet:
            sys.stdout.write("Spacewalk Proxy successfully deactivated.\n")
    return (errorCode, errorString)


def _activateProxy_api_v3_x(options, cfg):
    """ Activate this machine as Proxy.
        Do not check if has been already activated. For such case
        use activateProxy_api_v3_x method instead.
    """

    s = getServer(options, DEFAULT_WEBRPC_HANDLER_v3_x)
    systemid = getSystemId(cfg)

    errorCode, errorString = 0, ''
    try:
        s.proxy.activate_proxy(systemid, str(options.version))
    except:  # pylint: disable=W0702
        errorCode, errorString = _errorHandler()
        try:
            raise
        except SSL.SSL.Error:
            # let's force a system exit for this one.
            sys.stderr.write(errorString + '\n')
            sys.exit(errorCode)
        except (xmlrpclib.ProtocolError, socket.error):
            sys.stderr.write(errorString + '\n')
            sys.exit(errorCode)
        except (xmlrpclib.Fault, Exception):  # pylint: disable=E0012, W0703
            # let's force a slight change in messaging for this one.
            errorString = "ERROR: upon entitlement/activation attempt: %s" % errorString
        except:
            errorString = "ERROR: upon activation attempt (something unexpected): %s" % errorString
            return errorCode, errorString
    else:
        errorCode = 0
        if not options.quiet:
            sys.stdout.write("Spacewalk Proxy successfully activated.\n")
    return (errorCode, errorString)


def activateProxy(options, cfg):
    """ Activate proxy. Decide how to do it upon apiVersion. Currently we
        support only API v.3.1+. Support for 3.0 and older has been removed.
    """
    # errorCode == 0 means activated!
    errorCode, errorString = activateProxy_api_v3_x(options, cfg)

    if errorCode != 0:
        if not errorString:
            errorString = ("An unknown error occurred. Consult with your Red Hat representative.\n")
        sys.stderr.write("\nThere was a problem activating the Spacewalk Proxy entitlement:\n%s\n" % errorString)
        sys.exit(abs(errorCode))


def listAvailableProxyChannels(options, cfg):
    """ return list of version available to this system """

    server = getServer(options, DEFAULT_WEBRPC_HANDLER_v3_x)
    systemid = getSystemId(cfg)

    errorCode, errorString = 0, ''
    channel_list = []
    try:
        channel_list = server.proxy.list_available_proxy_channels(systemid)
    except:  # pylint: disable=W0702
        errorCode, errorString = _errorHandler()
        try:
            raise
        except:
            # let's force a system exit for this one.
            sys.stderr.write(errorString + '\n')
            sys.exit(errorCode)
    else:
        errorCode = 0
        if not options.quiet and channel_list:
            sys.stdout.write("\n".join(channel_list) + "\n")


def processCommandline(cfg):

    up2date_cfg = dict(cfg.items())

    if isinstance(up2date_cfg['serverURL'], type([])):
        rhn_parent = urlparse.urlparse(up2date_cfg['serverURL'][0])[1]
    else:
        rhn_parent = urlparse.urlparse(up2date_cfg['serverURL'])[1]

    httpProxy = urlparse.urlparse(up2date_cfg['httpProxy'])[1]
    httpProxyUsername = up2date_cfg['proxyUser']
    httpProxyPassword = up2date_cfg['proxyPassword']

    if not httpProxy:
        httpProxyUsername, httpProxyPassword = '', ''
    if not httpProxyUsername:
        httpProxyPassword = ''
    ca_cert = ''
    defaultVersion = '5.2'

    # parse options
    optionsTable = [
        Option('-s', '--server',     action='store',     default=rhn_parent,
               help="alternative server hostname to connect to, default is %s" % repr(rhn_parent)),
        Option('--http-proxy',      action='store',     default=httpProxy,
               help="alternative HTTP proxy to connect to (HOSTNAME:PORT), default is %s" % repr(httpProxy)),
        Option('--http-proxy-username', action='store', default=httpProxyUsername,
               help="alternative HTTP proxy usename, default is %s" % repr(httpProxyUsername)),
        Option('--http-proxy-password', action='store', default=httpProxyPassword,
               help="alternative HTTP proxy password, default is %s" % repr(httpProxyPassword)),
        Option('--ca-cert',         action='store',     default=ca_cert,
               help="alternative SSL certificate to use, default is %s" % repr(ca_cert)),
        Option('--no-ssl',          action='store_true',
               help='turn off SSL (not advisable), default is on.'),
        Option('--version',         action='store',     default=defaultVersion,
               help='which X.Y version of the Spacewalk Proxy are you upgrading to?' +
               ' Default is your current proxy version (' + defaultVersion + ')'),
        Option('--deactivate',      action='store_true',
               help='deactivate proxy, if already activated'),
        Option('-l', '--list-available-versions', action='store_true',
               help='print list of versions available to this system'),
        Option('--non-interactive', action='store_true',
               help='non-interactive mode'),
        Option('-q', '--quiet',     action='store_true',
               help='quiet non-interactive mode.'),
    ]
    parser = OptionParser(option_list=optionsTable)
    options, _args = parser.parse_args()

    if options.server:
        if options.server.find('http') != 0:
            options.server = 'https://' + options.server
        options.server = urlparse.urlparse(options.server)[1]

    if options.no_ssl:
        if not options.quiet:
            sys.stderr.write('warning: user disabled SSL\n')
        options.ca_cert = ''

    if not options.http_proxy:
        options.http_proxy_username, options.http_proxy_password = '', ''

    if not options.http_proxy_username:
        options.http_proxy_password = ''
    exploded_version = options.version.split('.')
    # Pad it to be at least 2 components
    if len(exploded_version) == 1:
        exploded_version.append('0')

    # Make it a string
    options.version = '.'.join(exploded_version[:2])

    if options.quiet:
        options.non_interactive = 1

    return options


def yn(prompt):
    """ returns 0 if 'n', and 1 if 'y' """
    _yn = ''
    while _yn == '':
        _yn = raw_input(prompt)
        if _yn and _yn[0].lower() not in ('y', 'n'):
            _yn = ''
    return _yn[0].lower() == 'y'


def main():
    """
        0      success

        1      general
        2      proxy_invalid_systemid
        4      proxy_no_management_entitlements
        5      proxy_no_enterprise_entitlements
        6      proxy_no_channel_entitlements
        7      proxy_no_proxy_child_channel
        8      proxy_not_activated

        10     connection issues?
        11     hostname unresolvable
        12     connection refused
        13     SSL connection failed

        44     host not found
        47     http proxy authentication failure
    """

    cfg = config.initUp2dateConfig()
    options = processCommandline(cfg)

    if options.list_available_versions:
        resolveHostnamePort(options.http_proxy)
        if not options.http_proxy:
            resolveHostnamePort(options.server)
        listAvailableProxyChannels(options, cfg)
        sys.exit(0)

    noSslString = 'false'
    if options.no_ssl:
        noSslString = 'true'

    if not options.non_interactive:
        print ("\n"
               "--server (RHN parent):  %s\n"
               "--http-proxy:           %s\n"
               "--http-proxy-username:  %s\n"
               "--http-proxy-password:  %s\n"
               "--ca-cert:              %s\n"
               "--no-ssl:               %s\n"
               "--version:              %s\n"
               % (options.server, options.http_proxy,
                  options.http_proxy_username, options.http_proxy_password,
                  options.ca_cert, noSslString, options.version))
        if not yn("Are you sure about these options? y/n: "):
            return 0

    # early checks
    resolveHostnamePort(options.http_proxy)
    if not options.http_proxy:
        resolveHostnamePort(options.server)

    if options.deactivate:
        _deactivateProxy_api_v3_x(options, cfg)
    else:
        # ACTIVATE!!!!!!!!
        activateProxy(options, cfg)

    return 0

if __name__ == '__main__':
    sys.exit(abs(main() or 0))
