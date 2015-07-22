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

from types import ListType

from spacewalk.common import rhnFlags
from spacewalk.common.rhnLog import log_debug, log_error
from spacewalk.common.rhnConfig import CFG
from spacewalk.common.rhnException import rhnFault
from spacewalk.common.rhnTranslate import _
from spacewalk.server import rhnSQL
from rhnLib import parseRPMFilename


#
# Functions that deal with the database
#

# New client
# Returns a package path, given a server_id, package filename and channel label
def get_package_path(server_id, pkg_spec, channel):
    log_debug(3, server_id, pkg_spec, channel)
    if isinstance(pkg_spec, ListType):
        pkg = pkg_spec[:4]
        # Insert EPOCH
        pkg.insert(1, None)
    else:
        pkg = parseRPMFilename(pkg_spec)
        if pkg is None:
            log_debug(4, "Error", "Requested weird package", pkg_spec)
            raise rhnFault(17, _("Invalid RPM package %s requested") % pkg_spec)

    statement = """
        select  p.id, p.path path, pe.epoch epoch
        from
                rhnPackageArch pa,
                rhnChannelPackage cp,
                rhnPackage p,
                rhnPackageEVR pe,
                rhnServerChannel sc,
                rhnPackageName pn,
                rhnChannel c
        where 1=1
            and c.label = :channel
            and pn.name = :name
            and sc.server_id = :server_id
            and pe.version = :ver
            and pe.release = :rel
            and c.id = sc.channel_id
            and c.id = cp.channel_id
            and pa.label = :arch
            and pn.id = p.name_id
            and p.id = cp.package_id
            and p.evr_id = pe.id
            and sc.channel_id = cp.channel_id
            and p.package_arch_id = pa.id
    """
    h = rhnSQL.prepare(statement)
    pkg = map(str, pkg)
    h.execute(name=pkg[0], ver=pkg[2], rel=pkg[3], arch=pkg[4],
              channel=channel, server_id=server_id)
    rs = h.fetchall_dict()
    if not rs:
        log_debug(4, "Error", "Non-existant package requested", server_id,
                  pkg_spec, channel)
        raise rhnFault(17, _("Invalid RPM package %s requested") % pkg_spec)
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

    # Set the flag for the proxy download accelerator
    rhnFlags.set("Download-Accelerator-Path", max_row['path'])
    return check_package_file(max_row['path'], max_row['id'], pkg_spec), max_row['id']


def check_package_file(rel_path, logpkg, raisepkg):
    if rel_path is None:
        log_error("Package path null for package id", logpkg)
        raise rhnFault(17, _("Invalid RPM package %s requested") % raisepkg)
    filePath = "%s/%s" % (CFG.MOUNT_POINT, rel_path)
    if not os.access(filePath, os.R_OK):
        # Package not found on the filesystem
        log_error("Package not found", filePath)
        raise rhnFault(17, _("Package not found"))

    return filePath


def unlink_package_file(path):
    try:
        os.unlink(path)
    except OSError:
        log_debug(1,  "Error unlinking %s;" % path)
    dirname = os.path.dirname(path)
    base_dirs = (CFG.MOUNT_POINT + '/' + CFG.PREPENDED_DIR, CFG.MOUNT_POINT)
    while dirname not in base_dirs:
        try:
            os.rmdir(dirname)
        except OSError, e:
            if e.errno == 39:  # OSError: [Errno 39] Directory not empty
                break
            else:
                raise
        dirname = os.path.dirname(dirname)


def get_all_package_paths(server_id, pkg_spec, channel):
    """
    return the remote path if available and localpath
    for the requested package with respect to package id
    """
    log_debug(3, server_id, pkg_spec, channel)
    remotepath = None
    # get the path and package
    localpath, pkg_id = get_package_path(server_id, pkg_spec, channel)

    return remotepath, localpath

# New client
# Returns the path to a source rpm


def get_source_package_path(server_id, pkgFilename, channel):
    log_debug(3, server_id, pkgFilename, channel)
    rs = __query_source_package_path_by_name(server_id, pkgFilename, channel)
    if rs is None:
        log_debug(4, "Error", "Non-existant package requested", server_id,
                  pkgFilename, channel)
        raise rhnFault(17, _("Invalid RPM package %s requested") % pkgFilename)

    # Set the flag for the proxy download accelerator
    rhnFlags.set("Download-Accelerator-Path", rs['path'])
    return check_package_file(rs['path'], pkgFilename, pkgFilename)


# 0 or 1: is this source in this channel?
def package_source_in_channel(server_id, pkgFilename, channel):
    log_debug(3, server_id, pkgFilename, channel)
    rs = __query_source_package_path_by_name(server_id, pkgFilename, channel)
    if rs is None:
        return 0
    return 1


# The query used both in get_source_package_path and package_source_in_channel
def __query_source_package_path_by_name(server_id, pkgFilename, channel):
    statement = """
    select
            unique ps.path
    from
            rhnSourceRPM sr,
            rhnPackageSource ps,
            rhnPackage p,
            rhnChannelPackage cp,
            rhnChannel c,
            rhnServerChannel sc
    where
                sc.server_id = :server_id
            and sc.channel_id = cp.channel_id
            and cp.channel_id = c.id
            and c.label = :channel
            and cp.package_id = p.id
            and p.source_rpm_id = sr.id
            and sr.name = :name
            and p.source_rpm_id = ps.source_rpm_id
            and ((p.org_id is null and ps.org_id is null)
                or p.org_id = ps.org_id)
    """
    h = rhnSQL.prepare(statement)
    h.execute(name=pkgFilename, channel=channel, server_id=server_id)
    return h.fetchone_dict()


def get_info_for_package(pkg, channel_id, org_id):
    log_debug(3, pkg)
    pkg = map(str, pkg)
    params = {'name': pkg[0],
              'ver': pkg[1],
              'rel': pkg[2],
              'epoch': pkg[3],
              'arch': pkg[4],
              'channel_id': channel_id,
              'org_id': org_id}
    # yum repo has epoch="0" not only when epoch is "0" but also if it's NULL
    if pkg[3] == '0' or pkg[3] == '' or pkg[3]==None:
        epochStatement = "(epoch is null or epoch = :epoch)"
    else:
        epochStatement = "epoch = :epoch"
    if params['org_id']:
        orgStatement = "org_id = :org_id"
    else:
        orgStatement = "org_id is null"

    statement = """
    select p.path, cp.channel_id,
           cv.checksum_type, cv.checksum
      from rhnPackage p
      join rhnPackageName pn
        on p.name_id = pn.id
      join rhnPackageEVR pe
        on p.evr_id = pe.id
      join rhnPackageArch pa
        on p.package_arch_id = pa.id
      left join rhnChannelPackage cp
        on p.id = cp.package_id
       and cp.channel_id = :channel_id
      join rhnChecksumView cv
        on p.checksum_id = cv.id
     where pn.name = :name
       and pe.version = :ver
       and pe.release = :rel
       and %s
       and pa.label = :arch
       and %s
     order by cp.channel_id nulls last
    """ % (epochStatement, orgStatement)

    h = rhnSQL.prepare(statement)
    h.execute(**params)

    ret = h.fetchone_dict()
    if not ret:
        return {'path':          None,
                'channel_id': None,
                'checksum_type': None,
                'checksum':      None,
                }
    return ret


def _none2emptyString(foo):
    if foo is None:
        return ""
    return str(foo)

if __name__ == '__main__':
    """Test code.
    """
    from spacewalk.common.rhnLog import initLOG
    initLOG("stdout", 1)
    rhnSQL.initDB()
    print
    # new client
    print get_package_path(1000463284, 'kernel-2.4.2-2.i686.rpm', 'redhat-linux-i386-7.1')
    print get_source_package_path(1000463284, 'kernel-2.4.2-2.i686.rpm', 'redhat-linux-i386-7.1')
