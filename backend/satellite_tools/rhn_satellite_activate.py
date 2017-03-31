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
from spacewalk.common import fileutils
from spacewalk.common.rhnConfig import CFG, initCFG, PRODUCT_NAME
from spacewalk.common.rhnTranslate import _
from spacewalk.server.rhnServer import satellite_cert
# Try to import cdn activation module if available
try:
    from spacewalk.cdn_tools import activation as cdn_activation
    from spacewalk.cdn_tools.manifest import MissingSatelliteCertificateError, ManifestValidationError
    from spacewalk.cdn_tools.common import CdnMappingsLoadError
except ImportError:
    cdn_activation = None
    MissingSatelliteCertificateError = None
    ManifestValidationError = None
    CdnMappingsLoadError = None


DEFAULT_RHSM_MANIFEST_LOCATION = '/etc/sysconfig/rhn/rhsm-manifest.zip'
DEFAULT_WEBAPP_GPG_KEY_RING = "/etc/webapp-keyring.gpg"
DEFAULT_CONFIG_FILE = "/etc/rhn/rhn.conf"
DEFAULT_RHSM_CONFIG_FILE = "/etc/rhsm/rhsm.conf"
SUPPORTED_RHEL_VERSIONS = ['5', '6']


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


def validateSatCert(cert, verbosity=0):
    """ validating (i.e., verifing sanity of) this product.
        I.e., makes sure the product Certificate is a sane certificate
    """

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


def writeRhsmManifest(options, manifest):
    if os.path.exists(DEFAULT_RHSM_MANIFEST_LOCATION):
        fileutils.rotateFile(DEFAULT_RHSM_MANIFEST_LOCATION, depth=5)
    fo = open(DEFAULT_RHSM_MANIFEST_LOCATION, 'w+b')
    fo.write(manifest)
    fo.close()
    options.manifest = DEFAULT_RHSM_MANIFEST_LOCATION


def prepRhsmManifest(options):
    """ minor prepping of the RHSM manifest
        writing to default storage location
    """

    # NOTE: db_* options MUST be populated in /etc/rhn/rhn.conf before this
    #       function is run.
    #       validateSatCert() must have been run prior to this as well (it
    #       populates "/var/log/entitlementCert"
    if options.manifest and options.manifest != DEFAULT_RHSM_MANIFEST_LOCATION:
        try:
            manifest = open(options.manifest, 'rb').read()
        except (IOError, OSError), e:
            msg = _('ERROR: "%s" (specified in commandline)\n'
                    'could not be opened and read:\n%s') % (options.manifest, str(e))
            sys.stderr.write(msg+'\n')
            raise
        try:
            writeRhsmManifest(options, manifest)
        except (IOError, OSError), e:
            msg = _('ERROR: "%s" could not be opened\nand/or written to:\n%s') % (
                DEFAULT_RHSM_MANIFEST_LOCATION, str(e))
            sys.stderr.write(msg+'\n')
            raise


def enableSatelliteRepo(rhn_cert):
    args = ['rpm', '-q', '--qf', '\'%{version} %{arch}\'', '-f', '/etc/redhat-release']
    ret, out, err = fileutils.rhn_popen(args)
    data = out.read().strip("'")
    version, arch = data.split()
    # Read from stdout, strip quotes if any and extract first number
    version = re.search(r'\d+', version).group()

    if version not in SUPPORTED_RHEL_VERSIONS:
        msg = "WARNING: No Satellite repository available for RHEL version: %s.\n" % version
        sys.stderr.write(msg)
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
               "Standard-error: %s\n\n"
               % (msg_, ret, out.read(), err.read()))
        sys.stderr.write(msg)
        raise EnableSatelliteRepositoryException("Enabling of Satellite repository failed. Is there Satellite "
                                                 "subscription attached to this system? Is the version of "
                                                 "RHEL and Satellite certificate correct?")


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
        Option('--cdn-deactivate', action='store_true', help='deactivate CDN-activated Satellite'),
        Option('--disconnected', action='store_true', help="activate locally, not subscribe to remote repository"),
        Option('--download-manifest', action='store_true', help="download new manifest from RHSM"),
        Option('--refresh-manifest', action='store_true', help="regenerate certificates in RHSM for your consumer")
    ]

    parser = OptionParser(option_list=options)
    options, args = parser.parse_args()

    # we take no extra commandline arguments that are not linked to an option
    if args:
        msg = "ERROR: these arguments make no sense in this context (try --help): %s\n" % repr(args)
        raise ValueError(msg)

    initCFG('server.satellite')

    # No need to check further if deactivating
    if options.cdn_deactivate:
        return options

    if options.sanity_only:
        options.disconnected = 1

    if CFG.DISCONNECTED and not options.disconnected:
        sys.stderr.write("""ERROR: Satellite server has been setup to run in disconnected mode.
       Either correct server configuration in /etc/rhn/rhn.conf
       or use --disconnected to activate it locally.
""")
        sys.exit(1)

    options.http_proxy = idn_ascii_to_puny(CFG.HTTP_PROXY)
    options.http_proxy_username = CFG.HTTP_PROXY_USERNAME
    options.http_proxy_password = CFG.HTTP_PROXY_PASSWORD
    if options.verbose:
        print 'HTTP_PROXY: %s' % options.http_proxy
        print 'HTTP_PROXY_USERNAME: %s' % options.http_proxy_username
        print 'HTTP_PROXY_PASSWORD: <password>'

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

        90   not registered to rhsm
        91   enabling sat repo failed

        127  general unknown failure (not really mapped yet)

        FIXME - need to redo how we process error codes - very manual
    """
    # pylint: disable=R0911

    options = processCommandline()

    def writeError(e):
        sys.stderr.write('\nERROR: %s\n' % e)

    if not cdn_activation:
        writeError("Package spacewalk-backend-cdn has to be installed for using this tool.")
        sys.exit(1)

    # CDN Deactivation
    if options.cdn_deactivate:
        cdn_activation.Activation.deactivate()
        return 0

    if options.rhn_cert:
        writeError("Activation with RHN Classic Satellite Certificate is deprecated.\nPlease obtain a Manifest for this"
                   " Satellite version via https://access.redhat.com/knowledge/tools/satcert, "
                   "and re-run this activation tool with option --manifest=MANIFEST-FILE.")
        sys.exit(1)

    if not options.manifest:
        if os.path.exists(DEFAULT_RHSM_MANIFEST_LOCATION):
            # Call refreshment API on Candlepin server
            if options.refresh_manifest:
                print("Refreshing manifest...")
                ok = cdn_activation.Activation.refresh_manifest(
                    DEFAULT_RHSM_MANIFEST_LOCATION,
                    http_proxy=options.http_proxy,
                    http_proxy_username=options.http_proxy_username,
                    http_proxy_password=options.http_proxy_password,
                    verbosity=options.verbose)
                if not ok:
                    writeError("Refreshing manifest failed!")
                    return 17
                print("Manifest refresh requested.")
                return 0
            # Get new refreshed manifest from Candlepin server
            if options.download_manifest:
                print("Downloading manifest...")
                path = cdn_activation.Activation.download_manifest(
                    DEFAULT_RHSM_MANIFEST_LOCATION,
                    http_proxy=options.http_proxy,
                    http_proxy_username=options.http_proxy_username,
                    http_proxy_password=options.http_proxy_password,
                    verbosity=options.verbose)
                if not path:
                    writeError("Download of manifest failed!")
                    return 16
                options.manifest = path
                print("New manifest downloaded to: '%s'" % path)
                return 0
            options.manifest = DEFAULT_RHSM_MANIFEST_LOCATION
        else:
            writeError("Manifest was not provided. Run the activation tool with option --manifest=MANIFEST.")
            return 1
    # Handle RHSM manifest
    try:
        cdn_activate = cdn_activation.Activation(options.manifest, verbosity=options.verbose)
    except CdnMappingsLoadError, e:
        writeError(e)
        return 15
    except MissingSatelliteCertificateError, e:
        writeError(e)
        return 13

    # general sanity/GPG check
    try:
        validateSatCert(cdn_activate.manifest.get_satellite_certificate(), options.verbose)
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
            writeError("Server not registered to RHSM? No identity found.")
            return 90
        try:
            enableSatelliteRepo(cdn_activate.manifest.get_satellite_certificate())
        except EnableSatelliteRepositoryException:
            e = sys.exc_info()[1]
            writeError(e)
            return 91

    prepRhsmManifest(options)

    try:
        cdn_activate.activate()
    except ManifestValidationError:
        e = sys.exc_info()[1]
        writeError(e)
        return 14

    return 0


#-------------------------------------------------------------------------------
if __name__ == "__main__":
    sys.stderr.write('\nWARNING: intended to be wrapped by another executable\n'
                     '           calling program.\n')
    sys.exit(abs(main() or 0))
#===============================================================================
