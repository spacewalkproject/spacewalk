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

import time
import gzip
import sys
import tempfile
from types import ListType
from cStringIO import StringIO

from spacewalk.common import rhnCache, rhnLib, rhnFlags
from spacewalk.common.rhnLog import log_debug, log_error
from spacewalk.common.rhnConfig import CFG
from spacewalk.common.rhnException import rhnFault
from spacewalk.server import rhnSQL
from spacewalk.satellite_tools import constants
from spacewalk.satellite_tools.exporter import exportLib, xmlWriter
from string_buffer import StringBuffer


class XML_Dumper:

    def __init__(self):
        self.compress_level = 5
        self.llimit = None
        self.ulimit = None
        self._channel_family_query = """
             select cf.id channel_family_id, to_number(null, null) quantity
             from rhnChannelFamily cf
        """
        self.channel_ids = []
        self.channel_ids_for_families = []
        self.exportable_orgs = 'null'
        self._raw_stream = None

    def send(self, data):
        # to be overwritten in subclass
        pass

    def close(self):
        # to be overwritten in subclass
        pass

    def get_channel_families_statement(self):
        query = """
            select cf.*, scf.quantity max_members
              from rhnChannelFamily cf,
                   (%s
                   ) scf
             where scf.channel_family_id = cf.id
        """ % self._channel_family_query
        return rhnSQL.prepare(query)

    @staticmethod
    def get_orgs_statement(org_ids):
        query = """
            select wc.id, wc.name
              from web_customer wc
             where wc.id in (%s)
        """ % org_ids
        return rhnSQL.prepare(query)

    @staticmethod
    def get_channel_families_statement_new(cids):

        args = {
            'ch_ids': cids
        }

        query = """
            select distinct cf.*, to_number(null, null) max_members
              from rhnchannelfamily cf, rhnchannelfamilymembers cfm
              where cf.id = cfm.channel_family_id and cfm.channel_id in ( %(ch_ids)s )
        """
        return rhnSQL.prepare(query % args)

    def get_channels_statement(self):
        query = """
            select c.id channel_id, c.label,
                   ct.label as checksum_type,
                   TO_CHAR(c.last_modified, 'YYYYMMDDHH24MISS') last_modified
              from rhnChannel c left outer join rhnChecksumType ct on c.checksum_type_id = ct.id,
                   rhnChannelFamilyMembers cfm,
                   (%s
                   ) scf
             where scf.channel_family_id = cfm.channel_family_id
               and cfm.channel_id = c.id
        """ % self._channel_family_query
        return rhnSQL.prepare(query)

    def get_packages_statement(self):
        query = """
            select p.id package_id,
                   TO_CHAR(p.last_modified, 'YYYYMMDDHH24MISS') last_modified
              from rhnChannelPackage cp, rhnPackage p,
                   rhnChannelFamilyMembers cfm,
                   (%s
                   ) scf
             where scf.channel_family_id = cfm.channel_family_id
               and cfm.channel_id = cp.channel_id
               and cp.package_id = :package_id
               and p.id = :package_id
        """ % self._channel_family_query
        return rhnSQL.prepare(query)

    def get_source_packages_statement(self):
        query = """
            select ps.id package_id,
                   TO_CHAR(ps.last_modified, 'YYYYMMDDHH24MISS') last_modified
              from rhnChannelPackage cp, rhnPackage p, rhnPackageSource ps,
                   rhnChannelFamilyMembers cfm,
                   (%s
                   ) scf
             where scf.channel_family_id = cfm.channel_family_id
               and cfm.channel_id = cp.channel_id
               and cp.package_id = p.id
               and p.source_rpm_id = ps.source_rpm_id
               and ((p.org_id is null and ps.org_id is null) or
                     p.org_id = ps.org_id)
               and ps.id = :package_id
        """ % self._channel_family_query
        return rhnSQL.prepare(query)

    def get_errata_statement(self):
        query = """
            select e.id errata_id,
                   TO_CHAR(e.last_modified, 'YYYYMMDDHH24MISS') last_modified
              from rhnChannelErrata ce, rhnErrata e,
                   rhnChannelFamilyMembers cfm,
                   (%s
                   ) scf
             where scf.channel_family_id = cfm.channel_family_id
               and cfm.channel_id = ce.channel_id
               and ce.errata_id = :errata_id
               and e.id = :errata_id
        """ % self._channel_family_query
        return rhnSQL.prepare(query)

    def _get_xml_writer(self):
        return xmlWriter.XMLWriter(stream=StringBuffer(self))

    def _write_dump(self, item_dumper_class, **kwargs):
        writer = self._get_xml_writer()
        dumper = SatelliteDumper(writer, item_dumper_class(writer, **kwargs))
        dumper.dump()
        writer.flush()
        log_debug(4, "OK")

    # Dumper functions here
    def dump_blacklist_obsoletes(self):
        log_debug(2)
        self._write_dump(exportLib.BlacklistObsoletesDumper)
        return 0

    def dump_arches(self, rpm_arch_type_only=0):
        log_debug(2)
        writer = self._get_xml_writer()
        dumper = SatelliteDumper(
            writer,
            exportLib.ChannelArchesDumper(writer, rpm_arch_type_only=rpm_arch_type_only),
            exportLib.PackageArchesDumper(writer, rpm_arch_type_only=rpm_arch_type_only),
            exportLib.ServerArchesDumper(writer, rpm_arch_type_only=rpm_arch_type_only),
            exportLib.CPUArchesDumper(writer),
            exportLib.ServerPackageArchCompatDumper(writer, rpm_arch_type_only=rpm_arch_type_only),
            exportLib.ServerChannelArchCompatDumper(writer, rpm_arch_type_only=rpm_arch_type_only),
            exportLib.ChannelPackageArchCompatDumper(writer, rpm_arch_type_only=rpm_arch_type_only))
        dumper.dump()
        writer.flush()
        log_debug(4, "OK")
        self.close()
        return 0

    def dump_server_group_type_server_arches(self, rpm_arch_type_only=0,
                                             virt_filter=0):
        log_debug(2)
        self._write_dump(exportLib.ServerGroupTypeServerArchCompatDumper,
                         rpm_arch_type_only=rpm_arch_type_only, virt_filter=virt_filter)
        return 0

    def dump_channel_families(self):
        log_debug(2)

        cids = ','.join([str(x['channel_id']) for x in self.channel_ids + self.channel_ids_for_families])

        h = self.get_channel_families_statement_new(cids)
        h.execute()

        self._write_dump(exportLib.ChannelFamiliesDumper,
                         data_iterator=h, null_max_members=0)
        return 0

    def set_exportable_orgs(self, org_list):
        if not org_list or len(org_list) == 0:
            self.exportable_orgs = 'null'
        elif isinstance(org_list, type('')):
            self.exportable_orgs = org_list
        else:
            self.exportable_orgs = ', '.join([str(x) for x in org_list])

    def dump_orgs(self):
        log_debug(2)

        h = self.get_orgs_statement(self.exportable_orgs)
        h.execute()

        self._write_dump(exportLib.OrgsDumper, data_iterator=h)
        return 0

    def dump_channels(self, channel_labels=None, start_date=None, end_date=None, use_rhn_date=True, whole_errata=False):
        log_debug(2)
        #channels = self._validate_channels(channel_labels=channel_labels)

        self._write_dump(ChannelsDumper,
                         channels=channel_labels, start_date=start_date, end_date=end_date, use_rhn_date=use_rhn_date,
                         whole_errata=whole_errata)
        return 0

    def _send_headers(self, error=0, init_compressed_stream=1):
        """to be overwritten in subclass"""
        pass

    def dump_channel_packages_short(self, channel_label, last_modified, filepath=None,
                                    validate_channels=False, send_headers=False,
                                    open_stream=True):
        log_debug(2, channel_label)
        if validate_channels:
            channels = self._validate_channels(channel_labels=[channel_label])
            channel_obj = channels[channel_label]
        else:
            channels = channel_label
            channel_obj = channels
        db_last_modified = int(rhnLib.timestamp(channel_obj['last_modified']))
        last_modified = int(rhnLib.timestamp(last_modified))
        log_debug(3, "last modified", last_modified, "db last modified",
                  db_last_modified)
        if last_modified != db_last_modified:
            raise rhnFault(3013, "The requested channel version does not match"
                           " the upstream version", explain=0)
        channel_id = channel_obj['channel_id']
        if filepath:
            key = filepath
        else:
            key = "xml-channel-packages/rhn-channel-%d.data" % channel_id
        # Try to get everything off of the cache
        val = rhnCache.get(key, compressed=0, raw=1, modified=last_modified)
        if val is None:
            # Not generated yet
            log_debug(4, "Cache MISS for %s (%s)" % (channel_label,
                                                     channel_id))
            stream = self._cache_channel_packages_short(channel_id, key,
                                                        last_modified)
        else:
            log_debug(4, "Cache HIT for %s (%s)" % (channel_label,
                                                    channel_id))
            temp_stream = tempfile.TemporaryFile()
            temp_stream.write(val)
            temp_stream.flush()
            stream = self._normalize_compressed_stream(temp_stream)

        # Copy the results to the output stream
        # They shold be already compressed if they were requested to be
        # compressed
        buffer_size = 16384
        # Send the HTTP headers - but don't init the compressed stream since
        # we send the data ourselves
        if send_headers:
            self._send_headers(init_compressed_stream=0)
        if open_stream:
            self._raw_stream = open(key, "w")
        while 1:
            buff = stream.read(buffer_size)
            if not buff:
                break
            try:
                self._raw_stream.write(buff)
            except IOError:
                log_error("Client disconnected prematurely")
                self.close()
                raise ClosedConnectionError, None, sys.exc_info()[2]
        # We're done
        if open_stream:
            self._raw_stream.close()
        return 0

    _query_get_channel_packages = rhnSQL.Statement("""
        select cp.package_id,
               TO_CHAR(p.last_modified, 'YYYYMMDDHH24MISS') last_modified
          from rhnChannelPackage cp,
               rhnPackage p
         where cp.channel_id = :channel_id
           and cp.package_id = p.id
    """)

    def _cache_channel_packages_short(self, channel_id, key, last_modified):
        """ Caches the short package entries for channel_id """
        # Create a temporary file
        temp_stream = tempfile.TemporaryFile()
        # Always compress the result
        compress_level = 5
        stream = gzip.GzipFile(None, "wb", compress_level, temp_stream)
        writer = xmlWriter.XMLWriter(stream=stream)

        # Fetch packages
        h = rhnSQL.prepare(self._query_get_channel_packages)
        h.execute(channel_id=channel_id)
        package_ids = h.fetchall_dict() or []
        # Sort packages
        package_ids.sort(lambda a, b: cmp(a['package_id'], b['package_id']))

        dumper = SatelliteDumper(writer,
                                 ShortPackagesDumper(writer, package_ids))
        dumper.dump()
        writer.flush()
        # We're done with the stream object
        stream.close()
        del stream
        temp_stream.seek(0, 0)
        # Set the value in the cache. We don't recompress the result since
        # it's already compressed
        rhnCache.set(key, temp_stream.read(), modified=last_modified,
                     compressed=0, raw=1)
        return self._normalize_compressed_stream(temp_stream)

    def _normalize_compressed_stream(self, stream):
        """ Given a compressed stream, will either return the stream, or will
            decompress it and return it, depending on the compression level
            self.compress_level
        """
        stream.seek(0, 0)
        if self.compress_level:
            # Output should be compressed; nothing else to to
            return stream
        # Argh, have to decompress
        return gzip.GzipFile(None, "rb", 0, stream)

    def dump_packages(self, packages):
        log_debug(2)
        return self._packages(packages, prefix='rhn-package-',
                              dump_class=PackagesDumper)

    def dump_packages_short(self, packages):
        log_debug(2)
        return self._packages(packages, prefix='rhn-package-',
                              dump_class=ShortPackagesDumper)

    def dump_source_packages(self, packages):
        log_debug(2)
        return self._packages(packages, prefix='rhn-source-package-',
                              dump_class=SourcePackagesDumper, sources=1)

    @staticmethod
    def _get_item_id(prefix, name, errnum, errmsg):
        prefix_len = len(prefix)
        if name[:prefix_len] != prefix:
            raise rhnFault(errnum, errmsg % name)
        try:
            uuid = int(name[prefix_len:])
        except ValueError:
            raise rhnFault(errnum, errmsg % name), None, sys.exc_info()[2]
        return uuid

    def _packages(self, packages, prefix, dump_class, sources=0,
                  verify_packages=False):
        packages_hash = {}
        if verify_packages:
            if sources:
                h = self.get_source_packages_statement()
            else:
                h = self.get_packages_statement()

            for package in packages:
                package_id = self._get_item_id(prefix, str(package),
                                               3002, 'Invalid package name %s')
                if packages_hash.has_key(package_id):
                    # Already verified
                    continue
                h.execute(package_id=package_id)
                row = h.fetchone_dict()
                if not row:
                    # XXX Silently ignore it?
                    raise rhnFault(3003, "No such package %s" % package)
                # Saving the row, it's handy later when we create the iterator
                packages_hash[package_id] = row
        else:
            for package in packages:
                packages_hash[package['package_id']] = package

        self._write_dump(dump_class, params=packages_hash.values())
        return 0

    def dump_errata(self, errata, verify_errata=False):
        log_debug(2)

        errata_hash = {}
        if verify_errata:
            h = self.get_errata_statement()
            for erratum in errata:
                errata_id = self._get_item_id('rhn-erratum-', str(erratum),
                                              3004, "Wrong erratum name %s")
                if errata_hash.has_key(errata_id):
                    # Already verified
                    continue
                h.execute(errata_id=errata_id)
                row = h.fetchone_dict()
                if not row:
                    # XXX Silently ignore it?
                    raise rhnFault(3005, "No such erratum %s" % erratum)
                # Saving the row, it's handy later when we create the iterator
                errata_hash[errata_id] = row
        else:
            for erratum in errata:
                errata_hash[erratum['errata_id']] = erratum

        self._write_dump(ErrataDumper, params=errata_hash.values())
        return 0

    def dump_kickstartable_trees(self, kickstart_labels=None,
                                 validate_kickstarts=False):
        log_debug(2)
        if validate_kickstarts:
            kickstart_labels = self._validate_kickstarts(
                kickstart_labels=kickstart_labels)

        self._write_dump(KickstartableTreesDumper, params=kickstart_labels)
        return 0

    def _validate_channels(self, channel_labels=None):
        log_debug(4)
        # Sanity check
        if channel_labels:
            if not isinstance(channel_labels, ListType):
                raise rhnFault(3000,
                               "Expected list of channels, got %s" % type(channel_labels))

        h = self.get_channels_statement()
        h.execute()
        # Hash the list of all available channels based on the label
        all_channels_hash = {}
        while 1:
            row = h.fetchone_dict()
            if not row:
                break
            all_channels_hash[row['label']] = row

        # Intersect the list of channels they've sent to us
        iss_slave_sha256_capable = (float(rhnFlags.get('X-RHN-Satellite-XML-Dump-Version'))
                                    >= constants.SHA256_SUPPORTED_VERSION)

        if not channel_labels:
            channels = all_channels_hash
        else:
            channels = {}
            for label in channel_labels:
                if not all_channels_hash.has_key(label):
                    raise rhnFault(3001, "Could not retrieve channel %s" %
                                   label)
                if not (iss_slave_sha256_capable
                        or all_channels_hash[label]['checksum_type'] in [None, 'sha1']):
                    raise rhnFault(3001,
                                   ("Channel %s has incompatible rpm checksum (%s). Please contact\n"
                                    + "Red Hat support for information about upgrade to newer version\n"
                                    + "of Satellite Server which supports it.") %
                                   (label, all_channels_hash[label]['checksum_type']))
                channels[label] = all_channels_hash[label]

        return channels

    _query_validate_kickstarts = rhnSQL.Statement("""
        select kt.label kickstart_label,
               TO_CHAR(kt.modified, 'YYYYMMDDHH24MISS') last_modified
          from rhnKickstartableTree kt
         where kt.channel_id = :channel_id
           and kt.org_id is null
    """)

    def _validate_kickstarts(self, kickstart_labels):
        log_debug(4)
        # Saity check
        if kickstart_labels:
            if not isinstance(kickstart_labels, ListType):
                raise rhnFault(3000,
                               "Expected list of kickstart labels, got %s" %
                               type(kickstart_labels))

        all_ks_hash = {}

        h = self.get_channels_statement()
        h.execute()

        hk = rhnSQL.prepare(self._query_validate_kickstarts)
        while 1:
            channel = h.fetchone_dict()
            if not channel:
                break

            hk.execute(channel_id=channel['channel_id'])
            while 1:
                row = hk.fetchone_dict()
                if not row:
                    break
                all_ks_hash[row['kickstart_label']] = row

        if not kickstart_labels:
            return all_ks_hash.values()

        result = []
        for l in kickstart_labels:
            if all_ks_hash.has_key(l):
                result.append(all_ks_hash[l])

        return result


class SatelliteDumper(exportLib.SatelliteDumper):

    def set_attributes(self):
        """ Overriding with our own version """
        attributes = exportLib.SatelliteDumper.set_attributes(self)
        attributes['version'] = constants.PROTOCOL_VERSION
        attributes['generation'] = CFG.SAT_CERT_GENERATION
        return attributes


class QueryIterator:

    """ A query iterator successively applies the list of params as execute() to the
        statement that was passed in, and presents the union of the result sets as a
        single result set.
        Params is a list of dictionaries that would fill the named bound variables
        from the statement.
    """

    def __init__(self, statement, params):
        self._statement = statement
        self._params = params
        # Position in the params list
        self._params_pos = -1
        self._result_set_exhausted = 1

    def fetchone_dict(self):
        log_debug(4)
        while 1:
            if self._result_set_exhausted:
                # Nothing to do here, move to the next set of params
                pos = self._params_pos
                pos = pos + 1
                self._params_pos = pos
                if pos == len(self._params):
                    # End of the list, we're done
                    return None
                # Execute the satement
                log_debug(5, "Using param", pos, self._params[pos])
                self._statement.execute(**self._params[pos])
                self._result_set_exhausted = 0
                # Go back into the loop
                continue

            # Result set not exhausted yet
            row = self._statement.fetchone_dict()
            if row:
                return row

            self._result_set_exhausted = 1


class CachedQueryIterator:

    """ This class will attempt to retrieve information, either from the database or
        from a local cache.

        Note that we expect at most one result set per database query - this can be
        easily fixed if we need more.
    """

    def __init__(self, statement, params, cache_get):
        self._statement = statement
        # XXX params has to be a list of hashes, containing at least a
        # last_modified - which is stripped before the execution of the
        # statement
        self._params = params
        self._params_pos = 0
        self._cache_get = cache_get

    def fetchone_dict(self):
        log_debug(4)
        while 1:
            if self._params_pos == len(self._params):
                log_debug(4, "End of iteration")
                self.close()
                return None
            log_debug(4, "Fetching set for param", self._params_pos)
            # Get the last modified attribute
            params = self._params[self._params_pos]
            self._params_pos = self._params_pos + 1

            # Look up the object in the cache
            val = self._cache_get(params)
            if val is not None:
                # Entry is cached
                log_debug(2, "Cache HIT for %s" % params)
                return val

            log_debug(4, "Cache MISS for %s" % params)
            start = time.time()
            self._execute(params)
            row = self._statement.fetchone_dict()

            if row:
                log_debug(5, "Timer: %.2f" % (time.time() - start))
                return (params, row)

        # Dummy return
        return None

    def _execute(self, params):
        log_debug(4, params)
        self._statement.execute(**params)

    def close(self):
        """ Make sure we remove references to these objects, or circular
            references can occur.
        """
        log_debug(3, "Closing the iterator")
        self._statement = None
        self._cache_get = None
        self._params = None


class CachedDumper(exportLib.BaseDumper):
    iterator_query = None
    item_id_key = 'id'
    hash_factor = 1
    key_template = 'dump/%s/dump-%s.xml'

    def __init__(self, writer, params):
        statement = rhnSQL.prepare(self.iterator_query)
        iterator = CachedQueryIterator(statement, params,
                                       cache_get=self.cache_get)
        exportLib.BaseDumper.__init__(self, writer, data_iterator=iterator)
        self.non_cached_class = self.__class__.__bases__[1]

    @staticmethod
    def _get_last_modified(params):
        """ To be overwritten. """
        return params['last_modified']

    def _get_key(self, params):
        item_id = str(params[self.item_id_key])
        hash_val = rhnLib.hash_object_id(item_id, self.hash_factor)
        return self.key_template % (hash_val, item_id)

    def cache_get(self, params):
        log_debug(4, params)
        key = self._get_key(params)
        last_modified = self._get_last_modified(params)
        return rhnCache.get(key, modified=last_modified, raw=1)

    def cache_set(self, params, value):
        log_debug(4, params)
        last_modified = self._get_last_modified(params)
        key = self._get_key(params)
        return rhnCache.set(key, value, modified=last_modified,
                            raw=1, user='apache', group='apache', mode=0755)

    def dump_subelement(self, data):
        log_debug(2)
        # CachedQueryIterator returns (params, row) as data
        params, row = data
        s = StringIO()
        # Back up the old writer and replace it with a StringIO-based one
        ow = self.get_writer()
        # Use into a tee stream (which writes to both streams at the same
        # time)
        tee_stream = TeeStream(s, ow.stream)
        self.set_writer(xmlWriter.XMLWriter(stream=tee_stream, skip_xml_decl=1))

        start = time.time()
        # call dump_subelement() from original (non-cached) class
        self.non_cached_class.dump_subelement(self, row)
        log_debug(5,
                  "Timer for _dump_subelement: %.2f" % (time.time() - start))

        # Restore the old writer
        self.set_writer(ow)

        self.cache_set(params, s.getvalue())


class ChannelsDumper(exportLib.ChannelsDumper):
    _query_list_channels = rhnSQL.Statement("""
        select c.id, c.org_id,
               c.label, ca.label channel_arch, c.basedir, c.name,
               c.summary, c.description, c.gpg_key_url,
               ct.label checksum_type,
               TO_CHAR(c.last_modified, 'YYYYMMDDHH24MISS') last_modified,
               pc.label parent_channel, c.channel_access
          from rhnChannel c left outer join rhnChannel pc on c.parent_channel = pc.id
               left outer join rhnChecksumType ct on c.checksum_type_id = ct.id, rhnChannelArch ca
         where c.id = :channel_id
           and c.channel_arch_id = ca.id
    """)

    def __init__(self, writer, channels=(), start_date=None, end_date=None, use_rhn_date=True, whole_errata=False):
        exportLib.ChannelsDumper.__init__(self, writer, channels)
        self.start_date = start_date
        self.end_date = end_date
        self.use_rhn_date = use_rhn_date
        self.whole_errata = whole_errata

    def dump_subelement(self, data):
        log_debug(6, data)
        # return exportLib.ChannelsDumper.dump_subelement(self, data)
        # pylint: disable=W0212
        c = exportLib._ChannelDumper(self._writer, data, self.start_date, self.end_date,
                                     self.use_rhn_date, self.whole_errata)
        c.dump()

    def set_iterator(self):
        if not self._channels:
            # Nothing to do
            return

        h = rhnSQL.prepare(self._query_list_channels)
        return QueryIterator(statement=h, params=self._channels)


class ChannelsDumperEx(CachedDumper, exportLib.ChannelsDumper):
    iterator_query = rhnSQL.Statement("""
        select c.id, c.label, ca.label channel_arch, c.basedir, c.name,
               c.summary, c.description, c.gpg_key_url, c.org_id,
               TO_CHAR(c.last_modified, 'YYYYMMDDHH24MISS') last_modified,
               c.channel_product_id,
               pc.label parent_channel,
               cp.product channel_product,
               cp.version channel_product_version,
               cp.beta channel_product_beta,
               c.receiving_updates,
               ct.label checksum_type,
               c.channel_access
          from rhnChannel c left outer join rhnChannel pc on c.parent_channel = pc.id
               left outer join rhnChannelProduct cp on c.channel_product_id = cp.id
               left outer join rhnChecksumType ct on c.checksum_type_id = ct.id,
               rhnChannelArch ca
         where c.id = :channel_id
           and c.channel_arch_id = ca.id
    """)

    def _get_key(self, params):
        channel_id = params['channel_id']
        return "xml-channels/rhn-channel-%d.xml" % channel_id


class ShortPackagesDumper(CachedDumper, exportLib.ShortPackagesDumper):
    iterator_query = rhnSQL.Statement("""
            select
                p.id,
                p.org_id,
                pn.name,
                (pe.evr).version as version,
                (pe.evr).release as release,
                (pe.evr).epoch as epoch,
                pa.label as package_arch,
                c.checksum_type,
                c.checksum,
                p.package_size,
                TO_CHAR(p.last_modified, 'YYYYMMDDHH24MISS') as last_modified
            from rhnPackage p, rhnPackageName pn, rhnPackageEVR pe,
                rhnPackageArch pa, rhnChecksumView c
            where p.id = :package_id
            and p.name_id = pn.id
            and p.evr_id = pe.id
            and p.package_arch_id = pa.id
            and p.checksum_id = c.id
        """)
    item_id_key = 'package_id'
    hash_factor = 2
    key_template = 'xml-short-packages/%s/rhn-package-short-%s.xml'


class PackagesDumper(CachedDumper, exportLib.PackagesDumper):
    iterator_query = rhnSQL.Statement("""
            select
                p.id,
                p.org_id,
                pn.name,
                (pe.evr).version as version,
                (pe.evr).release as release,
                (pe.evr).epoch as epoch,
                pa.label as package_arch,
                pg.name as package_group,
                p.rpm_version,
                p.description,
                p.summary,
                p.package_size,
                p.payload_size,
                p.installed_size,
                p.build_host,
                TO_CHAR(p.build_time, 'YYYYMMDDHH24MISS') as build_time,
                sr.name as source_rpm,
                c.checksum_type,
                c.checksum,
                p.vendor,
                p.payload_format,
                p.compat,
                p.header_sig,
                p.header_start,
                p.header_end,
                p.copyright,
                p.cookie,
                TO_CHAR(p.last_modified, 'YYYYMMDDHH24MISS') as last_modified
            from rhnPackage p, rhnPackageName pn, rhnPackageEVR pe,
                rhnPackageArch pa, rhnPackageGroup pg, rhnSourceRPM sr,
                rhnChecksumView c
            where p.id = :package_id
            and p.name_id = pn.id
            and p.evr_id = pe.id
            and p.package_arch_id = pa.id
            and p.package_group = pg.id
            and p.source_rpm_id = sr.id
            and p.checksum_id = c.id
        """)
    item_id_key = 'package_id'
    hash_factor = 2
    key_template = 'xml-packages/%s/rhn-package-%s.xml'


class SourcePackagesDumper(CachedDumper, exportLib.SourcePackagesDumper):
    iterator_query = rhnSQL.Statement("""
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
            where ps.id = :package_id
            and ps.package_group = pg.id
            and ps.source_rpm_id = sr.id
            and ps.checksum_id = c.id
            and ps.sigchecksum_id = sig.id
        """)
    item_id_key = 'package_id'
    hash_factor = 2
    key_template = 'xml-packages/%s/rhn-source-package-%s.xml'


class ErrataDumper(exportLib.ErrataDumper):
    iterator_query = rhnSQL.Statement("""
            select
                e.id,
                e.org_id,
                e.advisory_name,
                e.advisory,
                e.advisory_type,
                e.advisory_rel,
                e.product,
                e.description,
                e.synopsis,
                e.topic,
                e.solution,
                TO_CHAR(e.issue_date, 'YYYYMMDDHH24MISS') issue_date,
                TO_CHAR(e.update_date, 'YYYYMMDDHH24MISS') update_date,
                TO_CHAR(e.last_modified, 'YYYYMMDDHH24MISS') last_modified,
                e.refers_to,
                e.notes,
                e.errata_from
            from rhnErrata e
            where e.id = :errata_id
        """)

    def __init__(self, writer, params):
        statement = rhnSQL.prepare(self.iterator_query)
        iterator = QueryIterator(statement, params)
        exportLib.ErrataDumper.__init__(self, writer, iterator)


class KickstartableTreesDumper(CachedDumper, exportLib.KickstartableTreesDumper):
    iterator_query = rhnSQL.Statement("""
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
           and kt.label = :kickstart_label
    """)

    def _get_key(self, params):
        kickstart_label = params['kickstart_label']
        return "xml-kickstartable-tree/%s.xml" % kickstart_label


class ClosedConnectionError(Exception):
    pass


class TeeStream:

    """Writes to multiple streams at the same time"""

    def __init__(self, *streams):
        self.streams = streams

    def write(self, data):
        log_debug(6, "Writing %s bytes" % len(data))
        for stream in self.streams:
            stream.write(data)
