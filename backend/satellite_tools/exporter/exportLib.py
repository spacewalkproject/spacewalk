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

import time
from types import StringType

from spacewalk.common import rhnLib
from spacewalk.common.rhnLog import log_debug
from spacewalk.server import rhnSQL

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

class BaseChecksumRowDumper(BaseRowDumper):
    def set_iterator(self):
        # checksums
        checksum_arr = [{'type':  self._row['checksum_type'],
                         'value': self._row['checksum']}]
        arr = [_ChecksumDumper(self._writer, data_iterator=ArrayIterator(checksum_arr))]
        return ArrayIterator(arr)

class BaseQueryDumper(BaseDumper):
    iterator_query = None
    def set_iterator(self):
        if self._iterator:
            return self._iterator
        h = rhnSQL.prepare(self.iterator_query)
        h.execute()
        return h

class BaseSubelementDumper(BaseDumper):
    subelement_dumper_class = None
    def dump_subelement(self, data):
        d = self.subelement_dumper_class(self._writer, data)
        d.dump()

####

class ExportTypeDumper(BaseDumper):
    def __init__(self, writer, start_date=None, end_date=None):
        if start_date:
            self.type = 'incremental'
        else:
            self.type = 'full'
        self.start_date = start_date
        if end_date:
            self.end_date = end_date
        else:
            self.end_date = time.strftime("%Y%m%d%H%M%S")
        BaseDumper.__init__(self, writer)

    def dump(self):
        self._writer.open_tag('export-type')
        self._writer.stream.write(self.type)
        self._writer.close_tag('export-type')
        if self.start_date:
            self._writer.open_tag('export-start-date')
            self._writer.stream.write(self.start_date)
            self._writer.close_tag('export-start-date')
        if self.end_date:
            self._writer.open_tag('export-end-date')
            self._writer.stream.write(self.end_date)
            self._writer.close_tag('export-end-date')

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

class _ChannelDumper(BaseRowDumper):
    tag_name = 'rhn-channel'

    def __init__(self, writer, row, start_date=None, end_date=None, use_rhn_date=True, whole_errata=False):
        BaseRowDumper.__init__(self, writer, row)
        self.start_date = start_date
        self.end_date = end_date
        self.use_rhn_date = use_rhn_date
        self.whole_errata = whole_errata

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
            'packages'      : ' '.join(packages),
            'channel-errata' : ' '.join(errata),
            'kickstartable-trees'   : ' '.join(ks_trees),
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

        comp_last_modified = self._channel_comps_last_modified()
        if comp_last_modified != None:
            arr.append(SimpleDumper(self._writer, 'rhn-channel-comps-last-modified',
                _dbtime2timestamp(comp_last_modified[0]))
            )

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
        query_args = {'channel_id': channel_id}
        if self.start_date:
            query = self._query__get_errata_ids_by_limits
            query_args.update({'lower_limit': self.start_date,
                               'upper_limit': self.end_date})
        else:
            query = self._query__get_errata_ids

        h = rhnSQL.prepare(query)
        h.execute(**query_args)
        arr.append(ChannelErrataDumper(self._writer, h))
        arr.append(ExportTypeDumper(self._writer, self.start_date, self.end_date))

        return ArrayIterator(arr)

    _query_get_package_ids = rhnSQL.Statement("""
        select package_id as id
          from rhnChannelPackage
         where channel_id = :channel_id
    """)

    _query_get_package_ids_by_date_limits = rhnSQL.Statement("""
        select package_id as id
          from rhnChannelPackage rcp
         where rcp.channel_id = :channel_id
           and rcp.modified >= TO_TIMESTAMP(:lower_limit, 'YYYYMMDDHH24MISS')
           and rcp.modified <= TO_TIMESTAMP(:upper_limit, 'YYYYMMDDHH24MISS')
     """)

    _query_get_package_ids_by_rhndate_limits = rhnSQL.Statement("""
        select package_id as id
          from rhnPackage rp, rhnChannelPackage rcp
         where rcp.channel_id = :channel_id
           and rcp.package_id = rp.id
           and rp.last_modified >= TO_TIMESTAMP(:lower_limit, 'YYYYMMDDHH24MISS')
           and rp.last_modified <= TO_TIMESTAMP(:upper_limit, 'YYYYMMDDHH24MISS')
     """)

    _query_get_package_ids_by_date_limits_whole_errata = rhnSQL.Statement("""
        select rcp.package_id as id
          from rhnChannelPackage rcp, rhnPackage rp
            left join rhnErrataPackage rep on rp.id = rep.package_id
            left join rhnErrata re on rep.errata_id = re.id
          rhnErrataPackage rep, rhnErrata re
         where rcp.channel_id = :channel_id
           and rcp.package_id = rp.id
           and ((re.modified >= TO_TIMESTAMP(:lower_limit, 'YYYYMMDDHH24MISS')
               and re.modified <= TO_TIMESTAMP(:upper_limit, 'YYYYMMDDHH24MISS')
            ) or (rep.package_id is NULL
               and rcp.modified >= TO_TIMESTAMP(:lower_limit, 'YYYYMMDDHH24MISS')
               and rcp.modified <= TO_TIMESTAMP(:upper_limit, 'YYYYMMDDHH24MISS'))
            )
     """)

    _query_get_package_ids_by_rhndate_limits_whole_errata = rhnSQL.Statement("""
        select rcp.package_id as id
          from rhnChannelPackage rcp, rhnPackage rp
            left join rhnErrataPackage rep on rp.id = rep.package_id
            left join rhnErrata re on rep.errata_id = re.id
         where rcp.channel_id = :channel_id
           and rcp.package_id = rp.id
           and rp.id = rep.package_id
           and rep.errata_id = re.id
           and ((re.last_modified >= TO_TIMESTAMP(:lower_limit, 'YYYYMMDDHH24MISS')
               and re.last_modified <= TO_TIMESTAMP(:upper_limit, 'YYYYMMDDHH24MISS')
            ) or (rep.package_id is NULL
               and rp.last_modified >= TO_TIMESTAMP(:lower_limit, 'YYYYMMDDHH24MISS')
               and rp.last_modified <= TO_TIMESTAMP(:upper_limit, 'YYYYMMDDHH24MISS'))
            )
     """)


    # Things that can be overwriten in subclasses
    def _get_package_ids(self):
        if self.start_date and self.whole_errata:
            return self._get_ids(self._query_get_package_ids_by_date_limits_whole_errata,
                             self._query_get_package_ids_by_rhndate_limits_whole_errata,
                             self._query_get_package_ids)
        else:
            return self._get_ids(self._query_get_package_ids_by_date_limits,
                             self._query_get_package_ids_by_rhndate_limits,
                             self._query_get_package_ids)

    def _get_ids(self, query_with_limit, query_with_rhnlimit, query_no_limits):
        query_args = {'channel_id': self._row['id']}
        if self.start_date:
            if self.use_rhn_date:
                query = query_with_rhnlimit
            else:
                query = query_with_limit
            query_args.update({'lower_limit': self.start_date,
                               'upper_limit': self.end_date})
        else:
            query = query_no_limits
        h = rhnSQL.prepare(query)
        h.execute(**query_args)
        return map(lambda x: x['id'], h.fetchall_dict() or [])

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
        select ce.errata_id as id, e.advisory_name,
              TO_CHAR(e.last_modified, 'YYYYMMDDHH24MISS') last_modified
          from rhnChannelErrata ce, rhnErrata e
         where ce.channel_id = :channel_id
           and ce.errata_id = e.id
    """)

    _query__get_errata_ids_by_limits = rhnSQL.Statement("""
         %s
           and ce.modified >= TO_TIMESTAMP(:lower_limit, 'YYYYMMDDHH24MISS')
           and ce.modified <= TO_TIMESTAMP(:upper_limit, 'YYYYMMDDHH24MISS')
    """ % _query__get_errata_ids)

    _query__get_errata_ids_by_rhnlimits = rhnSQL.Statement("""
         %s
           and e.last_modified >= TO_TIMESTAMP(:lower_limit, 'YYYYMMDDHH24MISS')
           and e.last_modified <= TO_TIMESTAMP(:upper_limit, 'YYYYMMDDHH24MISS')
    """ % _query__get_errata_ids)
    
    def _get_errata_ids(self):
        return self._get_ids(self._query__get_errata_ids_by_limits,
                             self._query__get_errata_ids_by_rhnlimits,
                             self._query__get_errata_ids)

    _query_get_kickstartable_trees = rhnSQL.Statement("""
        select kt.label as id
          from rhnKickstartableTree kt
         where kt.channel_id = :channel_id
           and kt.org_id is null
    """)

    _query_get_kickstartable_trees_by_rhnlimits = rhnSQL.Statement("""
         %s
           and kt.last_modified >= TO_TIMESTAMP(:lower_limit, 'YYYYMMDDHH24MISS')
           and kt.last_modified <= TO_TIMESTAMP(:upper_limit, 'YYYYMMDDHH24MISS')
    """ % _query_get_kickstartable_trees)

    _query_get_kickstartable_trees_by_limits = rhnSQL.Statement("""
         %s
           and kt.modified >= TO_TIMESTAMP(:lower_limit, 'YYYYMMDDHH24MISS')
           and kt.modified <= TO_TIMESTAMP(:upper_limit, 'YYYYMMDDHH24MISS')
    """ % _query_get_kickstartable_trees)

    def _get_kickstartable_trees(self):
        ks_trees = self._get_ids(self._query_get_kickstartable_trees_by_limits,
                                 self._query_get_kickstartable_trees_by_rhnlimits,
                                 self._query_get_kickstartable_trees)
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

    _query_channel_comps_last_modified = rhnSQL.Statement("""
        select to_char(last_modified, 'YYYYMMDDHH24MISS') as comps_last_modified
        from rhnChannelComps
        where channel_id = :channel_id
        order by id desc
    """)

    def _channel_comps_last_modified(self):
        channel_id = self._row['id']
        h = rhnSQL.prepare(self._query_channel_comps_last_modified)
        h.execute(channel_id=channel_id)
        return h.fetchone()

class ChannelsDumper(BaseSubelementDumper):
    tag_name = 'rhn-channels'
    subelement_dumper_class = _ChannelDumper

    def __init__(self, writer, channels=[]):
        BaseDumper.__init__(self, writer)
        self._channels = channels

    def set_iterator(self):
        if not self._channels:
            # Nothing to do
            return

        raise NotImplementedError, "To be overridden in a child class"


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

class _ChannelSourcePackageDumper(BaseRowDumper):
    tag_name = 'source-package'
    def set_attributes(self):
        return {
            'id'            : 'rhn-source-package-%s' % self._row['id'],
            'source-rpm'    : self._row['source_rpm'],
            'last-modified' : _dbtime2timestamp(self._row['last_modified']),
        }

class ChannelSourcePackagesDumper(BaseSubelementDumper):
    # Dumps the erratum id and the last modified for an erratum in this
    # channel
    tag_name = 'source-packages'
    subelement_dumper_class = _ChannelSourcePackageDumper

class _ChannelErratumDumper(BaseRowDumper):
    tag_name = 'erratum'
    def set_attributes(self):
        return {
            'id'            : 'rhn-erratum-%s' % self._row['id'],
            'advisory-name' : self._row['advisory_name'],
            'last-modified' : _dbtime2timestamp(self._row['last_modified']),
        }

class ChannelErrataDumper(BaseSubelementDumper):
    # Dumps the erratum id and the last modified for an erratum in this
    # channel
    tag_name = 'rhn-channel-errata'
    subelement_dumper_class = _ChannelErratumDumper

class _DistDumper(BaseRowDumper):
    tag_name = 'rhn-dist'

    def set_attributes(self):
        return {
            'os'            : self._row['os'],
            'release'       : self._row['release'],
            'channel-arch'  : self._row['channel_arch'],
        }

class DistsDumper(BaseSubelementDumper):
    tag_name = 'rhn-dists'
    subelement_dumper_class = _DistDumper

class ChannelFamiliesDumper(BaseQueryDumper):
    tag_name = 'rhn-channel-families'
    iterator_query = 'select cf.* from rhnChannelFamily'

    def __init__(self, writer, data_iterator=None, ignore_subelements=0, 
            null_max_members=1, virt_filter=0):
        BaseDumper.__init__(self, writer, data_iterator=data_iterator)
        self._ignore_subelements = ignore_subelements
        self._null_max_members = null_max_members
        self.virt_filter = virt_filter

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
         where cfvsl.channel_family_id = :channel_family_id
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
            cf_vsl_label = ' '.join(vsl_label)

            vsl_name = map(lambda x: x['name'], cf_virt_data)
            cf_vsl_name = ','.join(vsl_name)
        
        attributes = {
            'id'            : "rhn-channel-family-%s" % channel_family_id,
            'label'         : self._row['label'],
            'channel-labels': ' '.join(channels),
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
class _PackageDumper(BaseRowDumper):
    tag_name = 'rhn-package'

    def set_attributes(self):
        attrs = ["name", "version", "release", "package_arch",
            "package_group", "rpm_version", "package_size", "payload_size", 
            "build_host", "source_rpm", "payload_format",
            "compat"]
        dict = {
            'id'            : "rhn-package-%s" % self._row['id'],
            'org_id'        : self._row['org_id'] or "",
            'epoch'         : self._row['epoch'] or "",
            'cookie'        : self._row['cookie'] or "",
            'build-time'    : _dbtime2timestamp(self._row['build_time']),
            'last-modified' : _dbtime2timestamp(self._row['last_modified']),
        }
        for attr in attrs:
            dict[attr.replace('_', '-')] = self._row[attr]
        if self._row['checksum_type'] == 'md5':
            # compatibility with older satellite
            dict['md5sum'] = self._row['checksum']
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

        # checksums
        checksum_arr = [{'type':  self._row['checksum_type'],
                         'value': self._row['checksum']}]
        arr.append(_ChecksumDumper(self._writer,
                        data_iterator=ArrayIterator(checksum_arr)))

        h = rhnSQL.prepare("""
            select 
                name, text,
                TO_CHAR(time, 'YYYYMMDDHH24MISS') as time
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
            ['rhnPackageRecommends',  'rhn-package-recommends',
                'rhn-package-recommends-entry'],
            ['rhnPackageSuggests',  'rhn-package-suggests',
                'rhn-package-suggests-entry'],
            ['rhnPackageSupplements',  'rhn-package-supplements',
                'rhn-package-supplements-entry'],
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
                c.checksum_type as "checksum-type",
                c.checksum, pf.linkto, pf.flags, pf.verifyflags, pf.lang
            from rhnPackageFile pf
            left join rhnChecksumView c
              on pf.checksum_id = c.id,
                rhnPackageCapability pc
            where pf.capability_id = pc.id
            and pf.package_id = :package_id
        """)
        h.execute(package_id=self._row['id'])
        arr.append(_PackageFilesDumper(self._writer, data_iterator=h))
        return ArrayIterator(arr)

class PackagesDumper(BaseSubelementDumper, BaseQueryDumper):
    tag_name = 'rhn-packages'
    subelement_dumper_class = _PackageDumper
    def set_iterator(self):
        return BaseQueryDumper.set_iterator(self)

##
class ShortPackageEntryDumper(BaseChecksumRowDumper):
    tag_name = 'rhn-package-short'

    def set_attributes(self):
        attr = {
            'id'            : "rhn-package-%s" % self._row['id'],
            'name'          : self._row['name'],
            'version'       : self._row['version'],
            'release'       : self._row['release'],
            'epoch'         : self._row['epoch'] or "",
            'package-arch'  : self._row['package_arch'],
            'package-size'  : self._row['package_size'],
            'last-modified' : _dbtime2timestamp(self._row['last_modified']),
            'org-id'        : self._row['org_id'] or "",
        }
        if self._row['checksum_type'] == 'md5':
            # compatibility with older satellite
            attr['md5sum'] = self._row['checksum']
        return attr

class ShortPackagesDumper(BaseSubelementDumper, BaseQueryDumper):
    tag_name = 'rhn-packages-short'
    subelement_dumper_class = ShortPackageEntryDumper
    def set_iterator(self):
        return BaseQueryDumper.set_iterator(self)

##
class SourcePackagesDumper(BaseQueryDumper):
    tag_name = 'rhn-source-packages'
    def dump_subelement(self, data):
        attributes = {}
        attrs = [
            "id", "source_rpm", "package_group", "rpm_version", 
            "payload_size", "build_host", "sigchecksum_type", "sigchecksum", "vendor",
            "cookie", "package_size", "checksum_type", "checksum"
        ]
        for attr in attrs:
            attributes[attr.replace('_', '-')] = data[attr]
        attributes['id'] = "rhn-source-package-%s" % data['id']
        attributes['build-time'] = _dbtime2timestamp(data['build_time'])
        attributes['last-modified'] = _dbtime2timestamp(data['last_modified'])
        d = EmptyDumper(self._writer, 'rhn-source-package',
            attributes=attributes)
        d.dump()

##
class _ChecksumDumper(BaseDumper):
    tag_name = 'checksums'

    def dump_subelement(self, data):
        c = EmptyDumper(self._writer, 'checksum', attributes={
                'type' : data['type'],
                'value': data['value'],
        })
        c.dump()

##
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

class _ChangelogDumper(BaseSubelementDumper):
    tag_name = 'rhn-package-changelog'
    subelement_dumper_class = _ChangelogEntryDumper

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
        data['checksum-type'] = data['checksum-type'] or ""
        data['checksum'] = data['checksum'] or ""
        if data['checksum-type'] in ('md5', ''):
            # generate md5="..." attribute
            # for compatibility with older satellites
            data['md5'] = data['checksum']
        data['linkto'] = data['linkto'] or ""
        data['lang'] = data['lang'] or ""
        d = EmptyDumper(self._writer, 'rhn-package-file', 
            attributes=data)
        d.dump()

## Errata
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
            'channels'  : ' '.join(channels),
            'packages'  : ' '.join(packages),
            'cve-names' : ' '.join(cves),
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
            ('rhn-erratum-errata-from', 'errata_from', 127),
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
            select bug_id, summary, href
            from rhnErrataBuglist
            where errata_id = :errata_id
        """)
        h.execute(errata_id=self._row['id'])
        arr.append(_ErratumBuglistDumper(self._writer, data_iterator=h))
        _query_errata_file_info = """
             select ef.id errata_file_id, c.checksum_type, c.checksum,
                    ef.filename, eft.label as type,
                    efp.package_id, efps.package_id as source_package_id
               from rhnErrataFile ef left outer join rhnErrataFilePackage efp on ef.id = efp.errata_file_id
                    left outer join rhnErrataFilePackageSource efps on ef.id = efps.errata_file_id,
                    rhnErrataFileType eft, rhnChecksumView c
              where ef.errata_id = :errata_id
                and ef.type = eft.id
                and ef.checksum_id = c.id
                %s
        """  
        h = rhnSQL.prepare(_query_errata_file_info % self.type_id_column)
        h.execute(errata_id=self._row['id'])
        arr.append(_ErratumFilesDumper(self._writer, data_iterator=h))

        return ArrayIterator(arr)

class ErrataDumper(BaseSubelementDumper):
    tag_name = 'rhn-errata'
    subelement_dumper_class = _ErratumDumper

    def set_iterator(self):
        if self._iterator:
            return self._iterator
        raise NotImplementedError, "To be overridden in a child class"

class _ErratumKeywordDumper(BaseDumper):
    tag_name = 'rhn-erratum-keywords'

    def dump_subelement(self, data):
        d = SimpleDumper(self._writer, 'rhn-erratum-keyword', data['keyword'])
        d.dump()

class _ErratumBugDumper(BaseRowDumper):
    tag_name = 'rhn-erratum-bug'

    def set_iterator(self):
        arr = [
            SimpleDumper(self._writer, 'rhn-erratum-bug-id', self._row['bug_id']),
            SimpleDumper(self._writer, 'rhn-erratum-bug-summary', 
                self._row['summary'] or ""),
            SimpleDumper(self._writer, 'rhn-erratum-bug-href', self._row['href']),
        ]
        return ArrayIterator(arr)

class _ErratumBuglistDumper(BaseSubelementDumper):
    tag_name = 'rhn-erratum-bugs'
    subelement_dumper_class = _ErratumBugDumper

class _ErratumFileEntryDumper(BaseChecksumRowDumper):
    tag_name = 'rhn-erratum-file'

    def set_attributes(self):
        attributes = {
            # XXX: band-aid - truncate to 128 chars for olde satellites.
            'filename'  : self._row['filename'][:128],
            'type'      : self._row['type'],
        }
        if self._row['checksum_type'] == 'md5':
            attributes['md5sum'] = self._row['checksum']

        # Compute the channels for this file
        h = rhnSQL.prepare("""
            select c.label
            from rhnErrataFileChannel efc, rhnChannel c
            where efc.errata_file_id = :errata_file_id
            and efc.channel_id = c.id
        """)
        h.execute(errata_file_id=self._row['errata_file_id'])
        channels = ' '.join(
            map(lambda x: x['label'], h.fetchall_dict() or []))
        if channels:
            attributes['channels'] = channels

        # Get the package id or source_package_id
        if self._row['type'] == 'RPM':
            package_id = self._row['package_id']
            if package_id is not None:
                attributes['package'] = 'rhn-package-%s' % package_id
        elif self._row['type'] == 'SRPM':
            package_id = self._row['source_package_id']
            if package_id is not None:
                attributes['source-package'] = 'rhn-package-source-%s' % package_id
        return attributes

class _ErratumFilesDumper(BaseSubelementDumper):
    tag_name = 'rhn-erratum-files'
    subelement_dumper_class = _ErratumFileEntryDumper

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
    def dump(self):
        note = """\n<!-- This file is intentionally left empty.
     Older Satellites and Spacewalks require this file to exist in the dump. -->\n"""
        self._writer.stream.write(note)
        self._writer.empty_tag(self.tag_name)

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
            select relative_filename,
                   c.checksum_type,
                   c.checksum,
                   file_size,
                    TO_CHAR(last_modified, 'YYYYMMDDHH24MISS') "last-modified"
              from rhnKSTreeFile, rhnChecksumView c
             where kstree_id = :kstree_id
               and checksum_id = c.id
        """)
        h.execute(kstree_id=kstree_id)
        return ArrayIterator([_KickstartFilesDumper(self._writer, h)])

class KickstartableTreesDumper(BaseSubelementDumper, BaseQueryDumper):
    tag_name = 'rhn-kickstartable-trees'
    subelement_dumper_class = _KickstartableTreeDumper
    iterator_query = """
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
        """
    def set_iterator(self):
        return BaseQueryDumper.set_iterator(self)

class _KickstartFileEntryDumper(BaseChecksumRowDumper):
    tag_name = 'rhn-kickstart-file'

    def set_attributes(self):
        attr = {
            'relative-path': self._row['relative_filename'],
            'file-size'    : self._row['file_size'],
            'last-modified': _dbtime2timestamp(self._row['last-modified']),
        }
        if self._row['checksum_type'] == 'md5':
            attr['md5sum'] = self._row['checksum']
        return attr

class _KickstartFilesDumper(BaseSubelementDumper):
    tag_name = 'rhn-kickstart-files'
    subelement_dumper_class = _KickstartFileEntryDumper

def _dbtime2timestamp(val):
    return int(rhnLib.timestamp(val))


class ProductNamesDumper(BaseDumper):
    tag_name = "rhn-product-names"
    iterator_query = 'select label, name from rhnProductName'

    def dump_subelement(self, data):
        EmptyDumper(self._writer, 'rhn-product-name', data).dump()

