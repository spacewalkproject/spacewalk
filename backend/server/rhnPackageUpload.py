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
# $Id$

import os
import sys
import tempfile

from spacewalk.common import rhn_mpm, rhn_deb, rhn_pkg
from spacewalk.common.rhnLog import log_debug
from spacewalk.common.rhnConfig import CFG
from spacewalk.common.rhnException import rhnFault
from spacewalk.common.rhn_rpm import get_header_byte_range

from spacewalk.server import rhnSQL
from spacewalk.server.importlib.backendOracle import SQLBackend
from spacewalk.server.importlib import importLib, userAuth, mpmSource, \
    packageImport, errataCache
from spacewalk.server.rhnLib import get_package_path, \
    get_package_path_without_package_name
from spacewalk.server.rhnServer import server_packages


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

def relative_path_from_header(header, org_id, checksum_type=None, checksum=None):
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
                                                            checksum_type, checksum)
        return os.path.join(rel_path, header["package_name"])

    return relative_path_from_nevra(nevra,
        org_id, header.packaging, checksum_type, checksum)

def relative_path_from_nevra(nevra, org_id, package_type=None, checksum_type=None, checksum=None):
    #4/18/05 wregglej. if 1051 is in the header's keys, then it's a nosrc package.
    if nevra[4] == 'src' or nevra[4] == 'nosrc':
        is_source = 1
    else:
        is_source = 0
    log_debug(4, nevra, is_source)
    return get_package_path(nevra, org_id=org_id, source=is_source, 
        prepend=CFG.PREPENDED_DIR, omit_epoch=None, package_type=package_type,
        checksum_type=checksum_type, checksum=checksum)

# bug #161989 - get the relative path from the nevra, but omit the package name
def relative_path_from_nevra_without_package_name(nevra, org_id, checksum_type, checksum):
    log_debug(4, nevra, "no package name")
    return get_package_path_without_package_name(nevra, org_id,
                                     CFG.PREPENDED_DIR, checksum_type, checksum)

def push_package(a_pkg, org_id=None, force=None, channels=[], relative_path=None):
    """Uploads a package"""

    # First write the package to the filesystem to final location
    try:
        importLib.move_package(a_pkg.payload_stream.name, basedir=CFG.MOUNT_POINT,
            relpath=relative_path,
            checksum_type=a_pkg.checksum_type, checksum=a_pkg.checksum, force=1)
    except OSError, e:
        raise rhnFault(50, "Package upload failed: %s" % e), None, sys.exc_info()[2]
    except importLib.FileConflictError:
        raise rhnFault(50, "File already exists"), None, sys.exc_info()[2]
    except:
        raise rhnFault(50, "File error"), None, sys.exc_info()[2]

    pkg = mpmSource.create_package(a_pkg.header, size=a_pkg.payload_size,
        checksum_type=a_pkg.checksum_type, checksum=a_pkg.checksum,
        relpath=relative_path, org_id=org_id, header_start=a_pkg.header_start,
        header_end=a_pkg.header_end, channels=channels)

    batch = importLib.Collection()
    batch.append(pkg)

    backend = SQLBackend()

    if force:
        upload_force = 4
    else:
        upload_force = 0
    importer = packageImport.packageImporter(batch, backend,
        source=a_pkg.header.is_source, caller="server.app.uploadPackage")
    importer.setUploadForce(upload_force)
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

        # MPMs do not store their headers on disk, so we must avoid performing
        # operations which rely on information only contained in the headers
        # (such as header signatures).
        if os.path.exists(orig_path) and a_pkg.header.packaging != 'mpm':
            oh = rhn_pkg.get_package_header(orig_path)
            _diff_header_sigs(a_pkg.header, oh, pdict['diff']['diff'])

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
        #realtive path in the db based on checksum of the pkg
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
                     rhnChecksumView c
            where
                c.checksum = :csum
            and c.checksum_type = :ctype
            and ps.checksum_id = c.id
            and (ps.org_id = :org_id or
                 (ps.org_id is null and :org_id is null)
                )
            """
        if a_pkg.header.is_source:
            h_package_table = 'rhnPackageSource'
        else:
            h_package_table = 'rhnPackage'
        h_path = rhnSQL.prepare(h_path_sql % h_package_table)
        h_path.execute(ctype=a_pkg.checksum_type, csum=a_pkg.checksum, org_id = org_id)

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
                        select id from rhnChecksumView c
                                 where c.checksum = :csum
                                   and c.checksum_type = :ctype)
            """)
            h_upd.execute(path=relative_path, ctype=a_pkg.checksum_type,
                                              csum=a_pkg.checksum)

    # commit the transactions
    rhnSQL.commit()
    if not a_pkg.header.is_source:
        # Process Package Key information
        server_packages.processPackageKeyAssociations(a_pkg.header,
                                        a_pkg.checksum_type, a_pkg.checksum)

    if not a_pkg.header.is_source:
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

def save_uploaded_package(stream, nevra, org_id, packaging,
                          checksum_type=None, checksum=None):
    a_pkg = rhn_pkg.package_from_stream(stream, packaging=packaging)
    a_pkg.read_header()

    temp_dir = os.path.join(CFG.MOUNT_POINT, CFG.PREPENDED_DIR, org_id, 'stage')
    if not os.path.isdir(temp_dir):
        os.makedirs(temp_dir)
    temp_stream = tempfile.NamedTemporaryFile(dir = temp_dir,
                        prefix = '-'.join((nevra[0], nevra[2], nevra[3], nevra[4])))
    a_pkg.save_payload(temp_stream)

    if checksum_type and checksum:
        # verify checksum
        if not (checksum_type == a_pkg.checksum_type
                and checksum == a_pkg.checksum):
            log_debug(1, "Mismatching checksums: expected %s:%s got %s:%s" %
                          (checksum_type, checksum,
                           a_pkg.checksum_type, a_pkg.checksum))
            raise rhnFault(104, "Mismatching information")

    temp_stream.delete=False
    return a_pkg

def load_package(package_stream):
    if package_stream.name.endswith('.deb'):
        try:
            header, payload_stream = rhn_deb.load(filename=package_stream.name)
        except:
            raise rhnFault(50, "Unable to load package", explain=0), None, sys.exc_info()[2]
    else:
        try:
            header, payload_stream = rhn_mpm.load(file=package_stream)
        except:
            raise rhnFault(50, "Unable to load package", explain=0), None, sys.exc_info()[2]

    payload_stream.seek(0, 0)
    if header.packaging == "mpm" or header.packaging == "deb":
        header.header_start = header.header_end = 0
        (header_start, header_end) = (0, 0)
    else:
        (header_start, header_end) = get_header_byte_range(payload_stream)
        payload_stream.seek(0,0)

    return header, payload_stream, header_start, header_end

class AlreadyUploadedError(Exception):
    pass

