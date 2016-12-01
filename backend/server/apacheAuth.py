#
# Copyright (c) 2008--2016 Red Hat, Inc.
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

import time
import string
import re

from spacewalk.common import rhnFlags
from spacewalk.common.rhnLog import log_debug, log_error
from spacewalk.common.rhnConfig import CFG
from spacewalk.common.rhnException import rhnFault
from spacewalk.common.rhnTranslate import _

from rhnLib import computeSignature


def splitProxyAuthToken(token):
    """ given a token:hostname, split it into a token-list, hostname """

    token = string.split(token, ':')
    hostname = ''
    if len(token) > 5:
        hostname = token[-1]
        token = token[:-1]
    else:
        # Spacewalk Proxy v1.1 (route tracking unsupported)
        hostname = None
    return token, hostname


def _verifyProxyAuthToken(auth_token):
    """ verifies the validity of a proxy auth token

        NOTE: X-RHN-Proxy-Auth described in proxy/broker/rhnProxyAuth.py
    """

    log_debug(4, auth_token)
    token, hostname = splitProxyAuthToken(auth_token)
    hostname = hostname.strip()
    ipv4_regex = '^([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\.([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\.([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\.([01]?\\d\\d?|2[0-4]\\d|25[0-5])$'
    # This ipv6 regex was develeoped by Stephen Ryan at Dataware.
    # (http://forums.intermapper.com/viewtopic.php?t=452) It is licenced
    # under a Creative Commons Attribution-ShareAlike 3.0 Unported
    # License, so we are free to use it as long as we attribute it to him.
    ipv6_regex = '^((([0-9A-Fa-f]{1,4}:){7}([0-9A-Fa-f]{1,4}|:))|(([0-9A-Fa-f]{1,4}:){6}(:[0-9A-Fa-f]{1,4}|((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){5}(((:[0-9A-Fa-f]{1,4}){1,2})|:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){4}(((:[0-9A-Fa-f]{1,4}){1,3})|((:[0-9A-Fa-f]{1,4})?:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){3}(((:[0-9A-Fa-f]{1,4}){1,4})|((:[0-9A-Fa-f]{1,4}){0,2}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){2}(((:[0-9A-Fa-f]{1,4}){1,5})|((:[0-9A-Fa-f]{1,4}){0,3}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){1}(((:[0-9A-Fa-f]{1,4}){1,6})|((:[0-9A-Fa-f]{1,4}){0,4}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(:(((:[0-9A-Fa-f]{1,4}){1,7})|((:[0-9A-Fa-f]{1,4}){0,5}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:)))(%.+)?$'
    hostname_is_ip_address = re.match(ipv4_regex, hostname) or re.match(ipv6_regex, hostname)

    headers = rhnFlags.get('outputTransportOptions')
    if len(token) < 5:
        # Bad auth information; decline any action
        log_debug(4, "incomplete proxy authentication token: %s"
                  % auth_token)
        headers['X-RHN-Proxy-Auth-Error'] = '%s:%s' % (
            1003, _("incomplete proxy authentication token: %s") % auth_token)
        if not hostname_is_ip_address:
            headers['X-RHN-Proxy-Auth-Origin'] = hostname
        raise rhnFault(1003)  # Invalid session key

    log_debug(5, "proxy auth token: %s,  hostname: %s"
                 % (repr(token), hostname or 'n/a'))

    proxyId, proxyUser, rhnServerTime, expireOffset, signature = token[:5]
    computed = computeSignature(CFG.SECRET_KEY, proxyId, proxyUser,
                                rhnServerTime, expireOffset)

    if computed != signature:
        log_error("Proxy signature failed: proxy id='%s', proxy user='%s'" %
                  (proxyId, proxyUser))
        log_debug(4, "Sent proxy signature %s does not match ours %s." % (
            signature, computed))
        headers['X-RHN-Proxy-Auth-Error'] = '%s:%s' % (
            1003, _("Sent proxy signature %s does not match ours %s.") % (
                signature, computed))
        if not hostname_is_ip_address:
            headers['X-RHN-Proxy-Auth-Origin'] = hostname
        raise rhnFault(1003)  # Invalid session key

    # Convert the expiration/time to floats:
    rhnServerTime = float(rhnServerTime)
    expireOffset = float(expireOffset)

    if rhnServerTime + expireOffset < time.time():
        log_debug(4, "Expired proxy authentication token")
        headers['X-RHN-Proxy-Auth-Error'] = '%s:%s' % (1004, "Expired")
        if not hostname_is_ip_address:
            headers['X-RHN-Proxy-Auth-Origin'] = hostname
        raise rhnFault(1004)  # Expired client authentication token

    log_debug(4, "Proxy auth OK: sigs match; not an expired token")
    return 1


def auth_proxy():
    """ Authenticates a proxy carrying a clients request. For a valid or
        unsigned request, this function returns 1 (OK), otherwise it raises
        rhnFault

        NOTE: X-RHN-Proxy-Auth described in proxy/broker/rhnProxyAuth.py
    """

    log_debug(3)
    headers = rhnFlags.get('outputTransportOptions')
    if not rhnFlags.test('X-RHN-Proxy-Auth'):
        # No auth information; decline any action
        log_debug(4, "declined proxy authentication")
        headers['X-RHN-Proxy-Auth-Error'] = '%s:%s' % (
            1003, _("declined proxy authentication"))
        raise rhnFault(1003)  # Invalid session key

    # NOTE:
    #   - < v3.1 RHN proxies send only 1 token in this header
    #   - > v3.1: we send the route of the requests via multiple tokens
    #     "token1:hostname1,token2:hostname2" the first tuple is the first
    #     proxy hit.

    tokens = string.split(rhnFlags.get('X-RHN-Proxy-Auth'), ',')
    tokens = [token for token in tokens if token]

    for auth_token in tokens:
        _verifyProxyAuthToken(auth_token)

    # if no rhnFault was raised then the tokens all passed
    return 1


def auth_client():
    """ Authenticates a request from a client
        For an unsigned request, this function returns 0 (request should be
        coming from a client).
    """

    log_debug(3)
    if not rhnFlags.test("AUTH_SESSION_TOKEN"):
        # No auth information; decline any GET action (XMLRPC requests
        # ignore this error).
        log_debug(4, "declined client authentication for GET requests")
        return 0

    token = dict((k.lower(),v) for k,v in rhnFlags.get("AUTH_SESSION_TOKEN").items())
    # Check to see if everything we need to compute the signature is there
    for k in ('x-rhn-server-id',
              'x-rhn-auth-user-id',
              'x-rhn-auth',
              'x-rhn-auth-server-time',
              'x-rhn-auth-expire-offset'):
        if k not in token:
            # No auth information; decline any action
            log_debug(4, "Declined auth of client for GET requests; "
                         "incomplete header info.")
            return 0

    clientId = token['x-rhn-server-id']
    username = token['x-rhn-auth-user-id']
    signature = token['x-rhn-auth']
    rhnServerTime = token['x-rhn-auth-server-time']
    expireOffset = token['x-rhn-auth-expire-offset']


    computed = computeSignature(CFG.SECRET_KEY, clientId, username,
                                rhnServerTime, expireOffset)
    if computed != signature:
        log_debug(4, "Sent client signature %s does not match ours %s." % (
            signature, computed))
        raise rhnFault(33, "Invalid client session key")

    # Convert the expiration/time to floats:
    rhnServerTime = float(rhnServerTime)
    expireOffset = float(expireOffset)

    if rhnServerTime + expireOffset < time.time():
        log_debug(4, "Expired client authentication token")
        raise rhnFault(34, "Expired client authentication token")

    log_debug(4, "Client auth OK")
    return 1
