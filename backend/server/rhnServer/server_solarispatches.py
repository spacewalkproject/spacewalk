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
# server_solarispatches module
# 
# Extra functionality for solaris patches

from common import log_debug
from server import rhnSQL

from server_packages import dbPackage

# functions --------------------------------------------------------------

def get_package_id(pkg):
    """Lookup a package id from rhnPackage in the database,
    Return the id or return None if the package is not found"""

    p = dbPackage(pkg)

    query = """SELECT id FROM rhnPackage
               WHERE name_id=LOOKUP_PACKAGE_NAME(:name)
               AND evr_id=LOOKUP_EVR(:epoch, :ver, :rel)
               AND package_arch_id=LOOKUP_PACKAGE_ARCH(:arch)"""

    handle = rhnSQL.prepare(query)

    handle.execute(name=p.n, epoch=p.e, ver=p.v, rel=p.r, arch=p.a)

    row = handle.fetchone_dict() or {}

    return row.get("id", None)

# db patch class ---------------------------------------------------------

class DBPatch(object):
    """DBPatch class
    Patch object for manipulating patches in the database"""

    def __init__(self, patch):
        """[constructor] This method looks up the patch in the databse, the 
        'id' field is the rhnPackage id. The 'id' field will be None if the
        patch does not exist in the database"""
        self.id = get_package_id(patch)

# solaris patches server class -------------------------------------------

class SolarisPatches(object):
    """Solaris patches server class
    Seperated server api for manipulating data pertinent to Solaris patches in
    the database"""

    def __init__(self):
        """[constructor]"""
        self._patches = {}

    def dispose_patched_packages(self, sysid):
        """Clear the patched packages on a system from the database"""

        log_debug(4, sysid, "disposing of patched packages")

        query = """DELETE FROM rhnSolarisPatchedPackage
                   WHERE server_id = :sysid"""

        handle = rhnSQL.prepare(query)
        handle.execute(sysid=sysid)

        # XXX return code from the execute call?

    def add_patch(self, sysid, patch):
        """Add a patch to the server"""

        log_debug(4, sysid, patch, "adding patch")

        if sysid not in self._patches:
            self._patches[sysid] = []

        self._patches[sysid].append(DBPatch(patch))

    def save_patched_packages(self, sysid):
        """Record the patched packages on a system in the database"""

        log_debug(4, sysid, "saving patched packages")

        select = """SELECT SP.name_id nid, SP.evr_id eid, 
                    SP.package_arch_id aid
                    FROM rhnPackageNEVRA PN,
                    rhnServerPackage SP,
                    rhnSolarisPatchPackages SPP
                    WHERE SPP.patch_id = :pid
                    AND SP.server_id = :sysid
                    AND PN.id = SPP.package_nevra_id
                    AND PN.name_id = SP.name_id
                    AND PN.evr_id = SP.evr_id
                    AND PN.package_arch_id = SP.package_arch_id"""

        insert = """INSERT INTO rhnSolarisPatchedPackage
                    (server_id, patch_id, package_nevra_id)
                    VALUES(:sysid, :pid, 
                    LOOKUP_PACKAGE_NEVRA(:nid, :eid, :aid))""" 

        for patch in self._patches.get(sysid, []):
            if patch.id is None:
                continue

            s_handle = rhnSQL.prepare(select)
            s_handle.execute(pid=patch.id, sysid=sysid)
            
            rows = s_handle.fetchall_dict() or []
            for row in rows:
                i_handle = rhnSQL.prepare(insert)
                i_handle.execute(sysid=sysid, pid=patch.id, nid=row['nid'], 
                                 eid=row['eid'], aid=row['aid'])
                # XXX return code from the execute call?

