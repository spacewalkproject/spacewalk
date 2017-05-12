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

import os
import hashlib
import string
import base64
import posixpath

from spacewalk.common.rhnLib import parseRPMName, parseDEBName
from spacewalk.common.rhnLog import log_debug
from spacewalk.common.rhnException import rhnFault

# architecture work
from rhnMapping import check_package_arch


def computeSignature(*fields):
    # Init the hash
    m = hashlib.new('sha256')
    for i in fields:
        # use str(i) since some of the fields may be non-string
        m.update(str(i))
    return base64.encodestring(m.digest()).rstrip()


# 'n_n-n-v.v.v-r_r.r:e.ARCH.rpm' ---> [n,v,r,e,a]
def parseRPMFilename(pkgFilename):
    """
    IN: Package Name: xxx-yyy-ver.ver.ver-rel.rel_rel:e.ARCH.rpm (string)
    Understood rules:
       o Name can have nearly any char, but end in a - (well seperated by).
         Any character; may include - as well.
       o Version cannot have a -, but ends in one.
       o Release should be an actual number, and can't have any -'s.
       o Release can include the Epoch, e.g.: 2:4 (4 is the epoch)
       o Epoch: Can include anything except a - and the : seperator???
         XXX: Is epoch info above correct?
    OUT: [n,e,v,r, arch].
    """
    if type(pkgFilename) != type(''):
        raise rhnFault(21, str(pkgFilename))  # Invalid arg.

    pkgFilename = os.path.basename(pkgFilename)

    # Check that this is a package NAME (with arch.rpm) and strip
    # that crap off.
    pkg = string.split(pkgFilename, '.')

    dist = string.lower(pkg[-1])

    # 'rpm' at end?
    if dist not in ['rpm', 'deb']:
        raise rhnFault(21, 'neither an rpm nor a deb package name: %s' % pkgFilename)

    # Valid architecture next?
    if check_package_arch(pkg[-2]) is None:
        raise rhnFault(21, 'Incompatible architecture found: %s' % pkg[-2])

    _arch = pkg[-2]

    # Nuke that arch.rpm.
    pkg = string.join(pkg[:-2], '.')

    if dist == "deb":
        ret = list(parseDEBName(pkg))
    else:
        ret = list(parseRPMName(pkg))

    if ret:
        ret.append(_arch)
    return ret

# XXX TBD where to place this function - it has to be accessible from several
# places


def normalize_server_arch(arch):
    log_debug(4, 'server arch', arch)

    if arch is None:
        return ''
    arch = str(arch)
    if '-' in arch:
        # Already normalized
        return arch

    # Fix the arch if need be
    suffix = '-redhat-linux'
    arch = arch + suffix
    return arch


class InvalidAction(Exception):

    """ An error class to signal when we can not handle an action """
    pass


class EmptyAction(Exception):

    """ An error class that signals that we encountered an internal error
        trying to handle an action through no fault of the client
    """
    pass


class ShadowAction(Exception):

    """ An error class for actions that should not get to the client """
    pass


def transpose_to_hash(arr, column_names):
    """ Handy function to transpose an array from row-based to column-based,
        with named columns.
    """
    result = []
    for c in column_names:
        result.append([])

    colnum = len(column_names)
    for r in arr:
        if len(r) != colnum:
            raise Exception(
                "Mismatching number of columns: expected %s, got %s; %s" % (
                    colnum, len(r), r))
        for i in range(len(r)):
            result[i].append(r[i])

    # Now build the hash labeled with the column names
    rh = {}
    for i in range(len(column_names)):
        rh[column_names[i]] = result[i]

    return rh


def get_package_path(nevra, org_id, source=0, prepend="", omit_epoch=None,
                     package_type='rpm', checksum_type=None, checksum=None):
    """ Computes a package path, optionally prepending a prefix
        The path will look like
        <prefix>/<org_id>/checksum[:3]/n/e:v-r/a/checksum/n-v-r.a.rpm if not omit_epoch
        <prefix>/<org_id>/checksum[:3]/n/v-r/a/checksum/n-v-r.a.rpm if omit_epoch
    """
    name, epoch, version, release, pkgarch = nevra

    # dirarch and pkgarch are special-cased for source rpms
    if source:
        dirarch = 'SRPMS'
    else:
        dirarch = pkgarch

    if org_id in ['', None]:
        org = "NULL"
    else:
        org = org_id

    if not omit_epoch and epoch not in [None, '']:
        version = str(epoch) + ':' + version
    # normpath sanitizes the path (removing duplicated / and such)
    template = os.path.normpath(prepend +
                                "/%s/%s/%s/%s-%s/%s/%s/%s-%s-%s.%s.%s")
    return template % (org, checksum[:3], name, version, release, dirarch, checksum,
                       name, nevra[2], release, pkgarch, package_type)


# bug #161989
# It seems that our software was written specifically for rpms in far too many
# ways. Here's a little bit of a hack function that will return the package path
# (as in from get_package_path) but without the filename appended.
# This enables us to append an arbitrary file name that is not restricted to the
# form: name-version-release.arch.type
def get_package_path_without_package_name(nevra, org_id, prepend="",
                                          checksum_type=None, checksum=None):
    """return a package path without the package name appended"""
    return os.path.dirname(get_package_path(nevra, org_id, prepend=prepend,
                                            checksum_type=checksum_type, checksum=checksum))


class CallableObj:

    """ Generic callable object """

    def __init__(self, name, func):
        self.func = func
        self.name = name

    def __call__(self, *args, **kwargs):
        return self.func(self.name, *args, **kwargs)


def make_evr(nvre, source=False):
    """ IN: 'e:name-version-release' or 'name-version-release:e'
        OUT: {'name':name, 'version':version, 'release':release, 'epoch':epoch }
    """
    if ":" in nvre:
        nvr, epoch = nvre.rsplit(":", 1)
    if "-" in epoch:
        nvr, epoch = epoch, nvr
    else:
        nvr, epoch = nvre, ""

    nvr_parts = nvr.rsplit("-", 2)
    if len(nvr_parts) != 3:
        raise rhnFault(err_code=21, err_text="NVRE is missing name, version, or release.")

    result = dict(zip(["name", "version", "release"], nvr_parts))
    result["epoch"] = epoch

    if source and result["release"].endswith(".src"):
        result["release"] = result["release"][:-4]

    return result


def _is_secure_path(path):
    path = posixpath.normpath(path)
    return not (path.startswith('/') or path.startswith('../'))


def get_crash_path(org_id, system_id, crash):
    """For a given org_id, system_id and crash, return relative path to a crash directory."""

    path = os.path.join('systems', org_id, system_id, 'crashes', crash)

    if _is_secure_path(path):
        return path
    else:
        return None


def get_crashfile_path(org_id, system_id, crash, filename):
    """For a given org_id, system_id, crash and filename, return relative path to a crash file."""
    path = os.path.join(get_crash_path(org_id, system_id, crash), filename)

    if _is_secure_path(path):
        return path
    else:
        return None


def get_action_path(org_id, system_id, action_id):
    """For a given org_id, system_id, and action_id, return relative path to a store directory."""
    path = os.path.join('systems', str(org_id), str(system_id), 'actions', str(action_id))
    if _is_secure_path(path):
        return path


def get_actionfile_path(org_id, system_id, action_id, filename):
    """For a given org_id, system_id, action_id, and file, return relative path to a file."""
    path = os.path.join(get_action_path(org_id, system_id, action_id), str(filename))

    if _is_secure_path(path):
        return path
