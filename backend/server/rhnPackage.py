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
        #Insert EPOCH
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
    h.execute(name = pkg[0], ver = pkg[2], rel = pkg[3], arch = pkg[4],
              channel = channel, server_id = server_id)
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


# Old client
# Get a package by [n,v,r,e] and compat arch
# Returns the path to the matching [n,v,r,e] with the max arch compatible w/ours,
def get_package_path_compat_arches(server_id, pkg, server_arch):
    log_debug(3, pkg, server_arch)
    # Ugly but effective
    pkg = map(str, pkg)
    # Build the param dict
    param_dict = {
        'name'      : pkg[0], 
        'ver'       : pkg[1],
        'rel'       : pkg[2], 
        'server_arch': server_arch,
        'server_id' : server_id
    }
    if pkg[3] == '':
        epochStatement = "is NULL"
    else:
        epochStatement = "= :epoch"
        param_dict['epoch'] = pkg[3]

    statement = """
    select
        p.id, p.path path, p.package_arch_id
    from
        rhnPackage p,
        rhnPackageName pn,
        rhnPackageEvr pe,
        rhnServerArch sa,
        rhnChannelPackage cp,
        rhnServerPackageArchCompat spac,
        rhnServerChannel sc
    where
            sc.server_id = :server_id
        and sc.channel_id = cp.channel_id
        and cp.package_id = p.id
        and p.name_id = pn.id
        and pn.name = :name
        and p.evr_id = pe.id
        and pe.version = :ver
        and pe.release = :rel
        and pe.epoch %s
        and p.package_arch_id = spac.package_arch_id
        and spac.server_arch_id = sa.id
        and sa.label = :server_arch
        order by spac.preference
    """ % epochStatement
    h = rhnSQL.prepare(statement)
    apply(h.execute, (), param_dict)
        
    # Because of the ordering, we have to retrieve only the first row in the
    # result set - that should be the best one
    row = h.fetchone_dict()
    if not row:
        log_debug(4, "Error", "Non-existant package requested", server_id, 
            pkg, server_arch)
        raise rhnFault(17, _("Invalid RPM package %s requested") % str(pkg))

    return check_package_file(row['path'], row['id'], str(pkg))

def get_all_package_paths(server_id, pkg_spec, channel):
    """
    return the remote path if available and localpath
    for the requested package with respect to package id
    """
    log_debug(3, server_id, pkg_spec, channel)
    remotepath = None
    #get the path and package
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
    h.execute(name = pkgFilename, channel = channel, server_id = server_id)
    return h.fetchone_dict()


# Old client
# get source package path by [n,v,r,e]
def get_source_package_path_by_nvre(server_id, pkg):
    log_debug(3, pkg)
    name = "%s-%s-%s.src.rpm" % tuple(pkg[:3])
    return get_source_package_path_by_name(server_id, name)


# Old client
# get source package path via package name.
def get_source_package_path_by_name(server_id, packageName):
    log_debug(3, packageName)
    statement = """
    select
            unique ps.path
    from
            rhnSourceRPM sr,
            rhnPackageSource ps,
            rhnPackage p,
            rhnChannelPackage cp,
            rhnServerChannel sc
    where   
                sc.server_id = :server_id
            and sc.channel_id = cp.channel_id
            and cp.package_id = p.id
            and p.source_rpm_id = sr.id
            and ((p.org_id is null and ps.org_id is null) 
                or p.org_id = ps.org_id)
            and sr.name = :name
            and p.source_rpm_id = ps.source_rpm_id
    """
    h = rhnSQL.prepare(statement)
    h.execute(name=packageName, server_id=server_id)
    rs = h.fetchone_dict()
    if not rs:
        log_debug(4, "Error", "Non-existant package requested", server_id, 
            packageName)
        raise rhnFault(17, _("Invalid RPM package %s requested") % packageName)

    filePath = "%s/%s" % (CFG.MOUNT_POINT, rs['path'])
    if not os.access(filePath, os.R_OK):
        # Package not found on the filesystem
        log_error("Package not found", filePath)
        raise rhnFault(17, _("Package not found"))

    # Set the flag for the proxy download accelerator
    rhnFlags.set("Download-Accelerator-Path", rs['path'])
    return filePath

def get_path_for_package(pkg, channel_label):
    log_debug(3, pkg)
    pkg = map(str, pkg)
    params = {'name': pkg[0],
              'ver': pkg[1],
              'rel': pkg[2],
              'epoch': pkg[3],
              'arch': pkg[4],
              'label': channel_label}
    # yum repo has epoch="0" not only when epoch is "0" but also if it's NULL
    if pkg[3] == '0' or pkg[3] == '':
        epochStatement = "(epoch is null or epoch = :epoch)"
    else:
        epochStatement = "epoch = :epoch"
    statement = """
    select p.path, c.label as channel_label
      from rhnPackage p
      join rhnPackageName pn
        on p.name_id = pn.id
      join rhnPackageEVR pe
        on p.evr_id = pe.id
      join rhnPackageArch pa
        on p.package_arch_id = pa.id
      left join rhnChannelPackage cp
        on p.id = cp.package_id
      left join rhnChannel c
        on cp.channel_id = c.id
       and p.org_id = c.org_id
       and c.label = :label
     where pn.name = :name
       and pe.version = :ver
       and pe.release = :rel
       and %s
       and pa.label = :arch
     order by c.label nulls last
    """ % epochStatement
    h = rhnSQL.prepare(statement)
    h.execute(**params)

    ret = h.fetchone_dict()
    if not ret:
        return None, None
    return ret['path'], ret['channel_label']


def _none2emptyString(foo):
    if foo is None:
        return ""
    return str(foo)

if __name__ == '__main__':
    """Test code.
    """
    from spacewalk.common.rhnLog import initLOG
    initLOG("stdout", 1)
    rhnSQL.initDB('rhnuser/rhnuser@webqa')
    print
    # new client
    print get_package_path(1000463284, 'kernel-2.4.2-2.i686.rpm', 'redhat-linux-i386-7.1')
    print get_package_path_compat_arches(1000463284, ['kernel', '2.4.2', '2', ''], 'i686')
    print get_source_package_path(1000463284, 'kernel-2.4.2-2.i686.rpm', 'redhat-linux-i386-7.1')
    
    # old client
    print get_source_package_path_by_nvre(1000463284, ['kernel', '2.4.2', '2', ''])
    print get_source_package_path_by_name(1000463284, 'kernel-2.4.2-2.src.rpm')
    
