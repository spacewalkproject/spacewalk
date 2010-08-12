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
import gzip
import string
import tempfile
import re
from types import ListType
from cStringIO import StringIO

from common import log_debug, log_error, rhnFault, UserDictCase, rhnCache, \
    CFG, rhnLib, rhnFlags
from server import rhnSQL, rhnDatabaseCache
from satellite_tools import constants
from satellite_tools.exporter import exportLib, xmlWriter
from string_buffer import StringBuffer

# globals

LOWER_LIMIT = None

UPPER_LIMIT = None

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
        return apply(self.statement.execute, (), kwparams)

    def next(self):
        return self.statement.fetchone_dict()

    def __getattr__(self, name):
        return getattr(self.statement, name)

class XML_Dumper:
    def __init__(self):
        self.compress_level = 5
        self.llimit = None
        self.ulimit = None
        self._channel_family_query = """
             select cf.id channel_family_id, to_number(null) quantity
             from rhnChannelFamily cf
        """
        #self._channel_family_query = """
        #    select pcf.channel_family_id, to_number(null) quantity
        #      from rhnPublicChannelFamily pcf
        #"""

    def get_channel_families_statement(self):
        query = """
            select cf.*, scf.quantity max_members
              from rhnChannelFamily cf,
                   (%s
                   ) scf
             where scf.channel_family_id = cf.id
        """ % self._channel_family_query
        return DatabaseStatement().set_statement(rhnSQL.prepare(query))

    def get_channel_families_statement_new(self, cids):
        
        args = {
	   'ch_ids'	: cids
        }

        query = """
            select unique cf.*, to_number(null) max_members 
              from rhnchannelfamily cf, rhnchannelfamilymembers cfm
              where cf.id = cfm.channel_family_id and cfm.channel_id in ( %(ch_ids)s )
        """
        return DatabaseStatement().set_statement(rhnSQL.prepare(query % args))

        
    def get_channels_statement(self):
        query = """
            select c.id channel_id, c.label,
	           ct.label as checksum_type,
                   TO_CHAR(c.last_modified, 'YYYYMMDDHH24MISS') last_modified
              from rhnChannel c, rhnChannelFamilyMembers cfm,
	           rhnChecksumType ct,
                   (%s
                   ) scf
             where scf.channel_family_id = cfm.channel_family_id
               and cfm.channel_id = c.id
	       and c.checksum_type_id = ct.id(+)
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

    def dump_channel_families(self):
        log_debug(2)

        cids = ','.join(map(lambda x:str(x['channel_id']), self.channel_ids + self.channel_ids_for_families))

        h = self.get_channel_families_statement_new(cids)
        h.execute()

        writer = self._get_xml_writer()
        dumper = SatelliteDumper(writer, 
            exportLib.ChannelFamiliesDumper(writer,
                data_iterator=h, null_max_members=0))

        dumper.dump()
        writer.flush()
        log_debug(4, "OK")
        self.close()
        return 0

    def dump_channels(self, channel_labels=None, start_date=None, end_date=None):
        log_debug(2)
        #channels = self._validate_channels(channel_labels=channel_labels)

        writer = self._get_xml_writer()

        dumper = SatelliteDumper(writer, 
            ChannelsDumper(writer, channel_labels, start_date, end_date))
        dumper.dump()
        writer.flush()
        log_debug(4, "OK")
        self.close()
        return 0

    def dump_channel_packages_short(self, channel_label, last_modified, filepath=None):
        log_debug(2, channel_label)
        channels = channel_label
        #channels = self._validate_channels(channel_labels=[channel_label])
        channel_obj = channels #channels[channel_label]
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
        #self._send_headers(init_compressed_stream=0)
        self._raw_stream = open(key, "w")
        while 1:
            buff = stream.read(buffer_size)
            if not buff:
                break
            self._raw_stream.write(buff)
        # We're done
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
        
    def _packages(self, packages, prefix, dump_class, sources=0):
        if sources:
            h = self.get_source_packages_statement()
        else:
            h = self.get_packages_statement()
        
        packages_hash = {}
        for package in packages:
            packages_hash[package['package_id']] = package
        #packages_hash = {} 
        #for package in packages:
        #    package = str(package)
        #    if package[:len(prefix)] != prefix:
        #        raise rhnFault(3002, "Invalid package name %s" % package)
        #    package_id = package[len(prefix):]
        #    try:
        #        package_id = int(package_id)
        #    except ValueError:
        #        raise rhnFault(3002, "Invalid package name %s" % package)
        #    if packages_hash.has_key(package_id):
        #        # Already verified
        #        continue
        #    h.execute(package_id=package_id)
        #    row = h.fetchone_dict()
        #    if not row:
        #        # XXX Silently ignore it?
        #        raise rhnFault(3003, "No such package %s" % package)
        #    # Saving the row, it's handy later when we create the iterator
        #    packages_hash[package_id] = row
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
        for erratum in errata:
            errata_hash[erratum['errata_id']] = erratum

        prefix = 'rhn-erratum-'
        #for erratum in errata:
        #    erratum = str(erratum)
        #    if erratum[:len(prefix)] != prefix:
        #        raise rhnFault(3004, "Wrong erratum name %s" % erratum)
        #    errata_id = erratum[len(prefix):]
        #    try:
        #        errata_id = int(errata_id)
        #    except ValueError:
        #        raise rhnFault(3004, "Wrong erratum name %s" % erratum)
        #    if errata_hash.has_key(errata_id):
        #        # Already verified
        #        continue
        #    h.execute(errata_id=errata_id)
        #    row = h.fetchone_dict()
        #    if not row:
        #        # XXX Silently ignore it?
        #        raise rhnFault(3005, "No such erratum %s" % erratum)
        #    # Saving the row, it's handy later when we create the iterator
        #    errata_hash[errata_id] = row

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
        #kickstarts = self._validate_kickstarts(
        #    kickstart_labels=kickstart_labels)
        
        
        writer = self._get_xml_writer()
        dumper = SatelliteDumper(writer, 
            KickstartableTreesDumper(writer, kickstarts=kickstart_labels))
        dumper.dump()
        writer.flush()
        log_debug(4, "OK")
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
	iss_slave_sha256_capable = (float(rhnFlags.get('X-RHN-Satellite-XML-Dump-Version')) >= constants.SHA256_SUPPORTED_VERSION)

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
                      "Channel %s has incompatible rpm checksum (%s). Please contact\n"
                      + "Red Hat support for information about upgrade to newer version\n"
                      + "of Satellite Server which supports it." %
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
                apply(self._statement.execute, (), self._params[pos])
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
        apply(self._statement.execute, (), self._params[self._params_pos])
        
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
        apply(self._statement.execute, (), params)

    def close(self):
        """ Make sure we remove references to these objects, or circular
            references can occur.
        """
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
        """ To be overwritten. """
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
            set_cache = rhnCache.set(key, value, modified=last_modified, \
                        raw=1, user='apache', group='apache', mode=0755)
            return set_cache
        return rhnDatabaseCache.set(key, value, modified=last_modified, raw=1,
            compressed=1)

    def _dump_subelement(self, data):
        """ To be overridden in subclasses. """
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

class ChannelsDumper(exportLib.ChannelsDumper):
    _query_list_channels = rhnSQL.Statement("""
        select c.id, c.org_id, 
	       c.label, ca.label channel_arch, c.basedir, c.name, 
               c.summary, c.description, c.gpg_key_url,
               ct.label checksum_type,
               TO_CHAR(c.last_modified, 'YYYYMMDDHH24MISS') last_modified, 
               pc.label parent_channel
          from rhnChannel c, rhnChannelArch ca, rhnChannel pc,
               rhnChecksumType ct
         where c.id = :channel_id
           and c.channel_arch_id = ca.id
           and c.parent_channel = pc.id (+)
           and c.checksum_type_id = ct.id (+)
    """)

    def __init__(self, writer, channels=[], start_date=None, end_date=None):
        exportLib.ChannelsDumper.__init__(self, writer, channels)
        self.start_date = start_date
        self.end_date = end_date

    def __format_date(self, writer, date):
	""" Takes date in format YYYYMMDDHH24MISS and write it to writer in format:
        <date><year>YY</year>....<second>SS</second></date>
        """
        m = re.match(r"(....)(..)(..)(..)(..)(..)", date)
        writer.open_tag('date')
        writer.open_tag('year')
        writer.stream.write(m.group(1))
        writer.close_tag('year')
        writer.open_tag('month')
        writer.stream.write(m.group(2))
        writer.close_tag('month')
        writer.open_tag('day')
        writer.stream.write(m.group(3))
        writer.close_tag('day')
        writer.open_tag('hour')
        writer.stream.write(m.group(4))
        writer.close_tag('hour')
        writer.open_tag('minute')
        writer.stream.write(m.group(5))
        writer.close_tag('minute')
        writer.open_tag('second')
        writer.stream.write(m.group(6))
        writer.close_tag('second')
        writer.close_tag('date')

    def dump_subelement(self, data):
        log_debug(6, data)
        #return exportLib.ChannelsDumper.dump_subelement(self, data)
        c = _ChannelsDumper(self._writer, data)
        c.dump()
        if self.start_date:
            export_type = 'incremental'
        else:
            export_type = 'full'
        self._writer.open_tag('export',  attributes={'type': export_type})
	if self.start_date:
            self._writer.open_tag('start-date')
            self.__format_date(self._writer, self.start_date)
            self._writer.close_tag('start-date')
        if self.end_date:
            end_date = self.end_date
        else:
            end_date = time.strftime("%Y%m%d%H%M%S")
        self._writer.open_tag('end-date')
        self.__format_date(self._writer, end_date)
        self._writer.close_tag('end-date')

        self._writer.close_tag('export')

    def set_iterator(self):
        if not self._channels:
            # Nothing to do
            return

        h = rhnSQL.prepare(self._query_list_channels)
        return QueryIterator(statement=h, params=self._channels)

class _ChannelsDumper(exportLib._ChannelDumper):
    tag_name = 'rhn-channel'

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
            arr.append(exportLib.SimpleDumper(self._writer, k, self._row[v]))

        arr.append(exportLib.SimpleDumper(self._writer, 'rhn-channel-last-modified',
            exportLib._dbtime2timestamp(self._row['last_modified']))
        )

        channel_product_details = self._get_channel_product_details()
        arr.append(exportLib.SimpleDumper(self._writer, 'rhn-channel-product-name',
            channel_product_details[0]))
        arr.append(exportLib.SimpleDumper(self._writer, 'rhn-channel-product-version',
            channel_product_details[1]))
        arr.append(exportLib.SimpleDumper(self._writer, 'rhn-channel-product-beta',
            channel_product_details[2]))

        comp_last_modified = self._channel_comps_last_modified()
        if comp_last_modified != None:
            arr.append(exportLib.SimpleDumper(self._writer, 'rhn-channel-comps-last-modified',
                exportLib._dbtime2timestamp(comp_last_modified[0]))
            )

        h = rhnSQL.prepare(self._query_channel_families)
        h.execute(channel_id=channel_id)
        arr.append(exportLib.ChannelFamiliesDumper(self._writer, data_iterator=h,
            ignore_subelements=1))

        h = rhnSQL.prepare(self._query_dist_channel_map)
        h.execute(channel_id=channel_id)
        arr.append(exportLib.DistsDumper(self._writer, h))

        # Source package information (with timestamps)
        h = self._get_cursor_source_packages()
        arr.append(exportLib.ChannelSourcePackagesDumper(self._writer, h))
        # Errata information (with timestamps)
        if LOWER_LIMIT:
            h = rhnSQL.prepare(self._query__get_errata_ids_by_limits)
            h.execute(channel_id=channel_id, lower_limit=LOWER_LIMIT, upper_limit=UPPER_LIMIT)
        else:
            h = rhnSQL.prepare(self._query__get_errata_ids)
            h.execute(channel_id=channel_id)
        arr.append(exportLib.ChannelErrataDumper(self._writer, h))

        return exportLib.ArrayIterator(arr)

    _query_get_package_ids = rhnSQL.Statement("""
        select package_id
          from rhnChannelPackage
         where channel_id = :channel_id
    """)

    _query_get_package_ids_by_date_limits = rhnSQL.Statement("""
        select package_id
          from rhnPackage rp, rhnChannelPackage rcp
         where rcp.channel_id = :channel_id
         and rcp.package_id = rp.id
         and rp.last_modified >= TO_Date(:lower_limit, 'YYYYMMDDHH24MISS')
         and rp.last_modified <= TO_Date(:upper_limit, 'YYYYMMDDHH24MISS')
     """)

    # Things that can be overwriten in subclasses
    def _get_package_ids(self):
        channel_id = self._row['id']
        if LOWER_LIMIT:
	    print "Dumping Incremental Channel Packages"
            h = rhnSQL.prepare(self._query_get_package_ids_by_date_limits)
            h.execute(channel_id=channel_id, lower_limit=LOWER_LIMIT, upper_limit=UPPER_LIMIT)
        else:
            print "Dumping Base Channel Packages"
            h = rhnSQL.prepare(self._query_get_package_ids)
            h.execute(channel_id=channel_id)
        return map(lambda x: x['package_id'], h.fetchall_dict() or [])

    _query__get_errata_ids_by_limits = rhnSQL.Statement("""
        select ce.errata_id, e.advisory_name,
               TO_CHAR(e.last_modified, 'YYYYMMDDHH24MISS') last_modified
          from rhnChannelErrata ce, rhnErrata e
         where ce.channel_id = :channel_id
           and ce.errata_id = e.id
           and e.last_modified >= TO_Date(:lower_limit, 'YYYYMMDDHH24MISS')
           and e.last_modified <= TO_Date(:upper_limit, 'YYYYMMDDHH24MISS')
    """)

    def _get_errata_ids(self):
        channel_id = self._row['id']
        if LOWER_LIMIT:
            #print "Errata Incremental"
            h = rhnSQL.prepare(self._query__get_errata_ids_by_limits)
            h.execute(channel_id=channel_id, lower_limit=LOWER_LIMIT, upper_limit=UPPER_LIMIT)
            #print h.fetchall_dict()
        else:
	    #print "Errata Base"
            h = rhnSQL.prepare(self._query__get_errata_ids)
            h.execute(channel_id=channel_id)
        return map(lambda x: x['errata_id'], h.fetchall_dict() or [])

    _query_get_kickstartable_trees_by_limits = rhnSQL.Statement("""
        select kt.label
          from rhnKickstartableTree kt
         where  kt.channel_id = :channel_id
           and  kt.last_modified >= TO_DATE(:lower_limit, 'YYYYMMDDHH24MISS')
           and  kt.last_modified <= TO_DATE(:upper_limit, 'YYYYMMDDHH24MISS')
           and  kt.org_id is null
    """)

    def _get_kickstartable_trees(self):
        channel_id = self._row['id']
        if LOWER_LIMIT:
            h = rhnSQL.prepare(self._query_get_kickstartable_trees_by_limits)
            h.execute(channel_id=channel_id, lower_limit=LOWER_LIMIT, upper_limit = UPPER_LIMIT)
        else: 
            h = rhnSQL.prepare(self._query_get_kickstartable_trees)
            h.execute(channel_id=channel_id)
        ks_trees = map(lambda x: x['label'], h.fetchall_dict() or [])
        ks_trees.sort()
        return ks_trees


class ChannelsDumperEx(CachedDumper, exportLib.ChannelsDumper):
    _query_list_channels = rhnSQL.Statement("""
        select c.id, c.label, ca.label channel_arch, c.basedir, c.name,
               c.summary, c.description, c.gpg_key_url, c.org_id,
               TO_CHAR(c.last_modified, 'YYYYMMDDHH24MISS') last_modified,
               c.channel_product_id,
               pc.label parent_channel,
               cp.product channel_product,
               cp.version channel_product_version,
               cp.beta channel_product_beta,
               c.receiving_updates,
               ct.label checksum_type
          from rhnChannel c, rhnChannelArch ca, rhnChannel pc, rhnChannelProduct cp,
               rhnChecksumType ct
         where c.id = :channel_id
           and c.channel_arch_id = ca.id
           and c.parent_channel = pc.id (+)
           and c.channel_product_id = cp.id (+)
           and c.checksum_type_id = ct.id (+)
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
                c.checksum_type,
                c.checksum,
                p.package_size,
                TO_CHAR(p.last_modified, 'YYYYMMDDHH24MISS') last_modified
            from rhnPackage p, rhnPackageName pn, rhnPackageEVR pe, 
                rhnPackageArch pa, rhnChecksumView c
            where p.id = :package_id 
            and p.name_id = pn.id
            and p.evr_id = pe.id
            and p.package_arch_id = pa.id
            and p.checksum_id = c.id
        """)
        CachedDumper.__init__(self, writer, statement=h, params=packages)

    def _get_key(self, params):
        package_id = str(params['package_id'])
        hash_val = rhnLib.hash_object_id(package_id, 2)
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
                p.header_start,
                p.header_end,
                p.copyright,
                p.cookie,
                TO_CHAR(p.last_modified, 'YYYYMMDDHH24MISS') last_modified
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
        CachedDumper.__init__(self, writer, statement=h, params=packages)

    def _get_key(self, params):
        package_id = str(params['package_id'])
        hash_val = rhnLib.hash_object_id(package_id, 2)
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
        CachedDumper.__init__(self, writer, statement=h, params=packages)

    def _get_key(self, params):
        package_id = str(params['package_id'])
        hash_val = rhnLib.hash_object_id(package_id, 2)
        return "xml-packages/%s/rhn-source-package-%s.xml" % (hash_val, package_id)

    def _dump_subelement(self, data):
        log_debug(6, data)
        return exportLib.SourcePackagesDumper.dump_subelement(self, data)

class ErrataDumper(CachedDumper, exportLib.ErrataDumper):
    def __init__(self, writer, errata):
        h = rhnSQL.prepare("""
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
                e.notes
            from rhnErrata e
            where e.id = :errata_id
        """)
        CachedDumper.__init__(self, writer, statement=h, params=errata)

    def _get_key(self, params):
        errata_id = str(params['errata_id'])
        hash_val = rhnLib.hash_object_id(errata_id, 1)
        return "xml-errata/%s/rhn-erratum-%s.xml" % (hash_val, errata_id)

    def _dump_subelement(self, data):
        log_debug(6, data)
        return exportLib.ErrataDumper.dump_subelement(self, data)

class KickstartableTreesDumper(CachedDumper, exportLib.KickstartableTreesDumper):
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
