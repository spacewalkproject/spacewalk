#
# Copyright (c) 2008--2014 Red Hat, Inc.
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

# language imports
import os
import sys
import time
import gzip
import tempfile
from optparse import Option, OptionParser
from rhn import rpclib
from rhn.connections import idn_ascii_to_puny
from M2Crypto import X509

# Check if python-rhsm is installed
try:
    from rhsm.config import RhsmConfigParser
except ImportError:
    RhsmConfigParser = None

# Recent rhnlib has support for timing out, rather than hanging.
try:
    from rhn.SSL import TimeoutException
except ImportError:
    class TimeoutException(Exception):
        pass

# common, server imports
from spacewalk.common import rhnLib, fileutils
from spacewalk.common.rhnConfig import CFG, initCFG, PRODUCT_NAME
from spacewalk.common.rhnTranslate import _
from spacewalk.server.rhnServer import satellite_cert
# Try to import cdn activation module if available
try:
    from spacewalk.cdn_tools import activation as cdn_activation
    from spacewalk.cdn_tools.manifest import Manifest
except ImportError:
    cdn_activation = None
    Manifest = None


DEFAULT_SYSTEMID_LOCATION = '/etc/sysconfig/rhn/systemid'
DEFAULT_RHN_CERT_LOCATION = '/etc/sysconfig/rhn/rhn-entitlement-cert.xml'
DEFAULT_WEB_HANDLER = '/rpc/api'
DEFAULT_WEBAPP_GPG_KEY_RING = "/etc/webapp-keyring.gpg"
DEFAULT_CONFIG_FILE = "/etc/rhn/rhn.conf"
DEFAULT_RHSM_CONFIG_FILE = "/etc/rhsm/rhsm.conf"


class CaCertInsertionError(Exception):
    "raise when fail to insert CA cert into the local database"


def getRHSMUuid():
    """ Tries to get UUID of of this system if it's registered into Subscription manager."""

    if RhsmConfigParser and os.path.isfile(DEFAULT_RHSM_CONFIG_FILE):
        cfg = RhsmConfigParser(config_file=DEFAULT_RHSM_CONFIG_FILE)
        cert_dir = cfg.get('rhsm', 'consumerCertDir')
        cert_path = os.path.join(cert_dir, 'cert.pem')
        if os.path.isfile(cert_path):
            f = open(cert_path, 'r')
            cert = X509.load_cert_string(f.read())
            f.close()
            subject = cert.get_subject()
            return subject.CN
    return None


def openGzippedFile(filename):
    """ Open a file for reading. File may or may not be a gzipped file.
        Returns a file object.
    """

    if filename[-2:] == 'gz':
        fo = gzip.open(filename, 'rb')
        try:
            fo.read(1)
        except IOError:
            # probably not a gzipped file
            pass
        else:
            # is a gzipped file; return a file object
            fo.close()
            fo = gzip.open(filename, 'rb')
            return fo
    # not a gzipped file; return a file object
    fo = open(filename, 'rb')
    return fo


def getXmlrpcServer(server, handler, proxy, proxyUser, proxyPass,
                    sslCertPath, sslYN=1):
    """ Return an XML-RPC Server connection object; no ssl if sslCertPath==None.
        May return rpclib.xmlrpclib.Fault, rpclib.xmlrpclib.ProtocolError,
        or socket.error.
    """

    _uri = server + handler
    uri = 'https://' + _uri
    if not sslYN or not sslCertPath:
        uri = 'http://' + _uri

    s = rpclib.Server(uri, refreshCallback=None,
                      proxy=proxy, username=proxyUser, password=proxyPass,
                      timeout=CFG.timeout)
    if sslYN and sslCertPath:
        if not os.access(sslCertPath, os.R_OK):
            sys.stderr.write("SSL CA Cert inaccessible: '%s'\n" % sslCertPath)
            sys.exit(1)
        s.add_trusted_cert(sslCertPath)

    return s


class RHNCertGeneralSanityException(Exception):
    "general failure"


def getCertChecksumString(sat_cert):
    result = ""
    tree = {}

    # Scalar attributes of sat_cert
    for field in sat_cert.fields_scalar:
        tree[field] = getattr(sat_cert, field)
    # List attributes of sat_cert
    for name, value in sat_cert.fields_list.items():
        field = value.attribute_name
        tree[name] = []
        for item in getattr(sat_cert, field):
            attributes = {}
            for k, v in item.attributes.items():
                attr = getattr(item, v)
                if attr != "":
                    attributes[k] = attr
            tree[name].append(attributes)

    # Create string from tree
    for key in sorted(tree):
        if isinstance(tree[key], list):
            for item in sorted(tree[key], key=lambda item: "".join(sorted(item.keys() + item.values()))):
                line = "%s" % key
                for attribute in sorted(item):
                    line += "-%s-%s" % (attribute, item[attribute])
                result += "%s\n" % line
        else:
            if tree[key] is not None:
                result += "%s-%s\n" % (key, tree[key])

    return result


def validateSatCert(certFilename, verbosity=0):
    """ validating (i.e., verifing sanity of) this product. Calls
        validate-sat-cert.pl
        I.e., makes sure the product Certificate is a sane certificate
    """

    cert = openGzippedFile(certFilename).read().strip()

    sat_cert = satellite_cert.SatelliteCert()
    sat_cert.load(cert)

    for key in ['generation', 'product', 'owner', 'issued', 'expires', 'slots']:
        if not getattr(sat_cert, key):
            sys.stderr.write("Error: Your satellite certificate is not valid. Field %s is not defined.\n"
                             "Please contact your support representative.\n" % key)
            raise RHNCertGeneralSanityException("RHN Entitlement Certificate failed "
                                                "to validate.")

    signature = sat_cert.signature

    # copy cert to temp location (it may be gzipped).
    fd, certTmpFile = tempfile.mkstemp(prefix = DEFAULT_RHN_CERT_LOCATION + '-')
    fo = os.fdopen(fd, 'wb')
    fo.write(getCertChecksumString(sat_cert))
    fo.flush()
    fo.close()

    fd, signatureTmpFile = tempfile.mkstemp(prefix = DEFAULT_RHN_CERT_LOCATION + '-signature-')
    fo = os.fdopen(fd, 'wb')
    fo.write(signature)
    fo.flush()
    fo.close()

    args = ['gpg', '--verify', '-q', '--keyring',
            DEFAULT_WEBAPP_GPG_KEY_RING, signatureTmpFile, certTmpFile]

    if verbosity:
        print "Checking cert XML sanity and GPG signature:", repr(' '.join(args))

    ret, out, err = fileutils.rhn_popen(args)
    err = err.read()
    out = out.read()

    # nuke temp cert
    os.unlink(certTmpFile)
    os.unlink(signatureTmpFile)

    if err.find('Ohhhh jeeee: ... this is a bug') != -1 or err.find('verify err') != -1 or ret:
        msg = "%s Entitlement Certificate failed to validate.\n" % PRODUCT_NAME
        msg = msg + "MORE INFORMATION:\n"
        msg = msg + "  Return value: %s\n" % ret +\
                    "  Standard-out: %s\n" % out +\
                    "  Standard-error: %s\n" % err
        sys.stderr.write(msg)
        raise RHNCertGeneralSanityException("RHN Entitlement Certificate failed "
                                            "to validate.")
    return 0


def writeRhnCert(options, cert):
    if os.path.exists(DEFAULT_RHN_CERT_LOCATION):
        fileutils.rotateFile(DEFAULT_RHN_CERT_LOCATION, depth=5)
    fo = open(DEFAULT_RHN_CERT_LOCATION, 'w+b')
    fo.write(cert)
    fo.close()
    options.rhn_cert = DEFAULT_RHN_CERT_LOCATION


def prepRhnCert(options):
    """ minor prepping of the RHN cerficate
        writing to default storage location
    """

    # NOTE: db_* options MUST be populated in /etc/rhn/rhn.conf before this
    #       function is run.
    #       validateSatCert() must have been run prior to this as well (it
    #       populates "/var/log/entitlementCert"
    if options.rhn_cert and options.rhn_cert != DEFAULT_RHN_CERT_LOCATION:
        try:
            cert = openGzippedFile(options.rhn_cert).read()
        except (IOError, OSError), e:
            msg = _('ERROR: "%s" (specified in commandline)\n'
                    'could not be opened and read:\n%s') % (options.rhn_cert, str(e))
            sys.stderr.write(msg+'\n')
            raise
        cert = cert.strip()
        try:
            writeRhnCert(options, cert)
        except (IOError, OSError), e:
            msg = _('ERROR: "%s" could not be opened\nand/or written to:\n%s') % (DEFAULT_RHN_CERT_LOCATION, str(e))
            sys.stderr.write(msg+'\n')
            raise


class RHNCertLocalActivationException(Exception):
    "general local activate failure exception"


class RHNCertRemoteActivationException(Exception):
    "general remote activate failure exception"


class RHNCertRemoteNoManagementSlotsException(Exception):
    "no_management_slots fault 1020"


class RHNCertRemoteSatelliteAlreadyActivatedException(Exception):
    "satellite_already_activated fault 1021 - we exit with code 0 if this happens"


class RHNCertRemoteNoAccessToSatChannelException(Exception):
    "no_access_to_sat_channel fault 1022"


class RHNCertRemoteInsufficientChannelEntitlementsException(Exception):
    "insufficient_channel_entitlements fault 1023"


class RHNCertRemoteInvalidSatCertificateException(Exception):
    "invalid_sat_certificate fault 1024"


class RHNCertRemoteSatelliteNotActivatedException(Exception):
    """ satellite_not_activated fault 1025 - if we get this as a final result,
        something bad happened """


class RHNCertRemoteSatelliteNoBaseChannelException(Exception):
    "satellite_no_base_channel fault 1026"


class RHNCertNoSatChanForVersion(Exception):
    "no_sat_chan_for_version fault 2"


def activateSatellite_remote(options):
    """ activate/entitle this product on the remote RHN servers

        NOTE: validateSatCert calls validate-sat-cert.pl which will activate
              the satellite as well. But we don't use it's version cuz
              (a) it doesn't handle http proxies/systemid's/ca-certs,
              and (b) I can't do error handling as easily.
    """

    # may raise InvalidRhnCertError, UnhandledXmlrpcError, socket.error,
    # or cgiwrap.ProtocolError

    s = getXmlrpcServer(options.server,
                        DEFAULT_WEB_HANDLER,
                        options.http_proxy,
                        options.http_proxy_username,
                        options.http_proxy_password,
                        options.ca_cert,
                        not options.no_ssl)
    if not os.path.exists(options.systemid):
        msg = ("ERROR: Server not registered? No systemid: %s"
               % options.systemid)
        sys.stderr.write(msg+"\n")
        raise RHNCertRemoteSatelliteAlreadyActivatedException(msg)
    systemid = open(options.systemid, 'rb').read()
    rhn_cert = openGzippedFile(options.rhn_cert).read()
    ret = None
    oldApiYN = DEFAULT_WEB_HANDLER == '/WEBRPC/satellite.pxt'
    if not oldApiYN:
        try:
            if options.verbose:
                print "Executing: remote XMLRPC deactivation (if necessary)."
            ret = s.satellite.deactivate_satellite(systemid, rhn_cert)
        except rpclib.xmlrpclib.Fault, f:
            # 1025 results in "satellite_not_activated"
            if abs(f.faultCode) != 1025:
                sys.stderr.write('ERROR: unhandled XMLRPC fault upon '
                                 'remote deactivation (reraising): %s\n' % f)
                raise RHNCertRemoteActivationException('%s' % f), None, sys.exc_info()[2]

    no_sat_chan_for_version = 'no_sat_for_version'
    no_sat_chan_for_version1 = "Unhandled exception 'no_sat_chan_for_version' (unhandled_named_exception)"
    # FIXME: that second version is a work-around to a bug ( 137656 ). It
    #        should go away eventually.

    try:
        if options.verbose:
            print "Executing: remote XMLRPC activation call."
        ret = s.satellite.activate_satellite(systemid, rhn_cert)
    except rpclib.xmlrpclib.Fault, f:
        sys.stderr.write("Error reported from RHN: %s\n" % f)
        # NOTE: we support the old (pre-cactus) web-handler API and the new.
        # The old web handler used faultCodes of 1|-1 and the new API uses
        # faultCodes in the range [1020, ..., 1039]
        if oldApiYN and abs(f.faultCode) == 1:
            sys.stderr.write(
                'ERROR: error upon attempt to activate this %s\n'
                'against the RHN hosted service.\n\n%s\n' % (PRODUCT_NAME, f))
            raise RHNCertRemoteActivationException('%s' % f), None, sys.exc_info()[2]

        if not oldApiYN \
          and (abs(f.faultCode) in range(1020, 1039+1)
               or f.faultString in (no_sat_chan_for_version,
                                    no_sat_chan_for_version1)):
            if abs(f.faultCode) == 1020:
                # 1020 results in "no_management_slots"
                print "NOTE: no management slots found on the hosted account."
                raise RHNCertRemoteNoManagementSlotsException('%s' % f), None, sys.exc_info()[2]
            elif abs(f.faultCode) == 1021:
                # 1021 results in "satellite_already_activated"
                # This shouldn't happen anymore (we deactivate prior to this step).
                print "NOTE: this %s is already activated - deactivate on the website and try again." % PRODUCT_NAME
                raise RHNCertRemoteSatelliteAlreadyActivatedException('%s' % f), None, sys.exc_info()[2]
            elif abs(f.faultCode) == 1022:
                # 1022 results in "no_access_to_sat_channel"
                print "NOTE: hosted RHN reports 'no_access_to_sat_channel'."
                raise RHNCertRemoteNoAccessToSatChannelException('%s' % f), None, sys.exc_info()[2]
            elif abs(f.faultCode) == 1023:
                # 1023 results in "insufficient_channel_entitlements"
                print "NOTE: hosted RHN reports 'insufficient_channel_entitlements'."
                raise RHNCertRemoteInsufficientChannelEntitlementsException('%s' % f), None, sys.exc_info()[2]
            elif abs(f.faultCode) == 1024:
                # 1024 results in "invalid_sat_certificate"
                print "NOTE: hosted RHN reports 'invalid_sat_certificate'."
                raise RHNCertRemoteInvalidSatCertificateException('%s' % f), None, sys.exc_info()[2]
            elif abs(f.faultCode) == 1025:
                # 1025 results in "satellite_not_activated"
                print """\
NOTE: hosted RHN reports 'satellite_not_activated'. This is an odd fault that
indicates an odd state - deactivate on the website and try again."""
                raise RHNCertRemoteSatelliteNotActivatedException('%s' % f), None, sys.exc_info()[2]
            elif abs(f.faultCode) == 1026:
                # 1026 results in "satellite_no_base_channel"
                print """\
NOTE: hosted RHN reports 'satellite_no_base_channel'. This system is not
entitled to a base channel in your RHN account."""
                raise RHNCertRemoteSatelliteNoBaseChannelException('%s' % f), None, sys.exc_info()[2]
            elif f.faultString in (no_sat_chan_for_version,
                                   no_sat_chan_for_version1):
                print """\
NOTE: hosted RHN reports 'no_sat_chan_for_version'. This system does not have
access to a channel that corresponds to the version of RHN certificate used to
attempted activation."""
                raise RHNCertNoSatChanForVersion('%s' % f), None, sys.exc_info()[2]

            # other errors [1027, ..., 1039]:
            sys.stderr.write(
                'ERROR: error upon attempt to activate this %s\n'
                'against the RHN hosted service.\n\n%s\n' % (PRODUCT_NAME, f))
            raise RHNCertRemoteActivationException('%s' % f), None, sys.exc_info()[2]

        # still in except: section. Need to raise unhandled.
        sys.stderr.write('ERROR: unhandled XMLRPC fault upon '
                         'remote activation: %s\n' % f)
        raise RHNCertRemoteActivationException('%s' % f), None, sys.exc_info()[2]

    return ret


class PopulateChannelFamiliesException(Exception):
    "general failure when populating channel families"


def populateChannelFamilies(options):
    """ Populate channel family permissions via satellite-sync """

    # TODO: Can't we do this programatically?
    args = ["/usr/bin/satellite-sync", "--list-channels"]

    # The next three if-blocks remove dependence on /etc/rhn/rhn.conf being
    # written (not a large gain, but there it is).
    # use a http proxy with satellite-sync
    if options.http_proxy:
        args.extend(['--http-proxy', options.http_proxy])
        if options.http_proxy_username:
            args.extend(['--http-proxy-username', options.http_proxy_username])
            if options.http_proxy_password:
                args.extend(['--http-proxy-password',
                             options.http_proxy_password])

    # use a ca cert with satellite-sync
    if options.ca_cert:
        args.extend(['--ca-cert', options.ca_cert])

    # use a ca cert with satellite-sync
    if options.no_ssl:
        args.extend(['--no-ssl'])

    if options.dump_version:
        args.extend(['--dump-version', options.dump_version])

    if options.verbose:
        print "Executing: %s\n" % repr(' '.join(args))
    ret, out_stream, err_stream = fileutils.rhn_popen(args)
    if ret:
        msg_ = "Population of the Channel Family permissions failed."
        msg = ("%s\nReturn value: %s\nStandard-out: %s\n\n"
               "Standard-error: %s\n\n"
               % (msg_, ret, out_stream.read(), err_stream.read()))
        sys.stderr.write(msg)
        raise PopulateChannelFamiliesException("Population of the Channel "
                                               "Family permissions failed.")


def expiredYN(certPath):
    """ dead simple check to see if our RHN cert is not expired
        returns either "" or the date of expiration.
    """

    ## open cert
    try:
        fo = open(certPath, 'rb')
    except IOError:
        sys.stderr.write("ERROR: unable to open the cert: %s\n" % certPath)
        sys.exit(1)

    cert = fo.read().strip()
    fo.close()

    # parse it and snag "expires"
    sc = satellite_cert.SatelliteCert()
    sc.load(cert)
    # note the correction for timezone
    # pylint: disable=E1101
    try:
        expires = time.mktime(time.strptime(sc.expires, sc.datesFormat_cert))-time.timezone
    except ValueError:
        sys.stderr.write("""\
ERROR: can't seem to parse the expires field in the RHN Certificate.
       RHN Certificate's version is incorrect?\n""")
        # a cop-out FIXME: not elegant
        sys.exit(11)

    now = time.time()
    if expires < now:
        return sc.expires
    else:
        return ''


def processCommandline():
    options = [
        Option('--systemid',     action='store',      help='(FOR TESTING ONLY) alternative systemid path/filename. '
               + 'The system default is used if not specified.'),
        Option('--rhn-cert',     action='store',      help='new RHN certificate path/filename (default is'
               + ' %s - the saved RHN cert).' % DEFAULT_RHN_CERT_LOCATION),
        Option('--no-ssl',       action='store_true', help='(FOR TESTING ONLY) disables SSL'),
        Option('--sanity-only',  action='store_true', help="confirm certificate sanity. Does not activate"
               + "the Red Hat Satellite locally or remotely."),
        Option('--ignore-expiration', action='store_true', help='execute regardless of the expiration'
               + 'of the RHN Certificate (not recommended).'),
        Option('--ignore-version-mismatch', action='store_true', help='execute regardless of version '
               + 'mismatch of existing and new certificate.'),
        Option('-v', '--verbose', action='count',      help='be verbose '
               + '(accumulable: -vvv means "be *really* verbose").'),
        Option('--dump-version', action='store', help="requested version of XML dump"),
        Option('--manifest',     action='store',      help='the RHSM manifest path/filename to activate for CDN'),
    ]

    options, args = OptionParser(option_list=options).parse_args()

    # we take no extra commandline arguments that are not linked to an option
    if args:
        msg = "ERROR: these arguments make no sense in this context (try --help): %s\n" % repr(args)
        raise ValueError(msg)

    initCFG('server.satellite')

    # systemid
    if not options.systemid:
        options.systemid = DEFAULT_SYSTEMID_LOCATION
    options.systemid = fileutils.cleanupAbsPath(options.systemid)

    if not options.rhn_cert and not options.manifest:
        print "NOTE: using backup cert as default: %s" % DEFAULT_RHN_CERT_LOCATION
        options.rhn_cert = DEFAULT_RHN_CERT_LOCATION

    if options.manifest:
        if not cdn_activation:
            sys.stderr.write("ERROR: Package spacewalk-backend-cdn has to be installed for using --manifest.\n")
            sys.exit(1)
        cdn_manifest = Manifest(options.manifest)
        tmp_cert_path = cdn_manifest.get_certificate_path()
        if tmp_cert_path is not None:
            options.rhn_cert = tmp_cert_path

    options.rhn_cert = fileutils.cleanupAbsPath(options.rhn_cert)
    if not os.path.exists(options.rhn_cert):
        sys.stderr.write("ERROR: RHN Cert (%s) does not exist\n" % options.rhn_cert)
        sys.exit(1)

    if not options.sanity_only and CFG.DISCONNECTED:
        sys.stderr.write("""ERROR: Satellite server has been setup to run in disconnected mode.
       Correct server configuration in /etc/rhn/rhn.conf.
""")
        sys.exit(1)

    options.server = ''
    if not options.sanity_only:
        if not CFG.RHN_PARENT:
            sys.stderr.write("ERROR: rhn_parent is not set in /etc/rhn/rhn.conf\n")
            sys.exit(1)
        options.server = idn_ascii_to_puny(rhnLib.parseUrl(CFG.RHN_PARENT)[1].split(':')[0])
        print 'RHN_PARENT: %s' % options.server

    options.http_proxy = idn_ascii_to_puny(CFG.HTTP_PROXY)
    options.http_proxy_username = CFG.HTTP_PROXY_USERNAME
    options.http_proxy_password = CFG.HTTP_PROXY_PASSWORD
    options.ca_cert = CFG.CA_CHAIN
    if options.verbose:
        print 'HTTP_PROXY: %s' % options.http_proxy
        print 'HTTP_PROXY_USERNAME: %s' % options.http_proxy_username
        print 'HTTP_PROXY_PASSWORD: <password>'
        if not options.no_ssl:
            print 'CA_CERT: %s' % options.ca_cert

    return options


#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

def main():
    """ main routine
        1    general failure
        10   general sanity check failure (to include a remedial cert
             version check)
        11   expired!
        12   certificate version fails remedially
        20   remote activation failure (general, and really unknown why)
        30   local activation failure
        40   channel population failure

        0   1021 satellite_already_activated exception - MAPS TO 0

        (CODE - 1000 + 60)
        80   1020 no_management_slots exception
        82   1022 no_access_to_sat_channel exception
        83   1023 insufficient_channel_entitlements exception
        84   1024 invalid_sat_certificate exception
        85   1025 satellite_not_activated exception - this shouldn't happen!
        86   1026 satellite_no_base_channel exception
        87   2(?) no_sat_chan_for_version exception

        127  general unknown failure (not really mapped yet)

        FIXME - need to redo how we process error codes - very manual
    """
    # pylint: disable=R0911

    options = processCommandline()

    def writeError(e):
        sys.stderr.write('\nERROR: %s\n' % e)

    # Handle RHSM manifest
    if options.manifest:
        cdn_activate = cdn_activation.Activation(options.manifest, options.rhn_cert)
    else:
        cdn_activate = None

    # general sanity/GPG check
    try:
        validateSatCert(options.rhn_cert, options.verbose)
    except RHNCertGeneralSanityException, e:
        writeError(e)
        return 10

    # expiration check
    if not options.ignore_expiration:
        date = expiredYN(options.rhn_cert)
        if date:
            just_date = date.split(' ')[0]
            writeError(
                'RHN Certificate appears to have expired: %s' % just_date)
            return 11

    if not options.sanity_only and not options.manifest:
        prepRhnCert(options)

        # remote activation
        try:
            activateSatellite_remote(options)
        except RHNCertRemoteActivationException, e:
            writeError(e)
            return 20
        except RHNCertRemoteNoManagementSlotsException, e:
            writeError(e)
            return 80
        except RHNCertRemoteSatelliteAlreadyActivatedException, e:
            # note, this is normally a 1021 fault, but it's what we want
            # so let's return 0
            return 0
        except RHNCertRemoteNoAccessToSatChannelException, e:
            writeError(e)
            return 82
        except RHNCertRemoteInsufficientChannelEntitlementsException, e:
            writeError(e)
            return 83
        except RHNCertRemoteInvalidSatCertificateException, e:
            writeError(e)
            return 84
        except RHNCertRemoteSatelliteNotActivatedException, e:
            writeError(e)
            return 85
        except RHNCertRemoteSatelliteNoBaseChannelException, e:
            writeError(e)
            return 86
        except RHNCertNoSatChanForVersion, e:
            writeError(e)
            return 87
        except TimeoutException, e:
            writeError(e)
            return 89

        # channel family stuff
        if CFG.RHN_PARENT and not CFG.ISS_PARENT:
            try:
                populateChannelFamilies(options)
            except PopulateChannelFamiliesException, e:
                writeError(e)
                return 40

    elif cdn_activate:
        cdn_activate.run()

    return 0


#-------------------------------------------------------------------------------
if __name__ == "__main__":
    sys.stderr.write('\nWARNING: intended to be wrapped by another executable\n'
                     '           calling program.\n')
    sys.exit(abs(main() or 0))
#===============================================================================

