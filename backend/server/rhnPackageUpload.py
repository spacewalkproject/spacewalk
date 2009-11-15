#!/usr/bin/python
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
# $Id$

import os
import tempfile

from common import CFG, log_debug, rhnFault, rhn_mpm, rhnLib, UserDictCase
from common.rhn_rpm import get_header_byte_range

from server import rhnSQL
from server.importlib import importLib, userAuth, mpmSource, backendOracle, \
    packageImport, errataCache
from server.rhnLib import get_package_path, \
    get_package_path_without_package_name
from server.rhnServer import server_packages


def source_match(v1, v2):
    """ returns true if both parameters are true, false otherwise """
    if v1 and v2:
        return 1
    if not v1 and not v2:
        return 1
    return 0


def write_temp_file(req, buffer_size):
    """ Write request to temporary file (write max. buffer_size at once).
        Returns the file object.
    """ 
    t = tempfile.TemporaryFile()
    while 1:
        buf = req.read(buffer_size)
        if not buf:
            break
        t.write(buf)
    t.seek(0, 0)
    return t

def authenticate(username, password, channels=[], null_org=None, force=None):
    log_debug(4, username, force)
    authobj = userAuth.UserAuth()
    authobj.auth(username, password)
    return _authenticate(authobj, channels, null_org, force)

def authenticate_session(session_string, channels=[], null_org=None, force=None):
    log_debug(4, session_string, force)
    authobj = userAuth.UserAuth()
    authobj.auth_session(session_string)
    return _authenticate(authobj, channels, null_org, force)

def _authenticate(authobj, channels, null_org, force):
    params = {}
    if null_org:
        params['orgId'] = ''

        # XXX don't allow superusers to force stuff
        if force:
            raise rhnFault(4, "Cannot force push nullorg content", explain=0)


    if force and not CFG.FORCE_PACKAGE_UPLOAD:
        raise rhnFault(55, "Package Upload Failed", explain=0)

    authobj.authzOrg(params)
    if channels:
        authobj.authzChannels(channels)

    if null_org:
        org_id = None
    else:
        org_id = authobj.org_id

    return org_id, force

def relative_path_from_header(header, org_id, checksum=(None,None)):
    nevra = importLib.get_nevra(header)
    if header.is_source:
        #4/18/05 wregglej. if 1051 is in the header's keys, then it's a nosrc package.
        if 1051 in header.keys():
            nevra[4] = 'nosrc'
        else:
            nevra[4] = 'src'

    log_debug(4, "NEVRA", nevra)

    # if the package isn't an rpm and the package name is spelled out in the
    # header, use it
    if header.packaging == "mpm" and "package_name" in header.keys() and \
       header["package_name"]:

        rel_path = relative_path_from_nevra_without_package_name(nevra, org_id,
                                                            checksum)
        return os.path.join(rel_path, header["package_name"])

    return relative_path_from_nevra(nevra,
        org_id, header.packaging, checksum)

def relative_path_from_nevra(nevra, org_id, package_type=None, checksum=None):
    #4/18/05 wregglej. if 1051 is in the header's keys, then it's a nosrc package.
    if nevra[4] == 'src' or nevra[4] == 'nosrc':
        is_source = 1
    else:
        is_source = 0
    log_debug(4, nevra, is_source)
    return get_package_path(nevra, org_id=org_id, source=is_source, 
        prepend=CFG.PREPENDED_DIR, omit_epoch=1, package_type=package_type,
        checksum=checksum)

# bug #161989 - get the relative path from the nevra, but omit the package name
def relative_path_from_nevra_without_package_name(nevra, org_id, checksum):
    log_debug(4, nevra, "no package name")
    return get_package_path_without_package_name(nevra, org_id,
                                     prepend=CFG.PREPENDED_DIR, checksum=checksum)

def push_package(header, payload_stream, md5sum, org_id=None, force=None,
    header_start=None, header_end=None, channels=[], relative_path=None):
    """Uploads an RPM package
    """

    # Get the payload size
    log_debug(3, CFG.MOUNT_POINT, relative_path, force, org_id)
    payload_stream.seek(0, 2)
    payload_size = payload_stream.tell()
    payload_stream.seek(0, 0)

    # First write the package to the filesystem to final location
    try:
        importLib.copy_package(payload_stream.fileno(), basedir=CFG.MOUNT_POINT,
            relpath=relative_path, md5sum=md5sum, force=1)
    except OSError, e:
        raise rhnFault(50, "Package upload failed: %s" % e)
    except importLib.FileConflictError:
        raise rhnFault(50, "File already exists")

    pkg = mpmSource.create_package(header, size=payload_size, md5sum=md5sum,
        relpath=relative_path, org_id=org_id, header_start=header_start,
        header_end=header_end, channels=channels)

    batch = importLib.Collection()
    batch.append(pkg)

    backend = backendOracle.OracleBackend()
    backend.init()

    if force:
        upload_force = 4
    else:
        upload_force = 0
    importer = packageImport.packageImporter(batch, backend,
        source=header.is_source, caller="server.app.uploadPackage")
    importer.setUploadForce(upload_force)
    importer.setIgnoreUploaded(1)
    importer.run()

    package = batch[0]
    log_debug(5, "Package diff", package.diff)

    if package.diff and not force and package.diff.level > 1:
        # Packages too different; bail out
        log_debug(1, "Packages too different", package.toDict(),
            "Level:", package.diff.level)
        pdict = package.toDict()
        orig_path = package['path']
        orig_path = os.path.join(CFG.MOUNT_POINT, orig_path)
        log_debug(4, "Original package", orig_path)

        # Determine the type of packaging that was used to create the package.
        packaging = 'rpm'
        if hasattr(header, 'packaging'):
            packaging = header.packaging

        # MPMs do not store their headers on disk, so we must avoid performing
        # operations which rely on information only contained in the headers
        # (such as header signatures).
        if os.path.exists(orig_path) and packaging != 'mpm':
            oh = rhn_mpm.get_package_header(orig_path)
            _diff_header_sigs(header, oh, pdict['diff']['diff'])

        return pdict, package.diff.level


    # Remove any pending scheduled file deletion for this package
    h = rhnSQL.prepare("""
        delete from rhnPackageFileDeleteQueue where path = :path
    """)
    h.execute(path=relative_path)

    if package.diff and not force and package.diff.level:
        #No need to copy it - just the path is modified
        #pkilambi bug#180347
        #case 1:check if the path exists in the db and also on the file system.
        #if it does then no need to copy
        #case2: file exists on file system but path not in db.then add the 
        #realtive path in the db based on md5sum of the pkg
        #case3: if no file on file system but path exists.then we write the
        #file to file system
        #case4:no file exists on FS and no path in db .then we write both.
        orig_path = package['path']
        orig_path = os.path.join(CFG.MOUNT_POINT, orig_path)
        log_debug(3, "Original package", orig_path)
        
        #check included to query for source and binary rpms
        h_path_sql = """
            select ps.path path
                from %s ps,
                     rhnChecksum c
            where
                c.checksum = :md5sum
            and ps.checksum_id = c.id
            and (ps.org_id = :org_id or
                 (ps.org_id is null and :org_id is null)
                )
            """
        if header.is_source:
            h_package_table = 'rhnPackageSource'
        else:
            h_package_table = 'rhnPackage'
        h_path = rhnSQL.prepare(h_path_sql % h_package_table)
        h_path.execute(md5sum=md5sum, org_id = org_id)

        rs_path = h_path.fetchall_dict()
        path_dict = {}
        if rs_path:
            path_dict = rs_path[0]

        if os.path.exists(orig_path) and path_dict['path']:
            return {}, 0
        elif not path_dict['path']:
            h_upd = rhnSQL.prepare("""
            update rhnpackage
               set path = :path
            where checksum_id = (
                        select id from rhnChecksum where checksum = :md5sum)
            """)
            h_upd.execute(path=relative_path, md5sum=md5sum)

    # commit the transactions
    rhnSQL.commit()
    if not header.is_source:
        # Process Package Key information
        server_packages.processPackageKeyAssociations(header, md5sum)

    if not header.is_source:
        errataCache.schedule_errata_cache_update(importer.affected_channels)
                        
    log_debug(2, "Returning")
    return {}, 0

def _diff_header_sigs(h1, h2, diff_list):
    # XXX This can be far more complicated if we take into account that
    # signatures can be different
    h1sigs = h1.signatures
    h2sigs = h2.signatures
    if not h1sigs and not h2sigs:
        # No differences here
        return
    h1_key_ids = _key_ids(h1sigs)
    h2_key_ids = _key_ids(h2sigs)

    diff_list.append(['sig_key_id', h1_key_ids, h2_key_ids])
    
def _key_ids(sigs):
    h = {}
    for sig in sigs:
        h[sig['key_id']] = None
    
    l = h.keys()
    l.sort()
    return l

def load_package(package_stream):
    try:
        header, payload_stream = rhn_mpm.load(file=package_stream)
    except rhn_mpm.InvalidPackageError, e:
        raise rhnFault(50, "Unable to load package", explain=0)

    payload_stream.seek(0, 0)
    if header.packaging == "mpm":
        header.header_start = header.header_end = 0
        (header_start, header_end) = (0, 0)
    else:
        (header_start, header_end) = get_header_byte_range(payload_stream)
        payload_stream.seek(0,0)

    return header, payload_stream, header_start, header_end

class AlreadyUploadedError(Exception):
    pass

class PackageConflictError(Exception):
    pass

def check_package_exists(package_path, package_md5sum, force=0):
    if not os.path.exists(package_path):
        return
    # File exists, same MD5sum?
    md5sum = rhnLib.getFileMD5(package_path)
    if package_md5sum == md5sum and not force:
        raise AlreadyUploadedError(package_path)
    if force:
        return
    raise PackageConflictError(package_path, md5sum)

