#!/usr/bin/python
# Copyright (C) 2008 Red Hat, Inc.
#
# The actual dumper
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
import math
import gzip
import tempfile
from types import ListType
from cStringIO import StringIO

from common import log_debug, log_error, rhnFault, UserDictCase, rhnCache, \
    CFG, rhnLib
from server import rhnSQL, rhnDatabaseCache
from satellite_tools.exporter import exportLib, xmlWriter
from satellite_exporter import constants
from satellite_exporter.exporter.string_buffer import StringBuffer

# A wrapper class for a database statement
class DatabaseStatement:
    def __init__(self, **kwparams):
        self.statement = None
        self.init_params = kwparams

    def add_params(self, **kwparams):
        self.init_params.update(kwparams)

    def set_statement(self, statement):
        self.statement = statement
        return self

    def execute(self, **kwparams):
        kwparams.update(self.init_params)
        return self.statement.execute(**kwparams)

    def next(self):
        return self.statement.fetchone_dict()

    def __getattr__(self, name):
        return getattr(self.statement, name)

class XML_Dumper:
    def __init__(self, req):
        self.compress_level = 5
        self.headers_out = UserDictCase()
        self._raw_stream = req
        self._raw_stream.content_type = 'application/octet-stream'
        # State machine
        self._headers_sent = 0
        self._is_closed = 0
        self._compressed_stream = None
        # Redefine in subclasses
        self._channel_family_query = """
            select pcf.channel_family_id, to_number(null) quantity
              from rhnPublicChannelFamily pcf
        """

    def _send_headers(self, error=0, init_compressed_stream=1):
        log_debug(4, "is_closed", self._is_closed)
        if self._is_closed:
            raise Exception, "Trying to write to a closed connection"
        if self._headers_sent:
            return
        self._headers_sent = 1
        if self.compress_level:
            self.headers_out['Content-Encoding'] = 'gzip'
        # Send the headers
        if error:
            # No compression
            self.compress_level = 0
            self._raw_stream.content_type = 'text/xml'
        for h, v in self.headers_out.items():
            self._raw_stream.headers_out[h] = str(v)
        self._raw_stream.send_http_header()
        # If need be, start gzipping
        if self.compress_level and init_compressed_stream:
            log_debug(4, "Compressing with factor %s" % self.compress_level)
            self._compressed_stream = gzip.GzipFile(None, "wb",
                self.compress_level, self._raw_stream)

    def send(self, data):
        log_debug(3, "Sending %d bytes" % len(data))
        try:
            self._send_headers()
            if self._compressed_stream:
                log_debug(4, "Sending through a compressed stream")
                self._compressed_stream.write(data)
            else:
                self._raw_stream.write(data)
        except IOError:
            log_error("Client appears to have closed connection")
            self.close()
            raise ClosedConnectionError
        log_debug(5, "Bytes sent", len(data))

    write = send

    def close(self):
        log_debug(2, "Closing")
        if self._is_closed:
            log_debug(3, "Already closed")
            return

        if self._compressed_stream:
            log_debug(5, "Closing a compressed stream")
            try:
                self._compressed_stream.close()
            except IOError, e:
                # Remote end has closed connection already
                log_error("Error closing the stream", str(e))
                pass
            self._compressed_stream = None
        self._is_closed = 1
        log_debug(3, "Closed")

    # Override the get_*_statement methods in subclasses
    def get_channel_families_statement(self):
        query = """
            select cf.*, scf.quantity max_members
              from rhnChannelFamily cf,
                   (%s
                   ) scf
             where scf.channel_family_id = cf.id
        """ % self._channel_family_query
        return DatabaseStatement().set_statement(rhnSQL.prepare(query))

    def get_channels_statement(self):
        query = """
            select c.id channel_id, c.label,
                   TO_CHAR(c.last_modified, 'YYYYMMDDHH24MISS') last_modified
              from rhnChannel c, rhnChannelFamilyMembers cfm,
                   (%s
                   ) scf
             where scf.channel_family_id = cfm.channel_family_id
               and cfm.channel_id = c.id
        """ % self._channel_family_query
        return DatabaseStatement().set_statement(rhnSQL.prepare(query))

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
        return DatabaseStatement().set_statement(rhnSQL.prepare(query))

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
        return DatabaseStatement().set_statement(rhnSQL.prepare(query))

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
        return DatabaseStatement().set_statement(rhnSQL.prepare(query))

    def _get_xml_writer(self):
        return xmlWriter.XMLWriter(stream=StringBuffer(self))

    # Dumper functions here
    def dump_blacklist_obsoletes(self):
        log_debug(2)
        writer = self._get_xml_writer()
        dumper = SatelliteDumper(writer,
            exportLib.BlacklistObsoletesDumper(writer))
        dumper.dump()
        writer.flush()
        log_debug(4, "OK")
        self.close()
        return 0

    def dump_arches(self, rpm_arch_type_only=0):
        log_debug(2)
        writer = self._get_xml_writer()
        dumper = SatelliteDumper(writer,
            exportLib.ChannelArchesDumper(writer,
                rpm_arch_type_only=rpm_arch_type_only),
            exportLib.PackageArchesDumper(writer,
                rpm_arch_type_only=rpm_arch_type_only),
            exportLib.ServerArchesDumper(writer,
                rpm_arch_type_only=rpm_arch_type_only),
            exportLib.CPUArchesDumper(writer),
            exportLib.ServerPackageArchCompatDumper(writer,
                rpm_arch_type_only=rpm_arch_type_only),
            exportLib.ServerChannelArchCompatDumper(writer,
                rpm_arch_type_only=rpm_arch_type_only),
            exportLib.ChannelPackageArchCompatDumper(writer,
                rpm_arch_type_only=rpm_arch_type_only),
        )
        dumper.dump()
        writer.flush()
        log_debug(4, "OK")
        self.close()
        return 0

    def dump_server_group_type_server_arches(self, rpm_arch_type_only=0,
            virt_filter=0):
        log_debug(2)
        writer = self._get_xml_writer()
        dumper = SatelliteDumper(writer,
            exportLib.ServerGroupTypeServerArchCompatDumper(writer,
                rpm_arch_type_only=rpm_arch_type_only, virt_filter=virt_filter),
        )
        dumper.dump()
        writer.flush()
        log_debug(4, "OK")
        self.close()
        return 0

    def dump_channel_families(self, virt_filter=0):
        log_debug(2)

        h = self.get_channel_families_statement()
        h.execute()

        writer = self._get_xml_writer()
        dumper = SatelliteDumper(writer,
            exportLib.ChannelFamiliesDumper(writer,
                data_iterator=h, null_max_members=0, virt_filter=virt_filter),)
        dumper.dump()
        writer.flush()
        log_debug(4, "OK")
        self.close()
        return 0

    def dump_channels(self, channel_labels=None):
        log_debug(2)
        channels = self._validate_channels(channel_labels=channel_labels)

        writer = self._get_xml_writer()
        dumper = SatelliteDumper(writer, ChannelsDumper(writer,
            channels=channels.values()))
        dumper.dump()
        writer.flush()
        log_debug(4, "OK")
        self.close()
        return 0

    def dump_channel_packages_short(self, channel_label, last_modified):
        log_debug(2, channel_label)
        channels = self._validate_channels(channel_labels=[channel_label])
        channel_obj = channels[channel_label]
        db_last_modified = int(rhnLib.timestamp(channel_obj['last_modified']))
        last_modified = int(rhnLib.timestamp(last_modified))
        log_debug(3, "last modified", last_modified, "db last modified",
            db_last_modified)
        if last_modified != db_last_modified:
            raise rhnFault(3013, "The requested channel version does not match"
                " the upstream version", explain=0)
        channel_id = channel_obj['channel_id']
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
        self._send_headers(init_compressed_stream=0)
        while 1:
            buff = stream.read(buffer_size)
            if not buff:
                break
            try:
                self._raw_stream.write(buff)
            except IOError:
                log_error("Client disconnected prematurely")
                self.close()
                raise ClosedConnectionError
        # We're done
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
        # Caches the short package entries for channel_id
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
        # Given a compressed stream, will either return the stream, or will
        # decompress it and return it, depending on the compression level
        # self.compress_level
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

    def _packages(self, packages, prefix, dump_class, sources=0):
        if sources:
            h = self.get_source_packages_statement()
        else:
            h = self.get_packages_statement()

        packages_hash = {}
        for package in packages:
            package = str(package)
            if package[:len(prefix)] != prefix:
                raise rhnFault(3002, "Invalid package name %s" % package)
            package_id = package[len(prefix):]
            try:
                package_id = int(package_id)
            except ValueError:
                raise rhnFault(3002, "Invalid package name %s" % package)
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

        writer = self._get_xml_writer()
        dumper = SatelliteDumper(writer,
            dump_class(writer, packages_hash.values()))
        dumper.dump()
        writer.flush()
        log_debug(4, "OK")
        self.close()
        return 0

    def dump_errata(self, errata):
        log_debug(2)

        h = self.get_errata_statement()

        errata_hash = {}
        prefix = 'rhn-erratum-'
        for erratum in errata:
            erratum = str(erratum)
            if erratum[:len(prefix)] != prefix:
                raise rhnFault(3004, "Wrong erratum name %s" % erratum)
            errata_id = erratum[len(prefix):]
            try:
                errata_id = int(errata_id)
            except ValueError:
                raise rhnFault(3004, "Wrong erratum name %s" % erratum)
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

        writer = self._get_xml_writer()
        dumper = SatelliteDumper(writer,
            ErrataDumper(writer, errata_hash.values()))
        dumper.dump()
        writer.flush()
        log_debug(4, "OK")
        self.close()
        return 0

    def dump_kickstartable_trees(self, kickstart_labels=None):
        log_debug(2)
        kickstarts = self._validate_kickstarts(
            kickstart_labels=kickstart_labels)

        writer = self._get_xml_writer()
        dumper = SatelliteDumper(writer,
            KickstartableTreesDumper(writer, kickstarts=kickstarts))
        dumper.dump()
        writer.flush()
        log_debug(4, "OK")
        self.close()
        return 0

    def dump_product_names(self):
        log_debug(4)
        writer = self._get_xml_writer()
        dumper = SatelliteDumper(writer, exportLib.ProductNamesDumper(writer))
        dumper.dump()
        writer.flush()
        self.close()
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
        if not channel_labels:
            channels = all_channels_hash
        else:
            channels = {}
            for label in channel_labels:
                if not all_channels_hash.has_key(label):
                    raise rhnFault(3001, "Could not retrieve channel %s" %
                        label)
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
    # Overriding with our own version
    def set_attributes(self):
        attributes = exportLib.SatelliteDumper.set_attributes(self)
        attributes['version'] = constants.PROTOCOL_VERSION
        attributes['generation'] = CFG.SAT_CERT_GENERATION
        return attributes


# A query iterator successively applies the list of params as execute() to the
# statement that was passed in, and presents the union of the result sets as a
# single result set.
# Params is a list of dictionaries that would fill the named bound variables
# from the statement
class QueryIterator:
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

    def _execute_next(self):
        log_debug(4)
        self._params_pos = self._params_pos + 1
        if self._params_pos == len(self._params):
            log_debug(5, "Done")
            self._statement = None
            return None
        self._statement.execute(**self._params[self._params_pos])

# This class will attempt to retrieve information, either from the database or
# from a local cache
#
# Note that we expect at most one result set per database query - this can be
# easily fixed if we need more
class CachedQueryIterator:
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
        # Make sure we remove references to these objects, or circular
        # references can occur
        log_debug(3, "Closing the iterator")
        self._statement = None
        self._cache_get = None
        self._params = None


class CachedDumper(exportLib.BaseDumper):
    def __init__(self, writer, statement, params):
        iterator = CachedQueryIterator(statement, params,
            cache_get=self.cache_get)
        exportLib.BaseDumper.__init__(self, writer, data_iterator=iterator)
        self.use_database_cache = CFG.USE_DATABASE_CACHE
        log_debug(1, "Use database cache", self.use_database_cache)

    def _get_last_modified(self, params):
        # To be overwritten
        return params['last_modified']

    def _get_key(self, params):
        raise NotImplementedError

    def cache_get(self, params):
        log_debug(4, params)
        key = self._get_key(params)
        last_modified = self._get_last_modified(params)
        if not self.use_database_cache:
            return rhnCache.get(key, modified=last_modified, raw=1)
        return rhnDatabaseCache.get(key, modified=last_modified, raw=1,
            compressed=1)

    def cache_set(self, params, value):
        log_debug(4, params)
        last_modified = self._get_last_modified(params)
        key = self._get_key(params)
        if not self.use_database_cache:
            return rhnCache.set(key, value, modified=last_modified, raw=1)
        return rhnDatabaseCache.set(key, value, modified=last_modified, raw=1,
            compressed=1)

    def _dump_subelement(self, data):
        # To be overridden in subclasses
        pass

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
        self._dump_subelement(row)
        log_debug(5,
            "Timer for _dump_subelement: %.2f" % (time.time() - start))

        # Restore the old writer
        self.set_writer(ow)

        self.cache_set(params, s.getvalue())


class ChannelsDumper(CachedDumper, exportLib.ChannelsDumper):
    _query_list_channels = rhnSQL.Statement("""
        select c.id, c.label, ca.label channel_arch, c.basedir, c.name,
               c.summary, c.description, c.gpg_key_url, c.org_id,
               TO_CHAR(c.last_modified, 'YYYYMMDDHH24MISS') last_modified,
               c.channel_product_id,
               pc.label parent_channel,
               cp.product channel_product,
               cp.version channel_product_version,
               cp.beta channel_product_beta,
               c.receiving_updates
          from rhnChannel c, rhnChannelArch ca, rhnChannel pc, rhnChannelProduct cp
         where c.id = :channel_id
           and c.channel_arch_id = ca.id
           and c.parent_channel = pc.id (+)
           and c.channel_product_id = cp.id (+)
    """)
    def __init__(self, writer, channels):
        h = rhnSQL.prepare(self._query_list_channels)
        CachedDumper.__init__(self, writer, statement=h, params=channels)

    def _get_key(self, params):
        channel_id = params['channel_id']
        return "xml-channels/rhn-channel-%d.xml" % channel_id

    def _dump_subelement(self, data):
        log_debug(6, data)
        return exportLib.ChannelsDumper.dump_subelement(self, data)

class ShortPackagesDumper(CachedDumper, exportLib.ShortPackagesDumper):
    def __init__(self, writer, packages):
        h = rhnSQL.prepare("""
            select
                p.id,
                p.org_id,
                pn.name,
                pe.evr.version version,
                pe.evr.release release,
                pe.evr.epoch epoch,
                pa.label package_arch,
                p.md5sum,
                p.package_size,
                TO_CHAR(p.last_modified, 'YYYYMMDDHH24MISS') last_modified
            from rhnPackage p, rhnPackageName pn, rhnPackageEVR pe,
                rhnPackageArch pa
            where p.id = :package_id
            and p.name_id = pn.id
            and p.evr_id = pe.id
            and p.package_arch_id = pa.id
        """)
        CachedDumper.__init__(self, writer, statement=h, params=packages)

    def _get_key(self, params):
        package_id = params['package_id']
        hash_val = hash_object_id(package_id, 100)
        return "xml-short-packages/%s/rhn-package-short-%s.xml" % (
            hash_val, package_id)

    def _dump_subelement(self, data):
        log_debug(6, data)
        return exportLib.ShortPackagesDumper.dump_subelement(self, data)

class PackagesDumper(CachedDumper, exportLib.PackagesDumper):
    def __init__(self, writer, packages):
        h = rhnSQL.prepare("""
            select
                p.id,
                pn.name,
                p.org_id,
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
                p.md5sum,
                p.vendor,
                p.payload_format,
                p.compat,
                p.header_sig,
                p.header_start,
                p.header_end,
                p.copyright,
                p.cookie,
                TO_CHAR(p.last_modified, 'YYYYMMDDHH24MISS') last_modified
            from rhnPackage p, rhnPackageName pn, rhnPackageEVR pe,
                rhnPackageArch pa, rhnPackageGroup pg, rhnSourceRPM sr
            where p.id = :package_id
            and p.name_id = pn.id
            and p.evr_id = pe.id
            and p.package_arch_id = pa.id
            and p.package_group = pg.id
            and p.source_rpm_id = sr.id
        """)
        CachedDumper.__init__(self, writer, statement=h, params=packages)

    def _get_key(self, params):
        package_id = params['package_id']
        hash_val = hash_object_id(package_id, 100)
        return "xml-packages/%s/rhn-package-%s.xml" % (hash_val, package_id)

    def _dump_subelement(self, data):
        log_debug(6, data)
        return exportLib.PackagesDumper.dump_subelement(self, data)

class SourcePackagesDumper(CachedDumper, exportLib.SourcePackagesDumper):
    def __init__(self, writer, packages):
        h = rhnSQL.prepare("""
            select
                ps.id,
                sr.name source_rpm,
                pg.name package_group,
                ps.rpm_version,
                ps.payload_size,
                ps.build_host,
                TO_CHAR(ps.build_time, 'YYYYMMDDHH24MISS') build_time,
                ps.sigmd5,
                ps.vendor,
                ps.cookie,
                ps.package_size,
                ps.md5sum,
                TO_CHAR(ps.last_modified, 'YYYYMMDDHH24MISS') last_modified
            from rhnPackageSource ps, rhnPackageGroup pg, rhnSourceRPM sr
            where ps.id = :package_id
            and ps.package_group = pg.id
            and ps.source_rpm_id = sr.id
        """)
        CachedDumper.__init__(self, writer, statement=h, params=packages)

    def _get_key(self, params):
        package_id = params['package_id']
        hash_val = hash_object_id(package_id, 100)
        return "xml-packages/%s/rhn-source-package-%s.xml" % (hash_val,
                package_id)

    def _dump_subelement(self, data):
        log_debug(6, data)
        return exportLib.SourcePackagesDumper.dump_subelement(self, data)


class ErrataDumper(CachedDumper, exportLib.ErrataSynopsisDumper):
    def __init__(self, writer, errata):
        h = rhnSQL.prepare("""
            select
                e.id,
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
                e.notes
            from rhnErrata e
            where e.id = :errata_id
        """)
        CachedDumper.__init__(self, writer, statement=h, params=errata)

    def _get_key(self, params):
        errata_id = params['errata_id']
        hash_val = hash_object_id(errata_id, 10)
        return "xml-errata/%s/rhn-erratum-%s.xml" % (hash_val, errata_id)

    def _dump_subelement(self, data):
        log_debug(6, data)
        return exportLib.ErrataSynopsisDumper.dump_subelement(self, data)

class KickstartableTreesDumper(CachedDumper,
        exportLib.KickstartableTreesDumper):
    _query_lookup_ks_tree = rhnSQL.Statement("""
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
    def __init__(self, writer, kickstarts):
        h = rhnSQL.prepare(self._query_lookup_ks_tree)
        CachedDumper.__init__(self, writer, statement=h, params=kickstarts)

    def _get_key(self, params):
        kickstart_label = params['kickstart_label']
        return "xml-kickstartable-tree/%s.xml" % kickstart_label

    def _dump_subelement(self, data):
        log_debug(6, data)
        return exportLib.KickstartableTreesDumper.dump_subelement(self, data)

# This looks complicated; it returns the (integer part of)
# obj_id, modulo factor
# The string is left padded with as many 0 chars as necessary to
# match factor
def hash_object_id(obj_id, factor):
    # Make sure obj_id is a string
    obj_id = str(obj_id)
    format = int(math.ceil(math.log10(factor)))
    format = "%%0%sd" % format
    return format % (int(obj_id.split('-')[-1]) % factor, )

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
