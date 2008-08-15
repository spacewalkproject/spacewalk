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
# Overloads/appends server.rhnPackage
# Satellite specific package routines.

import os

from common import log_debug, log_error, rhnFault, CFG
from common.rhnTranslate import _

from server import rhnSQL, rhnLib
from server.rhnPackage import _none2emptyString, \
			get_package_remote_location_path

class InvalidPackageError(Exception):
    # Requested package does not exist
    pass

class NullPathPackageError(Exception):
    # Path is null for this package
    pass

class MissingPackageError(Exception):
    # No path info exists for this package
    pass

# package retrieval from a satellite
def get_package_path_by_nvrea(server, pkg, channel):
    # pkg is nvrea
    server_id = server.getid()
    log_debug(3, server_id, pkg, channel)

    pkg = map(str, pkg)

    param_dict = {
        'name'      : pkg[0], 
        'ver'       : pkg[1],
        'rel'       : pkg[2], 
        'epoch'     : pkg[3],
        'arch'      : pkg[4],
        'server_id' : server_id,
        'channel'   : channel,
    }

    statement = """
        select distinct 
               p.id, p.path
          from rhnPackage p,
               rhnChannelPackage cp,
               (
                select channel_family_id
                  from rhnSatelliteChannelFamily
                 where server_id = :server_id
                union
                select channel_family_id
                  from rhnPublicChannelFamily
               ) scf,
               rhnChannelFamilyMembers cfm,
               rhnChannel c,
               rhnPackageArch pa
         where scf.channel_family_id = cfm.channel_family_id
           and cfm.channel_id = c.id
           and c.label = :channel
           and cp.channel_id = c.id
           and cp.package_id = p.id
           and p.name_id = LOOKUP_PACKAGE_NAME(:name)
           and p.evr_id = LOOKUP_EVR(:epoch, :ver, :rel)
           and p.package_arch_id = pa.id
           and pa.label = :arch
    """

    h = rhnSQL.prepare(statement)
    apply(h.execute, (), param_dict)

    try:
        return _get_path_from_cursor(h)
    except InvalidPackageError:
        log_debug(4, "Error", "Non-existant package requested", server_id, pkg)
        raise rhnFault(17, _("Invalid RPM package %s requested") % str(pkg))
    except NullPathPackageError, e:
        package_id = e[0]
        log_error("Package path null for package id", package_id)
        raise rhnFault(17, _("Invalid RPM package %s requested") % str(pkg))
    except MissingPackageError, e:
        filePath = e[0]
        log_error("Package not found", filePath)
        raise rhnFault(17, _("Package not found"))

# This query is similar to the one aove, except that we have already
# authorized this channel (so no need for server_id)
_query_get_package_path_by_nvra = rhnSQL.Statement("""
        select distinct 
               p.id, p.path
          from rhnPackage p,
               rhnChannelPackage cp,
               rhnChannel c,
               rhnPackageArch pa
         where c.label = :channel
           and cp.channel_id = c.id
           and cp.package_id = p.id
           and p.name_id = LOOKUP_PACKAGE_NAME(:name)
           and p.evr_id = LOOKUP_EVR(:epoch, :version, :release)
           and p.package_arch_id = pa.id
           and pa.label = :arch
""")

def get_package_path_by_filename(server_id, fileName, channel):
    log_debug(3, fileName, channel)
    fileName = str(fileName)
    n, v, r, e, a = rhnLib.parseRPMFilename(fileName)

    h = rhnSQL.prepare(_query_get_package_path_by_nvra)
    h.execute(name=n, version=v, release=r, epoch=e, arch=a, channel=channel)
    try:
        return _get_path_from_cursor(h)
    except InvalidPackageError:
        log_debug(4, "Error", "Non-existant package requested", server_id,
            fileName)
        raise rhnFault(17, _("Invalid RPM package %s requested") % fileName)
    except NullPathPackageError, e:
        package_id = e[0]
        log_error("Package path null for package id", package_id)
        raise rhnFault(17, _("Invalid RPM package %s requested") % fileName)
    except MissingPackageError, e:
        filePath = e[0]
        log_error("Package not found", filePath)
        raise rhnFault(17, _("Package not found"))

def get_all_paths_by_filename(server_id, fileName, channel):
    """
    returns the remote host edge network url+path and localpath for
    the available pkg
    """
    log_debug(3, server_id, fileName, channel)

    #get the rhn path and pkg Id the usual way.This way we only need to run this
    #once and obtain both paths,
    localpath, pkg_id = get_package_path_by_filename(server_id, fileName, channel)
    #check if the pkg has a remote path available.    
    remotepath = get_package_remote_location_path(pkg_id)
    
    return remotepath, localpath
    
def _get_path_from_cursor(h):
    """ Function shared between other retrieval functions """
    rs = h.fetchall_dict()
    if not rs:
        raise InvalidPackageError

    # It is unlikely for this query to return more than one row, 
    # but it is possible
    # (having two packages with the same n, v, r, a and different epoch in
    # the same channel is prohibited by the RPM naming scheme; but extra
    # care won't hurt)
    max_row = rs[0]
    for each in rs[1:]:
        # Compare the epoch as string
        if _none2emptyString(each['epoch']) > _none2emptyString(max_row['epoch']):
            max_row = each

    if max_row['path'] is None:

        raise NullPathPackageError(max_row['id'])
    filePath = "%s/%s" % (CFG.MOUNT_POINT, max_row['path'])
    pkgId = max_row['id']
    if not os.access(filePath, os.R_OK):
        # Package not found on the filesystem
        raise MissingPackageError(filePath)
    return filePath, pkgId
