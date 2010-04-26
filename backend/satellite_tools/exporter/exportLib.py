#!/usr/bin/python
#
# Copyright (c) 2008--2010 Red Hat, Inc.
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

import time
import string
from types import StringType

from common import log_debug, rhnLib
from server import rhnSQL

class ArrayIterator:
    def __init__(self, arr):
        self._arr = arr
        if self._arr:
            self._pos = 0
        else:
            # Nothing to iterate over
            self._pos = None

    def fetchone_dict(self):
        if self._pos is None:
            return None
        i = self._pos
        self._pos = self._pos + 1
        if self._pos == len(self._arr):
            self._pos = None
        return self._arr[i]

class BaseDumper:
    # tag_name has to be set in subclasses
    def __init__(self, writer, data_iterator=None):
        self._writer = writer
        self._attributes = {}
        self._iterator = data_iterator

    # Generic timing function
    def timer(self, debug_level, message, function, *args, **kwargs):
        start = time.time()
        result = apply(function, args, kwargs)
        log_debug(debug_level, message, "timing: %.3f" % (time.time() - start))
        return result

    def set_attributes(self):
        return self._attributes

    def set_iterator(self):
        return self._iterator

    def dump(self):
        if not hasattr(self, "tag_name"):
            raise Exception, "Programmer error: subclass did not set tag_name"
        tag_name = getattr(self, "tag_name")
        self._attributes = self.set_attributes() or {}
        self._iterator = self.timer(5, "set_iterator", self.set_iterator)

        if not self._iterator:
            self._writer.empty_tag(tag_name, attributes=self._attributes)
            return

        data_found = 0
        while 1:
            data = self.timer(6, "fetchone_dict", self._iterator.fetchone_dict)
            if not data:
                break
            if not data_found:
                data_found = 1
                self._writer.open_tag(tag_name, attributes=self._attributes)

            if isinstance(data, StringType):
                # The iterator produced some XML dump, just write it
                self._writer.stream.write(data)
            else:
                self.timer(6, "dump_subelement", self.dump_subelement, data)

        if data_found:
            self._writer.close_tag(tag_name)
        else:
            self._writer.empty_tag(tag_name, attributes=self._attributes)

    def dump_subelement(self, data):
        if isinstance(data, BaseDumper):
            data.dump()

    def get_writer(self):
        return self._writer

    def set_writer(self, writer):
        self._writer = writer


class EmptyDumper(BaseDumper):
    def __init__(self, writer, tag_name, attributes=None):
        self.tag_name = tag_name
        self.attributes = attributes or {}
        BaseDumper.__init__(self, writer)

    def dump(self):
        self._writer.empty_tag(self.tag_name, attributes=self.attributes)

class SimpleDumper(BaseDumper):
    def __init__(self, writer, tag_name, value, max_value_bytes=None):
        self.tag_name = tag_name
        self._value = value

        # max number of bytes satellite can handle in the matching db row
        self._max_value_bytes = max_value_bytes
        BaseDumper.__init__(self, writer)

    def dump(self):
        self._writer.open_tag(self.tag_name)
        if self._value is None:
            self._writer.empty_tag('rhn-null')
        else:
            self._writer.data(self._value, self._max_value_bytes)
        self._writer.close_tag(self.tag_name)


class BaseRowDumper(BaseDumper):
    def __init__(self, writer, row):
        BaseDumper.__init__(self, writer)
        self._row = row

####

class SatelliteDumper(BaseDumper):
    tag_name = 'rhn-satellite'

    def __init__(self, writer, *dumpers):
        BaseDumper.__init__(self, writer)
        self._dumpers = dumpers

    def set_attributes(self):
        return {
            'version'   : 'x.y',
        }

    def set_iterator(self):
        return ArrayIterator(self._dumpers)

class ChannelsDumper(BaseDumper):
    tag_name = 'rhn-channels'
    
    def __init__(self, writer, channels=[]):
        BaseDumper.__init__(self, writer)
        self._channels = channels

    def set_iterator(self):
        if not self._channels:
            # Nothing to do
            return

        raise NotImplementedError, "To be overridden in a child class"

    def dump_subelement(self, data):
       c = _ChannelDumper(self._writer, data)
       c.dump()


class _ChannelDumper(BaseRowDumper):
    tag_name = 'rhn-channel'

    def set_attributes(self):
        channel_id = self._row['id']

        packages = map(lambda x: "rhn-package-%s" % x, self._get_package_ids())
        # XXX channel-errata is deprecated and should go away in dump version
        # 3 or higher - we now dump that information in its own subelement
        # rhn-channel-errata
        errata = map(lambda x: "rhn-erratum-%s" % x, self._get_errata_ids())
        ks_trees = self._get_kickstartable_trees()

        return {
            'channel-id'    : 'rhn-channel-%s' % channel_id,
            'label'         : self._row['label'],
            'org_id'        : self._row['org_id'] or "",
            'channel-arch'  : self._row['channel_arch'],
            'packages'      : string.join(packages),
            'channel-errata' : string.join(errata),
            'kickstartable-trees'   : string.join(ks_trees),
            'has-comps' : self._row['has_comps'],
        }

    _query_channel_families = rhnSQL.Statement("""
        select cf.id, cf.label
          from rhnChannelFamily cf, rhnChannelFamilyMembers cfm
         where cfm.channel_family_id = cf.id
           and cfm.channel_id = :channel_id
    """)
    _query_dist_channel_map = rhnSQL.Statement("""
        select dcm.os, dcm.release, ca.label channel_arch
          from rhnDistChannelMap dcm, rhnChannelArch ca
         where dcm.channel_id = :channel_id
           and dcm.channel_arch_id = ca.id
    """)

    def set_iterator(self):
        channel_id = self._row['id']
        arr = []
        mappings = [ 
            ('rhn-channel-parent-channel', 'parent_channel'),
            ('rhn-channel-basedir', 'basedir'),
            ('rhn-channel-name', 'name'),
            ('rhn-channel-summary', 'summary'),
            ('rhn-channel-description', 'description'),
            ('rhn-channel-gpg-key-url', 'gpg_key_url'),
            ('rhn-channel-checksum-type', 'checksum_type'),
        ]
        for k, v in mappings:
            arr.append(SimpleDumper(self._writer, k, self._row[v]))

        arr.append(SimpleDumper(self._writer, 'rhn-channel-last-modified', 
            _dbtime2timestamp(self._row['last_modified']))
        )
        channel_product_details = self._get_channel_product_details()
        arr.append(SimpleDumper(self._writer, 'rhn-channel-product-name',
            channel_product_details[0]))
        arr.append(SimpleDumper(self._writer, 'rhn-channel-product-version',
            channel_product_details[1]))
        arr.append(SimpleDumper(self._writer, 'rhn-channel-product-beta',
            channel_product_details[2]))

        h = rhnSQL.prepare(self._query_channel_families)
        h.execute(channel_id=channel_id)
        arr.append(ChannelFamiliesDumper(self._writer, data_iterator=h,
            ignore_subelements=1))

        h = rhnSQL.prepare(self._query_dist_channel_map)
        h.execute(channel_id=channel_id)
        arr.append(DistsDumper(self._writer, h))

        # Source package information (with timestamps)
        h = self._get_cursor_source_packages()
        arr.append(ChannelSourcePackagesDumper(self._writer, h))
        # Errata information (with timestamps)
        h = rhnSQL.prepare(self._query__get_errata_ids)
        h.execute(channel_id=channel_id)
        arr.append(ChannelErrataDumper(self._writer, h))

        return ArrayIterator(arr)

    _query_get_package_ids = rhnSQL.Statement("""
        select package_id 
          from rhnChannelPackage
         where channel_id = :channel_id
    """)

    # Things that can be overwriten in subclasses
    def _get_package_ids(self):
        channel_id = self._row['id']

        h = rhnSQL.prepare(self._query_get_package_ids)
        h.execute(channel_id=channel_id)
        return map(lambda x: x['package_id'], h.fetchall_dict() or [])

    _query_get_source_package_ids = rhnSQL.Statement("""
        select distinct ps.id, sr.name source_rpm,
               TO_CHAR(ps.last_modified, 'YYYYMMDDHH24MISS') last_modified
          from rhnChannelPackage cp, rhnPackage p, rhnPackageSource ps,
               rhnSourceRPM sr
         where cp.channel_id = :channel_id
           and cp.package_id = p.id
           and p.source_rpm_id = ps.source_rpm_id
           and ((p.org_id is null and ps.org_id is null) or
               p.org_id = ps.org_id)
           and ps.source_rpm_id = sr.id
    """)
    def _get_cursor_source_packages(self):
        channel_id = self._row['id']

        h = rhnSQL.prepare(self._query_get_source_package_ids)
        h.execute(channel_id=channel_id)
        return h

    _query__get_errata_ids = rhnSQL.Statement("""
        select ce.errata_id, e.advisory_name,
              TO_CHAR(e.last_modified, 'YYYYMMDDHH24MISS') last_modified
          from rhnChannelErrata ce, rhnErrata e
         where ce.channel_id = :channel_id
           and ce.errata_id = e.id
    """)
    
    def _get_errata_ids(self):
        channel_id = self._row['id']

        h = rhnSQL.prepare(self._query__get_errata_ids)
        h.execute(channel_id=channel_id)
        return map(lambda x: x['errata_id'], h.fetchall_dict() or [])

    _query_get_kickstartable_trees = rhnSQL.Statement("""
        select label
          from rhnKickstartableTree
         where channel_id = :channel_id
           and org_id is null
    """)

    def _get_kickstartable_trees(self):
        channel_id = self._row['id']

        h = rhnSQL.prepare(self._query_get_kickstartable_trees)
        h.execute(channel_id=channel_id)
        ks_trees = map(lambda x: x['label'], h.fetchall_dict() or [])
        ks_trees.sort()
        return ks_trees

    _query_get_channel_product_details = rhnSQL.Statement("""
        select cp.product as name,
               cp.version as version,
               cp.beta
        from rhnChannel c,
             rhnChannelProduct cp
        where c.id = :channel_id
          and c.channel_product_id = cp.id
    """)

    def _get_channel_product_details(self):
        """
        Export rhnChannelProduct table content through ChannelDumper

        return a tuple containing (product name, product version, beta status)
        or (None, None, None) if the information is missing
        """

        channel_id = self._row['id']

        h = rhnSQL.prepare(self._query_get_channel_product_details)
        h.execute(channel_id=channel_id)
        row = h.fetchone_dict()
        if not row:
            return (None, None, None)
        else:
            return (row['name'], row['version'], row['beta'])

class ChannelDumper(_ChannelDumper):

    def __init__(self, writer, row):
        BaseRowDumper.__init__(self, writer, row)

    #_query_release_channel_map = rhnSQL.Statement("""
    #    select dcm.os product, dcm.release version,
    #           dcm.eus_release release, ca.label channel_arch,
    #           dcm.is_default is_default
    #      from rhnDistChannelMap dcm, rhnChannelArch ca
    #     where dcm.channel_id = :channel_id
    #       and dcm.channel_arch_id = ca.id
    #       and dcm.is_eus = 'Y'
    #""")

    def set_iterator(self):
        arrayiterator = _ChannelDumper.set_iterator()
        arr = arrayiterator._arr
        mappings = [
            ('rhn-channel-receiving-updates', 'receiving_updates'),
        ]
        for k, v in mappings:
            arr.append(SimpleDumper(self._writer, k, self._row[v]))

        #channel_id = self._row['id']
        ## Add EUS info
        #h = rhnSQL.prepare(self._query_release_channel_map)
        #h.execute(channel_id=channel_id)
        #arr.append(ReleaseDumper(self._writer, h))
        return arrayiterator

#class ReleaseDumper(BaseDumper):
#    tag_name = 'rhn-release'
#
#    def dump_subelement(self, data):
#        d = _ReleaseDumper(self._writer, data)
#        d.dump()
#
#class _ReleaseDumper(BaseRowDumper):
#    tag_name = 'rhn-release'
#
#    def set_attributes(self):
#        return {
#            'product'       : self._row['product'],
#            'version'       : self._row['version'],
#            'release'       : self._row['release'],
#            'channel-arch'  : self._row['channel_arch'],
#            'is-default'  : self._row['is_default'],
#        }

class ChannelSourcePackagesDumper(BaseDumper):
    # Dumps the erratum id and the last modified for an erratum in this
    # channel
    tag_name = 'source-packages'
    def dump_subelement(self, data):
        d = _ChannelSourcePackageDumper(self._writer, data)
        d.dump()

class _ChannelSourcePackageDumper(BaseRowDumper):
    tag_name = 'source-package'
    def set_attributes(self):
        return {
            'id'            : 'rhn-source-package-%s' % self._row['id'],
            'source-rpm'    : self._row['source_rpm'],
            'last-modified' : _dbtime2timestamp(self._row['last_modified']),
        }

class ChannelErrataDumper(BaseDumper):
    # Dumps the erratum id and the last modified for an erratum in this
    # channel
    tag_name = 'rhn-channel-errata'
    def dump_subelement(self, data):
        d = _ChannelErratumDumper(self._writer, data)
        d.dump()

class _ChannelErratumDumper(BaseRowDumper):
    tag_name = 'erratum'
    def set_attributes(self):
        return {
            'id'            : 'rhn-erratum-%s' % self._row['errata_id'],
            'advisory-name' : self._row['advisory_name'],
            'last-modified' : _dbtime2timestamp(self._row['last_modified']),
        }

class DistsDumper(BaseDumper):
    tag_name = 'rhn-dists'

    def dump_subelement(self, data):
        d = _DistDumper(self._writer, data)
        d.dump()

class _DistDumper(BaseRowDumper):
    tag_name = 'rhn-dist'

    def set_attributes(self):
        return {
            'os'            : self._row['os'],
            'release'       : self._row['release'],
            'channel-arch'  : self._row['channel_arch'],
        }

class ChannelFamiliesDumper(BaseDumper):
    tag_name = 'rhn-channel-families'

    def __init__(self, writer, data_iterator=None, ignore_subelements=0, 
            null_max_members=1, virt_filter=0):
        BaseDumper.__init__(self, writer, data_iterator=data_iterator)
        self._ignore_subelements = ignore_subelements
        self._null_max_members = null_max_members
        self.virt_filter = virt_filter

    def set_iterator(self):
        if self._iterator:
            return self._iterator

        h = rhnSQL.prepare('select cf.* from rhnChannelFamily')
        h.execute()
        return h

    def dump_subelement(self, data):
        cf = _ChannelFamilyDumper(self._writer, data, 
            ignore_subelements=self._ignore_subelements,
            null_max_members=self._null_max_members, virt_filter=self.virt_filter)
        cf.dump()


class _ChannelFamilyDumper(BaseRowDumper):
    tag_name = 'rhn-channel-family'

    def __init__(self, writer, row, ignore_subelements=0, null_max_members=1, virt_filter=0):
        BaseRowDumper.__init__(self, writer, row)
        self._ignore_subelements = ignore_subelements
        self._null_max_members = null_max_members

        self._virt_filter      = virt_filter
    
    _query_cf_virt_sublevel = """
        select vsl.label, vsl.name
          from rhnChannelFamilyVirtSubLevel cfvsl,
               rhnVirtSubLevel vsl
         where cfvsl.channel_family_id =: channel_family_id
           and cfvsl.virt_sub_level_id = vsl.id
    """
    def set_iterator(self):
        if self._ignore_subelements:
            return None

        arr = []

        mappings = [ 
            ('rhn-channel-family-name', 'name'),
            ('rhn-channel-family-product-url', 'product_url'),
        ]
        for k, v in mappings:
            arr.append(SimpleDumper(self._writer, k, self._row[v]))

        return ArrayIterator(arr)

    _query_get_channel_family_channels = rhnSQL.Statement("""
        select c.label
          from rhnChannelFamilyMembers cfm, rhnChannel c
         where cfm.channel_family_id = :channel_family_id
           and cfm.channel_id = c.id
    """)
    def set_attributes(self):
        # Get all channels that are part of this channel family
        h = rhnSQL.prepare(self._query_get_channel_family_channels)
        channel_family_id = self._row['id']
        h.execute(channel_family_id=channel_family_id)
        channels = map(lambda x: x['label'], h.fetchall_dict() or [])

        if not self._virt_filter:
            h_virt = rhnSQL.prepare(self._query_cf_virt_sublevel)
            h_virt.execute(channel_family_id=channel_family_id)

            cf_virt_data = h_virt.fetchall_dict() or []
            log_debug(3, cf_virt_data, channel_family_id)

            vsl_label = map(lambda x: x['label'], cf_virt_data)
            cf_vsl_label = string.join(vsl_label)

            vsl_name = map(lambda x: x['name'], cf_virt_data)
            cf_vsl_name = string.join(vsl_name, ',')
        
        attributes = {
            'id'            : "rhn-channel-family-%s" % channel_family_id,
            'label'         : self._row['label'],
            'channel-labels': string.join(channels),
        }
        if not self._virt_filter and cf_virt_data != []:
            attributes['virt-sub-level-label'] = cf_vsl_label
            attributes['virt-sub-level-name'] = cf_vsl_name
            
        if self._ignore_subelements:
            return attributes
        if self._row['label'] != 'rh-public':
            if self._null_max_members:
                attributes['max-members'] = 0
            elif self._row.has_key('max_members') and self._row['max_members']:
                attributes['max-members'] = self._row['max_members']
        return attributes

##
class PackagesDumper(BaseDumper):
    tag_name = 'rhn-packages'

    def set_iterator(self):
        if self._iterator:
            return self._iterator

        # Sample query only
        h = rhnSQL.prepare("""
            select 
                p.id,
                p.org_id, 
                pn.name, 
                pe.evr.version version, 
                pe.evr.release release, 
                pe.evr.epoch epoch, 
                pa.label package_arch,
                pg.name package_group, 
                p.rpm_version, 
                p.description,
                p.summary,
                p.package_size,
                p.payload_size,
                p.build_host, 
                TO_CHAR(p.build_time, 'YYYYMMDDHH24MISS') build_time,
                sr.name source_rpm, 
                c.checksum_type,
                c.checksum,
                p.vendor,
                p.payload_format, 
                p.compat, 
                p.header_sig,
                p.copyright,
                p.cookie,
                p.header_start,
                p.header_end,
                TO_CHAR(p.last_modified, 'YYYYMMDDHH24MISS') last_modified
            from rhnPackage p, rhnPackageName pn, rhnPackageEVR pe, 
                rhnPackageArch pa, rhnPackageGroup pg, rhnSourceRPM sr,
                rhnChecksumView c
            where p.name_id = pn.id
            and p.evr_id = pe.id
            and p.package_arch_id = pa.id
            and p.package_group = pg.id
            and p.source_rpm_id = sr.id
            and p.path is not null
            and p.checksum_id = c.id
            and rownum < 3
        """)
        h.execute()
        return h

    def dump_subelement(self, data):
        p = _PackageDumper(self._writer, data) 
        p.dump()


class _PackageDumper(BaseRowDumper):
    tag_name = 'rhn-package'

    def set_attributes(self):
        attrs = ["name", "version", "release", "package_arch",
            "package_group", "rpm_version", "package_size", "payload_size", 
            "build_host", "source_rpm", "checksum_type", "checksum", "payload_format",
            "compat", "cookie"]
        dict = {
            'id'            : "rhn-package-%s" % self._row['id'],
            'org_id'        : self._row['org_id'] or "",
            'epoch'         : self._row['epoch'] or "",
            'build-time'    : _dbtime2timestamp(self._row['build_time']),
            'last-modified' : _dbtime2timestamp(self._row['last_modified']),
        }
        for attr in attrs:
            dict[string.replace(attr, '_', '-')] = self._row[attr]
        return dict

    def set_iterator(self):
        arr = []

        mappings = [ 
            ('rhn-package-summary', 'summary'),
            ('rhn-package-description', 'description'),
            ('rhn-package-vendor', 'vendor'),
            ('rhn-package-copyright', 'copyright'),
            ('rhn-package-header-sig', 'header_sig'),
            ('rhn-package-header-start', 'header_start'),
            ('rhn-package-header-end', 'header_end')
        ]
        for k, v in mappings:
            arr.append(SimpleDumper(self._writer, k, self._row[v]))

        h = rhnSQL.prepare("""
            select 
                name, text,
                TO_CHAR(time, 'YYYYMMDDHH24MISS') time
            from rhnPackageChangeLog
            where package_id = :package_id
        """)
        h.execute(package_id = self._row['id'])
        arr.append(_ChangelogDumper(self._writer, data_iterator=h))

        # Dependency information
        mappings = [
            ['rhnPackageRequires',   'rhn-package-requires',
                'rhn-package-requires-entry'],
            ['rhnPackageProvides',   'rhn-package-provides',
                'rhn-package-provides-entry'],
            ['rhnPackageConflicts',   'rhn-package-conflicts',
                'rhn-package-conflicts-entry'],
            ['rhnPackageObsoletes',   'rhn-package-obsoletes',
                'rhn-package-obsoletes-entry'],
        ]
        for table_name, container_name, entry_name in mappings:
            h = rhnSQL.prepare("""
                select pc.name, pc.version, pd.sense
                from %s pd, rhnPackageCapability pc
                where pd.capability_id = pc.id
                and pd.package_id = :package_id
            """ % table_name)
            h.execute(package_id = self._row['id'])
            arr.append(_DependencyDumper(self._writer, data_iterator=h, 
                container_name=container_name,
                entry_name=entry_name))

        # Files
        h = rhnSQL.prepare("""
            select 
                pc.name, pf.device, pf.inode, pf.file_mode, pf.username,
                pf.groupname, pf.rdev, pf.file_size,
                TO_CHAR(mtime, 'YYYYMMDDHH24MISS') mtime,
                c.checksum_type, c.checksum, pf.linkto, pf.flags, pf.verifyflags, pf.lang
            from rhnPackageFile pf, rhnPackageCapability pc,
                 rhnChecksumView c
            where pf.capability_id = pc.id
            and pf.package_id = :package_id
            and pf.checksum_id = c.id
        """)
        h.execute(package_id=self._row['id'])
        arr.append(_PackageFilesDumper(self._writer, data_iterator=h))
        return ArrayIterator(arr)

##
class ShortPackagesDumper(BaseDumper):
    tag_name = 'rhn-packages-short'

    def set_iterator(self):
        if self._iterator:
            return self._iterator

        # Sample query only
        h = rhnSQL.prepare("""
            select 
                p.id, 
                pn.name, 
                pe.evr.version version, 
                pe.evr.release release, 
                pe.evr.epoch epoch, 
                pa.label package_arch,
                c.checksum_type,
                c.checksum,
                p.org_id,
                TO_CHAR(p.last_modified, 'YYYYMMDDHH24MISS') last_modified
            from rhnPackage p, rhnPackageName pn, rhnPackageEVR pe, 
                rhnPackageArch pa, rhnChecksumView c
            where p.name_id = pn.id
            and p.evr_id = pe.id
            and p.package_arch_id = pa.id
            and p.path is not null
            and p.checksum_id = c.id
            and rownum < 3
        """)
        h.execute()
        return h

    def dump_subelement(self, data):
        attributes = {}
        attrs = [
            "id", "name", "version", "release", "epoch", 
            "package_arch", "checksum_type", "checksum", "package_size",
        ]
        for attr in attrs:
            attributes[string.replace(attr, '_', '-')] = data[attr]
        attributes['id'] = "rhn-package-%s" % data['id']
        attributes['epoch'] = data['epoch'] or ""
        attributes['last-modified'] = _dbtime2timestamp(data['last_modified'])
        attributes['org-id'] =  data['org_id'] or ""
        d = EmptyDumper(self._writer, 'rhn-package-short',
            attributes=attributes)
        d.dump()

##
class SourcePackagesDumper(BaseDumper):
    tag_name = 'rhn-source-packages'

    def set_iterator(self):
        if self._iterator:
            return self._iterator

        # Sample query only
        h = rhnSQL.prepare("""
            select 
                ps.id, 
                sr.name source_rpm, 
                pg.name package_group, 
                ps.rpm_version, 
                ps.payload_size,
                ps.build_host, 
                TO_CHAR(ps.build_time, 'YYYYMMDDHH24MISS') build_time,
                sig.checksum sigchecksum,
                sig.checksum_type sigchecksum_type,
                ps.vendor,
                ps.cookie,
                ps.package_size,
                c.checksum_type,
                c.checksum,
                TO_CHAR(ps.last_modified, 'YYYYMMDDHH24MISS') last_modified
            from rhnPackageSource ps, rhnPackageGroup pg, rhnSourceRPM sr,
                 rhnChecksumView c, rhnChecksumView sig
            where ps.package_group = pg.id
            and ps.source_rpm_id = sr.id
            and ps.path is not null
            and ps.checksum_id = c.id
            and ps.sigchecksum_id = sig.id
            and rownum < 3
        """)
        h.execute()
        return h

    def dump_subelement(self, data):
        attributes = {}
        attrs = [
            "id", "source_rpm", "package_group", "rpm_version", 
            "payload_size", "build_host", "sigchecksum_type", "sigchecksum", "vendor",
            "cookie", "package_size", "checksum_type", "checksum"
        ]
        for attr in attrs:
            attributes[string.replace(attr, '_', '-')] = data[attr]
        attributes['id'] = "rhn-source-package-%s" % data['id']
        attributes['build-time'] = _dbtime2timestamp(data['build_time'])
        attributes['last-modified'] = _dbtime2timestamp(data['last_modified'])
        d = EmptyDumper(self._writer, 'rhn-source-package',
            attributes=attributes)
        d.dump()

##
class _ChangelogDumper(BaseDumper):
    tag_name = 'rhn-package-changelog'
    
    def dump_subelement(self, data):
        c = _ChangelogEntryDumper(self._writer, data) 
        c.dump()

class _ChangelogEntryDumper(BaseRowDumper):
    tag_name = 'rhn-package-changelog-entry'

    def set_iterator(self):
        arr = []
        mappings = [ 
            ('rhn-package-changelog-entry-name', 'name'),
            ('rhn-package-changelog-entry-text', 'text'),
        ]
        for k, v in mappings:
            arr.append(SimpleDumper(self._writer, k, self._row[v]))

        arr.append(SimpleDumper(self._writer, 'rhn-package-changelog-entry-time',
            _dbtime2timestamp(self._row['time'])))

        return ArrayIterator(arr)

##
class _DependencyDumper(BaseDumper):
    def __init__(self, writer, data_iterator, container_name, entry_name):
        self.tag_name = container_name
        self.entry_name = entry_name
        BaseDumper.__init__(self, writer, data_iterator=data_iterator)

    def dump_subelement(self, data):
        d = EmptyDumper(self._writer, self.entry_name, attributes={
            'name'      : data['name'],
            'version'   : data['version'] or "",
            'sense'     : data['sense'],
        })
        d.dump()

## Files
class _PackageFilesDumper(BaseDumper):
    tag_name = 'rhn-package-files'

    def dump_subelement(self, data):
        data['mtime'] = _dbtime2timestamp(data['mtime'])
        data['checksum_type'] = data['checksum_type'] or ""
        data['checksum'] = data['checksum'] or ""
        if data['checksum_type'] == 'md5':
            # generate md5="..." attribute
            # for compatibility with older satellites
            data['md5'] = data['checksum']
        data['linkto'] = data['linkto'] or ""
        data['lang'] = data['lang'] or ""
        d = EmptyDumper(self._writer, 'rhn-package-file', 
            attributes=data)
        d.dump()

## Errata
class ErrataDumper(BaseDumper):
    tag_name = 'rhn-errata'

    synposis_column = "e.synposis,"

    def set_iterator(self):
        if self._iterator:
            return self._iterator

        _query_errata_info = """
	    select
                    e.id,
                    e.org_id,
                    e.advisory_name,
                    e.advisory,
                    e.advisory_type,
                    e.advisory_rel,
                    e.product,
                    e.description,
                    %s
                    e.topic,
                    e.solution,
                    TO_CHAR(e.issue_date, 'YYYYMMDDHH24MISS') issue_date,
                    TO_CHAR(e.update_date, 'YYYYMMDDHH24MISS') update_date,
                    TO_CHAR(e.last_modified, 'YYYYMMDDHH24MISS') last_modified,
                    e.refers_to,
                    e.notes
             from rhnErrata e
            where rownum < 3
	""" 
        h = rhnSQL.prepare(_query_errata_info % self.synposis_column)
        h.execute()
        return h

    def dump_subelement(self, data):
        d = _ErratumDumper(self._writer, data) 
        d.dump()

class _ErratumDumper(BaseRowDumper):
    tag_name = 'rhn-erratum'

    def set_attributes(self):
        h = rhnSQL.prepare("""
            select c.label
            from rhnChannelErrata ec, rhnChannel c
            where ec.channel_id = c.id
            and ec.errata_id = :errata_id
        """)
        h.execute(errata_id=self._row['id'])
        channels = map(lambda x: x['label'], h.fetchall_dict() or [])

        h = rhnSQL.prepare("""
            select ep.package_id
            from rhnErrataPackage ep
            where ep.errata_id = :errata_id
        """)
        h.execute(errata_id=self._row['id'])
        packages = map(lambda x: "rhn-package-%s" % x['package_id'], 
            h.fetchall_dict() or [])

        h = rhnSQL.prepare("""
            select c.name cve
            from rhnErrataCVE ec, rhnCVE c
            where ec.errata_id = :errata_id
            and ec.cve_id = c.id
        """)
        h.execute(errata_id=self._row['id'])
        cves = map(lambda x: x['cve'], h.fetchall_dict() or [])
        
        return {
            'id'        : 'rhn-erratum-%s' % self._row['id'],
            'org_id'    : self._row['org_id'] or "",
            'advisory'  : self._row['advisory'],
            'channels'  : string.join(channels),
            'packages'  : string.join(packages),
            'cve-names' : string.join(cves),
        }

    type_id_column = ""

    def set_iterator(self):
        arr = []

        mappings = [
            ('rhn-erratum-advisory-name', 'advisory_name', 32),
            ('rhn-erratum-advisory-rel', 'advisory_rel', 32),
            ('rhn-erratum-advisory-type', 'advisory_type', 32),
            ('rhn-erratum-product', 'product', 64),
            ('rhn-erratum-description', 'description', 4000),
            ('rhn-erratum-synopsis', 'synopsis', 4000),
            ('rhn-erratum-topic', 'topic', 4000),
            ('rhn-erratum-solution', 'solution', 4000),
            ('rhn-erratum-refers-to', 'refers_to', 4000),
            ('rhn-erratum-notes', 'notes', 4000),
        ]
        for k, v, b in mappings:
            arr.append(SimpleDumper(self._writer, k, self._row[v] or "", b))
        arr.append(SimpleDumper(self._writer, 'rhn-erratum-issue-date',
            _dbtime2timestamp(self._row['issue_date'])))
        arr.append(SimpleDumper(self._writer, 'rhn-erratum-update-date',
            _dbtime2timestamp(self._row['update_date'])))
        arr.append(SimpleDumper(self._writer, 'rhn-erratum-last-modified',
            _dbtime2timestamp(self._row['last_modified'])))

        h = rhnSQL.prepare("""
            select keyword
            from rhnErrataKeyword
            where errata_id = :errata_id
        """)
        h.execute(errata_id=self._row['id'])
        arr.append(_ErratumKeywordDumper(self._writer, data_iterator=h))

        h = rhnSQL.prepare("""
            select bug_id, summary
            from rhnErrataBuglist
            where errata_id = :errata_id
        """)
        h.execute(errata_id=self._row['id'])
        arr.append(_ErratumBuglistDumper(self._writer, data_iterator=h))
        _query_errata_file_info = """
             select ef.id errata_file_id, c.checksum_type, c.checksum,
                    ef.filename, eft.label type,
                    efp.package_id, efps.package_id source_package_id
               from rhnErrataFile ef, rhnErrataFileType eft,
                    rhnErrataFilePackage efp, rhnErrataFilePackageSource efps,
                    rhnChecksumView c
              where ef.errata_id = :errata_id
                and ef.type = eft.id
                and ef.checksum_id = c.id
                %s
                and ef.id = efp.errata_file_id (+)
                and ef.id = efps.errata_file_id (+)

        """  
        h = rhnSQL.prepare(_query_errata_file_info % self.type_id_column)
        h.execute(errata_id=self._row['id'])
        arr.append(_ErratumFilesDumper(self._writer, data_iterator=h))

        return ArrayIterator(arr)

class ErrataSynopsisDumper(ErrataDumper):
    # include severity into synopsis before
    # exporting to satellite.
    # Also ignore the first 18 characters in
    # the label(errata.sev.label.) from
    # rhnErrataSeverity table
    synposis_column = """
            (select SUBSTR(label,18) || ':'
               from rhnErrataSeverity
              where id = e.severity_id) || e.synopsis synposis,"""

class _ErratumSynopsisDumper(_ErratumDumper):
    # SATSYNC: Ignore the Oval files stuff(typeid=4)
    # while exporting errata File info to satellite
    type_id_column = """and ef.type != (select id
                                           from rhnErrataFileType
                                          where label = 'OVAL')"""

class _ErratumKeywordDumper(BaseDumper):
    tag_name = 'rhn-erratum-keywords'

    def dump_subelement(self, data):
        d = SimpleDumper(self._writer, 'rhn-erratum-keyword', data['keyword'])
        d.dump()

class _ErratumBuglistDumper(BaseDumper):
    tag_name = 'rhn-erratum-bugs'

    def dump_subelement(self, data):
        d = _ErratumBugDumper(self._writer, data)
        d.dump()

class _ErratumBugDumper(BaseRowDumper):
    tag_name = 'rhn-erratum-bug'

    def set_iterator(self):
        arr = [
            SimpleDumper(self._writer, 'rhn-erratum-bug-id', self._row['bug_id']),
            SimpleDumper(self._writer, 'rhn-erratum-bug-summary', 
                self._row['summary'] or ""),
        ]
        return ArrayIterator(arr)

class _ErratumFilesDumper(BaseDumper):
    tag_name = 'rhn-erratum-files'

    def dump_subelement(self, data):
        attributes = {
            'checksum-type'    : data['checksum_type'],
            'checksum'    : data['checksum'],
            # XXX: band-aid - truncate to 128 chars for olde satellites.
            'filename'  : data['filename'][:128],
            'type'      : data['type'],
        }
        # Compute the channels for this file
        h = rhnSQL.prepare("""
            select c.label
            from rhnErrataFileChannel efc, rhnChannel c
            where efc.errata_file_id = :errata_file_id
            and efc.channel_id = c.id
        """)
        h.execute(errata_file_id=data['errata_file_id'])
        channels = string.join(
            map(lambda x: x['label'], h.fetchall_dict() or []))
        if channels:
            attributes['channels'] = channels

        # Get the package id or source_package_id
        if data['type'] == 'RPM':
            package_id = data.get('package_id')
            if package_id is not None:
                attributes['package'] = 'rhn-package-%s' % package_id
        elif data['type'] == 'SRPM':
            package_id = data.get('source_package_id')
            if package_id is not None:
                attributes['source-package'] = 'rhn-package-source-%s' % package_id
        d = EmptyDumper(self._writer, 'rhn-erratum-file', attributes=attributes)
        d.dump()

# Arches
class BaseArchesDumper(BaseDumper):
    table_name = 'foo'
    subelement_tag = 'foo'
    
    def set_iterator(self):
        h = rhnSQL.prepare("""
            select id, label, name
            from %s
        """ % self.table_name)
        h.execute()
        return h

    def dump_subelement(self, data):
        attributes = {
            'id'            : "%s-id-%s" % (self.subelement_tag, data['id']),
            'label'         : data['label'],
            'name'          : data['name'],
        }
        EmptyDumper(self._writer, self.subelement_tag, attributes).dump()

class RestrictedArchesDumper(BaseArchesDumper):
    def __init__(self, writer, data_iterator=None, rpm_arch_type_only=0):
        BaseArchesDumper.__init__(self, writer=writer,
            data_iterator=data_iterator)
        self.rpm_arch_type_only = rpm_arch_type_only

    def set_iterator(self):
        query_templ = """
            select aa.id, aa.label, aa.name, 
                   at.label arch_type_label, at.name arch_type_name
              from %s aa,
                   rhnArchType at
             where aa.arch_type_id = at.id
               %s
        """
        if self.rpm_arch_type_only:
            h = rhnSQL.prepare(query_templ % (self.table_name, "and at.label = 'rpm'"))
        else:
            h = rhnSQL.prepare(query_templ % (self.table_name, ""))
        h.execute()
        return h

    def dump_subelement(self, data):
        attributes = {
            'id'            : "%s-id-%s" % (self.subelement_tag, data['id']),
            'label'         : data['label'],
            'name'          : data['name'],
            'arch-type-label'   : data['arch_type_label'],
            'arch-type-name'    : data['arch_type_name'],
        }
        EmptyDumper(self._writer, self.subelement_tag, attributes).dump()

class ChannelArchesDumper(RestrictedArchesDumper):
    tag_name = 'rhn-channel-arches'
    subelement_tag = 'rhn-channel-arch'
    table_name = 'rhnChannelArch'


class PackageArchesDumper(RestrictedArchesDumper):
    tag_name = 'rhn-package-arches'
    subelement_tag = 'rhn-package-arch'
    table_name = 'rhnPackageArch'


class ServerArchesDumper(RestrictedArchesDumper):
    tag_name = 'rhn-server-arches'
    subelement_tag = 'rhn-server-arch'
    table_name = 'rhnServerArch'


class CPUArchesDumper(BaseArchesDumper):
    tag_name = 'rhn-cpu-arches'
    subelement_tag = 'rhn-cpu-arch'
    table_name = 'rhnCPUArch'

class RestrictedArchCompatDumper(BaseArchesDumper):
    _query_rpm_arch_type_only = ""
    _query_arch_type_all = ""
    _subelement_tag = ""

    def __init__(self, writer, data_iterator=None, rpm_arch_type_only=0, virt_filter=0):
        BaseArchesDumper.__init__(self, writer=writer,
            data_iterator=data_iterator)
        self.rpm_arch_type_only = rpm_arch_type_only
        self.virt_filter = virt_filter

    def set_iterator(self):
        _virt_filter_sql = ""
        if self.virt_filter:
            _virt_filter_sql = """and sgt.label not like 'virt%'"""
        
        if self._subelement_tag == 'rhn-server-group-server-arch-compat':
            if self.rpm_arch_type_only:
                h = rhnSQL.prepare(self._query_rpm_arch_type_only % _virt_filter_sql)
            else:
                h = rhnSQL.prepare(self._query_arch_type_all % _virt_filter_sql)
        else:
            if self.rpm_arch_type_only:
                h = rhnSQL.prepare(self._query_rpm_arch_type_only)
            else:
                h = rhnSQL.prepare(self._query_arch_type_all)

        h.execute()
        return h

    def dump_subelement(self, data):
        EmptyDumper(self._writer, self._subelement_tag, data).dump()
        
class ServerPackageArchCompatDumper(RestrictedArchCompatDumper):
    tag_name = 'rhn-server-package-arch-compatibility-map'
    _subelement_tag = 'rhn-server-package-arch-compat'

    _query_rpm_arch_type_only = rhnSQL.Statement("""
        select sa.label "server-arch", 
            pa.label "package-arch",
            spac.preference
        from rhnServerPackageArchCompat spac, 
            rhnServerArch sa,
            rhnPackageArch pa,
            rhnArchType aas,
            rhnArchType aap
        where spac.server_arch_id = sa.id
        and spac.package_arch_id = pa.id
        and sa.arch_type_id = aas.id
        and aas.label = 'rpm'
        and pa.arch_type_id = aap.id
        and aap.label = 'rpm'
    """)

    _query_arch_type_all = rhnSQL.Statement("""
        select sa.label "server-arch", 
            pa.label "package-arch",
            spac.preference
        from rhnServerPackageArchCompat spac, 
            rhnServerArch sa,
            rhnPackageArch pa
        where spac.server_arch_id = sa.id
        and spac.package_arch_id = pa.id
    """)


class ServerChannelArchCompatDumper(RestrictedArchCompatDumper):
    tag_name = 'rhn-server-channel-arch-compatibility-map'
    _subelement_tag = 'rhn-server-channel-arch-compat'


    _query_rpm_arch_type_only = rhnSQL.Statement("""
        select sa.label "server-arch", 
               ca.label "channel-arch"
          from rhnServerChannelArchCompat scac, 
               rhnServerArch sa,
               rhnChannelArch ca,
               rhnArchType aas,
               rhnArchType aac
         where scac.server_arch_id = sa.id
           and scac.channel_arch_id = ca.id
           and sa.arch_type_id = aas.id
           and aas.label = 'rpm'
           and ca.arch_type_id = aac.id
           and aac.label = 'rpm'
    """)

    _query_arch_type_all = rhnSQL.Statement("""
        select sa.label "server-arch", 
               ca.label "channel-arch"
          from rhnServerChannelArchCompat scac, 
               rhnServerArch sa,
               rhnChannelArch ca
         where scac.server_arch_id = sa.id
           and scac.channel_arch_id = ca.id
    """)


class ChannelPackageArchCompatDumper(RestrictedArchCompatDumper):
    tag_name = 'rhn-channel-package-arch-compatibility-map'
    _subelement_tag = 'rhn-channel-package-arch-compat'

    _query_rpm_arch_type_only = rhnSQL.Statement("""
        select ca.label "channel-arch",
               pa.label "package-arch"
          from rhnChannelPackageArchCompat cpac, 
               rhnChannelArch ca,
               rhnPackageArch pa,
               rhnArchType aac,
               rhnArchType aap
         where cpac.channel_arch_id = ca.id
           and cpac.package_arch_id = pa.id
           and ca.arch_type_id = aac.id
           and aac.label = 'rpm'
           and pa.arch_type_id = aap.id
           and aap.label = 'rpm'
    """)

    _query_arch_type_all = rhnSQL.Statement("""
        select ca.label "channel-arch",
               pa.label "package-arch"
          from rhnChannelPackageArchCompat cpac, 
               rhnChannelArch ca,
               rhnPackageArch pa
         where cpac.channel_arch_id = ca.id
           and cpac.package_arch_id = pa.id
    """)


class ServerGroupTypeDumper(BaseDumper):
    tag_name = 'rhn-server-group-types'

    _query_set_iterator = rhnSQL.Statement("""
        select label, name
          from rhnServerGroupType
    """)
    def set_iterator(self):
        h = rhnSQL.prepare(self._query_set_iterator)
        h.execute()
        return h

    def dump_subelement(self, data):
        EmptyDumper(self._writer, 'rhn-server-group-type', data).dump()


class ServerGroupTypeServerArchCompatDumper(RestrictedArchCompatDumper):
    tag_name = 'rhn-server-group-server-arch-compatibility-map'
    _subelement_tag = 'rhn-server-group-server-arch-compat'

    _query_rpm_arch_type_only = """
        select sgt.label "server-group-type",
               sa.label "server-arch",
               (select vsl.label "virt-sub-level"
                from rhnSGTypeVirtSubLevel sgtvsl,
                     rhnVirtSubLevel vsl
                where sgtvsl.server_group_type_id = sgt.id
                  AND vsl.id = sgtvsl.virt_sub_level_id) as virt_sub_level
          from rhnServerGroupType sgt,
               rhnServerArch sa,
               rhnArchType aas,
               rhnServerServerGroupArchCompat ssgac
         where ssgac.server_arch_id = sa.id
           and sa.arch_type_id = aas.id
           and aas.label = 'rpm'
           and ssgac.server_group_type = sgt.id
           %s
    """

    #_query_arch_type_all = rhnSQL.Statement("""
    _query_arch_type_all = """
        select sgt.label "server-group-type",
               sa.label "server-arch",
               (select vsl.label "virt-sub-level"
                from rhnSGTypeVirtSubLevel sgtvsl,
                     rhnVirtSubLevel vsl
                where sgtvsl.server_group_type_id = sgt.id
                  AND vsl.id = sgtvsl.virt_sub_level_id) as virt_sub_level
          from rhnServerGroupType sgt,
               rhnServerArch sa,
               rhnServerServerGroupArchCompat ssgac
         where ssgac.server_arch_id = sa.id
           and ssgac.server_group_type = sgt.id
           %s
    """

class BlacklistObsoletesDumper(BaseDumper):
    tag_name = 'rhn-blacklist-obsoletes'

    def set_iterator(self):
        h = rhnSQL.prepare("""
            select pn1.name, pe.epoch, pe.version, pe.release, 
                pa.name "package-arch", pn2.name "ignored-name"
            from rhnBlacklistObsoletes bo, 
                rhnPackageName pn1, rhnPackageEVR pe, rhnPackageArch pa,
                rhnPackageName pn2
            where bo.name_id = pn1.id
                and bo.evr_id = pe.id
                and bo.package_arch_id = pa.id
                and bo.ignore_name_id = pn2.id
        """)
        h.execute()
        return h

    def dump_subelement(self, data):
        if data['epoch'] is None:
            data['epoch'] = ""
        EmptyDumper(self._writer, 'rhn-blacklist-obsolete', data).dump()


class KickstartableTreesDumper(BaseDumper):
    tag_name = 'rhn-kickstartable-trees'

    def set_iterator(self):
        h = rhnSQL.prepare("""
            select kt.id, 
                   c.label channel, 
                   kt.base_path "base-path", 
                   kt.label, 
                   kt.boot_image "boot-image",
                   ktt.name "kstree-type-name",
                   ktt.label "kstree-type-label",
                   kit.name "install-type-name",
                   kit.label "install-type-label",
                   TO_CHAR(kt.last_modified, 'YYYYMMDDHH24MISS') "last-modified"
              from rhnKickstartableTree kt,
                   rhnKSTreeType ktt,
                   rhnKSInstallType kit,
                   rhnChannel c
             where kt.channel_id = c.id
               and ktt.id = kt.kstree_type
               and kit.id = kt.install_type
               and kt.org_id is NULL
        """)
        h.execute()
        return h

    def dump_subelement(self, data):
        d = _KickstartableTreeDumper(self._writer, data)
        return d.dump()

class _KickstartableTreeDumper(BaseRowDumper):
    tag_name = 'rhn-kickstartable-tree'

    def set_attributes(self):
        dict = self._row.copy()
        del dict['id']
        # XXX Should we export this one?
        #del dict['base-path']
        last_modified = dict['last-modified']
        dict['last-modified'] = _dbtime2timestamp(last_modified)
        return dict

    def set_iterator(self):
        kstree_id = self._row['id']
        h = rhnSQL.prepare("""
            select relative_filename "relative-path",
                   c.checksum_type "checksum-type",
                   c.checksum,
                   file_size "file-size",
                    TO_CHAR(last_modified, 'YYYYMMDDHH24MISS') "last-modified"
              from rhnKSTreeFile, rhnChecksumView c
             where kstree_id = :kstree_id
               and checksum_id = c.id
        """)
        h.execute(kstree_id=kstree_id)
        return ArrayIterator([_KickstartFilesDumper(self._writer, h)])

class _KickstartFilesDumper(BaseDumper):
    tag_name = 'rhn-kickstart-files'

    def dump_subelement(self, data):
        last_modified = data['last-modified']
        data['last-modified'] = _dbtime2timestamp(last_modified)

        EmptyDumper(self._writer, 'rhn-kickstart-file', data).dump()

class _KickstartTreeTypeDumper(BaseDumper):
    tag_name = 'rhn-kickstart-tree-type'
    # STUB

class _KickstartInstalTypeDumper(BaseDumper):
    tag_name = 'rhn-kickstart-install-type'
    # STUB

def _dbtime2timestamp(val):
    return int(rhnLib.timestamp(val))


def packages_cursor(package_id, sources=0):
    if sources:
        return _source_packages_cursor(package_id)

    h = rhnSQL.prepare("""
        select 
            p.id, 
            pn.name, 
            pe.evr.version version, 
            pe.evr.release release, 
            pe.evr.epoch epoch, 
            pa.label package_arch,
            pg.name package_group, 
            p.rpm_version, 
            p.description,
            p.summary,
            p.package_size,
            p.payload_size,
            p.build_host, 
            TO_CHAR(p.build_time, 'YYYYMMDDHH24MISS') build_time,
            sr.name source_rpm, 
            c.checksum_type,
            c.checksum,
            p.vendor,
            p.payload_format, 
            p.compat, 
            p.header_sig,
            p.header_start,
            p.header_end,
            p.copyright,
            p.cookie 
        from rhnPackage p, rhnPackageName pn, rhnPackageEVR pe, 
            rhnPackageArch pa, rhnPackageGroup pg, rhnSourceRPM sr,
            rhnChecksumView c
        where p.name_id = pn.id
        and p.evr_id = pe.id
        and p.package_arch_id = pa.id
        and p.package_group = pg.id
        and p.source_rpm_id = sr.id
        and p.path is not null
        and p.id = :package_id
        and p.checksum_id = c.id
    """)
    h.execute(package_id=package_id)
    return h


def _source_packages_cursor(package_id):
    h = rhnSQL.prepare("""
        select 
            ps.id, 
            sr.name source_rpm, 
            pg.name package_group, 
            ps.rpm_version, 
            ps.payload_size,
            ps.build_host, 
            TO_CHAR(ps.build_time, 'YYYYMMDDHH24MISS') build_time,
            sig.checksum sigchecksum,
            sig.checksum_type sigchecksum_type,
            ps.vendor,
            ps.cookie,
            ps.package_size,
            c.checksum_type,
            c.checksum
        from rhnPackageSource ps, rhnPackageGroup pg, rhnSourceRPM sr,
             rhnChecksumView c, rhnChecksumView sig
        where ps.package_group = pg.id
        and ps.source_rpm_id = sr.id
        and ps.path is not null
        and ps.id = :package_id
        and ps.checksum_id = c.id
        and ps.sigchecksum_id = sig.id
    """)
    h.execute(package_id=package_id)
    return h


def _errata_cursor(errata_id, synopsis):
    _query_errata_info = """
        select 
            e.id,
            e.advisory_name,
            e.advisory,
            e.advisory_type,
            e.advisory_rel,
            e.product,
            e.description,
            %s
            e.topic,
            e.solution,
            TO_CHAR(e.issue_date, 'YYYYMMDDHH24MISS') issue_date,
            TO_CHAR(e.update_date, 'YYYYMMDDHH24MISS') update_date,
            e.refers_to,
            e.notes
        from rhnErrata e
        where e.id = :errata_id
    """
    h = rhnSQL.prepare(_query_errata_info % synopsis)
    h.execute(errata_id=errata_id)
    return h

def errata_cursor(errata_id):
    return _errata_cursor(errata_id, "e.synopsis,")

def errata_severity_cursor(errata_id):
    # include severity into synopsis before
    # exporting to satellite.
    # Also ignore the first 17 characters in
    # the label(errata.sev.label.) from
    # rhnErrataSeverity table
    synopsis = """
        (select SUBSTR(label,18) || ':'
           from rhnErrataSeverity
          where id = e.severity_id) || e.synopsis synposis,
    """
    return _errata_cursor(errata_id, synopsis)

class ChannelProductsDumper(BaseDumper):
    
    def set_iterator(self):
        h = rhnSQL.prepare("""
            select id, product, version, beta
            from rhnChannelProduct
        """)
        h.execute()
        return h

    def dump_subelement(self, data):
        attributes = {
            'id'            : "rhn-channel-product-id-%s" % (data['id']),
            'product'       : data['product'],
            'version'       : data['version'],
            'beta'          : data['beta'],
        }
        EmptyDumper(self._writer, 'rhn-channel-product', attributes).dump()

class ProductNamesDumper(BaseDumper):
    tag_name = "rhn-product-names"

    def set_iterator(self):
        query = rhnSQL.prepare("""
            select label, name from rhnProductName
        """)
        query.execute()
        return query

    def dump_subelement(self, data):
        EmptyDumper(self._writer, 'rhn-product-name', data).dump()

