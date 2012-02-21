#
# Copyright (c) 2008--2011 Red Hat, Inc.
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
import re
import hashlib
import string
import base64

from spacewalk.common.rhnLog import log_debug
from spacewalk.common.rhnException import rhnFault

# architecture work
from rhnMapping import check_package_arch

def computeSignature(*fields):
    # Init the hash
    m = hashlib.new('md5')
    for i in fields:
        # use str(i) since some of the fields may be non-string
        m.update(str(i))
    return base64.encodestring(m.digest()).rstrip()


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
        return apply(self.func, (self.name, ) + args, kwargs)

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
        raise rhnFault(err_code = 21, err_text = \
                       "NVRE is missing name, version, or release.")

    result = dict(zip(["name", "version", "release"], nvr_parts))
    result["epoch"] = epoch

    if source and result["release"].endswith(".src"):
        result["release"] = result["release"][:-4]

    return result
