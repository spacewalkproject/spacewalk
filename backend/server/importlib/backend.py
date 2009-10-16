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
# Generic DB backend
#

import copy
import string
import re
import sys

from common import rhnFault, rhn_rpm, CFG
from server import rhnSQL, rhnChannel, taskomatic
from importLib import Diff, Package, IncompletePackage, Erratum, \
        AlreadyUploadedError, InvalidPackageError, TransactionError, \
        InvalidSeverityError, SourcePackage
from backendLib import TableCollection, sanitizeValue, TableDelete, \
        TableUpdate, TableLookup, addHash, TableInsert

sequences = {
    'rhnPackageCapability'      : 'rhn_pkg_capability_id_seq',
    'rhnPackage'                : 'rhn_package_id_seq',
    'rhnSourceRPM'              : 'rhn_sourcerpm_id_seq',
    'rhnPackageGroup'           : 'rhn_package_group_id_seq',
    'rhnErrata'                 : 'rhn_errata_id_seq',
    'rhnChannel'                : 'rhn_channel_id_seq',
    'rhnChannelProduct'         : 'rhn_channelprod_id_seq',
    'rhnPackageSource'          : 'rhn_package_source_id_seq',
    'rhnChannelFamily'          : 'rhn_channel_family_id_seq',
    'rhnCVE'                    : 'rhn_cve_id_seq',
    'rhnChannelArch'            : 'rhn_channel_arch_id_seq',
    'rhnPackageArch'            : 'rhn_package_arch_id_seq',
    'rhnServerArch'             : 'rhn_server_arch_id_seq',
    'rhnCPUArch'                : 'rhn_cpu_arch_id_seq',
    'rhnErrataFile'             : 'rhn_erratafile_id_seq',
    'rhnKickstartableTree'      : 'rhn_kstree_id_seq',
    'rhnArchType'               : 'rhn_archtype_id_seq',
}

class NoFreeEntitlementsError(Exception):
    "No free entitlements available to activate this satellite"  

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

    def processCapabilities(self, capabilityHash):
        # First figure out which capabilities are already inserted
	templ = """
            select id
              from rhnPackageCapability
             where name = :name 
               and version %s"""
        sqlNonNull = templ % "= :version"
        sqlNull = templ % "is null"
        nullStatement = None
        nonnullStatement = None
        toinsert = [[], [], []]
        for name, version in capabilityHash.keys():
            ver = version
            if version is None or version == '':
                # Oracle inserts nulls as empty strings better
                ver = ''
                if not nullStatement:
                    nullStatement = self.dbmodule.prepare(sqlNull)
                nullStatement.execute(name=name)
                row = nullStatement.fetchone_dict()
            else:
                if not nonnullStatement:
                    nonnullStatement = self.dbmodule.prepare(sqlNonNull)
                nonnullStatement.execute(name=name, version=version)
                row = nonnullStatement.fetchone_dict()
            if row:
                capabilityHash[(name, version)] = row['id']
                continue
            # Generate an id
            id = self.sequences['rhnPackageCapability'].next()
            capabilityHash[(name, version)] = id
            toinsert[0].append(id)
            toinsert[1].append(name)
            toinsert[2].append(ver)
        if not toinsert[0]:
            # Nothing to do
            return
        sql = """
            insert into rhnPackageCapability 
                (id, name, version) values
                (:id, :name, :version)
        """
        h = self.dbmodule.prepare(sql)
        h.executemany(id=toinsert[0], name=toinsert[1], version=toinsert[2])

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
                declare
                    pragma autonomous_transaction;
                begin
                    insert into rhnArchType (id, label, name)
                    values (:id, :label, :name);
                    commit;
                end;
            """)
            h.executemany(id=inserts[0], label=inserts[1], name=inserts[2])
        if updates[0]:
            h = self.dbmodule.prepare("""
                declare
                    pragma autonomous_transaction;
                begin
                    update rhnArchType 
                       set name = :name
                     where id = :id;
                    commit;
                end;
            """)
            h.executemany(id=updates[0], name=updates[1])

        # Finally, update the hash
        arch_types_hash.update(results)

    def lookupOrg(self): 
        # Returns the org id
        sql = "select min(id) as id from web_customer"
        h = self.dbmodule.prepare(sql)
        h.execute()
        rows = h.fetchall_dict()
        if not rows:
            raise ValueError, "No user is created"
        return rows[0]['id']

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

    def updateChannelFamilyInfo(self, familyid, orgid):
        _query_org_priv_family = """
             SELECT  1
               FROM  rhnPrivateChannelFamily PCF
              WHERE  PCF.channel_family_id = :cfid
                AND  PCF.org_id = :orgid 
        """
        h = self.dbmodule.prepare(_query_org_priv_family)
        h.execute(cfid = familyid, orgid = orgid)
        row = h.fetchone_dict()
        if row:
          return
          
        _query_priv_cf_org =  """
            insert into rhnPrivateChannelFamily
            (channel_family_id, org_id)  values
            (:cfid, :orgid)
        """
        h = self.dbmodule.prepare(_query_priv_cf_org)
        h.execute(cfid = familyid, orgid = orgid)
        

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

        #concatenate the severity to reflect the db
	#bz-204374: rhnErrataSeverity tbl has lower case severity values,
	#so we convert severity in errata hash to lower case to lookup.
        severity_label = 'errata.sev.label.' + erratum['security_impact'].lower()
        
        h.execute(severity= severity_label)
        row = h.fetchone_dict()

        if not row:
            raise InvalidSeverityError("Invalid severity: %s" % erratum['security_impact'])

        return row['id']

    def lookupChecksums(self, checksumHash):
        if not checksumHash:
            return
        sql = "select lookup_checksum(:checksum) id from dual"
        h = self.dbmodule.prepare(sql)
        for k in checksumHash.keys():
            h.execute(name=k)
            checksumHash[k] = h.fetchone_dict()['id']

    def ovalFileMD5sumCheck(self, erratum):
        """
        When oval file is dumped on to RHN filesystem
        check if file exists and verifies their checksum
        
        XXX:: as we create these files on RHN itself
        this call is not used. But leaving it here
        in case we decide to change it.
        """
        if not erratum:
            return None

        sql = """
            select c.checksum
              from rhnErrataFile ef,
                   rhnErrata e,
                   rhnChecksum c
            where ef.filename = :filename
              and e.advisory_name = :aname
              and ef.errata_id = e.id
              and ef.checksum_id = c.id
        """

        h = self.dbmodule.prepare(sql)
        h.execute(filename = erratum['filename'], \
                  aname = erratum['advisory_name'])
        row = h.fetchone_dict()
        
        #file does'nt exist proceed to populate.
        if not row:
            return 1
        #file exists, check if checksums are same
        if erratum['checksum'] == row['checksum']:
            return 1
        return 0
            
    
    def processBugzillaPaths(self, hash):
        if not hash:
            return
        sql = """
            select beehive_path, ftp_path
            from rhnBeehivePathMap
            where path = :path
        """
        h = self.dbmodule.prepare(sql)
        for k in hash.keys():
            h.execute(path=k)
            row = h.fetchone_dict()
            if not row:
                continue
            hash[k] = (row['ftp_path'], row['beehive_path'])
                
    def processPathChannels(self, hash):
        if not hash:
            return
        sql = """
            select c.label channel, pcm.is_source
            from rhnPathChannelMap pcm, rhnChannel c
            where pcm.path = :path
            and pcm.channel_id = c.id
        """
        h = self.dbmodule.prepare(sql)
        for k in hash.keys():
            h.execute(path=k)
            channels = []
            while 1:
                row = h.fetchone_dict()
                if not row:
                    break
                channels.append((row['channel'], row['is_source']))
            hash[k] = channels
    
    def lookupEVRs(self, evrHash):
        sql = "select LOOKUP_EVR(:epoch, :version, :release) id from dual"
        h = self.dbmodule.prepare(sql)
        for evr in evrHash.keys():
            epoch, version, release = evr
            if epoch is None:
                epoch = ''
            else:
                epoch = str(epoch)
            h.execute(epoch=epoch, version=version, release=release)
            row = h.fetchone_dict()
            if row:
                evrHash[evr] = row['id']

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
        key_id = None #_key_ids(sigkeys)[0]
        for sig in sigkeys:
            if sig['signature_type'] == 'gpg':
                key_id = sig['key_id']

        lookup_keyid_sql.execute(key_id = key_id)
        keyid = lookup_keyid_sql.fetchall_dict()

        return keyid[0]['id']

    def lookupSourceRPMs(self, hash):
        self.__processHash('rhnSourceRPM', 'name', hash) 

    def lookupPackageGroups(self, hash):
        self.__processHash('rhnPackageGroup', 'name', hash)

    def lookupPackages(self, packages, ignore_missing = 0):
        # If nevra is enabled use checksum as primary key
        self.validate_pks()
        for package in packages:
            if not isinstance(package, IncompletePackage):
                raise TypeError("Expected an IncompletePackage instance, found %s" % \
                                str(type(package)))
        self.__lookupObjectCollection(packages, 'rhnPackage', ignore_missing)

    def lookupSolarisPackages(self, packages, ignore_missing=0):
        for pkg in packages:
            if not isinstance(pkg, IncompletePackage):
                raise TypeError("Expected an IncompletePackage instance")
        self.__lookupObjectCollection(packages, 'rhnSolarisPackage', ignore_missing)

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
            declare
                pragma autonomous_transaction;
            begin
                insert into %s (id, label, name) values (:id, :label, :name);
                commit;
            end;
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
            declare
                pragma autonomous_transaction;
            begin
                update %s set name = :name where label = :label;
                commit;
            end;
            """
            h = self.dbmodule.prepare(sql % table_name)
            h.executemany(label=labels, name=names)
            
        # Update the returning value
        hash.clear()
        hash.update(result)
        return hash
    
    def processBlacklistObsoletes(self, blacklists):
        # Slightly different: the table doesn't have a sequenced field
        parentTable = 'rhnBlacklistObsoletes'
        parentTableObj = self.tables[parentTable]
        dml = DML([parentTable], self.tables)

        q = "select %s from %s" % (string.join(parentTableObj.pk, ", "),
            parentTable)
        h = self.dbmodule.prepare(q)
        h.execute()

        db_fields = {}
        for k in parentTableObj.pk:
            db_fields[k] = parentTableObj.fields[k]

        db_values_hash = {}
        while 1:
            row = h.fetchone_dict()
            if not row:
                break
            val = _buildDatabaseValue(row, db_fields)
            key = build_key(val, parentTableObj.pk)
            db_values_hash[key] = val

        # Now iterate through the values
        for entry in blacklists:
            val = {}
            _buildExternalValue(val, entry, parentTableObj)
            key =  build_key(val, parentTableObj.pk)
            if db_values_hash.has_key(key):
                # Value exists
                del db_values_hash[key]
                continue
            # Have to add this value
            addHash(dml.insert[parentTable], val)
        # The rest of the stuff has to be deleted
        for k, v in db_values_hash.items():
            addHash(dml.delete[parentTable], v)

        self.__doDML(dml)
        

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
            'rhnPackageFile':       'package_id',
            'rhnPackageChangeLog':  'package_id',
        }

        solarisChildTables = {
            'rhnSolarisPackage':    'package_id',
        }

        solarisPatchChildTables = {
            'rhnSolarisPatch':      'package_id',
            'rhnSolarisPatchPackages':'patch_id',
        }

        solarisPatchSetChildTables = {
            'rhnSolarisPatchSet':   'package_id',
            'rhnSolarisPatchSetMembers':'patch_set_id',
        }

        for package in packages:
            if not isinstance(package, Package):
                raise TypeError("Expected a Package instance")

            tableList = copy.deepcopy(childTables)

            if 'solaris_package' in package:
                tableList.update(solarisChildTables)

            if 'solaris_patch' in package:
                tableList.update(solarisPatchChildTables)

            if 'solaris_patch_set' in package:
                tableList.update(solarisPatchSetChildTables)

            # older sat packages wont have these fields
            # avoid Null insertions
            if package['header_start'] is None:
                package['header_start'] = -1
                package['header_end'] = -1

            self.__processObjectCollection__([package,], 'rhnPackage', tableList,
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
                        errata_channel_ids.append(\
                               (erratum.id, cid['channel_id']))

        if not errata_channel_ids:
            # Nothing to do
            return

        hdel = self.dbmodule.prepare("""
            delete from rhnErrataQueue where errata_id = :errata_id
        """)

        h = self.dbmodule.prepare("""
            insert into rhnErrataQueue (errata_id, channel_id, next_action) 
            values (:errata_id, :channel_id, sysdate + :timeout / 86400)
        """)
        errata_ids = map(lambda x:x[0], errata_channel_ids)
        channel_ids = map(lambda x:x[1], errata_channel_ids)
        timeouts = [timeout] * len(errata_ids) 
        hdel.executemany(errata_id=errata_ids)
        return h.executemany(errata_id=errata_ids, channel_id=channel_ids,\
                             timeout=timeouts)

    
    def processChannels(self, channels):
        childTables = [
            'rhnChannelFamilyMembers', 'rhnDistChannelMap',
            'rhnReleaseChannelMap',
        ]
        self.__processObjectCollection(channels, 'rhnChannel', childTables,
            'channel_id', uploadForce=4, ignoreUploaded=1, forceVerify=1)

    def processReleaseChannelMap(self, relcms):
        """
        Process additional channel Mapping data for
        X.Y channels based on version, arch, product
        and release.
        """
        rcmTable = self.tables['rhnReleaseChannelMap']
        lookup = TableLookup(rcmTable, self.dbmodule)
        dmlobj = DML([rcmTable.name], self.tables)
        
        #for rcm in relcms:
        if relcms.ignored:
            # Skip it
            pass 
        h = lookup.query(relcms)
        row = h.fetchone_dict()
        if not row:
            extObject = {}
            _buildExternalValue(extObject, relcms, rcmTable)
            addHash(dmlobj.insert[rcmTable.name], extObject)

        self.__doDML(dmlobj)


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

    def processChannelFamilyVirtSubLevel(self, channel_families):
        h_lookup_virtid = self.dbmodule.prepare("""
            select vsl.label
              from rhnChannelFamilyVirtSubLevel cfvsl,
                   rhnVirtSubLevel vsl
             where cfvsl.channel_family_id = :channel_family_id
               and vsl.id = cfvsl.virt_sub_level_id
                   
        """)

        lookup_vsl = self.dbmodule.prepare("""
            select id
              from rhnVirtSubLevel
             where label = :label
        """)
        cf_ids = []
        vsl_ids = []
        for cf in channel_families:
            if not cf.has_key('virt_sub_level_label'):
                continue
            vsl_labels = cf['virt_sub_level_label'].split()
            h_lookup_virtid.execute(channel_family_id = cf.id)
            row = h_lookup_virtid.fetchall_dict()
            
            if row:
                labels_existing = map(lambda x: x['label'], row) 
            for vsl_label in vsl_labels:
                if row and vsl_label in labels_existing:
                    continue
                cf_ids.append(cf.id)
                lookup_vsl.execute(label = vsl_label)
                row_id = lookup_vsl.fetchone_dict()
                if row_id:
                    vsl_ids.append(row_id['id'])

        if not vsl_ids:
            # We're done
            return
        hdel = self.dbmodule.prepare("""
            delete from rhnChannelFamilyVirtSubLevel
             where channel_family_id = :channel_family_id
        """)
        hins = self.dbmodule.prepare("""
            insert into rhnChannelFamilyVirtSubLevel 
              (virt_sub_level_id, channel_family_id)
            values (:vsl_id, :channel_family_id)
        """)

        # hdel.executemany(channel_family_id=cf_ids)
        hins.executemany(vsl_id=vsl_ids,channel_family_id=cf_ids)

    def processVirtSubLevel(self, entries):
        h_lookup_virt = self.dbmodule.prepare("""
            select label 
              from rhnVirtSubLevel
             where label = :virt_label 
        """)
        virt_labels = []
        virt_text = []
        for entry in entries:
            if not entry.has_key('virt_sub_level_label'):
                continue
            if not entry.has_key('virt_sub_level_name'):
                continue
            h_lookup_virt.execute(virt_label=entry['virt_sub_level_label'])
            row = h_lookup_virt.fetchone_dict()
            if row and row['label'] == entry['virt_sub_level_label']:
                continue
            virt_labels.append(entry['virt_sub_level_label'])
            virt_text.append(entry['virt_sub_level_name'])
        if not virt_labels:
            return
        hdel = self.dbmodule.prepare("""
           delete from rhnVirtSubLevel
            where label = :vsl_label
        """)
        hins = self.dbmodule.prepare("""
            insert into rhnVirtSubLevel 
              (label, name)
            values (:vsl_label, :vsl_text)
        """)

        hdel.executemany(vsl_label = virt_labels)
        hins.executemany(vsl_label=virt_labels,vsl_text=virt_text)

    def processSGTVirtSubLevel(self, entries):
        h_lookup_virtid = self.dbmodule.prepare("""
            select vsl.label
              from rhnSGTypeVirtSubLevel sgtvsl,
                   rhnVirtSubLevel vsl
             where sgtvsl.server_group_type_id = :sgt_id
               and vsl.id = sgtvsl.virt_sub_level_id
                   
        """)
        lookup_vsl = self.dbmodule.prepare("""
            select id
              from rhnVirtSubLevel
             where label = :label
        """)
        lookup_sgtid = self.dbmodule.prepare("""
            select id
              from rhnServerGroupType
            where label = :sgt_label
        """)
        sgt_ids = []
        vsl_ids = []
        for entry in entries:
            if not entry.has_key('virt-sub-level'):
                continue
            lookup_sgtid.execute(sgt_label = entry['server-group-type'])
            row_sgt_id = lookup_sgtid.fetchone_dict()
            h_lookup_virtid.execute(sgt_id = row_sgt_id['id'])
            row = h_lookup_virtid.fetchone_dict()
            if row and row['label'] == entry['virt-sub-level']:
                continue
            sgt_ids.append(row_sgt_id['id'])
            lookup_vsl.execute(label = entry['virt-sub-level'])
            row_id = lookup_vsl.fetchone_dict()
            if row_id:
                vsl_ids.append(row_id['id'])
        if not vsl_ids:
            # We're done
            return
        hdel = self.dbmodule.prepare("""
            delete from rhnSGTypeVirtSubLevel
             where server_group_type_id = :sgt_id
        """)
        hins = self.dbmodule.prepare("""
            insert into rhnSGTypeVirtSubLevel 
              (virt_sub_level_id, server_group_type_id)
            values (:vsl_id, :sgt_id)
        """)

        hdel.executemany(sgt_id=sgt_ids)
        hins.executemany(vsl_id=vsl_ids,sgt_id=sgt_ids)

    def processChannelFamilyPermissions(self, cfps):
        # Process channelFamilyPermissions
	activate_channel_entitlements = self.dbmodule.Procedure(
	                      'rhn_entitlements.activate_channel_entitlement')         
        for cfp in cfps:
	    if "private-channel-family" in cfp['channel_family']:
	        # As this is a generic list of channel families
                # skip private channel families from channel family 
                # perm checks, as they are specific to ui and should
                # not be handed over for org checks through satellite-sync 
                # or activate to pl/sql. As there is no unique way to 
                # identify these, filter based on name which is a 
                # standard for private channel families. Hopefully we'll 
                # have a better param to filter this in future.
                continue
	    try:
	        activate_channel_entitlements(cfp['org_id'], 
		               cfp['channel_family'], cfp['max_members'])
            except rhnSQL.SQLError, e:
		raise rhnFault(23, str(e[1]) + ": org_id [%s] family [%s] max [%s]" % \
		    (cfp['org_id'], cfp['channel_family'], cfp['max_members']), explain=0)
            
        # The way we constructed the list of channel family permissions, we
        # should have (at least) all of the permissions from the database in
        # the cfps list, so no need to prune channel entitlements outside of
        # the set_family_count call

        # Now subscribe the newest servers
        # bug 146395: apparently this is an undesired 'nicety'
#        org_id = self.lookupOrg()
#        subscribe_newest_servers = self.dbmodule.Procedure(
#            'rhn_entitlements.subscribe_newest_servers')
#        subscribe_newest_servers(org_id)

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

        statement.execute(id = channel.id,
                          channel_product_id = channel['channel_product_id'])

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
                statement.execute(product_label = channel['label'], 
	                          product_name = channel['name'])
        

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

    def lookupChannelProduct(self, channel):
        statement = self.dbmodule.prepare("""
            SELECT id
              FROM rhnChannelProduct
             WHERE product = :product
               AND version = :version
               AND beta = :beta
        """)

        statement.execute(product = channel['channel_product'],
                         version = channel['channel_product_version'],
                         beta = channel['channel_product_beta'])

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

        statement.execute(id = id,
                          product = channel['channel_product'],
                          version = channel['channel_product_version'],
                          beta = channel['channel_product_beta'])

        return id
                                          
    def subscribeToChannels(self, packages, strict=0):
        hash = {
            'package_id' : [], 
            'channel_id' : [],
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
                    'package_id' : package.id,
                    'channel_id' : channelId,
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
            'package_id'    : [],
            'channel_id'    : [],
        }
        # Now get the extra packages from the DB
        if strict:
            sql = """
                select package_id
                  from rhnChannelPackage
                 where channel_id = :channel_id
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

    def update_newest_package_cache(self, caller, affected_channels):
        # affected_channels is a hash keyed on the channel id, and with a
        # tuple (added_package_list, deleted_package_list) as values
        refresh_newest_package = self.dbmodule.Procedure('rhn_channel.refresh_newest_package')
        update_channel = self.dbmodule.Procedure('rhn_channel.update_channel')
        for channel_id, (added_packages_list, deleted_packages_list) in affected_channels.items():
            try:
                refresh_newest_package(channel_id, caller)
            except rhnSQL.SQLError, e:
                raise rhnFault(23, str(e[1]), explain=0)
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

    def __processHash(self, table, field, hash):
        if not hash:
            # Nothing to do
            return

        sequence = self.sequences[table]
        sql = "select id from %s where %s = :p" % (table, field)
        h = self.dbmodule.prepare(sql)
        ids = []
        values = []
        for k in hash.keys():
            h.execute(p=k)
            row = h.fetchone_dict()
            if row:
                hash[k] = row['id']
                continue
            # Not here
            id = sequence.next()
            hash[k] = id
            ids.append(id)
            values.append(k)
        if ids:
            sql = "insert into %s (id, %s) values (:id, :value)" % (table,
                                                                    field)
            h = self.dbmodule.prepare(sql)
            try:
                h.executemany(id=ids, value=values)
            except rhnSQL.SQLSchemaError, e:
                if e.errno == 01401:
                    raise ValueError, e.errmsg
                else:
                    raise rhnFault(30, e.errmsg, explain=0)

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
            'uploadForce'       : 0,
            # Raises exceptions when the object is already uploaded
            'ignoreUploaded'    : 0,
            # Forces a full object verification - including the child tables
            'forceVerify'       : 0,
            # When the severity is below this limit, the object is not
            # updated
            'severityLimit'     : 0,
            # All-or-nothing
            'transactional'     : 0,
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
        lookup = TableLookup(self.tables[parentTable], self.dbmodule)
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
                extObject = {'id' : id}
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
                        extObject = {childTables[tname] : id}
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
            extObject = {'id' : row['id']}
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
            'insert'    : {},
            'update'    : {},
            'delete'    : {},
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
                continue;
                
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
                raise rhnFault(54, str(e[1]), explain=0)

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

    def __lookupObjectCollection(self, objColl, tableName, ignore_missing = 0):
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

    def listChannel(self, channel):
        fields = ['name', 'epoch', 'version', 'release', 'arch', 'org_id']
        query = """
            select
                 pn.name, 
                 pe.evr.epoch epoch,
                 pe.evr.version version, 
                 pe.evr.release release,
                 pa.label arch,
                 p.org_id,
                 cc.checksum
            from rhnChannel c, 
                 rhnChannelPackage cp,
                 rhnPackage p,
                 rhnPackageName pn,
                 rhnPackageEVR pe,
                 rhnPackageArch pa,
                 rhnChecksum cc
            where c.label = :label
                 and p.package_arch_id = pa.id
                 and cp.channel_id = c.id
                 and cp.package_id = p.id
                 and p.name_id = pn.id
                 and p.evr_id = pe.id
                 and p.checksum_id = pc.id
        """
        h = self.dbmodule.prepare(query)
        h.execute(label=channel)
        result = {}
        while 1:
            row = h.fetchone_dict()
            if not row:
                break
            nevrao = []
            for f in fields:
                nevrao.append(row[f])
            # Fix the epoch and org, just in case
            for i in [1, 5]:
                if nevrao[i] == '':
                    nevrao[i] = None
            result[tuple(nevrao)] = row
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
            params = {first_uq_col : val}
            apply(h.execute, (), params)
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
            apply(h.executemany, (), params)
        if inserts:
            params = transpose(inserts, all_fields)
            query = "insert into %s (%s) values (%s)" % (
                table_name,
                string.join(all_fields, ', '),
                string.join(map(lambda x: ":" + x, all_fields), ', '),
            )
            h = self.dbmodule.prepare(query)
            apply(h.executemany, (), params)
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
            apply(h.executemany, (), params)

    def validate_pks(self):
        # If nevra is enabled use checksum as primary key
        tbs = self.tables['rhnPackage']
        if CFG.ENABLE_NVREA:
            # Add checksum as a primarykey if nevra is enabled
            if 'checksum' not in tbs.pk:
                tbs.pk.append('checksum')
            
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
    ignore_keys = ['last_modified', 'channel_product_id']

    for k, v in hash1.items():
        if k in ignore_keys:
            # Dont decide the diff based on last_modified
            # as this obviously wont match due to our db
            # other triggers.
            continue
        if hash2[k] == v:
            # Same values
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

    return  difference
