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


import copy
import optparse
import os
import re
import socket
import StringIO
import string
import sys
import traceback
import time

try:
    import hashlib
except ImportError:
    import md5
    class hashlib:
        @staticmethod
        def new(checksum):
            # Add sha1 if needed.
            if checksum == 'md5':
                return md5.new()
            # if not md5 or sha1, its invalid
            if checksum not in ['md5', 'sha1']:
                raise ValueError, "Incompatible checksum type"

from rhn.common import rhn_mpm

from archive import get_archive_parser

if __debug__: from pprint import pprint

__revision__ = "0.101"
__copyright__ = "Copyright (c) 2005, Red Hat Inc."

# tempfiles that need to be cleaned up -----------------------------------

_temp_files = []

# package dependency parsing regular expressions -------------------------

_dep_regex = re.compile("(?P<code>[PIR]) +(?P<name>[^ \t]+)")
_arch_ver_regex = re.compile("^ *\((?P<arch>[a-zA-Z0-9]+)\)"
                         " *(?P<ver>[^,]+)(,[ \t\S]*REV=(?P<rev>[^,\s]+))?")
_ver_regex = re.compile("(?P<ver>[^,]+)(,[ \t\S]*REV=(?P<rev>[^,\s]+))?")
_illegal_ver_regex = re.compile("[/\\\?\*:\|\"'<>\~\$\(\)[\]{}&=\s,]")

# common solaris abreviations for the months -----------------------------

_months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
]

# mpm header fields ------------------------------------------------------

_solaris_header_fields = {
    # fields required to be overwritten
    'name'          : None,
    'summary'       : None,
    'description'   : None,
    'package_name'  : None,
    'package_group' : 'NoGroup',
    'package_size'  : 0,
    'pkginfo'       : '',
    'pkgmap'        : '',
    'intonly'       : 'N',
    'sigmd5'        : None,
    'arch'          : 'sparc-solaris',
    'version'       : None,
    # fields with acceptable default values
    'epoch'         : None,
    'release'       : 1,
    'provides'      : [],
    'obsoletes'     : [],
    'requires'      : [],
    'conflicts'     : [],
    'package_type'  : 'solaris',
    'vendor'        : '(unknown)',
    'build_time'    : time.strftime("%Y-%m-%d %H:%M:%S"),
    'build_host'    : socket.gethostname(),
    'sigsize'       : 0,
    'payload_format': None,
    'payload_size'  : None,
    'cookie'        : None,
    'license'       : None,
    'sourcerpm'     : None,
    'rpm_version'   : None,
}

# XXX I currently don't know where to glean this information
_valid_patch_types = {
    'general'       : 1,
    'kernel'        : 2,
    'restricted'    : 3,
    'point'         : 4,
    'temporary'     : 5,
    'nonstandard'   : 6,
}

_solaris_patch_header_fields = {
    'summary'       : 'Solaris Patch',
    'package_group' : 'Patches',
    'arch'          : 'solaris-patch',
    'patch_type'    : _valid_patch_types['general'],
    'date'          : None,
    'solaris_rel'   : None,
    'sunos_rel'     : None,
    'target_arch'   : None,
    'readme'        : None,
    'packages'      : [],
}

_solaris_patch_set_header_fields = {
    'summary'       : 'Solaris Patch Cluster',
    'package_group' : 'Patch Clusters',
    'arch'          : 'solaris-patch-cluster',
    'date'          : None,
    'readme'        : None,
    'patches'       : [],
}

# exceptions -------------------------------------------------------------

class MPMInputError(Exception):
    """Exception raised for invalid input for conversion to mpm"""
    pass

class PStampParseException(Exception):
    """Exception raised when the PSTAMP field cannot be parsed."""
    pass

# command line options ---------------------------------------------------

options = None

def _parse_options():

    usage = "usage: solaris2mpm <options> archive1 [archive2 [...]]"
    version = "solaris2mpm %s, %s" % (__revision__, __copyright__)

    parser = optparse.OptionParser(usage=usage, version=version)

    parser.add_option("-?", "--usage", action="store_true", dest="USAGE",
                      help="print program usage and exit")
    parser.add_option("--tempdir", action="store", dest="TEMPDIR",
                      default="/tmp/", help="temporary directory to work from")
    parser.add_option("--select-arch", action="store", dest="ARCH",
                      help="select architecture (i386 or sparc) for multi-arch packages")
    parser.add_option("--no-cleanup", action="store_false", dest="CLEANUP",
                      default=True, help=optparse.SUPPRESS_HELP)

    global options
    options, args = parser.parse_args()

    if options.USAGE:
        print usage
        sys.exit(0)

    # bug 164756: allow an optional temporary directory to work from
    if options.TEMPDIR is not None:
        if not os.path.isdir(options.TEMPDIR):
            print "no such directory: %s" % options.TEMPDIR
            sys.exit(2)
        if not os.access(options.TEMPDIR, os.W_OK):
            print "permission denied: %s" % options.TEMPDIR
            sys.exit(2)

    # sanity check on arch selection
    if options.ARCH and options.ARCH not in ("i386", "sparc"):
        print "unknown arch selection '%s'\n" % options.ARCH
        sys.exit(2)

    if not args:
        print "no archives specified"
        print usage
        sys.exit(1)

    return args

# run --------------------------------------------------------------------

def _run(archives=sys.argv[1:]):

    for archive in archives:

        archive = os.path.abspath(archive)

        try:
            print "Opening archive, this may take a while"
            archive_parser = get_archive_parser(archive, tempdir=options.TEMPDIR)

            # patch set
            if _is_patch_set_archive(archive_parser):
                # create the top-level patch set mpm
                set_mpm = create_patch_set_mpm(archive_parser, archive)
                write_mpm(set_mpm)
                # create the individual patch mpms
                patches, x = archive_parser.list()
                if __debug__: patches.sort()
                for dir in patches:
                    patch_mpm = create_patch_mpm(archive_parser, prefix=dir)
                    write_mpm(patch_mpm)
                    _close_mpm(patch_mpm)

            # single patch
            elif _is_patch_archive(archive_parser):
                patch_mpm = create_patch_mpm(archive_parser, archive=archive)
                write_mpm(patch_mpm)
                _close_mpm(patch_mpm)

            # package
            elif _is_package_archive(archive_parser):
                pkgs, x = archive_parser.list()
                if __debug__: pkgs.sort()
                for dir in pkgs:
                    pkg_mpm = create_pkg_mpm(archive_parser, prefix=dir)
                    write_mpm(pkg_mpm)
                    _close_mpm(pkg_mpm)
                        

            # don't know what the hell the customer is trying to run this on
            else:
                raise MPMInputError("'%s' does not appear to contain Solaris content")

        except Exception, e:
            print "Error creating mpm for %s:" % archive
            if __debug__: traceback.print_exc()
            # print str(e)

        # cleanup as we go
        if options.CLEANUP:
            for file in _temp_files:
                if os.path.isfile(file):
                    os.unlink(file)

# archive tests ----------------------------------------------------------

# This is not a good way to do this, but it will suffice for now.
def _close_mpm(mpm):
    if hasattr(mpm, "payload_stream") and mpm.payload_stream:
        mpm.payload_stream.close()

def _is_patch_set_archive(archive_parser):
    """[internal] Returns true iff the parser contains a patch set archive"""
#    x, files = archive_parser.list()
#    return "install_cluster" in files
    return archive_parser.contains("install_cluster")


def _is_patch_archive(archive_parser):
    """[internal] Returns true iff the parser contains a patch archive"""
    patch_name = os.path.basename(archive_parser._archive_dir) # hack
    readme = "README.%s" % patch_name
#    x, files = archive_parser.list()
#    return readme in files
    return archive_parser.contains(readme)


def _is_package_archive(archive_parser):
    """[internal] Returns true iff the parser contains a patch archive"""
    # NOTE: this functions is just to determine that the content in the archive 
    # is indeed Solaris content. This function witll also return True for 
    # patches and patch cluster, so this test needs to come last!
    return archive_parser.contains("pkginfo")

# mpm object creation ----------------------------------------------------

def create_patch_set_mpm(archive_parser, archive):
    """Create an mpm package from a parser holding a patch set archive"""
#    if __debug__: print "DEBUG: creating patch set mpm for %s" % archive

    # header
    header = copy.deepcopy(_solaris_header_fields)
    header.update(_solaris_patch_set_header_fields)

    # package
    package = rhn_mpm.MPM_Package()

    # basics
    p_name = os.path.basename(archive_parser._archive_dir)
    header['name'] = "patch-cluster-solaris-" + p_name

    readme = archive_parser.read("CLUSTER_README")
    if readme is None:
        readme = archive_parser.read(p_name + ".README")
    assert readme is not None, "Couldn't fine README file for %s" % p_name

    header['readme'] = archive_parser.read("CLUSTER_README")

    # provides fields: date, summary, and description
    dct = parse_cluster_readme(readme)
    header.update(dct)

    # manufactured basics
    header['version'] = header['date'].split()[0].replace("-", "")
    provide_self(header)

    # patch member info
    patch_order = archive_parser.read("patch_order")
    assert patch_order is not None, "ERROR: no patch_order file in patch cluster"

    patches = patch_order.splitlines()
    for i in range(0, len(patches)):
        patch = patches[i]
        name = patch.split('-')
        header['patches'].append({'name': "patch-solaris-" + name[0],
                                 'version': name[1], 'patch_order': i+1})

        # arch info is put into each patch's readme, so parse the first one
        if i == 0:
            patch_readme = archive_parser.read(os.path.join(patch, "README." + patch))
            dct = parse_patch_readme(patch_readme)
            header['arch'] = dct['target_arch'] + '-' + header['arch']

    # payload: creates a dummy file object out of an empty string
#    package.payload_stream = StringIO.StringIO()
    # XXX kludey hack to get the client operations working for patch clusters
    header['package_name'] = os.path.basename(archive)
    header['package_size'] = os.path.getsize(archive)
    package.payload_stream = open(archive)

    # signature and encoding
    header['sigmd5'] = md5sum_for_stream(package.payload_stream)
    package.header = rhn_mpm.MPM_Header(header)

    return package


def create_patch_mpm(archive_parser, prefix="", archive=""):
    """Create an mpm package from a parser holding a patch archive"""
#    if __debug__: print "DEBUG: creating patch mpm for %s" % (prefix or archive)

    # have to have one or the other
    assert prefix or archive

    # header
    header = copy.deepcopy(_solaris_header_fields)
    header.update(_solaris_patch_header_fields)

    # package
    package = rhn_mpm.MPM_Package()

    # basics
    p_name = prefix or os.path.basename(archive_parser._archive_dir)
    p_array = p_name.split("-")
    header['name'] = "patch-solaris-" + p_array[0]
    header['version'] = p_array[1]
    provide_self(header)

    readme = archive_parser.read(os.path.join(prefix, "README.%s" % p_name))
    header['readme'] = readme

    # provides fields: date, summary, description, solaris_rel,
    # sunos_rel, target_arch
    dct = parse_patch_readme(readme)
    header['arch'] = dct['target_arch'] + '-' + header['arch']
    header.update(dct)

    # provides fields: intonly, requires, conflicts, obsoletes
    patchinfo_file = os.path.join(prefix, 'patchinfo')
    if archive_parser.contains(patchinfo_file):
        patchinfo = archive_parser.read(patchinfo_file)
        dct = parse_patchinfo(patchinfo)
        header.update(dct)

    # a patch can patch multiple packages
    pkgs, x = archive_parser.list(prefix)
    if __debug__: pkgs.sort()

    for pkg in pkgs:
        pkginfo_file = os.path.join(prefix, pkg, 'pkginfo')

        # directory doesn't actually correspond to a patch
        if not archive_parser.contains(pkginfo_file):
            continue

        pkginfo = archive_parser.read(pkginfo_file)
        dct = parse_patch_pkginfo(pkginfo)

        if dct['package']:
            header['packages'].append(dct['package'])

        # dependency info is included in the package info
        if dct['obsoletes']:
            header['obsoletes'] += dct['obsoletes']
        if dct['requires']:
            header['requires'] += dct['requires']
        if dct['conflicts']:
            header['conflicts'] += dct['conflicts']

    header['obsoletes'] = _unique_list_of_dicts(header['obsoletes'])
    header['provides'].extend(header['obsoletes'])
    header['requires'] = _unique_list_of_dicts(header['requires'])
    header['conflicts'] = _unique_list_of_dicts(header['conflicts'])

    # payload
    if archive:
#        if __debug__: print "DEBUG: payload file: %s" % archive
        header['package_name'] = os.path.basename(archive)
        header['package_size'] = os.path.getsize(archive)
        package.payload_stream = open(archive)
    else:
        zip_file = archive_parser.zip(prefix)
        _temp_files.append(zip_file)

#        if __debug__: print "DEBUG: payload file: %s" % zip_file
        header['package_name'] = os.path.basename(zip_file)
        header['package_size'] = os.path.getsize(zip_file)
        package.payload_stream = open(zip_file)

    # signature and encoding
    header['sigmd5'] = md5sum_for_stream(package.payload_stream)
    package.header = rhn_mpm.MPM_Header(header)

    return package


def create_pkg_mpm(archive_parser, prefix=""):
    """create a pacakge mpm from an archive parser holding the package
    archive"""
#    if __debug__: print "DEBUG: creating package mpm for %s" % prefix

    # header
    header = copy.deepcopy(_solaris_header_fields)

    # package
    package = rhn_mpm.MPM_Package()

    # basics: provides name, version, release, package_group, arch, etc
    pkginfo_str = archive_parser.read(os.path.join(prefix, "pkginfo"))
    header['pkginfo'] = pkginfo_str
    dct = parse_pkginfo(pkginfo_str)
    header.update(dct)

    header['release'] = compose_pstamp_and_release(header)

    # bug 159323: pkgmap
    header['pkgmap'] = archive_parser.read(os.path.join(prefix, "pkgmap")) or ""

    # dependency info, if it exists
    dep_file = os.path.join(prefix, "install/depend")
    if archive_parser.contains(dep_file):
        dep_str = archive_parser.read(dep_file)
        dct = parse_depends(dep_str)
        header.update(dct)

    # Provides ourself after the header has been updated with the dependency
    # info (if at all).  This will prevent our own provides from being 
    # overwritten.
    provide_self(header)

    # payload
    cpio_file = archive_parser.cpio(prefix)
    _temp_files.append(cpio_file)
    header['package_name'] = os.path.basename(cpio_file)
    header['package_size'] = os.path.getsize(cpio_file)
    package.payload_stream = open(cpio_file)

    # signature and encoding
    header['sigmd5'] = md5sum_for_stream(package.payload_stream)
    package.header = rhn_mpm.MPM_Header(header)

    return package

# pkg mpm creation -------------------------------------------------------

def parse_pkginfo(pkginfo_str):
    """Parse a package pkginfo file and return the name, summary, etc"""

    lines = pkginfo_str.splitlines()
    trans_dict = {"PKG=":       "name",
                  "NAME=":      "summary",
                  "DESC=":      "description",
                  "CATEGORY=":  "package_group",
                  "ARCH=":      "arch",
                  "VERSION=":   "version",
                  "PSTAMP=":    "pstamp",
                  "VENDOR=":    "vendor" }

    parse_dict, x = parser(lines, trans_dict.keys(), "=")

    dct = _translate_dict(trans_dict, parse_dict)

    # Some package names have extensions which are derived from their arch.
    name_ext = _compute_pkg_name_extension(dct['arch'])
    if name_ext:
        dct['name'] += "." + name_ext

    dct['arch'] = _normalize_arch(dct['arch']) + "-solaris"

    # munge the version and release
    version = None
    release = None

    version_match = _ver_regex.match(dct.get('version', ''))
    if version_match:
        #version = _illegal_ver_regex.sub("_", version_match.group("ver")) or "0"
       #if __debug__: print "DEBUG: version is  %s" % version_match.group("ver")
        version = _sanitize_string_version(string.rstrip(version_match.group("ver"))) or "0"
        release = version_match.group("rev")
       #if __debug__: print "DEBUG: release is %s" % version_match.group("rev")

    dct['version'] = version
    if release:
        dct['release'] = release

    return dct

##
# This method adds the pstamp (if one exists) to the release part of the header.
# The end result will be:
#
#    header['release'] <-- release + [ "_PSTAMP_" + pstamp ]
#
def compose_pstamp_and_release(header):
    
    release_part = ''
    if header.has_key('release'):
        release_part = str(header['release'])

    pstamp_part = ''
    if header.has_key('pstamp'):
        delimiter = '_PSTAMP_'
        try:
            pstamp = _extract_pstamp_as_release(header['pstamp'])
            pstamp_part = delimiter + pstamp
        except PStampParseException, pspe:
            # Could not convert the pstamp into a release number.  Just use
            # the raw string.
            pstamp = header['pstamp']
            if pstamp is not None:
                pstamp = _sanitize_string(pstamp)
                pstamp_part = delimiter + pstamp

    return release_part + pstamp_part

def _sanitize_string(str):
    """Replaces all non-alphanumeric chars with an underscore and returns the
       result.
    """
    result = ''
    underscore_mode = 0

    for c in str:
        if not c.isalnum():
            underscore_mode = 1
        else:
            if underscore_mode:
                result += '_'
                underscore_mode = 0
            result += c

    if underscore_mode:
        result += '_'

    return result

def _sanitize_string_version(str):
    """Replaces all none-valid version chars with an underscore and returns the
       result.
    """
    result = ''
    underscore_mode = 0

    for c in str:
       if _illegal_ver_regex.match(c) is not None:
            underscore_mode = 1
       else:
            if underscore_mode:
                result += '_'
                underscore_mode = 0
            result += c

    if underscore_mode:
        result += '_'

    return result

def parse_depends(depends_str):
    """Parse the dependency info for a solaris package"""

    lines = depends_str.splitlines()

    dct = { 'requires': [],
            'conflicts': [],
            'obsoletes': [],
            'provides': [] }

    pkg_dict = { 'name'     : None,
                 'version'  : None,
                 'release'  : 1,
                 'flags'    : 0 }

    for i in range(0, len(lines)):
        line = lines[i]

        match = _dep_regex.match(line)

        if match:
            # bug #170826 blank name means invalid dependency
            name = match.group("name")
            name = name.strip()
            if not name:
                continue

            code = match.group("code")

            pkg = copy.deepcopy(pkg_dict)
            pkg['name'] = name
            pkg['version'], pkg['release'] = _parse_dep_lookahead(i, lines)

            # requires
            if code == "P":
                if pkg['version']:
                    pkg['flags'] = 12
                dct['requires'].append(pkg)

            # conflicts
            elif code == "I":
                if pkg['version']:
                    pkg['flags'] = 8
                dct['conflicts'].append(pkg)

    return dct


def _parse_dep_lookahead(index, lines):
    """Look one line ahead for version and release info while parsing package
    depends"""

    if index+1 < len(lines):
        match = _arch_ver_regex.match(lines[index+1])

        if match:
            version = match.group("ver")
            release = match.group("rev") or "1"

            return (version, release)

    return (None, None)


def provide_self(header):
    """Figure out the info needed to put a package into its provides list"""

    dct = { 'name'      : None,
             'version'   : None,
             'flags'     : 8, }

    dct['name'] = header['name']
    dct['version'] = header['version']

    if not header.has_key('provides'):
        header['provides'] = []
    header['provides'].insert(0, dct)

    if header.has_key('release'):
        header['provides'].insert(1, { 'name' : dct['name'], 'flags' : 8, 'version' : "%s-%s" % (header['version'], header['release'])})

def md5sum_for_stream(data_stream):
    """Calcualte the md5sum for a datastream and return it in a utf8 friendly
    format"""

    md5obj = hashlib.new('md5')
    md5obj.update(data_stream.read())
    data_stream.seek(0)

    return md5obj.hexdigest()

# patch set mpm creation -------------------------------------------------

def parse_cluster_readme(readme_string):
    """Parse the CLUSTER_README file for the summary, date and description"""
#    if __debug__: print "DEBUG: parsing cluster readme"

    lines = readme_string.splitlines()
    trans_dict = { "NAME:":                 "summary",
                   "DATE:":                 "date",
                   "CLUSTER DESCRIPTION":   "description" }

    parse_dict, x = parser(lines, trans_dict.keys(), ":")

    dct = _translate_dict(trans_dict, parse_dict)
    # munge some fields
    dct['date'] = _to_db_timestamp(dct['date'])

    return dct

# patch mpm creation -----------------------------------------------------

def parse_patch_readme(readme_string):
    """Parse the patch readme and return a dict containing fields: date,
    summary, solaris_rel, sunos_rel, and target_arch"""
#    if __debug__: print "DEBUG: parsing patch readme"

    lines = readme_string.splitlines()
    trans_dict = { "Date:":                     "date",
                   "Synopsis:":                 "description",
                   "Topic:":                    "summary",
                   "Solaris Release:":          "solaris_rel",
                   "SunOS Release:":            "sunos_rel",
                   "Relevant Architectures:":   "target_arch" }

    parse_dict, x = parser(lines, trans_dict.keys(), ":")

    dct = _translate_dict(trans_dict, parse_dict)
    # Munge munge munge
    dct['date'] = _to_db_timestamp(dct["date"])
#    dct['target_arch'] = dct['target_arch'].strip().split()[0]
#    dct['target_arch'] = dct['target_arch'].split('.')[0]
    dct['target_arch'] = _normalize_arch(dct['target_arch'])

    return dct


def parse_patchinfo(patchinfo_string):
    """Parse the patchinfo file and return a dictionary containing the
    following: interavcitve-only (intonly), list of requires, conflicts, and
    obsoletes
    """
    lines = patchinfo_string.splitlines()
    trans_dict = { "PATCH_PROPERTIES=": "intonly",
                   "PATCH_REQUIRES=":   "requires",
                   "PATCH_INCOMPAT=":   "conflicts",
                   "PATCH_OBSOLETES=":  "obsoletes" }

    parse_dict, x = parser(lines, trans_dict.keys(), "=")

    dct = _translate_dict(trans_dict, parse_dict)

    if 'intonly' in dct:
        if dct['intonly'].lower().find("interactive") >= 0:
            dct['intonly'] = 'Y'
        else:
            del dct['intonly']

    if "requires" in dct:
        dct['requires']  = patch_list(dct['requires'], sense=12)
    else:
        dct['requires'] = []

    if "conflicts" in dct:
        dct['conflicts'] = patch_list(dct['conflicts'], sense=8)
    else:
        dct['conflicts'] = []

    if "obsoletes" in dct:
        dct['obsoletes'] = patch_list(dct['obsoletes'], sense=10)
    else:
        dct['obsoletes'] = []

    return dct


def parse_patch_pkginfo(pkginfo_string):
    """Parse a pkginfo file from a patch archive and return a list of a package,
    version tuple along with a dict containing the fields: (package, version),
    obsoletes, requires, conflicts
    """
    lines = pkginfo_string.splitlines()
    trans_dict = { "PKG=":              "name",
                   "VERSION=":          "version",
                   "PSTAMP=":           "pstamp",
                   "ARCH=":             "arch",
                   "SUNW_OBSOLETES=":   "obsoletes",
                   "SUNW_REQUIRES=":    "requires",
                   "SUNW_INCOMPAT=":    "conflicts" }

    parse_dict, x = parser(lines, trans_dict.keys(), "=")

    dct = _translate_dict(trans_dict, parse_dict)

    # get the package info for this pkginfo file
    pkg_dict = { 'name'      : None,
                 'epoch'     : None,
                 'version'   : None,
                 'pstamp'    : None,
                 'release'   : '1',
                 'arch'      : None, }

    pkg_dict['name'] = dct['name']
    # Some package names have extensions which are derived from their arch.
    name_ext = _compute_pkg_name_extension(dct['arch'])
    if name_ext:
        pkg_dict['name'] += "." + name_ext
    del dct['name']

    version = None
    release = None

    version_match = _ver_regex.match(dct.get('version', ''))
    if version_match:
        version = version_match.group("ver") or "0"
        release = version_match.group("rev")

    del dct['version']
    pkg_dict['version'] = version
    if release:
        pkg_dict['release'] = release

    pkg_dict['pstamp'] = dct['pstamp']
    pkg_dict['release'] = compose_pstamp_and_release(pkg_dict)

    pkg_dict['arch'] = _normalize_arch(dct['arch']) + "-solaris"
    del dct['arch']

    dct['package'] = pkg_dict

    # munge obsoletes, requires, and conflicts
    obsoletes = dct.get('obsoletes', '')
    dct['obsoletes'] = patch_list(obsoletes, sense=10)

    requires = dct.get('requires', '')
    dct['requires'] = patch_list(requires, sense=12)

    conflicts = dct.get('conflicts', '')
    dct['conflicts'] = patch_list(conflicts, sense=8)

    return dct


def patch_list(patch_str, sense):
    """Compile a list of patches, 'sense' is the rpm sense:
    obsoletes: <= rpm sense -> 10
    requires:  >= rpm sense -> 12
    conflicts: == rpm sense ->  8
    """

    if patch_str.find('(') >= 0:
        print "Unsupported patch list expression:", patch_str
        return []
    
    dct = { 'name'      : None,
             'version'   : None,
             'flags'     : sense }

    patches = []
    l = patch_str.split()

    for p in l:
        # bug 170723, quotes are screwing up the provides and obsolete lists
        # thank you Richard from UBS for the fix ;-)
        p = p.replace('"', '')
        p = p.replace('\'', '')
        patch = p.split('-')

        # bug #170826 blank name means invalid dependency
        if not patch[0]:
            continue

        d = copy.deepcopy(dct)

        d['name'] = "patch-solaris-" + patch[0]
        if len(patch) == 2:
            d['version'] = patch[1]
        else:
            d['version'] = "01"

        patches.append(d)

    return patches


def _unique_list_of_dicts(list_):

    list_.sort()

    i = 0
    while i < len(list_)-1:
        if list_[i] == list_[i+1]:
            del list_[i]
            continue
        i+=1

    return list_


def unique_patches(dict1, dict2, key):
    """traverse lists of patches in 2 dictionaries, and remove and duplicates
    from the list in dict2"""
    # NOTE this is something of a kludge, and a bug that came up after the main
    # implementation because a patch can patch multiple packages and each
    # pkginfo file for each package can list the same requires, conflicts,
    # obsoletes patches, potentially adding the same patch(es) to these lists
    # multiple times

    removals = []

    # simple mxn algorithm, these lists shouldn't be more than a couple of
    # elements in length
    for p1 in dict1[key]:
        for p2 in dict2[key]:
            if p1['name'] == p2['name'] and p1['version'] == p2['version']:
                removals.append(p2)

    for r in removals:
        dict2[key].remove(r)

    return dict2[key]

# write mpm files --------------------------------------------------------

def write_mpm(mpm):
    """Write out the mpm file"""

    if mpm is None: return

#    if __debug__:
#        print "DEBUG: mpm header"
#        pprint(mpm.header.hdr)

    dest = _compute_filename(mpm.header)
    print "Writing %s" % dest

    outstream = open(dest, "w+")
    mpm.write(outstream)
    outstream.close()

# utilities --------------------------------------------------------------

def _translate_dict(trans_dict, parse_dict):
    """Translate parse dict entries according to a translation dict"""

    ret_dict = {}

    for key in parse_dict:
        ret_dict[trans_dict[key]] = parse_dict[key]

    return ret_dict


def _normalize_arch(arch):
    """Normalize the architecture into something usable by rhn"""

    # bug 170722 address multi-arch packages and alternate arch labels
    # munge multi-arch packages
    if re.match(".*,.*", arch):
        arch_list = arch.split(',')
        # use the selected arch
        if options.ARCH:
            arch = options.ARCH
        # default to the first arch in the list
        else:
            arch = arch_list[0].strip()

    # bug 172726 apparently 'all' is considered to be a valid arch
    if re.match(".*all.*", arch):
        if options.ARCH:
            arch = options.ARCH
        # pull the default out of my ass
        else:
            arch = "sparc"

    # fix the arch label
    if arch in ("intel", "i86pc", "i386.i86pc", "i386 i386.i86pc"):
        arch = "i386"

    elif re.match(".*sun4.*", arch, re.IGNORECASE):
        arch = "sparc"

    elif arch == "noarch":
        arch = "noarch"

    elif arch == "sparcv9":
        arch = "sparc"

    # bug 170722, check that the arch is something sane
    if __debug__: assert arch in ("i386", "sparc", "noarch"), "Unknown arch %s" % arch

    return arch

def _compute_pkg_name_extension(arch):
    # First, figure out if the arch contains a '.'.  If not, return an empty
    # string because there is no extension.

    dot_index = arch.find('.')
    if dot_index == -1:
        return None

    # Ok.  The presence of a '.' in the arch means this is an arch-specific 
    # package and we should return the appropriate extension.

    specific_arch = arch[dot_index + 1:]

    # Now let's get a hold of the arch family.  Only sparc and i386 arch
    # families are meaningful here.

    arch_family = _normalize_arch(arch)
    if arch_family not in ["sparc", "i386"]:
        return None

    # For i386, the extension will just be an "i".
    if arch_family == "i386":
        return "i"
    # For sparc, the extension will be the string following 'sun4'.
    elif arch_family == "sparc":
        if specific_arch.startswith("sun4"):
            return specific_arch[len("sun4"):]

    # We shouldn't get here.  Print a warning.

    print "Unknown architecture: " + str(arch)
    return None


def _extract_pstamp_as_release(pstamp):
    """
    This function convert a PSTAMP in the format

        nameYYMMDDHHMMSS

    into a release number of the format

        YYYY.MM.DD.HH.MM

    If the PSTAMP is of an unknown format, PStampParseException is raised.
    Otherwise, the release number is returned.
    """

    if pstamp is None:
        raise PStampParseException("PSTAMP is null")
    
    # Extract the last 12 characters from the pstamp.  This will represent the
    # date and time.
    date_time_stamp = pstamp[-12:]
    if len(date_time_stamp) != 12:
        raise PStampParseException("Date stamp is not 12 characters.")

    # Now break the date/time stamp into a time structure.
    date_time_struct = None
    try:
        date_time_struct = time.strptime(date_time_stamp, "%y%m%d%H%M%S")
    except ValueError, ve:
        raise PStampParseException("Error parsing date/time: %s" % str(ve))

    # Convert the structure into a string in the release number format.
    release_number = time.strftime("%Y.%m.%d.%H.%M", date_time_struct)

    return release_number


def _compute_filename(dct):
    """Compute the file name for an mpm package from its header"""
    return '%s-%s-%s.%s.mpm' % (dct['name'], dct['version'],
                                dct['release'], dct['arch'])


def _to_db_timestamp(s):
    """Convert common Solaris date convention to a unix timestamp"""

    arr = s.split('/', 2)
    if len(arr) != 3:
        return None
    m, d, y = arr

    try:
        m = int(m)

    except ValueError:
        for i in range(len(_months)):
            if m == _months[i]:
                break
        else:
            raise Exception("unknown month %s" % arr[0])
        m = i + 1

    d = int(d)
    y = int(y)
    if y < 30:
        y = 2000 + y
    elif y < 100:
        y = 1900 + y

    return time.strftime("%Y-%m-%d %H:%M:%S", (y, m, d, 0, 0, 0, 0, 1, -1))


def parser(lines, sections, delim):
    """Parse an array of strings looking for key,value pairs where the keys are
    sections of the text defined in the list 'sections' and values are everthing
    appearing after the 'delim' string up to the next section
    Returns a dictionary of 'section -> value' items for all sections found in
    the text. If a section in sections was not found in the text, no
    corresponding key will exist for it in the returned dictionary
    """

    resp = {}
    sect_dict = {}

    section = None
    content = []
    no_section = []
    for line in lines:
        for s in sections:
            if not line.startswith(s):
                continue
            if section:
                # Close the old section
                resp[section] = '\n'.join(content)
                section = None
                content = []
            if s.endswith(delim) or s.endswith('='):
                # Simple name: value line
                resp[s] = _line_val(line, delim)
                break
            # Mark beginning of new section
            section = s
            break
        else:
            # No section
            if section:
                if line.startswith('---'):
                    # ignore it
                    continue
                if line.startswith('###'):
                    # Ignore it
                    continue
                content.append(line)
                continue
            if line.startswith('#'):
                # Comment
                continue

            no_section.append(line)

    if section:
        resp[section] = "\n".join(content).strip()

    return resp, "\n".join(no_section).strip()


# For a Name: Value line, return Value
def _line_val(s, delim):
    return s.split(delim, 1)[1].strip()

# main -------------------------------------------------------------------

def main():
    args = _parse_options()
    return _run(args)

if __name__ == '__main__':
    sys.exit(main() or 0)

