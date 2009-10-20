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
#
# This file contains classes and functions that save and retrieve package
# profiles.
#

import string
from types import ListType, TupleType

from common import log_debug, rhn_rpm, rhnFault
from server import rhnSQL, rhnLib
from server_lib import snapshot_server, check_entitlement

def get_nvrea(entry):
    if type(entry) not in (ListType, TupleType):
        return None
    if len(entry) < 4:
        return None
    if len(entry) >= 5:
        arch = entry[4]
        if arch is None:
            arch = ""
        else:
            arch = str(arch)
    else:
        arch = ""
    name, version, release, epoch = map(str, entry[:4])
    if string.lower(epoch) == "(none)" or epoch == None:
        epoch = ""
    if None in [name, version, release, epoch, arch]:
        return None
    return (name, version, release, epoch, arch)

# A small class that helps us represent things about a
# database package. In this structure "real" means that we have an
# entry in the database for it.
class dbPackage:
    def __init__(self, plist, real = 0, name_id=None, evr_id=None,
            package_arch_id=None): 
        if not isinstance(plist, TupleType):
            plist = tuple(plist)
        self.n, self.v, self.r, self.e, self.a = plist
        # nvrea is a tuple; we can use tuple as dictionary keys since they are
        # immutable
        self.nvrea = (self.n, self.v, self.r, self.e, self.a)
        self.real = real
        self.name_id = name_id
        self.evr_id = evr_id
        self.package_arch_id = package_arch_id
        self.status = not real # 0 = unchanged, 1 = added, 2 = deleted
    def setval(self, value):
        self.status = value
    def add(self):
        if self.status == 2: # deleted
            if self.real: self.status = 0 # real entries remain unchanged
            else:         self.status = 1 # others are added
        return
    def delete(self):
        if self.real:
            self.status = 2
        else:
            self.status = 0 # we prefer unchanged for the non-real packages
        return

##### PACKAGES Routines
class Packages:
    def __init__(self):
        self.__p = {}
        # Have we loaded the packages or not?
        self.__loaded = 0
        self.__changed = 0
        
    def add_package(self, sysid, entry):
        log_debug(4, sysid, entry)
        p = get_nvrea(entry)
        if p is None:
            # Not a valid package spec
            return -1
        if not self.__loaded:
            self.reload_packages_byid(sysid)        
        if self.__p.has_key(p):
            self.__p[p].add()
            self.__changed = 1
            return 0
        self.__p[p] = dbPackage(p)
        self.__changed = 1
        return 0

    # delete a package from the list
    def delete_package(self, sysid, entry):
        log_debug(4, sysid, entry)
        p = get_nvrea(entry)
        if p is None:
            # Not a valid package spec
            return -1
        if not self.__loaded:
            self.reload_packages_byid(sysid)        
        if self.__p.has_key(p):
            log_debug(4, "  Package deleted")
            self.__p[p].delete()
            self.__changed = 1
        # deletion is always successfull
        return 0

    # delete all packages and get an empty package list
    def dispose_packages(self, sysid):
        log_debug(4, sysid)
        if not self.__loaded:
            self.reload_packages_byid(sysid)        
        for k in self.__p.keys():
            self.__p[k].delete()
            self.__changed = 1
        return 0

    # produce a list of packages
    def get_packages(self):
        return map(lambda a: a.nvrea, filter(lambda a: a.status != 2, self.__p.values()))

    # save the package list
    def save_packages_byid(self, sysid, schedule=1):
        log_debug(3, sysid, "Errata cache to run:", schedule, 
            "Changed:", self.__changed, "%d total packages" % len(self.__p))

        if not self.__changed:
            return 0
        
        commits = 0
        
        # get rid of the deleted packages
        dlist = filter(lambda a: a.real and a.status == 2, self.__p.values())
        if dlist:
            log_debug(4, sysid, len(dlist), "deleted packages")
            h = rhnSQL.prepare("""
            delete from rhnServerPackage
            where server_id = :sysid 
            and name_id = :name_id
            and evr_id = :evr_id
            and ((:package_arch_id is null and package_arch_id is null)
                or package_arch_id = :package_arch_id)
            """)
            h.execute_bulk({
                'sysid'     : [sysid] * len(dlist),
                'name_id'   : map(lambda a: a.name_id, dlist),
                'evr_id'    : map(lambda a: a.evr_id, dlist),
                'package_arch_id'   : map(lambda a: a.package_arch_id, dlist),
            })
            commits = commits + len(dlist)
            del dlist
        
        # And now add packages
        alist = filter(lambda a: a.status == 1, self.__p.values())
        if alist:
            log_debug(4, sysid, len(alist), "added packages")
            h = rhnSQL.prepare("""
            insert into rhnServerPackage
            (server_id, name_id, evr_id, package_arch_id)
            values (:sysid, LOOKUP_PACKAGE_NAME(:n), LOOKUP_EVR(:e, :v, :r),
                LOOKUP_PACKAGE_ARCH(:a)
            )
            """)
            package_data = {
                'sysid' : [sysid] * len(alist),
                'n'     : map(lambda a: a.n, alist),
                'v'     : map(lambda a: a.v, alist),
                'r'     : map(lambda a: a.r, alist),
                'e'     : map(lambda a: a.e, alist),
                'a'     : map(lambda a: a.a, alist),
            }
            try:
                h.execute_bulk(package_data)
            except rhnSQL.SQLSchemaError, e:
                # LOOKUP_PACKAGE_ARCH failed
                if e.errno == 20243:
                    log_debug(2, "Unknown package arch found", e)
                    raise rhnFault(45, "Unknown package arch found")
                
            commits = commits + len(alist)
            del alist

        if schedule:
            # queue this server for an errata update
            update_errata_cache(sysid)

        # if provisioning box, and there was an actual delta, snapshot
	ents = check_entitlement(sysid)
        if commits and ents.has_key("provisioning_entitled"):
            snapshot_server(sysid, "Package profile changed")

        # Our new state does not reflect what's on the database anymore
        self.__loaded = 0
        self.__changed = 0
        return 0
    
    _query_get_package_arches = rhnSQL.Statement("""
        select id, label
          from rhnPackageArch
    """)
    def get_package_arches(self):
        # None gets automatically converted to empty string
        package_arches_hash = {None : ''}
        h = rhnSQL.prepare(self._query_get_package_arches)
        h.execute()
        while 1:
            row = h.fetchone_dict()
            if not row:
                break
            package_arches_hash[row['id']] = row['label']
        return package_arches_hash

    # reload the packages list from the database
    def reload_packages_byid(self, sysid):
        log_debug(3, sysid)
        # First, get the package arches
        package_arches_hash = self.get_package_arches()
        # XXX we could achieve the same thing with an outer join but that's
        # more expensive
        # Now load packages
        h = rhnSQL.prepare("""
        select
            rpn.name n,
            rpe.version v,
            rpe.release r,
            rpe.epoch e,
            sp.name_id,
            sp.evr_id,
            sp.package_arch_id
        from
            rhnServerPackage sp,
            rhnPackageName rpn, 
            rhnPackageEVR rpe
        where sp.server_id = :sysid
        and sp.name_id = rpn.id
        and sp.evr_id = rpe.id
        """)
        h.execute(sysid = sysid)
        self.__p = {}
        while 1:
            t = h.fetchone_dict()
            if not t:
                break
            if t["e"] is None: t["e"] = ""
            package_arch_id = t["package_arch_id"]
            package_arch = package_arches_hash[package_arch_id]
            nvrea = (t['n'], t['v'], t['r'], t['e'], package_arch)
            self.__p[nvrea] = dbPackage(nvrea, real=1, 
                name_id=t["name_id"], evr_id=t["evr_id"], 
                package_arch_id=package_arch_id)
        log_debug(4, "Loaded %d packages for server %s" % (len(self.__p), sysid))
        self.__loaded = 1
        self.__changed = 0
        return 0

# Function that updates rhnServerNeededPackageCache by deltas (as opposed to
# calling queue_server which removes the old entries and inserts new ones).
# It now also updates rhnServerNeededErrataCache, but as the entries there
# are a subset of rhnServerNeededPackageCache's entries, it still gives
# statistics regarding only rhnServerNeededPackageCache.
def update_errata_cache(server_id):
    log_debug(2, "Updating the errata cache", server_id)
    h = rhnSQL.prepare("""
        select 
            server_id,  errata_id, package_id 
        from
            rhnServerNeededView
        where 
            server_id = :server_id
    """)

    # Use a dictionary to store the final state
    new_packages = {}
    h.execute(server_id=server_id)
    while 1:
        r = h.fetchone_dict()
        if not r:
            break
        p = ( r['errata_id'], r['package_id'])
        new_packages[p] = None
    
    h = rhnSQL.prepare("""
        select 
            server_id, errata_id, package_id 
        from
            rhnServerNeededCache 
        where 
            server_id = :server_id
    """)

    # Fetch the current state and do the diff as we go
    deleted_packages = []
    h.execute(server_id=server_id)
    while 1:
        r = h.fetchone_dict()
        if not r:
            break
        p = (r['errata_id'], r['package_id'])
        if new_packages.has_key(p):
            # The entry is already present
            del new_packages[p]
            continue

        # Remove this entry
        deleted_packages.append(p)


    # Delete unneeded packages
    non_null_errata = filter(lambda x: x[0] is not None, deleted_packages)
    null_errata = filter(lambda x: x[0] is None, deleted_packages)

    changed = 0

    if non_null_errata:
        h = rhnSQL.prepare("""
            delete from rhnServerNeededCache
            where
                server_id = :server_id
                and errata_id = :errata_id
                and package_id = :package_id
        """)
        dict = rhnLib.transpose_to_hash(non_null_errata,
             ['errata_id', 'package_id'])
        # Add server_id
        dict['server_id'] = [server_id] * len(dict['package_id'])
        h.execute_bulk(dict)
        changed = changed + len(non_null_errata)

    if null_errata:
        h = rhnSQL.prepare("""
            delete from rhnServerNeededCache
            where
                server_id = :server_id
                and package_id = :package_id
        """)
        dict = rhnLib.transpose_to_hash(null_errata,
            [ 'errata_id', 'package_id'])
        # Add server_id
        dict['server_id'] = [server_id] * len(dict['package_id'])
        # We don't need errata_id since it's null
        del dict['errata_id']
        h.execute_bulk(dict)
        changed = changed + len(null_errata)

    log_debug(4, "Deleted packages", len(deleted_packages))


    if new_packages:
        changed = changed + len(new_packages.keys())
        h = rhnSQL.prepare("""
            insert into rhnServerNeededCache
            (server_id, errata_id, package_id)
            values (:server_id, :errata_id, :package_id)
        """)
        dict = rhnLib.transpose_to_hash(new_packages.keys(), 
            [ 'errata_id', 'package_id'])
        dict['server_id'] = [server_id] * len(new_packages.keys())
        
        h.execute_bulk(dict)

        log_debug(4, "Inserted packages", len(new_packages.keys()))

    # Return the number of changes
    return changed

def processPackageKeyAssociations(header, md5sum):
    provider_sql = rhnSQL.prepare("""
        insert into rhnPackageKeyAssociation
            (package_id, key_id) values
            (:package_id, :key_id)
    """)

    insert_keyid_sql = rhnSQL.prepare("""
        insert into rhnPackagekey
            (id, key_id, key_type_id) values
            (sequence_nextval('rhn_pkey_id_seq'), :key_id, :key_type_id)
    """)

    lookup_keyid_sql = rhnSQL.prepare("""
       select pk.id
         from rhnPackagekey pk
        where pk.key_id = :key_id
    """)

    lookup_keytype_id = rhnSQL.prepare("""
       select id
         from rhnPackageKeyType
        where LABEL = 'gpg'
    """)

    lookup_pkgid_sql = rhnSQL.prepare("""
        select id
          from rhnPackage, rhnChecksum c
         where c.checksum = :md5sum
           and p.checksum_id = c.id
    """)

    lookup_pkgkey_sql = rhnSQL.prepare("""
        select 1
          from rhnPackageKeyAssociation
         where package_id = :package_id
           and key_id = :key_id
    """)

    lookup_pkgid_sql.execute(md5sum = md5sum)
    pkg_id = lookup_pkgid_sql.fetchall_dict()

    if not pkg_id:
        # No package to associate, continue with next
        return

    sigkeys = rhn_rpm.RPM_Header(header).signatures
    key_id = None #_key_ids(sigkeys)[0]
    for sig in sigkeys:
        if sig['signature_type'] == 'gpg':
            key_id = sig['key_id']

    if not key_id:
        # package is not signed, skip gpg key insertion
        return
     
    lookup_keyid_sql.execute(key_id = key_id)
    keyid = lookup_keyid_sql.fetchall_dict()

    if not keyid:
        lookup_keytype_id.execute()
        key_type_id = lookup_keytype_id.fetchone_dict()
        insert_keyid_sql.execute(key_id = key_id, key_type_id = key_type_id['id'])
        lookup_keyid_sql.execute(key_id = key_id)
        keyid = lookup_keyid_sql.fetchall_dict()

    lookup_pkgkey_sql.execute(key_id=keyid[0]['id'], \
                            package_id=pkg_id[0]['id'])
    exists_check = lookup_pkgkey_sql.fetchall_dict()

    if not exists_check:
        provider_sql.execute(key_id=keyid[0]['id'], package_id=pkg_id[0]['id'])


# Compares list1 and list2 (each list is a tuple (n, v, r, e)
# returns two lists
# (install, remove)
# XXX upgrades and downgrades are simulated by a removal and an install
def package_delta(list1, list2):
    # Package registry - canonical versions for all packages
    package_registry = {}
    hash1 = _package_list_to_hash(list1, package_registry)
    hash2 = _package_list_to_hash(list2, package_registry)
    del package_registry

    installs = []
    removes = []
    for pn, ph1 in hash1.items():
        if not hash2.has_key(pn):
            removes.extend(ph1.keys())
            continue

        ph2 = hash2[pn]
        del hash2[pn]

        # Now, compute the differences between ph1 and ph2
        for p in ph1.keys():
            if not ph2.has_key(p):
                # We have to remove it
                removes.append(p)
            else:
                del ph2[p]
        # Everything else left in ph2 has to be installed
        installs.extend(ph2.keys())
            
    # Whatever else is left in hash2 should be installed
    for ph2 in hash2.values():
        installs.extend(ph2.keys())

    installs.sort()
    removes.sort()
    return installs, removes
        
            
# Converts package_list into a hash keyed by name
# package_registry contains the canonical version of the package
# for instance, version 51 and 0051 are indentical, but that would break the
# list comparison in Python. package_registry is storing representatives for
# each equivalence class (where the equivalence relationship is rpm's version
# comparison algorigthm
# Side effect: Modifies second argument!
def _package_list_to_hash(package_list, package_registry):
    hash = {}
    for e in package_list:
        e = tuple(e)
        pn = e[0]
        if not package_registry.has_key(pn):
            # Definitely new equivalence class
            _add_to_hash(package_registry, pn, e)
            _add_to_hash(hash, pn, e)
            continue

        # Look for a match for this package name in the registry
        plist = package_registry[pn].keys()
        for p in plist:
            if rhn_rpm.nvre_compare(p, e) == 0:
                # Packages are identical
                e = p
                break
        else:
            # Package not found in the global registry - add it
            _add_to_hash(package_registry, pn, e)

        # Add it to the hash too
        _add_to_hash(hash, pn, e)
            
    return hash

def _add_to_hash(hash, key, value):
    if not hash.has_key(key):
        hash[key] = { value : None }
    else:
        hash[key][value] = None
    
if __name__ == '__main__':
    raise Exception("Not intended for standalone use")
