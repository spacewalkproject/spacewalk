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
#
# Generic DB backend
#

import copy
import string
import sys

from spacewalk.common import rhn_rpm
from spacewalk.common.rhnConfig import CFG
from spacewalk.common.rhnException import rhnFault
from spacewalk.server import rhnSQL, rhnChannel, taskomatic
from importLib import Diff, Package, IncompletePackage, Erratum, \
    AlreadyUploadedError, InvalidPackageError, TransactionError, \
    InvalidSeverityError, SourcePackage
from backendLib import TableCollection, sanitizeValue, TableDelete, \
    TableUpdate, TableLookup, addHash, TableInsert

sequences = {
    'rhnPackageCapability': 'rhn_pkg_capability_id_seq',
    'rhnPackage': 'rhn_package_id_seq',
    'rhnSourceRPM': 'rhn_sourcerpm_id_seq',
    'rhnPackageGroup': 'rhn_package_group_id_seq',
    'rhnErrata': 'rhn_errata_id_seq',
    'rhnChannel': 'rhn_channel_id_seq',
    'rhnChannelProduct': 'rhn_channelprod_id_seq',
    'rhnPackageSource': 'rhn_package_source_id_seq',
    'rhnChannelFamily': 'rhn_channel_family_id_seq',
    'rhnCVE': 'rhn_cve_id_seq',
    'rhnChannelArch': 'rhn_channel_arch_id_seq',
    'rhnPackageArch': 'rhn_package_arch_id_seq',
    'rhnServerArch': 'rhn_server_arch_id_seq',
    'rhnCPUArch': 'rhn_cpu_arch_id_seq',
    'rhnErrataFile': 'rhn_erratafile_id_seq',
    'rhnKickstartableTree': 'rhn_kstree_id_seq',
    'rhnArchType': 'rhn_archtype_id_seq',
    'rhnPackageChangeLogRec': 'rhn_pkg_cl_id_seq',
    'rhnPackageChangeLogData': 'rhn_pkg_cld_id_seq',
}


class Backend:
    # This object is initialized by the specific subclasses (e.g.
    # OracleBackend)
    tables = TableCollection()
    # TODO: Some reason why we're passing a module in here? Seems to
    # always be rhnSQL anyhow...

    def __init__(self, dbmodule):
        self.dbmodule = dbmodule
        self.sequences = {}

    # TODO: Why is there a pseudo-constructor here instead of just using
    # __init__?
    def init(self):
        # Initializes the database connection objects
        # This function has to be called on a newly defined Backend object
        # Initialize sequences
        for k, v in sequences.items():
            self.sequences[k] = self.dbmodule.Sequence(v)
        # TODO: Why do we return a reference to ourselves? If somebody called
        # this method they already have a reference...
        return self

    def setDateFormat(self, format):
        sth = self.dbmodule.prepare("alter session set nls_date_format ='%s'"
                                    % format)
        sth.execute()
        sth = self.dbmodule.prepare("alter session set nls_timestamp_format ='%s'"
                                    % format)
        sth.execute()

    # Note: postgres-specific implementation overrides this in PostgresBackend
    def processCapabilities(self, capabilityHash):
        h = self.dbmodule.prepare("select lookup_package_capability(:name, :version) as id from dual")
        for name, version in capabilityHash.keys():
            ver = version
            if version is None or version == '':
                ver = None
            h.execute(name=name, version=ver)
            row = h.fetchone_dict()
            capabilityHash[(name, version)] = row['id']

    def processChangeLog(self, changelogHash):
        sql = "select id from rhnPackageChangeLogData where name = :name and time = :time and text = :text"
        h = self.dbmodule.prepare(sql)
        toinsert = [[], [], [], []]
        for name, time, text in changelogHash.keys():
            val = {}
            _buildExternalValue(val, {'name': name, 'time': time, 'text': text}, self.tables['rhnPackageChangeLogData'])
            h.execute(name=val['name'], time=val['time'], text=val['text'])
            row = h.fetchone_dict()
            if row:
                changelogHash[(name, time, text)] = row['id']
                continue

            id = self.sequences['rhnPackageChangeLogData'].next()
            changelogHash[(name, time, text)] = id

            toinsert[0].append(id)
            toinsert[1].append(val['name'])
            toinsert[2].append(val['time'])
            toinsert[3].append(val['text'])

        if not toinsert[0]:
            # Nothing to do
            return

        sql = "insert into rhnPackageChangeLogData (id, name, time, text) values (:id, :name, :time, :text)"
        h = self.dbmodule.prepare(sql)
        h.executemany(id=toinsert[0], name=toinsert[1], time=toinsert[2], text=toinsert[3])

    def processCVEs(self, cveHash):
        # First figure out which CVE's are already inserted
        sql = "select id from rhnCVE where name = :name"
        h = self.dbmodule.prepare(sql)
        toinsert = [[], []]

        for cve_name in cveHash.keys():
            h.execute(name=cve_name)
            row = h.fetchone_dict()

            if row:
                cveHash[cve_name] = row['id']
                continue

            # Generate an id
            id = self.sequences['rhnCVE'].next()

            cveHash[cve_name] = id

            toinsert[0].append(id)
            toinsert[1].append(cve_name)

        if not toinsert[0]:
            # Nothing to do
            return

        sql = "insert into rhnCVE (id, name) values (:id, :name)"
        h = self.dbmodule.prepare(sql)
        h.executemany(id=toinsert[0], name=toinsert[1])

    def lookupErrataFileTypes(self, hash):
        hash.clear()
        h = self.dbmodule.prepare("select id, label from rhnErrataFileType")
        h.execute()
        while 1:
            row = h.fetchone_dict()
            if not row:
                break
            hash[row['label']] = row['id']
        return hash

    def __lookupArches(self, archHash, table):
        if not archHash:
            return

        sql = "select id from %s where label = :name" % table
        h = self.dbmodule.prepare(sql)
        for k in archHash.keys():
            h.execute(name=str(k))
            row = h.fetchone_dict()
            if row:
                archHash[k] = row['id']
            # Else, it's an unsupported architecture

    def lookupChannelArches(self, archHash):
        return self.__lookupArches(archHash, 'rhnChannelArch')

    def lookupPackageArches(self, archHash):
        return self.__lookupArches(archHash, 'rhnPackageArch')

    def lookupServerArches(self, archHash):
        return self.__lookupArches(archHash, 'rhnServerArch')

    def lookupArchTypes(self, arch_types_hash):
        h = self.dbmodule.prepare(
            "select id, name from rhnArchType where label = :label")
        seq = self.sequences['rhnArchType']
        updates = [[], []]
        inserts = [[], [], []]
        results = {}
        for label, name in arch_types_hash.items():
            h.execute(label=label)
            row = h.fetchone_dict()
            if not row:
                next_id = seq.next()
                inserts[0].append(next_id)
                inserts[1].append(label)
                inserts[2].append(name)
                results[label] = next_id
                continue
            aid = row['id']
            results[label] = aid
            if name == row['name']:
                # Nothing to do
                continue
            updates[0].append(aid)
            updates[1].append(name)
        if inserts[0]:
            h = self.dbmodule.prepare("""
                    insert into rhnArchType (id, label, name)
                    values (:id, :label, :name)
            """)
            h.executemany(id=inserts[0], label=inserts[1], name=inserts[2])
        if updates[0]:
            h = self.dbmodule.prepare("""
                    update rhnArchType
                       set name = :name
                     where id = :id
            """)
            h.executemany(id=updates[0], name=updates[1])

        # Finally, update the hash
        arch_types_hash.update(results)

    def _lookupOrg(self):
        # Returns the org id
        sql = "select min(id) as id from web_customer"
        h = self.dbmodule.prepare(sql)
        h.execute()
        rows = h.fetchall_dict()
        if not rows:
            raise ValueError, "No user is created"
        return rows[0]['id']

    def lookupOrg(self, org_name=None):
        if not org_name:
            return self._lookupOrg()
        # Returns id of the org if found, None otherwise
        sql = "select id from web_customer where name = :name"
        h = self.dbmodule.prepare(sql)
        h.execute(name=org_name)
        row = h.fetchone_dict()
        if not row:
            return None
        return row['id']

    def lookupMaster(self, master_label):
        # Returns the master record (if it exists)
        sql = "select * from rhnISSMaster where label = :label"
        h = self.dbmodule.prepare(sql)
        h.execute(label=master_label)
        return h.fetchone_dict()

    def createMaster(self, master_label):
        # Creates a master record with label master_label
        sql = """
            insert into rhnISSMaster (id, label)
            values (sequence_nextval('rhn_issmaster_seq'), :label)
        """
        h = self.dbmodule.prepare(sql)
        h.execute(label=master_label)

    def createMasterOrgs(self, master, orgs):
        # Create master org records
        insert = [[], [], []]
        for org in orgs:
            insert[0].append(master)
            insert[1].append(org['id'])
            insert[2].append(org['name'])
        sql = """
            insert into rhnISSMasterOrgs
                   (id, master_id, master_org_id, master_org_name)
            values (sequence_nextval('rhn_issmasterorgs_seq'),
                   (select id from rhnISSMaster where label = :label),
                   :id, :name)
        """
        h = self.dbmodule.prepare(sql)
        h.executemany(label=insert[0], id=insert[1], name=insert[2])

    def createOrgs(self, orgs):
        # Create local org records
        sql = """
            insert into web_customer (id, name)
            values (sequence_nextval('web_customer_id_seq'), :name)
        """
        h = self.dbmodule.prepare(sql)
        h.executemany(name=orgs)
        sql = "select id, name from web_customer"
        h = self.dbmodule.prepare(sql)
        h.execute()
        rows = h.fetchall_dict()
        ret = {}
        for row in rows:
            ret[row['name']] = row['id']
        return ret

    def updateMasterOrgs(self, master_orgs):
        # Update the master org to local org mapping
        insert = [[], []]
        for org in master_orgs:
            insert[0].append(org['master_id'])
            insert[1].append(org['local_id'])
        sql = """
            update rhnISSMasterOrgs
               set local_org_id=:local
             where master_org_id=:master
        """
        h = self.dbmodule.prepare(sql)
        h.executemany(master=insert[0], local=insert[1])

    def lookupOrgTrusts(self):
        # Return a hash of org trusts
        sql = "select org_id, org_trust_id from rhnTrustedOrgs"
        h = self.dbmodule.prepare(sql)
        h.execute()
        rows = h.fetchall_dict()
        ret = {}
        if rows:
            for row in rows:
                if row['org_id'] not in ret.keys():
                    ret[row['org_id']] = []
                ret[row['org_id']].append(row['org_trust_id'])
        return ret

    def clearOrgTrusts(self, org_id):
        # Delete all trusts involving this org; trusts are always
        # bi-directional
        sql = """
        delete from rhnTrustedOrgs
              where org_id = :org_id
                 or org_trust_id = :org_id
        """
        h = self.dbmodule.prepare(sql)
        h.execute(org_id=org_id)

    def createOrgTrusts(self, trusts):
        # Create org trusts
        insert = [[], []]
        for trust in trusts:
            insert[0].append(trust['org_id'])
            insert[1].append(trust['trust'])
        sql = """
            insert into rhnTrustedOrgs (org_id, org_trust_id)
            values (:id, :trust)
        """
        h = self.dbmodule.prepare(sql)
        h.executemany(id=insert[0], trust=insert[1])

    def lookupOrgMap(self, master_label):
        sql = """
            select imo.master_org_id, imo.master_org_name, imo.local_org_id
              from rhnISSMasterOrgs imo,
                   rhnISSMaster im
             where im.id = imo.master_id
               and im.label = :master_label
        """
        h = self.dbmodule.prepare(sql)
        h.execute(master_label=master_label)
        rows = h.fetchall_dict()
        maps = {'master-name-to-master-id': {},
                'master-id-to-local-id': {}}
        if not rows:
            return maps
        mn_to_mi = {}  # master org name to master org id map
        mi_to_li = {}  # master org id to local org id map
        for org in rows:
            if ('master_org_id' in org.keys()
                    and 'master_org_name' in org.keys()
                    and org['master_org_id']
                    and org['master_org_name']):
                mn_to_mi[org['master_org_name']] = org['master_org_id']
            if ('master_org_id' in org.keys()
                    and 'local_org_id' in org.keys()
                    and org['master_org_id']
                    and org['local_org_id']):
                mi_to_li[org['master_org_id']] = org['local_org_id']
        maps['master-name-to-master-id'] = mn_to_mi
        maps['master-id-to-local-id'] = mi_to_li
        return maps

    def lookupChannels(self, hash):
        if not hash:
            return
        sql = "select id, channel_arch_id from rhnChannel where label = :label"
        h = self.dbmodule.prepare(sql)
        for k in hash.keys():
            h.execute(label=k)
            row = h.fetchone_dict()
            if row:
                hash[k] = row
            # Else, it's an unsupported channel

    def lookupChannelPackageArchCompat(self, channelArchHash):
        # Return all the arches compatible with each key of archHash
        sql = """
            select package_arch_id
            from rhnChannelPackageArchCompat
            where channel_arch_id = :channel_arch_id
        """
        h = self.dbmodule.prepare(sql)
        for channel_arch_id in channelArchHash.keys():
            dict = {}
            h.execute(channel_arch_id=channel_arch_id)
            while 1:
                row = h.fetchone_dict()
                if not row:
                    break
                dict[row['package_arch_id']] = None
            channelArchHash[channel_arch_id] = dict

    def lookupServerGroupTypes(self, entries_hash):
        sql = """
            select id
              from rhnServerGroupType
             where label = :label
        """
        h = self.dbmodule.prepare(sql)
        for sgt in entries_hash.keys():
            h.execute(label=sgt)
            row = h.fetchone_dict()
            if not row:
                # server group not found
                continue
            entries_hash[sgt] = row['id']

    def lookupPackageNames(self, nameHash):
        if not nameHash:
            return
        sql = "select LOOKUP_PACKAGE_NAME(:name) id from dual"
        h = self.dbmodule.prepare(sql)
        for k in nameHash.keys():
            h.execute(name=k)
            nameHash[k] = h.fetchone_dict()['id']

    def lookupErratum(self, erratum):
        if not erratum:
            return None

        sql = """
            select advisory
              from rhnErrata
             where advisory_name = :advisory_name
        """
        h = self.dbmodule.prepare(sql)
        h.execute(advisory_name=erratum['advisory_name'])
        return h.fetchone_dict()

    def lookupErrataSeverityId(self, erratum):
        """
        for the given severity type retuns the id
        associated in the rhnErratSeverity table.
        """
        if not erratum:
            return None

        sql = """
            select id
              from rhnErrataSeverity
             where label = :severity
        """

        h = self.dbmodule.prepare(sql)

        if erratum['security_impact'] == '':
            return None

        # concatenate the severity to reflect the db
        # bz-204374: rhnErrataSeverity tbl has lower case severity values,
        # so we convert severity in errata hash to lower case to lookup.
        severity_label = 'errata.sev.label.' + erratum['security_impact'].lower()

        h.execute(severity=severity_label)
        row = h.fetchone_dict()

        if not row:
            raise InvalidSeverityError("Invalid severity: %s" % erratum['security_impact'])

        return row['id']

    def lookupEVRs(self, evrHash):
        sql = "select LOOKUP_EVR(:epoch, :version, :release) id from dual"
        h = self.dbmodule.prepare(sql)
        for evr in evrHash.keys():
            epoch, version, release = evr
            if epoch == '' or epoch is None:
                epoch = None
            else:
                epoch = str(epoch)
            h.execute(epoch=epoch, version=version, release=release)
            row = h.fetchone_dict()
            if row:
                evrHash[evr] = row['id']

    # Note: postgres-specific implementation overrides this in PostgresBackend
    def lookupChecksums(self, checksumHash):
        if not checksumHash:
            return
        sql = "select lookup_checksum(:ctype, :csum) id from dual"
        h = self.dbmodule.prepare(sql)
        for k in checksumHash.keys():
            ctype, csum = k
            if csum != '':
                h.execute(ctype=ctype, csum=csum)
                row = h.fetchone_dict()
                if row:
                    checksumHash[k] = row['id']

    def lookupChecksumTypes(self, checksumTypeHash):
        if not checksumTypeHash:
            return
        sql = "select id from rhnChecksumType where label = :label"
        h = self.dbmodule.prepare(sql)
        for l in checksumTypeHash.keys():
            h.execute(label=l)
            row = h.fetchone_dict()
            if row:
                checksumTypeHash[l] = row['id']

    def lookupPackageNEVRAs(self, nevraHash):
        sql = "select LOOKUP_PACKAGE_NEVRA(:name, :evr, :arch) id from dual"
        h = self.dbmodule.prepare(sql)
        for nevra in nevraHash:
            name, evr, arch = nevra
            if arch is None:
                arch = ''
            h.execute(name=name, evr=evr, arch=arch)
            row = h.fetchone_dict()
            if row:
                nevraHash[nevra] = row['id']

    def lookupPackagesByNEVRA(self, nevraHash):
        sql = """
              select id from rhnPackage
              where name_id = :name and
                    evr_id = :evr and
                    package_arch_id = :arch
              """
        h = self.dbmodule.prepare(sql)

        for nevra in nevraHash:
            name, evr, arch = nevra
            h.execute(name=name, evr=evr, arch=arch)
            row = h.fetchone_dict()
            if row:
                nevraHash[nevra] = row['id']

    def lookupPackageKeyId(self, header):
        lookup_keyid_sql = rhnSQL.prepare("""
           select pk.id
             from rhnPackagekey pk,
                  rhnPackageKeyType pkt,
                  rhnPackageProvider pp
            where pk.key_id = :key_id
              and pk.key_type_id = pkt.id
              and pk.provider_id = pp.id
        """)
        sigkeys = rhn_rpm.RPM_Header(header).signatures
        key_id = None  # _key_ids(sigkeys)[0]
        for sig in sigkeys:
            if sig['signature_type'] == 'gpg':
                key_id = sig['key_id']

        lookup_keyid_sql.execute(key_id=key_id)
        keyid = lookup_keyid_sql.fetchall_dict()

        return keyid[0]['id']

    def lookupSourceRPMs(self, hash):
        self.__processHash('lookup_source_name', hash)

    def lookupPackageGroups(self, hash):
        self.__processHash('lookup_package_group', hash)

    def lookupPackages(self, packages, checksums, ignore_missing=0):
        # If nevra is enabled use checksum as primary key
        self.validate_pks()
        for package in packages:
            if not isinstance(package, IncompletePackage):
                raise TypeError("Expected an IncompletePackage instance, found %s" %
                                str(type(package)))
        for package in packages:
            # here we need to figure out which checksum we have in the database
            not_found = None
            for type, chksum in package['checksums'].iteritems():
                package['checksum_type'] = type
                package['checksum'] = chksum
                package['checksum_id'] = checksums[(type, chksum)]
                try:
                    self.__lookupObjectCollection([package], 'rhnPackage')
                    not_found = None
                    break
                except InvalidPackageError, e:
                    not_found = (e, sys.exc_info()[2])
            if not_found and not ignore_missing:
                # package is not in database at all
                raise not_found[0], None, not_found[1]

    def lookupChannelFamilies(self, hash):
        if not hash:
            return
        sql = "select id from rhnChannelFamily where label = :label"
        h = self.dbmodule.prepare(sql)
        for k in hash.keys():
            h.execute(label=k)
            row = h.fetchone_dict()
            if row:
                hash[k] = row['id']
            # Else, it's an unsupported channel

    def lookup_kstree_types(self, hash):
        return self._lookup_in_table('rhnKSTreeType', 'rhn_kstree_type_seq',
                                     hash)

    def lookup_ks_install_types(self, hash):
        return self._lookup_in_table('rhnKSInstallType',
                                     'rhn_ksinstalltype_id_seq', hash)

    def _lookup_in_table(self, table_name, sequence_name, hash):
        t = self.dbmodule.Table(table_name, 'label')
        seq = self.dbmodule.Sequence(sequence_name)
        to_insert = []
        to_update = []
        result = {}
        for label, name in hash.items():
            row = t[label]
            if not row:
                row_id = seq.next()
                result[label] = row_id
                to_insert.append((label, name, row_id))
                continue
            row_id = row['id']
            result[label] = row_id
            if row['name'] != name:
                to_update.append((label, name))
                continue
            # Entry found in the table - nothing more to do

        if to_insert:
            # Have to insert rows
            row_ids = []
            labels = []
            names = []
            for label, name, row_id in to_insert:
                row_ids.append(row_id)
                labels.append(label)
                names.append(name)

            sql = """
                insert into %s (id, label, name) values (:id, :label, :name)
            """
            h = self.dbmodule.prepare(sql % table_name)
            h.executemany(id=row_ids, label=labels, name=names)

        if to_update:
            labels = []
            names = []
            for label, name in to_update:
                labels.append(label)
                names.append(name)

            sql = """
                update %s set name = :name where label = :label
            """
            h = self.dbmodule.prepare(sql % table_name)
            h.executemany(label=labels, name=names)

        # Update the returning value
        hash.clear()
        hash.update(result)
        return hash

    def processChannelArches(self, arches):
        self.__processObjectCollection(arches, 'rhnChannelArch',
                                       uploadForce=4, ignoreUploaded=1, severityLimit=4)

    def processPackageArches(self, arches):
        self.__processObjectCollection(arches, 'rhnPackageArch',
                                       uploadForce=4, ignoreUploaded=1, severityLimit=4)

    def processServerArches(self, arches):
        self.__processObjectCollection(arches, 'rhnServerArch',
                                       uploadForce=4, ignoreUploaded=1, severityLimit=4)

    def processCPUArches(self, arches):
        self.__processObjectCollection(arches, 'rhnCPUArch',
                                       uploadForce=4, ignoreUploaded=1, severityLimit=4)

    def processMasterOrgs(self, orgs):
        self.__processObjectCollection(orgs, 'rhnISSMasterOrgs',
                                       uploadForce=4, ignoreUploaded=1, severityLimit=4)

    def processOrgs(self, orgs):
        self.__processObjectCollection(orgs, 'web_customer',
                                       uploadForce=4, ignoreUploaded=1, severityLimit=4)

    def processServerPackageArchCompatMap(self, entries):
        self.__populateTable('rhnServerPackageArchCompat', entries,
                             delete_extra=1)

    def processServerChannelArchCompatMap(self, entries):
        self.__populateTable('rhnServerChannelArchCompat', entries,
                             delete_extra=1)

    def processChannelPackageArchCompatMap(self, entries):
        self.__populateTable('rhnChannelPackageArchCompat', entries,
                             delete_extra=1)

    def processServerGroupServerArchCompatMap(self, entries):
        self.__populateTable('rhnServerServerGroupArchCompat', entries,
                             delete_extra=1)

    def processPackages(self, packages, uploadForce=0, ignoreUploaded=0,
                        forceVerify=0, transactional=0):
        # Insert/update the packages
        self.validate_pks()

        childTables = {
            'rhnPackageProvides':   'package_id',
            'rhnPackageRequires':   'package_id',
            'rhnPackageConflicts':  'package_id',
            'rhnPackageObsoletes':  'package_id',
            'rhnPackageRecommends': 'package_id',
            'rhnPackageSuggests':   'package_id',
            'rhnPackageSupplements': 'package_id',
            'rhnPackageEnhances': 'package_id',
            'rhnPackageBreaks':     'package_id',
            'rhnPackagePredepends': 'package_id',
            'rhnPackageFile':       'package_id',
            'rhnPackageChangeLogRec':  'package_id',
        }

        for package in packages:
            if not isinstance(package, Package):
                raise TypeError("Expected a Package instance")

            tableList = copy.deepcopy(childTables)

            # older sat packages wont have these fields
            # avoid Null insertions
            if package['header_start'] is None:
                package['header_start'] = -1
                package['header_end'] = -1

            self.__processObjectCollection__([package, ], 'rhnPackage', tableList,
                                             uploadForce=uploadForce, forceVerify=forceVerify,
                                             ignoreUploaded=ignoreUploaded, severityLimit=1,
                                             transactional=transactional)

    def processErrata(self, errata):
        # Insert/update the packages

        childTables = [
            'rhnChannelErrata',
            'rhnErrataBugList',
            'rhnErrataFile',
            'rhnErrataKeyword',
            'rhnErrataPackage',
            'rhnErrataCVE',
        ]

        for erratum in errata:
            if not isinstance(erratum, Erratum):
                raise TypeError("Expected an Erratum instance")

        return self.__processObjectCollection(errata, 'rhnErrata', childTables,
                                              'errata_id', uploadForce=4, ignoreUploaded=1, forceVerify=1,
                                              transactional=1)

    def update_channels_affected_by_errata(self, dml):

        # identify errata that were affected
        affected_errata_ids = {}
        for op_type in ['insert', 'update', 'delete']:
            op_values = getattr(dml, op_type)
            for table_name, values_hash in op_values.items():
                if table_name == 'rhnErrata':
                    field = 'id'
                elif values_hash.has_key('errata_id'):
                    field = 'errata_id'

                # Now we know in which field to look for changes
                for erratum_id in values_hash[field]:
                    affected_errata_ids[erratum_id] = None

        # Get affected channels
        affected_channel_ids = {}
        h = self.dbmodule.prepare("""
            select channel_id
              from rhnChannelErrata
             where errata_id = :errata_id
        """)
        for errata_id in affected_errata_ids.keys():
            h.execute(errata_id=errata_id)

            channel_ids = h.fetchall_dict() or []
            channel_ids = map(lambda x: x['channel_id'], channel_ids)
            for channel_id in channel_ids:
                affected_channel_ids[channel_id] = errata_id

        # Now update the channels
        update_channel = self.dbmodule.Procedure('rhn_channel.update_channel')
        invalidate_ss = 0

        for channel_id in affected_channel_ids.keys():
            update_channel(channel_id, invalidate_ss)
            h = self.dbmodule.prepare("""
                select advisory from rhnErrata where id = :errata_id
            """)
            h.execute(errata_id=affected_channel_ids[channel_id])
            advisory = h.fetchone()[0]

            channel = rhnChannel.Channel()
            channel.load_by_id(channel_id)
            taskomatic.add_to_repodata_queue(channel.get_label(), "errata",
                                             advisory)

    def processKickstartTrees(self, ks_trees):
        childTables = [
            'rhnKSTreeFile',
            #'rhnKSTreeType',
            #'rhnKSInstallType',
        ]
        self.__processObjectCollection(ks_trees, 'rhnKickstartableTree',
                                       childTables, 'kstree_id', uploadForce=4, forceVerify=1,
                                       ignoreUploaded=1, severityLimit=1, transactional=1)

    def queue_errata(self, errata, timeout=0):
        # timeout is the numer of seconds we want the execution to be delayed
        if not errata:
            return
        # Figure out the errata ids
        errata_channel_ids = []
        for erratum in errata:
            if erratum.ignored:
                # Skip it
                continue
            if erratum.diff_result is not None:
                if erratum.diff_result.level != 0:
                    # New or modified in some way, queue it
                    # XXX we may not want to do this for trivial changes,
                    # but not sure what trivial is
                    for cid in erratum['channels']:
                        errata_channel_ids.append(
                            (erratum.id, cid['channel_id']))

        if not errata_channel_ids:
            # Nothing to do
            return

        hdel = self.dbmodule.prepare("""
            delete from rhnErrataQueue where errata_id = :errata_id
        """)

        h = self.dbmodule.prepare("""
            insert into rhnErrataQueue (errata_id, channel_id, next_action)
            values (:errata_id, :channel_id, current_timestamp + numtodsinterval(:timeout, 'second'))
        """)
        errata_ids = map(lambda x: x[0], errata_channel_ids)
        channel_ids = map(lambda x: x[1], errata_channel_ids)
        timeouts = [timeout] * len(errata_ids)
        hdel.executemany(errata_id=errata_ids)
        return h.executemany(errata_id=errata_ids, channel_id=channel_ids,
                             timeout=timeouts)

    def processChannels(self, channels, base_channels):
        childTables = [
            'rhnChannelFamilyMembers', 'rhnReleaseChannelMap',
        ]
        if base_channels:
            childTables.append('rhnDistChannelMap')
        self.__processObjectCollection(channels, 'rhnChannel', childTables,
                                       'channel_id', uploadForce=4, ignoreUploaded=1, forceVerify=1)

    def orgTrustExists(self, org_id, trust_id):
        sql = """
        select *
          from rhnTrustedOrgs
         where org_id = :org_id
           and org_trust_id = :trust_id
        """
        h = self.dbmodule.prepare(sql)
        h.execute(org_id=org_id, trust_id=trust_id)
        row = h.fetchone_dict()
        if row:
            return True
        return False

    def clearChannelTrusts(self, label):
        sql = """
        delete from rhnChannelTrust where channel_id =
        (select id from rhnChannel where label = :label)
        """
        h = self.dbmodule.prepare(sql)
        h.execute(label=label)

    def processChannelTrusts(self, channel_trusts):
        # Create channel trusts
        insert = [[], []]
        for trust in channel_trusts:
            insert[0].append(trust['channel-label'])
            insert[1].append(trust['org-id'])
        sql = """
            insert into rhnChannelTrust (channel_id, org_trust_id)
            values ((select id from rhnChannel where label = :label),
                    :org_id)
        """
        h = self.dbmodule.prepare(sql)
        h.executemany(label=insert[0], org_id=insert[1])

    def processChannelFamilies(self, channels):
        childTables = []
        self.__processObjectCollection(channels, 'rhnChannelFamily',
                                       childTables, 'channel_family_id', uploadForce=4, ignoreUploaded=1,
                                       forceVerify=1)

    def processChannelFamilyMembers(self, channel_families):
        # Channel families now contain channel memberships too
        h_lookup_cfid = self.dbmodule.prepare("""
            select channel_family_id
              from rhnChannelFamilyMembers
             where channel_id = :channel_id
        """)
        cf_ids = []
        c_ids = []
        for cf in channel_families:
            if 'private-channel-family' in cf['label']:
                # Its a private channel family and channel family members
                # will be different from server as this is most likely ISS
                # sync. Don't compare and delete custom channel families.
                continue
            for cid in cf['channel_ids']:
                # Look up channel families for this channel
                h_lookup_cfid.execute(channel_id=cid)
                row = h_lookup_cfid.fetchone_dict()
                if row and row['channel_family_id'] == cf.id:
                    # Nothing to do here, we already have this mapping
                    continue
                # need to delete this entry and add the one for the new
                # channel family
                cf_ids.append(cf.id)
                c_ids.append(cid)
        if not c_ids:
            # We're done
            return

        hdel = self.dbmodule.prepare("""
            delete from rhnChannelFamilyMembers
             where channel_id = :channel_id
        """)
        hins = self.dbmodule.prepare("""
            insert into rhnChannelFamilyMembers (channel_id, channel_family_id)
            values (:channel_id, :channel_family_id)
        """)
        hdel.executemany(channel_id=c_ids)
        hins.executemany(channel_family_id=cf_ids, channel_id=c_ids)

    def processChannelFamilyPermissions(self, channel_families):
        # Since this is not evaluated in rhn_entitlements anymore,
        # make channel families without org globally visible

        cf_ids = []

        for cf in channel_families:
            if not cf['org_id']:
                cf_ids.append(cf.id)

        h_private_del = self.dbmodule.prepare("""
            delete from rhnPublicChannelFamily
             where channel_family_id = :channel_family_id
        """)
        h_private_ins = self.dbmodule.prepare("""
            insert into rhnPublicChannelFamily (channel_family_id)
            values (:channel_family_id)
        """)

        h_private_del.executemany(channel_family_id=cf_ids)
        h_private_ins.executemany(channel_family_id=cf_ids)

    def processDistChannelMap(self, dcms):
        dcmTable = self.tables['rhnDistChannelMap']
        lookup = TableLookup(dcmTable, self.dbmodule)
        dmlobj = DML([dcmTable.name], self.tables)

        for dcm in dcms:
            if dcm.ignored:
                # Skip it
                continue
            h = lookup.query(dcm)
            row = h.fetchone_dict()
            if not row:
                extObject = {}
                _buildExternalValue(extObject, dcm, dcmTable)
                addHash(dmlobj.insert[dcmTable.name], extObject)
            # Since this table has all the columns in unique constraints, we
            # don't care much about updates

        self.__doDML(dmlobj)

    def processChannelProduct(self, channel):
        """ Associate product with channel """

        channel['channel_product'] = channel['product_name']
        channel['channel_product_version'] = channel['product_version']
        channel['channel_product_beta'] = channel['product_beta']
        channel['channel_product_id'] = self.lookupChannelProduct(channel)

        if not channel['channel_product_id']:
            # If no channel product dont update
            return
        statement = self.dbmodule.prepare("""
            UPDATE rhnChannel
               SET channel_product_id = :channel_product_id
             WHERE id = :id
               AND (channel_product_id is NULL
                OR channel_product_id <> :channel_product_id)
        """)

        statement.execute(id=channel.id,
                          channel_product_id=channel['channel_product_id'])

    def processProductNames(self, batch):
        """ Check if ProductName for channel in batch is already in DB.
            If not add it there.
        """
        statement = self.dbmodule.prepare("""
            insert into rhnProductName
                 (id, label, name)
              values (sequence_nextval('rhn_productname_id_seq'),
                      :product_label, :product_name)
        """)

        for channel in batch:
            if not self.lookupProductNames(channel['label']):
                statement.execute(product_label=channel['label'],
                                  product_name=channel['name'])

    def lookupProductNames(self, label):
        """ For given label of product return its id.
                 If product do not exist return None
        """
        statement = self.dbmodule.prepare("""
            SELECT id
              FROM rhnProductName
             WHERE label = :label
        """)

        statement.execute(label=label)

        product = statement.fetchone_dict()

        if product:
            return product['id']

        return

    # bug #528227
    def lookupChannelOrg(self, label):
        """For given label of channel return its org_id.
           If channel with given label does not exist or is NULL, return None.
        """
        statement = self.dbmodule.prepare("""
            SELECT org_id
              FROM rhnChannel
             WHERE label = :label
        """)

        statement.execute(label=label)
        org_id = statement.fetchone_dict()

        if org_id:
            return org_id

        return

    def lookupChannelProduct(self, channel):
        statement = self.dbmodule.prepare("""
            SELECT id
              FROM rhnChannelProduct
             WHERE product = :product
               AND version = :version
               AND beta = :beta
        """)

        statement.execute(product=channel['channel_product'],
                          version=channel['channel_product_version'],
                          beta=channel['channel_product_beta'])

        product = statement.fetchone_dict()

        if product:
            return product['id']

        return self.createChannelProduct(channel)

    def createChannelProduct(self, channel):
        id = self.sequences['rhnChannelProduct'].next()

        statement = self.dbmodule.prepare("""
            INSERT
              INTO rhnChannelProduct
                   (id, product, version, beta)
            VALUES (:id, :product, :version, :beta)
        """)

        statement.execute(id=id,
                          product=channel['channel_product'],
                          version=channel['channel_product_version'],
                          beta=channel['channel_product_beta'])

        return id

    def subscribeToChannels(self, packages, strict=0):
        hash = {
            'package_id': [],
            'channel_id': [],
        }
        # Keep a list of packages for a channel too, so we can easily compare
        # what's extra, if strict is 1
        channel_packages = {}
        sql = """
            select channel_id
            from rhnChannelPackage
            where package_id = :package_id"""
        affected_channels = {}
        statement = self.dbmodule.prepare(sql)
        for package in packages:
            if package.ignored:
                # Skip it
                continue
            if package.id is None:
                raise InvalidPackageError(package, "Invalid package")
            # Look it up first
            statement.execute(package_id=package.id)
            channels = {}
            while 1:
                row = statement.fetchone_dict()
                if not row:
                    break
                channels[row['channel_id']] = None

            for channelId in package['channels'].keys():
                # Build the channel-package list
                if channel_packages.has_key(channelId):
                    cp = channel_packages[channelId]
                else:
                    channel_packages[channelId] = cp = {}
                cp[package.id] = None

                if channels.has_key(channelId):
                    # Already subscribed
                    continue
                dict = {
                    'package_id': package.id,
                    'channel_id': channelId,
                }
                if not affected_channels.has_key(channelId):
                    modified_packages = ([], [])
                    affected_channels[channelId] = modified_packages
                else:
                    modified_packages = affected_channels[channelId]
                # Package was added to this channel
                modified_packages[0].append(package.id)
                addHash(hash, dict)

        # Packages we'd have to delete
        extra_cp = {
            'package_id': [],
            'channel_id': [],
        }
        if strict:
            # if strict remove the extra packages from the DB
            sql = """
                select package_id
                  from rhnChannelPackage
                 where channel_id = :channel_id
            """
        else:
            # or at least we should delete packages from different org
            sql = """
                select package_id
                  from rhnChannelPackage cp
                  join rhnPackage p
                    on p.id = cp.package_id
                  join rhnChannel c
                    on c.id = cp.channel_id
                 where cp.channel_id = :channel_id
                   and c.org_id != p.org_id
            """

        statement = self.dbmodule.prepare(sql)
        for channel_id, pid_hash in channel_packages.items():
            statement.execute(channel_id=channel_id)
            while 1:
                row = statement.fetchone_dict()
                if not row:
                    break
                package_id = row['package_id']
                if not pid_hash.has_key(package_id):
                    # Have to remove it
                    extra_cp['package_id'].append(package_id)
                    extra_cp['channel_id'].append(channel_id)
                    # And mark this channel as being affected
                    if not affected_channels.has_key(channel_id):
                        modified_packages = ([], [])
                        affected_channels[channel_id] = modified_packages
                    else:
                        modified_packages = affected_channels[channel_id]
                    # Package was deletef from this channel
                    modified_packages[1].append(package_id)

        self.__doDeleteTable('rhnChannelPackage', extra_cp)
        self.__doInsertTable('rhnChannelPackage', hash)
        # This function returns the channels that were affected
        return affected_channels

    def update_newest_package_cache(self, caller, affected_channels, name_ids=[]):
        # affected_channels is a hash keyed on the channel id, and with a
        # tuple (added_package_list, deleted_package_list) as values
        refresh_newest_package = self.dbmodule.Procedure('rhn_channel.refresh_newest_package')
        update_channel = self.dbmodule.Procedure('rhn_channel.update_channel')
        for channel_id, (added_packages_list, deleted_packages_list) in affected_channels.items():
            try:
                if name_ids:
                    for id in name_ids:
                        refresh_newest_package(channel_id, caller, id)
                else:
                    refresh_newest_package(channel_id, caller, None)
            except rhnSQL.SQLError, e:
                raise rhnFault(23, str(e[1]), explain=0), None, sys.exc_info()[2]
            if deleted_packages_list:
                invalidate_ss = 1
            else:
                invalidate_ss = 0
            update_channel(channel_id, invalidate_ss)

    def processSourcePackages(self, packages, uploadForce=0, ignoreUploaded=0,
                              forceVerify=0, transactional=0):
        # Insert/update the packages

        childTables = []

        for package in packages:
            if not isinstance(package, SourcePackage):
                raise TypeError("Expected a Package instance")

        # Process the packages

        self.__processObjectCollection(packages, 'rhnPackageSource', childTables,
                                       'package_id', uploadForce=uploadForce, forceVerify=forceVerify,
                                       ignoreUploaded=ignoreUploaded, severityLimit=1,
                                       transactional=transactional)

    def commit(self):
        self.dbmodule.commit()

    def rollback(self):
        self.dbmodule.rollback()

    def __processHash(self, lookup, hash):
        if not hash:
            # Nothing to do
            return

        h = rhnSQL.prepare("select " + lookup + "(:name) from dual")
        for k in hash.keys():
            h.execute(name=k)
            # saving id
            hash[k] = h.fetchone_dict().popitem()[1]

    def __buildQueries(self, childTables):
        childTableLookups = {}
        queryTempl = "select * from %s where %s = :id"
        for childTableName in childTables:
            childTableLookups[childTableName] = self.dbmodule.prepare(
                queryTempl % (childTableName, childTables[childTableName]))
        return childTableLookups

    def __processObjectCollection(self, objColl, parentTable, childTables=[],
                                  colname=None, **kwargs):
        # Returns the DML object that was processed
        # This helps identify what the changes were

        # XXX this is a total hack keeping tranlating the old interface into the
        # new interface to keep me from having to change all the places in the
        # code that call this method, as there are 10 of them...

        childDict = {}

        for tbl in childTables:
            childDict[tbl] = colname

        return self.__processObjectCollection__(objColl, parentTable, childDict, **kwargs)

    def __processObjectCollection__(self, objColl, parentTable, childTables={},
                                    **kwargs):
        # Returns the DML object that was processed
        # This helps identify what the changes were

        # FIXME I need to break this method apart into smaller method calls that
        # will allow *different* colname fields for different childTables
        # NOTE objColl == packages
        # Process the object collection, starting with parentTable, having
        # colname as a link column between the parent and child tables
        #
        # We create a DML object for the operations we're supposed to perform
        # on the database
        kwparams = {
            # The 'upload force'
            'uploadForce': 0,
            # Raises exceptions when the object is already uploaded
            'ignoreUploaded': 0,
            # Forces a full object verification - including the child tables
            'forceVerify': 0,
            # When the severity is below this limit, the object is not
            # updated
            'severityLimit': 0,
            # All-or-nothing
            'transactional': 0,
        }

        for k, v in kwargs.items():
            if not kwparams.has_key(k):
                raise TypeError("Unknown keyword parameter %s" % k)
            if v is not None:
                # Leave the default values in case of a None
                kwparams[k] = v

        uploadForce = kwparams['uploadForce']
        ignoreUploaded = kwparams['ignoreUploaded']
        severityLimit = kwparams['severityLimit']
        transactional = kwparams['transactional']
        forceVerify = kwparams['forceVerify']

        # All the tables affected
        tables = [parentTable] + childTables.keys()

        # Build the hash for the operations on the tables
        dml = DML(tables, self.tables)
        # Reverse hash: object id to object for already-uploaded objects
        uploadedObjects = {}
        # Information related to the parent table
        parentTableObj = self.tables[parentTable]
        ptFields = parentTableObj.getFields()
        severityHash = parentTableObj.getSeverityHash()

        # A flag that indicates if something has to be modified beyond the
        # current severity limit
        brokenTransaction = 0

        # Lookup object
        lookup = TableLookup(parentTableObj, self.dbmodule)
        # XXX
        childTableLookups = self.__buildQueries(childTables)
        # For each valid object in the collection, look it up
        #   if it doesn't exist, insert all the associated information
        #   if it already exists:
        #       save it in the uploadedObjects hash for later processing
        #       the object's diff member will contain data if that object
        #         failed to push; the content should be explicit enough about
        #         what failed
        #   The object's diff_result should reliably say if the object was
        #       different in any way, or if it was new. Each field that gets
        #       compared will present its won severity field (or the default
        #       one if not explicitly specified). The "global" severity is the
        #       max of all severities.
        #   New objects will have a diff level of -1
        for object in objColl:
            if object.ignored:
                # Skip it
                continue
            h = lookup.query(object)
            row = h.fetchone_dict()
            if not row:
                # Object does not exist
                id = self.sequences[parentTable].next()
                object.id = id
                extObject = {'id': id}
                _buildExternalValue(extObject, object, parentTableObj)
                addHash(dml.insert[parentTable], extObject)

                # Insert child table information
                for tname in childTables:
                    tbl = self.tables[tname]
                    # Get the list of objects for this package
                    entry_list = object[tbl.getAttribute()]
                    if entry_list is None:
                        continue
                    for entry in entry_list:
                        extObject = {childTables[tname]: id}
                        seq_col = tbl.sequenceColumn
                        if seq_col:
                            # This table has to insert values in a sequenced
                            # column; since it's a child table and the entry
                            # in the master table is not created yet, there
                            # shouldn't be a problem with uniqueness
                            # constraints
                            new_id = self.sequences[tbl.name].next()
                            extObject[seq_col] = new_id
                            # Make sure we initialize the object's sequenced
                            # column as well
                            entry[seq_col] = new_id
                        _buildExternalValue(extObject, entry, tbl)
                        addHash(dml.insert[tname], extObject)
                object.diff_result = Diff()
                # New object
                object.diff_result.level = -1
                continue

            # Already uploaded
            if not ignoreUploaded:
                raise AlreadyUploadedError(object, "Already uploaded")

            # XXX package id set here!!!!!!!!!!
            object.id = row['id']
            # And save the object and the row for later processing
            uploadedObjects[row['id']] = [object, row]

        # Deal with already-uploaded objects
        for objid, (object, row) in uploadedObjects.items():
            # Build the external value
            extObject = {'id': row['id']}
            _buildExternalValue(extObject, object, parentTableObj)
            # Build the DB value
            row = _buildDatabaseValue(row, ptFields)
            # compare them
            object.diff = object.diff_result = Diff()
            diffval = computeDiff(extObject, row, severityHash, object.diff)
            if not forceVerify:
                # If there is enough karma, force the full object check
                # maybe they want the object overwritten
                if uploadForce < object.diff.level and diffval <= severityLimit:
                    # Same object, or not different enough
                    # not enough karma either
                    continue

            localDML = self.__processUploaded(objid, object, childTables,
                                              childTableLookups)

            if uploadForce < object.diff.level:
                # Not enough karma
                if object.diff.level > severityLimit:
                    # Broken transaction - object is too different
                    brokenTransaction = 1
                continue

            # Clean up the object diff since we pushed the package
            object.diff = None

            if diffval:
                # Different parent object
                localDML['update'][parentTable] = [extObject]

            # And transfer the local DML to the global one
            for k, tablehash in localDML.items():
                dmlhash = getattr(dml, k)
                for tname, vallist in tablehash.items():
                    for val in vallist:
                        addHash(dmlhash[tname], val)

        if transactional and brokenTransaction:
            raise TransactionError("Error uploading package source batch")
        return self.__doDML(dml)

    def __processUploaded(self, objid, object, childTables, childTableLookups):
        # Store the DML operations locally
        localDML = {
            'insert': {},
            'update': {},
            'delete': {},
        }

        # Grab the rest of the information
        childTablesInfo = self.__getChildTablesInfo(objid, childTables.keys(),
                                                    childTableLookups)

        # Start computing deltas
        for childTableName in childTables:
            # Init the local hashes
            for k in ['insert', 'update', 'delete']:
                localDML[k][childTableName] = []

            dbside = childTablesInfo[childTableName]
            # The child table object
            childTableObj = self.tables[childTableName]
            # The name of the attribute in the parent object
            parentattr = childTableObj.getAttribute()
            # The list of entries associated with the attribute linked to
            # this table
            entrylist = object[parentattr]
            fields = childTableObj.getFields()
            pks = childTableObj.getPK()
            childSeverityHash = childTableObj.getSeverityHash()
            if entrylist is None:
                continue
            for ent in entrylist:
                # Build the primary key
                key = []
                for f in pks:
                    if f == childTables[childTableName]:
                        # Special-case it
                        key.append(objid)
                        continue
                    datatype = fields[f]
                    # Get the proper attribute name for this column
                    attr = childTableObj.getObjectAttribute(f)
                    key.append(sanitizeValue(ent[attr], datatype))
                key = tuple(key)
                # Build the value
                val = {childTables[childTableName]: objid}
                if childTableObj.sequenceColumn:
                    # Initialize the sequenced column with a dummy value
                    ent[childTableObj.sequenceColumn] = None
                _buildExternalValue(val, ent, childTableObj)

                # Look this value up
                if not dbside.has_key(key):
                    if childTableObj.sequenceColumn:
                        # Initialize the sequence column too
                        sc = childTableObj.sequenceColumn
                        nextid = self.sequences[childTableName].next()
                        val[sc] = ent[sc] = nextid
                    # This entry has to be inserted
                    object.diff.append((parentattr, val, None))
                    # XXX change to a default value
                    object.diff.setLevel(4)

                    localDML['insert'][childTableName].append(val)
                    continue

                # Already exists in the DB
                dbval = _buildDatabaseValue(dbside[key], fields)

                if childTableObj.sequenceColumn:
                    # Copy the sequenced value - we dpn't want it updated
                    sc = childTableObj.sequenceColumn
                    val[sc] = ent[sc] = dbval[sc]
                # check for updates
                diffval = computeDiff(val, dbval, childSeverityHash,
                                      object.diff, parentattr)
                if not diffval:
                    # Same value
                    del dbside[key]
                    continue

                # Different value; have to update the entry
                localDML['update'][childTableName].append(val)
                del dbside[key]

            if childTableName == 'rhnErrataPackage':
                continue

            # Anything else should be deleted
            for key, val in dbside.items():
                # Send only the PKs
                hash = {}
                for k in pks:
                    hash[k] = val[k]

                # XXX change to a default value
                object.diff.setLevel(4)

                localDML['delete'][childTableName].append(hash)
                object.diff.append((parentattr, None, val))

        return localDML

    def __doDML(self, dml):
        self.__doDelete(dml.delete, dml.tables)
        self.__doUpdate(dml.update, dml.tables)
        self.__doInsert(dml.insert, dml.tables)
        return dml

    def __doInsert(self, hash, tables):
        for tname in tables:
            dict = hash[tname]
            try:
                self.__doInsertTable(tname, dict)
            except rhnSQL.SQLError, e:
                raise rhnFault(54, str(e[1]), explain=0), None, sys.exc_info()[2]

    def __doInsertTable(self, table, hash):
        if not hash:
            return
        tab = self.tables[table]
        k = hash.keys()[0]
        if not hash[k]:
            # Nothing to do
            return

        insertObj = TableInsert(tab, self.dbmodule)
        insertObj.query(hash)
        return

    def __doDelete(self, hash, tables):
        for tname in tables:
            dict = hash[tname]
            self.__doDeleteTable(tname, dict)

    def __doDeleteTable(self, tname, hash):
        if not hash:
            return
        tab = self.tables[tname]
        # Need to extract the primary keys and look for items to delete only
        # in those columns, the other ones may not be populated
        # See bug 154216 for details (misa 2005-04-08)
        pks = tab.getPK()
        k = pks[0]
        if not hash[k]:
            # Nothing to do
            return
        deleteObj = TableDelete(tab, self.dbmodule)
        deleteObj.query(hash)

    def __doUpdate(self, hash, tables):
        for tname in tables:
            dict = hash[tname]
            self.__doUpdateTable(tname, dict)

    def __doUpdateTable(self, tname, hash):
        if not hash:
            return
        tab = self.tables[tname]
        # See bug 154216 for details (misa 2005-04-08)
        pks = tab.getPK()
        k = pks[0]
        if not hash[k]:
            # Nothing to do
            return
        updateObj = TableUpdate(tab, self.dbmodule)
        updateObj.query(hash)
        return

    def __lookupObjectCollection(self, objColl, tableName, ignore_missing=0):
        # Looks the object up in tableName, and fills in its id
        lookup = TableLookup(self.tables[tableName], self.dbmodule)
        for object in objColl:
            if object.ignored:
                # Skip it
                continue
            h = lookup.query(object)
            row = h.fetchone_dict()
            if not row:
                if ignore_missing:
                    # Ignore the missing objects
                    object.ignored = 1
                    continue
                # Invalid
                raise InvalidPackageError(object, "Could not find object %s in table %s" % (object, tableName))
            object.id = row['id']

    def __getChildTablesInfo(self, id, tables, queries):
        # Returns a hash with the information about package id from tables
        result = {}
        for tname in tables:
            tableobj = self.tables[tname]
            fields = tableobj.getFields()
            q = queries[tname]
            q.execute(id=id)
            hash = {}
            while 1:
                row = q.fetchone_dict()
                if not row:
                    break
                pks = tableobj.getPK()
                key = []
                for f in pks:
                    value = row[f]
                    datatype = fields[f]
                    value = sanitizeValue(value, datatype)
                    key.append(value)
                val = {}
                for f, datatype in fields.items():
                    value = row[f]
                    value = sanitizeValue(value, datatype)
                    val[f] = value
                hash[tuple(key)] = val

            result[tname] = hash
        return result

    def __populateTable(self, table_name, data, delete_extra=1):
        table = self.tables[table_name]
        fields = table.getFields()
        # Build a hash with the incoming data
        incoming = {}
        for entry in data:
            t = hash2tuple(entry, fields)
            incoming[t] = entry

        # Build the query to dump the table's contents
        h = self.dbmodule.prepare("select * from %s" % table.name)
        h.execute()
        deletes = {}
        inserts = {}
        for f in fields.keys():
            inserts[f] = []
            deletes[f] = []

        while 1:
            row = h.fetchone_dict()
            if not row:
                break

            t = hash2tuple(row, fields)
            if incoming.has_key(t):
                # we already have this value uploaded
                del incoming[t]
                continue
            addHash(deletes, row)

        for row in incoming.values():
            addHash(inserts, row)

        if delete_extra:
            self.__doDeleteTable(table.name, deletes)
        self.__doInsertTable(table.name, inserts)

    # This function does a diff on the specified table name for the presented
    # data, using pk_fields as unique fields
    def _do_diff(self, data, table_name, uq_fields, fields):
        first_uq_col = uq_fields[0]
        uq_col_values = {}
        all_fields = uq_fields + fields
        for entry in data:
            for f in all_fields:
                if not entry.has_key(f):
                    raise Exception, "Missing field %s" % f
            val = entry[first_uq_col]
            if not uq_col_values.has_key(val):
                valhash = {}
                uq_col_values[val] = valhash
            else:
                valhash = uq_col_values[val]
            key = build_key(entry, uq_fields)
            valhash[key] = entry

        query = "select %s from %s where %s = :%s" % (
            string.join(all_fields, ", "),
            table_name,
            first_uq_col, first_uq_col,
        )
        h = self.dbmodule.prepare(query)
        updates = []
        deletes = []
        for val, valhash in uq_col_values.items():
            params = {first_uq_col: val}
            h.execute(**params)
            while 1:
                row = h.fetchone_dict()
                if not row:
                    break
                key = build_key(row, uq_fields)
                if not valhash.has_key(key):
                    # Need to delete this one
                    deletes.append(row)
                    continue
                entry = valhash[key]
                for f in fields:
                    if entry[f] != row[f]:
                        # Different, we have to update
                        break
                else:
                    # Same value, remove it from valhash
                    del valhash[key]
                    continue
                # Need to update
                updates.append(entry)

        inserts = []
        map(inserts.extend, map(lambda x: x.values(), uq_col_values.values()))

        if deletes:
            params = transpose(deletes, uq_fields)
            query = "delete from %s where %s" % (
                table_name,
                string.join(map(lambda x: "%s = :%s" % (x, x), uq_fields),
                            ' and '),
            )
            h = self.dbmodule.prepare(query)
            h.executemany(**params)
        if inserts:
            params = transpose(inserts, all_fields)
            query = "insert into %s (%s) values (%s)" % (
                table_name,
                string.join(all_fields, ', '),
                string.join(map(lambda x: ":" + x, all_fields), ', '),
            )
            h = self.dbmodule.prepare(query)
            h.executemany(**params)
        if updates:
            params = transpose(updates, all_fields)
            query = "update % set %s where %s" % (
                table_name,
                string.join(map(lambda x: "%s = :s" + (x, x), fields),
                            ', '),
                string.join(map(lambda x: "%s = :%s" % (x, x), uq_fields),
                            ' and '),
            )
            h = self.dbmodule.prepare(query)
            h.executemany(**params)

    def validate_pks(self):
        # If nevra is enabled use checksum as primary key
        tbs = self.tables['rhnPackage']
        if not CFG.ENABLE_NVREA:
            # remove checksum from a primary key if nevra is disabled.
            if 'checksum_id' in tbs.pk:
                tbs.pk.remove('checksum_id')

# Returns a tuple for the hash's values


def build_key(hash, fields):
    return tuple(map(lambda x, h=hash: h[x], fields))


def transpose(arrhash, fields):
    params = {}
    for f in fields:
        params[f] = []
    for h in arrhash:
        for f in fields:
            params[f].append(h[f])
    return params


def hash2tuple(hash, fields):
    # Converts the hash into a tuple, with the fields ordered as presented in
    # the fields list
    result = []
    for fname, ftype in fields.items():
        result.append(sanitizeValue(hash[fname], ftype))
    return tuple(result)


class DML:

    def __init__(self, tables, tableHash):
        self.update = {}
        self.delete = {}
        self.insert = {}
        self.tables = tables
        for k in ('insert', 'update', 'delete'):
            dmlhash = {}
            setattr(self, k, dmlhash)
            for tname in tables:
                hash = {}
                for f in tableHash[tname].getFields().keys():
                    hash[f] = []
                dmlhash[tname] = hash


def _buildDatabaseValue(row, fieldsHash):
    # Returns a dictionary containing the interesting values of the row,
    # sanitized
    dict = {}
    for f, datatype in fieldsHash.items():
        dict[f] = sanitizeValue(row[f], datatype)
    return dict


def _buildExternalValue(dict, entry, tableObj):
    # updates dict with values from entry
    # entry is a hash-like object (non-db)
    for f, datatype in tableObj.getFields().items():
        if dict.has_key(f):
            # initialized somewhere else
            continue
        # Get the attribute's name
        attr = tableObj.getObjectAttribute(f)
        # Sanitize the value according to its datatype
        if not entry.has_key(attr):
            entry[attr] = None
        dict[f] = sanitizeValue(entry[attr], datatype)


def computeDiff(hash1, hash2, diffHash, diffobj, prefix=None):
    # Compare if the key-values of hash1 are a subset of hash2's
    difference = 0
    ignore_keys = ['last_modified']

    for k, v in hash1.items():
        if k in ignore_keys:
            # Dont decide the diff based on last_modified
            # as this obviously wont match due to our db
            # other triggers.
            continue
        if hash2[k] == v:
            # Same values
            continue
        if k == 'installed_size' and v is not None and hash2[k] is None:
            # Skip installed_size which might not have been populated
            continue
        if diffHash.has_key(k):
            diffval = diffHash[k]
            if diffval == 0:
                # Completely ignore this key
                continue
        else:
            diffval = diffobj.level + 1

        if prefix:
            diffkey = prefix + '::' + k
        else:
            diffkey = k

        diffobj.setLevel(diffval)
        diffobj.append((diffkey, v, hash2[k]))

        difference = diffobj.level

    return difference
