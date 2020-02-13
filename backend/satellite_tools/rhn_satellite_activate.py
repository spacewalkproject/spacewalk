#
# Copyright (c) 2008--2017 Red Hat, Inc.
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
import tempfile
import re
from optparse import Option, OptionParser
from M2Crypto import X509

from rhn.connections import idn_ascii_to_puny
# Check if python-rhsm is installed
try:
    from rhsm.config import RhsmConfigParser
except ImportError:
    RhsmConfigParser = None

# common, server imports
from spacewalk.common import fileutils, rhnLog
from spacewalk.common.rhnConfig import CFG, initCFG, PRODUCT_NAME
from spacewalk.common.rhnTranslate import _
from spacewalk.server.rhnServer import satellite_cert
# Try to import cdn activation module if available
try:
    from spacewalk.cdn_tools import activation as cdn_activation
    from spacewalk.cdn_tools.manifest import MissingSatelliteCertificateError, ManifestValidationError,\
        IncorrectEntitlementsFileFormatError
    from spacewalk.cdn_tools.common import CdnMappingsLoadError
except ImportError:
    cdn_activation = None
    MissingSatelliteCertificateError = None
    ManifestValidationError = None
    CdnMappingsLoadError = None
from spacewalk.satellite_tools.syncLib import log, log2disk, log2


DEFAULT_RHSM_MANIFEST_LOCATION = '/etc/sysconfig/rhn/rhsm-manifest.zip'
DEFAULT_WEBAPP_GPG_KEY_RING = "/etc/webapp-keyring.gpg"
DEFAULT_CONFIG_FILE = "/etc/rhn/rhn.conf"
DEFAULT_RHSM_CONFIG_FILE = "/etc/rhsm/rhsm.conf"
SUPPORTED_RHEL_VERSIONS = ['5', '6']
LOG_PATH = '/var/log/rhn/activation.log'


def writeError(e):
    log2(0, 0, '\nERROR: %s\n' % e, stream=sys.stderr, cleanYN=1)


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


def validateSatCert(cert):
    """ validating (i.e., verifing sanity of) this product.
        I.e., makes sure the product Certificate is a sane certificate
    """

    sat_cert = satellite_cert.SatelliteCert()
    sat_cert.load(cert)

    for key in ['generation', 'product', 'owner', 'issued', 'expires', 'slots']:
        if not getattr(sat_cert, key):
            writeError("Your satellite certificate is not valid. Field %s is not defined.\n"
                       "Please contact your support representative." % key)
            raise RHNCertGeneralSanityException("RHN Entitlement Certificate failed "
                                                "to validate.")

    signature = sat_cert.signature

    # copy cert to temp location (it may be gzipped).
    fd, certTmpFile = tempfile.mkstemp(prefix="/tmp/cert-")
    fo = os.fdopen(fd, 'wb')
    fo.write(getCertChecksumString(sat_cert))
    fo.flush()
    fo.close()

    fd, signatureTmpFile = tempfile.mkstemp(prefix="/tmp/cert-signature-")
    fo = os.fdopen(fd, 'wb')
    fo.write(signature)
    fo.flush()
    fo.close()

    args = ['gpg', '--verify', '-q', '--keyring',
            DEFAULT_WEBAPP_GPG_KEY_RING, signatureTmpFile, certTmpFile]

    log(1, "Checking cert XML sanity and GPG signature: %s" % repr(' '.join(args)))

    ret, out, err = fileutils.rhn_popen(args)
    err = err.read()
    out = out.read()

    # nuke temp cert
    os.unlink(certTmpFile)
    os.unlink(signatureTmpFile)

    if err.find('Ohhhh jeeee: ... this is a bug') != -1 or err.find('verify err') != -1 or ret:
        msg = "%s Entitlement Certificate failed to validate.\n" % PRODUCT_NAME
        msg += "MORE INFORMATION:\n"
        msg = msg + "  Return value: %s\n" % ret +\
                    "  Standard-out: %s\n" % out +\
                    "  Standard-error: %s" % err
        writeError(msg)
        raise RHNCertGeneralSanityException("RHN Entitlement Certificate failed "
                                            "to validate.")
    return 0


def writeRhsmManifest(options, manifest):
    if os.path.exists(DEFAULT_RHSM_MANIFEST_LOCATION):
        fileutils.rotateFile(DEFAULT_RHSM_MANIFEST_LOCATION, depth=5)
    fo = open(DEFAULT_RHSM_MANIFEST_LOCATION, 'w+b')
    fo.write(manifest)
    fo.close()
    # Delete from temporary location
    if options.manifest_refresh:
        os.unlink(options.manifest)
    options.manifest = DEFAULT_RHSM_MANIFEST_LOCATION


def storeRhsmManifest(options):
    """ storing of the RHSM manifest
        writing to default storage location
    """

    if options.manifest and options.manifest != DEFAULT_RHSM_MANIFEST_LOCATION:
        try:
            manifest = open(os.path.abspath(os.path.expanduser(options.manifest)), 'rb').read()
        except (IOError, OSError), e:
            msg = _('"%s" (specified in commandline)\n'
                    'could not be opened and read:\n%s') % (options.manifest, str(e))
            writeError(msg)
            raise
        try:
            writeRhsmManifest(options, manifest)
        except (IOError, OSError), e:
            msg = _('"%s" could not be opened\nand/or written to:\n%s') % (
                DEFAULT_RHSM_MANIFEST_LOCATION, str(e))
            writeError(msg)
            raise


def enableSatelliteRepo(rhn_cert):
    args = ['rpm', '-q', '--qf', '\'%{version} %{arch}\'', '-f', '/etc/redhat-release']
    ret, out, err = fileutils.rhn_popen(args)
    data = out.read().strip("'")
    version, arch = data.split()
    # Read from stdout, strip quotes if any and extract first number
    version = re.search(r'\d+', version).group()

    if version not in SUPPORTED_RHEL_VERSIONS:
        log(0, "WARNING: No Satellite repository available for RHEL version: %s." % version)
        return

    arch_str = "server"
    if arch == "s390x":
        arch_str = "system-z"

    sat_cert = satellite_cert.SatelliteCert()
    sat_cert.load(rhn_cert)
    sat_version = getattr(sat_cert, 'satellite-version')

    repo = "rhel-%s-%s-satellite-%s-rpms" % (version, arch_str, sat_version)
    args = ['/usr/bin/subscription-manager', 'repos', '--enable', repo]
    ret, out, err = fileutils.rhn_popen(args)
    if ret:
        msg_ = "Enabling of Satellite repository failed."
        msg = ("%s\nReturn value: %s\nStandard-out: %s\n\n"
               "Standard-error: %s\n"
               % (msg_, ret, out.read(), err.read()))
        writeError(msg)
        raise EnableSatelliteRepositoryException("Enabling of Satellite repository failed. Make sure Satellite "
                                                 "subscription is attached to this system, both versions of RHEL and "
                                                 "Satellite are supported or run activation with --disconnected "
                                                 "option.")


class EnableSatelliteRepositoryException(Exception):
    "when there is no attached satellite subscription in rhsm or incorrect combination of rhel and sat version"


def expiredYN(cert):
    """ dead simple check to see if our RHN cert is not expired
        returns either "" or the date of expiration.
    """

    # parse it and snag "expires"
    sc = satellite_cert.SatelliteCert()
    sc.load(cert)
    # note the correction for timezone
    # pylint: disable=E1101
    try:
        expires = time.mktime(time.strptime(sc.expires, sc.datesFormat_cert))-time.timezone
    except ValueError:
        writeError("Can't seem to parse the expires field in the RHN Certificate. "
                   "RHN Certificate's version is incorrect?")
        # a cop-out FIXME: not elegant
        sys.exit(11)

    now = time.time()
    if expires < now:
        return sc.expires
    else:
        return ''


def processCommandline():
    options = [
        Option('--sanity-only',  action='store_true', help="confirm certificate sanity. Does not activate "
               + "the Red Hat Satellite locally or remotely."),
        Option('--ignore-expiration', action='store_true', help='execute regardless of the expiration '
               + 'of the RHN Certificate (not recommended).'),
        Option('--ignore-version-mismatch', action='store_true', help='execute regardless of version '
               + 'mismatch of existing and new certificate.'),
        Option('-v', '--verbose', action='count',      help='be verbose '
               + '(accumulable: -vvv means "be *really* verbose").'),
        Option('--dump-version', action='store', help="requested version of XML dump"),
        Option('--manifest',     action='store',      help='the RHSM manifest path/filename to activate for CDN'),
        Option('--rhn-cert', action='store', help='this option is deprecated, use --manifest instead'),
        Option('--deactivate', action='store_true', help='deactivate CDN-activated Satellite'),
        Option('--disconnected', action='store_true', help="activate locally, not subscribe to remote repository"),
        Option('--manifest-info', action='store_true', help="show information about currently activated manifest"),
        Option('--manifest-download', action='store_true',
               help="download new manifest from RHSM to temporary location"),
        Option('--manifest-refresh', action='store_true', help="download new manifest from RHSM and activate it"),
        Option('--manifest-reconcile-request', action='store_true',
               help="request regeneration of entitlement certificates")
    ]

    parser = OptionParser(option_list=options)
    options, args = parser.parse_args()

    initCFG('server.satellite')
    if options.verbose is None:
        options.verbose = 0
    CFG.set('DEBUG', options.verbose)
    rhnLog.initLOG(LOG_PATH, options.verbose)
    log2disk(0, "Command: %s" % str(sys.argv))

    # we take no extra commandline arguments that are not linked to an option
    if args:
        writeError("These arguments make no sense in this context (try --help): %s" % repr(args))
        sys.exit(1)

    # No need to check further if deactivating
    if options.deactivate:
        return options

    if options.sanity_only:
        options.disconnected = 1

    if options.manifest_refresh:
        options.manifest_download = 1

    if CFG.DISCONNECTED and not options.disconnected:
        msg = """Satellite server has been setup to run in disconnected mode.
       Either correct server configuration in /etc/rhn/rhn.conf
       or use --disconnected to activate it locally."""
        writeError(msg)
        sys.exit(1)

    options.http_proxy = idn_ascii_to_puny(CFG.HTTP_PROXY)
    options.http_proxy_username = CFG.HTTP_PROXY_USERNAME
    options.http_proxy_password = CFG.HTTP_PROXY_PASSWORD
    log(1, 'HTTP_PROXY: %s' % options.http_proxy)
    log(1, 'HTTP_PROXY_USERNAME: %s' % options.http_proxy_username)
    log(1, 'HTTP_PROXY_PASSWORD: <password>')

    return options


#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

def main():
    """ main routine
        1    general failure
        10   general sanity check failure (to include a remedial cert
             version check)
        11   expired!
        12   certificate version fails remedially
        13   certificate missing in manifest
        14   manifest signature incorrect
        15   cannot load mapping files
        16   manifest download failed
        17   manifest refresh failed
        18   manifest entitlements parse failed
        30   local activation failure

        90   not registered to rhsm
        91   enabling sat repo failed

        127  general unknown failure (not really mapped yet)

        FIXME - need to redo how we process error codes - very manual
    """
    # pylint: disable=R0911

    options = processCommandline()

    if not cdn_activation:
        writeError("Package spacewalk-backend-cdn has to be installed for using this tool.")
        sys.exit(1)

    # CDN Deactivation
    if options.deactivate:
        cdn_activation.Activation.deactivate()
        # Rotate the manifest to not have any currently used
        if os.path.exists(DEFAULT_RHSM_MANIFEST_LOCATION):
            fileutils.rotateFile(DEFAULT_RHSM_MANIFEST_LOCATION, depth=5)
            os.unlink(DEFAULT_RHSM_MANIFEST_LOCATION)
        return 0

    if options.rhn_cert:
        writeError("Activation with RHN Classic Satellite Certificate is deprecated.\nPlease obtain a Manifest for this"
                   " Satellite version via https://access.redhat.com/knowledge/tools/satcert, "
                   "and re-run this activation tool with option --manifest=MANIFEST-FILE.")
        sys.exit(1)

    if not options.manifest:
        if os.path.exists(DEFAULT_RHSM_MANIFEST_LOCATION):
            options.manifest = DEFAULT_RHSM_MANIFEST_LOCATION
            if options.manifest_info:
                cdn_activation.Activation.manifest_info(DEFAULT_RHSM_MANIFEST_LOCATION)
                return 0
            # Call regeneration API on Candlepin server
            if options.manifest_reconcile_request:
                log(0, "Requesting manifest regeneration...")
                ok = cdn_activation.Activation.refresh_manifest(
                    DEFAULT_RHSM_MANIFEST_LOCATION,
                    http_proxy=options.http_proxy,
                    http_proxy_username=options.http_proxy_username,
                    http_proxy_password=options.http_proxy_password)
                if not ok:
                    writeError("Manifest regeneration failed!")
                    return 17
                log(0, "Manifest regeneration requested.")
                return 0
            # Get new refreshed manifest from Candlepin server
            if options.manifest_download:
                log(0, "Downloading manifest...")
                path = cdn_activation.Activation.download_manifest(
                    DEFAULT_RHSM_MANIFEST_LOCATION,
                    http_proxy=options.http_proxy,
                    http_proxy_username=options.http_proxy_username,
                    http_proxy_password=options.http_proxy_password)
                if not path:
                    writeError("Manifest download failed!")
                    return 16
                if options.manifest_refresh:
                    options.manifest = path
                else:
                    log(0, "New manifest saved to: '%s'" % path)
                    return 0
        else:
            writeError("No currently activated manifest was found. "
                       "Run the activation tool with option --manifest=MANIFEST.")
            return 1
    # Handle RHSM manifest
    try:
        cdn_activate = cdn_activation.Activation(options.manifest)
    except CdnMappingsLoadError, e:
        writeError(e)
        return 15
    except MissingSatelliteCertificateError, e:
        writeError(e)
        return 13
    except IncorrectEntitlementsFileFormatError, e:
        writeError(e)
        return 18

    # general sanity/GPG check
    try:
        validateSatCert(cdn_activate.manifest.get_satellite_certificate())
    except RHNCertGeneralSanityException, e:
        writeError(e)
        return 10

    # expiration check
    if not options.ignore_expiration:
        date = expiredYN(cdn_activate.manifest.get_satellite_certificate())
        if date:
            just_date = date.split(' ')[0]
            writeError(
                'Satellite Certificate appears to have expired: %s' % just_date)
            return 11

    if options.sanity_only:
        return 0

    if not options.disconnected:
        rhsm_uuid = getRHSMUuid()
        if not rhsm_uuid:
            writeError("System not registered to RHSM? No identity found. Please register system to RHSM"
                       " or run activation with --disconnected option.")
            return 90
        try:
            enableSatelliteRepo(cdn_activate.manifest.get_satellite_certificate())
        except EnableSatelliteRepositoryException:
            e = sys.exc_info()[1]
            writeError(e)
            return 91

    try:
        cdn_activate.activate()
    except ManifestValidationError:
        e = sys.exc_info()[1]
        writeError(e)
        return 14

    storeRhsmManifest(options)

    return 0


#-------------------------------------------------------------------------------
if __name__ == "__main__":
    sys.stderr.write('\nWARNING: intended to be wrapped by another executable\n'
                     '           calling program.\n')
    sys.exit(abs(main() or 0))
#===============================================================================
