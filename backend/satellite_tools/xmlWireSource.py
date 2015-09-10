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


# system imports
import os
import sys
import time
import connection

# rhn imports
from spacewalk.common import rhnLib
from spacewalk.common.rhnConfig import CFG
sys.path.append("/usr/share/rhn")
from up2date_client import config

# local imports
from syncLib import log, log2, RhnSyncException

from rhn import rpclib


class BaseWireSource:

    """ Base object for wire-commo to RHN for delivery of XML/RPMS. """

    serverObj = None
    handler = ''
    url = ''
    sslYN = 0
    systemid = None
    server_handler = None
    xml_dump_version = None

    def __init__(self, systemid, sslYN=0, xml_dump_version=None):
        if not BaseWireSource.systemid:
            BaseWireSource.systemid = systemid
        BaseWireSource.sslYN = sslYN
        BaseWireSource.xml_dump_version = xml_dump_version

    def getServer(self, forcedYN=0):
        if forcedYN:
            self.setServer(self.handler, self.url, forcedYN)
        return BaseWireSource.serverObj

    def schemeAndUrl(self, url):
        """ http[s]://BLAHBLAHBLAH/ACKACK --> http[s]://BLAHBLAHBLAH """

        if not url:
            url = CFG.RHN_PARENT  # the default
        # just make the url complete.
        hostname = rhnLib.parseUrl(url or '')[1]
        hostname = hostname.split(':')[0]  # just in case
        if self.sslYN:
            url = 'https://' + hostname
        else:
            url = 'http://' + hostname
        return url

    def setServer(self, handler, url=None, forcedYN=0):
        """ XMLRPC server object (ssl set in parameters).
            NOTE: url expected to be of the form: scheme://machine/HANDLER
        """

        url = self.schemeAndUrl(url)

        if self._cached_connection_params(handler, url, forcedYN=forcedYN):
            # Already cached
            return

        self._set_connection_params(handler, url)

        url = '%s%s' % (url, handler)  # url is properly set up now.

        serverObj = self._set_connection(url)
        self._set_ssl_trusted_certs(serverObj)
        return serverObj

    @staticmethod
    def _set_connection_params(handler, url):
        BaseWireSource.handler = handler
        BaseWireSource.url = url

    def _cached_connection_params(self, handler, url, forcedYN=0):
        """Helper function; returns 0 if we have to reset the connection
        params, 1 if the cached values are ok"""
        if forcedYN:
            return 0
        if handler != self.handler or url != self.url:
            return 0
        return 1

    def _set_connection(self, url):
        "Instantiates a connection object"

        serverObj = connection.StreamConnection(url, proxy=CFG.HTTP_PROXY,
                                                username=CFG.HTTP_PROXY_USERNAME, password=CFG.HTTP_PROXY_PASSWORD,
                                                xml_dump_version=self.xml_dump_version, timeout=CFG.timeout)
        BaseWireSource.serverObj = serverObj
        return serverObj

    def _set_ssl_trusted_certs(self, serverObj):
        if not self.sslYN:
            return None

        # Check certificate
        if CFG.ISS_PARENT:
            caChain = CFG.ISS_CA_CHAIN
        else:
            caChain = CFG.CA_CHAIN
        if caChain:
            # require RHNS-CA-CERT file to be able to authenticate the SSL
            # connections.
            if not os.access(caChain, os.R_OK):
                message = "ERROR: can not find RHN CA file: %s" % caChain
                log(-1, message, stream=sys.stderr)
                raise Exception(message)
            # force the validation of the SSL cert
            serverObj.add_trusted_cert(caChain)
            return caChain

        message = '--- Warning: SSL connection made but no CA certificate used'
        log(1, message, stream=sys.stderr)
        return None

    def _openSocketStream(self, method, params):
        """Wraps the gzipstream.GzipStream instantiation in a test block so we
           can open normally if stream is not gzipped."""

        stream = None
        retryYN = 0
        wait = 0.33
        lastErrorMsg = ''
        cfg = config.initUp2dateConfig()
        for i in range(cfg['networkRetries']):
            server = self.getServer(retryYN)
            if server is None:
                log2(-1, 2, 'ERROR: server unable to initialize, attempt %s' % i, stream=sys.stderr)
                retryYN = 1
                time.sleep(wait)
                continue
            func = getattr(server, method)
            try:
                stream = func(*params)
                return stream
            except rpclib.xmlrpclib.ProtocolError, e:
                p = tuple(['<the systemid>'] + list(params[1:]))
                lastErrorMsg = 'ERROR: server.%s%s: %s' % (method, p, e)
                log2(-1, 2, lastErrorMsg, stream=sys.stderr)
                retryYN = 1
                time.sleep(wait)
                # do not reraise this exception!
            except (KeyboardInterrupt, SystemExit):
                raise
            except rpclib.xmlrpclib.Fault, e:
                lastErrorMsg = e.faultString
                break
            except Exception, e:  # pylint: disable=E0012, W0703
                p = tuple(['<the systemid>'] + list(params[1:]))
                lastErrorMsg = 'ERROR: server.%s%s: %s' % (method, p, e)
                log2(-1, 2, lastErrorMsg, stream=sys.stderr)
                break
                # do not reraise this exception!
        if lastErrorMsg:
            raise RhnSyncException, lastErrorMsg, sys.exc_info()[2]
        # Returns a stream
        # Should never be reached
        return stream

    def setServerHandler(self, isIss=0):
        if isIss:
            self.server_handler = CFG.RHN_ISS_METADATA_HANDLER
        else:
            self.server_handler = CFG.RHN_METADATA_HANDLER


class MetadataWireSource(BaseWireSource):

    """retrieve specific xml stream through xmlrpc interface."""

    @staticmethod
    def is_disk_loader():
        return False

    def _prepare(self):
        self.setServer(self.server_handler)

    def getArchesXmlStream(self):
        """retrieve xml stream for arch data."""
        self._prepare()
        return self._openSocketStream("dump.arches", (self.systemid,))

    def getArchesExtraXmlStream(self):
        "retrieve xml stream for the server group type arch compat"
        self._prepare()
        return self._openSocketStream("dump.arches_extra", (self.systemid,))

    def getProductNamesXmlStream(self):
        "retrieve xml stream for the product names data"
        self._prepare()
        return self._openSocketStream("dump.product_names", (self.systemid,))

    def getChannelFamilyXmlStream(self):
        """retrieve xml stream for channel family data."""
        self._prepare()
        return self._openSocketStream("dump.channel_families", (self.systemid,))

    def getOrgsXmlStream(self):
        """retrieve xml stream for org data."""
        self._prepare()
        return self._openSocketStream("dump.orgs", (self.systemid,))

    def getChannelXmlStream(self):
        """retrieve xml stream for channel data given a
        list of channel labels."""
        self._prepare()
        return self._openSocketStream("dump.channels", (self.systemid, []))

    def getShortPackageXmlStream(self, packageIds):
        """retrieve xml stream for short package data given
        a list of package ids."""
        self._prepare()
        return self._openSocketStream("dump.packages_short", (self.systemid, packageIds))

    def getChannelShortPackagesXmlStream(self, channel, last_modified):
        """retrieve xml stream for short package data given a channel
        label and the last modified timestamp of the channel"""
        self._prepare()
        return self._openSocketStream("dump.channel_packages_short",
                                      (self.systemid, channel, last_modified))

    def getPackageXmlStream(self, packageIds):
        """retrieve xml stream for package data given a
        list of package ids."""
        self._prepare()
        return self._openSocketStream("dump.packages", (self.systemid, packageIds))

    def getSourcePackageXmlStream(self, packageIds):
        """retrieve xml stream for package data given a
        list of package ids."""
        self._prepare()
        return self._openSocketStream("dump.source_packages", (self.systemid, packageIds))

    def getErrataXmlStream(self, erratumIds):
        """retrieve xml stream for erratum data given a list of erratum ids."""
        self._prepare()
        return self._openSocketStream("dump.errata", (self.systemid, erratumIds))

    def getKickstartsXmlStream(self, ksLabels):
        "retrieve xml stream for kickstart trees"
        self._prepare()
        return self._openSocketStream("dump.kickstartable_trees",
                                      (self.systemid, ksLabels))

    def getComps(self, channel):
        return self._openSocketStream("dump.get_comps",
                                      (self.systemid, channel))

    def getRpm(self, nvrea, channel):
        release = nvrea[2]
        epoch = nvrea[3]
        if epoch:
            release = "%s:%s" % (release, epoch)
        package_name = "%s-%s-%s.%s.rpm" % (nvrea[0], nvrea[1], release,
                                            nvrea[4])
        self._prepare()
        return self._openSocketStream("dump.get_rpm",
                                      (self.systemid, package_name, channel))

    def getKickstartFile(self, ks_label, relative_path):
        self._prepare()
        return self._openSocketStream("dump.get_ks_file",
                                      (self.systemid, ks_label, relative_path))


class XMLRPCWireSource(BaseWireSource):

    "Base class for all the XMLRPC calls"

    @staticmethod
    def _xmlrpc(function, params):
        try:
            retval = getattr(BaseWireSource.serverObj, function)(*params)
        except TypeError, e:
            log(-1, 'ERROR: during "getattr(BaseWireSource.serverObj, %s)(*(%s))"' % (function, params))
            raise
        except rpclib.xmlrpclib.ProtocolError, e:
            log2(-1, 2, 'ERROR: ProtocolError: %s' % e, stream=sys.stderr)
            raise
        return retval


class AuthWireSource(XMLRPCWireSource):

    """Simply authenticate this systemid as a satellite."""

    def checkAuth(self):
        self.setServer(CFG.RHN_XMLRPC_HANDLER)
        authYN = None
        log(2, '   +++ Satellite synchronization tool checking in.')
        try:
            authYN = self._xmlrpc('authentication.check', (self.systemid,))
        except (rpclib.xmlrpclib.ProtocolError, rpclib.xmlrpclib.Fault):
            raise
        if authYN:
            log(2, '   +++ Entitled satellite validated.', stream=sys.stderr)
        elif authYN is None:
            log(-1, '   --- An error occurred upon authentication of this satellite -- '
                    'review the pertinent log file (%s) and/or alert RHN at rhn-satellite@redhat.com.' % CFG.LOG_FILE,
                stream=sys.stderr)
            sys.exit(-1)
        elif authYN == 0:
            log(-1, '   --- This server is not an entitled satellite.', stream=sys.stderr)
            sys.exit(-1)
        return authYN

class RPCGetWireSource(BaseWireSource):

    "Class to retrieve various files via authenticated GET requests"
    get_server_obj = None
    login_token = None
    get_server_obj = None

    def __init__(self, systemid, sslYN, xml_dump_version):
        BaseWireSource.__init__(self, systemid, sslYN, xml_dump_version)
        self.extinctErrorYN = 0

    @staticmethod
    def _set_connection_params(handler, url):
        BaseWireSource._set_connection_params(handler, url)
        RPCGetWireSource.login_token = None

    def login(self, force=0):
        "Perform a login, return a GET Server instance"
        if force:
            # Invalidate it
            self._set_login_token(None)
        if self.login_token:
            # Return cached one
            return self.get_server_obj

        # Force a login otherwise
        self._set_login_token(self._login())
        url = self.url + self.handler
        get_server_obj = connection.GETServer(url, proxy=CFG.HTTP_PROXY,
                                              username=CFG.HTTP_PROXY_USERNAME, password=CFG.HTTP_PROXY_PASSWORD,
                                              headers=self.login_token, timeout=CFG.timeout)
        # Add SSL trusted cert
        self._set_ssl_trusted_certs(get_server_obj)
        self._set_rpc_server(get_server_obj)
        return self.get_server_obj

    def _login(self):
        if not self.systemid:
            raise Exception("systemid not set!")

        # Set the URL to the one for regular XML-RPC calls
        self.setServer(CFG.RHN_XMLRPC_HANDLER)

        try:
            login_token = self.getServer().authentication.login(self.systemid)
        except rpclib.xmlrpclib.ProtocolError, e:
            log2(-1, 2, 'ERROR: ProtocolError: %s' % e, stream=sys.stderr)
            raise
        return login_token

    @staticmethod
    def _set_login_token(token):
        RPCGetWireSource.login_token = token

    @staticmethod
    def _set_rpc_server(server):
        RPCGetWireSource.get_server_obj = server

    def _rpc_call(self, function_name, params):
        get_server_obj = self.login()
        # Try a couple of times
        fault_count = 0
        expired_token = 0
        cfg = config.initUp2dateConfig()
        while fault_count - expired_token < cfg['networkRetries']:
            try:
                ret = getattr(get_server_obj, function_name)(*params)
            except rpclib.xmlrpclib.ProtocolError, e:
                # We have two codes to check: the HTTP error code, and the
                # combination (failtCode, faultString) encoded in the headers
                # of the request.
                http_error_code = e.errcode
                fault_code, fault_string = rpclib.reportError(e.headers)
                fault_count += 1
                if http_error_code == 401 and fault_code == -34:
                    # Login token expired
                    get_server_obj = self.login(force=1)
                    # allow exactly one respin for expired token
                    expired_token = 1
                    continue
                if http_error_code == 404 and fault_code == -17:
                    # File not found
                    self.extinctErrorYN = 1
                    return None
                log(-1, 'ERROR: http error code :%s; fault code: %s; %s' %
                    (http_error_code, fault_code, fault_string))
                # XXX
                raise
            else:
                return ret
        raise Exception("Failed after multiple attempts!")

    def getPackageStream(self, channel, nvrea):
        release = nvrea[2]
        epoch = nvrea[3]
        if epoch:
            release = "%s:%s" % (release, epoch)
        package_name = "%s-%s-%s.%s.rpm" % (nvrea[0], nvrea[1], release,
                                            nvrea[4])
        return self._rpc_call("getPackage", (channel, package_name))

    def getKickstartFileStream(self, channel, ks_tree_label, relative_path):
        return self._rpc_call("getKickstartFile", (channel, ks_tree_label,
                                                   relative_path))

    def getCompsFileStream(self, channel):
        return self._rpc_call("repodata", (channel, 'comps.xml'))
