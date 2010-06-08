#!/usr/bin/python
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

"""
Non-authenticated dumper
"""

import os
import xmlrpclib

from common import log_debug, log_error, rhnFault, CFG
from server import rhnSQL, rhnLib
from server.rhnHandler import rhnHandler
from server.importlib.backendLib import localtime
from common.rhnTranslate import _

from satellite_tools.exporter import exportLib
from satellite_tools.disk_dumper import dumper

class InvalidPackageError(Exception):
    pass

class NullPathPackageError(Exception):
    pass

class MissingPackageError(Exception):
    pass

class NonAuthenticatedDumper(rhnHandler, dumper.XML_Dumper):
    def __init__(self, req):
        rhnHandler.__init__(self)
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

        # Don't check for abuse
        self.check_for_abuse = 0

        self.functions = [
            'arches',
            'arches_extra',
            'channel_families',
            'channels',
            'get_comps',
            'channel_packages_short',
            'packages_short',
            'packages',
            'source_packages',
            'errata',
            'blacklist_obsoletes',
            'product_names',
            'get_rpm',
            'get_source_rpm',
            'kickstartable_trees',
            'get_ks_file',
        ]

        self.system_id = None
        self._channel_family_query_template = """
            select cfm.channel_family_id, 0 quantity
              from rhnChannelFamilyMembers cfm,
                   rhnChannel c, rhnChannelFamily cf
             where cfm.channel_id = c.id
               and c.label in (%s)
               and cfm.channel_family_id = cf.id
               and cf.label != 'rh-public'
            union
            select id channel_family_id, NULL quantity
              from rhnChannelFamily
             where label = 'rh-public'
        """
        self._channel_family_query_public = """
            select id channel_family_id, 0 quantity
              from rhnChannelFamily
        """
        self._channel_family_query = None

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
            raise dumper.ClosedConnectionError
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

    def set_channel_family_query(self, channel_labels=[]):
        if not channel_labels:
            # All null-pwned channel families
            self._channel_family_query = self._channel_family_query_public
            return self

        self._channel_family_query = self._channel_family_query_template % (
            ', '.join(["'%s'" % x for x in channel_labels]), )
        return self

    def _get_channel_data(self, channels):
        writer = ContainerWriter()
        d = ChannelsDumper(writer, channels=channels.values())
        d.dump()
        data = writer.get_data()
        # We don't care about <rhn-channels> here
        channel_data = self._cleanse_channels(data[2])
        return channel_data

    def _cleanse_channels(channels_dom):
        channels = {}
        for dummy, attributes, child_elements in channels_dom:
            channel_label = attributes['label']
            channels[channel_label] = channel_entry = {}

            packages = attributes['packages'].split()
            del attributes['packages']

            # Get dir of the prefix
            prefix = "rhn-package-"
            prefix_len = len(prefix)
            packages = [ int(x[prefix_len:]) for x in packages ]

            channel_entry['packages'] = packages

            ks_trees = attributes['kickstartable-trees'].split()

            channel_entry['ks_trees'] = ks_trees

            # Clean up to reduce memory footprint if possible
            attributes.clear()

            # tag name to object prefix
            maps = {
                'source-packages' : ('source_packages', 'rhn-source-package-'),
                'rhn-channel-errata' : ('errata', 'rhn-erratum-'),
            }
            # Now look for package sources
            for tag_name, dummy, celem in child_elements:
                if not maps.has_key(tag_name):
                    continue
                field, prefix = maps[tag_name]
                prefix_len = len(prefix)
                # Hmm. x[1] is the attributes hash; we fetch the id and we get
                # rid of te prefix, then we run that through int()
                objects = []
                for dummy, ceattr, dummy in celem:
                    obj_id = ceattr['id']
                    obj_id = int(obj_id[prefix_len:])
                    last_modified = localtime(ceattr['last-modified'])
                    objects.append((obj_id, last_modified))
                channel_entry[field] = objects

            # Clean up to reduce memory footprint if possible
            del child_elements[:]

        return channels

    _cleanse_channels = staticmethod(_cleanse_channels)

    def _lookup_last_modified(channel_data):
        for channel_label, data in channel_data.items():
            packages = data['packages']
            packages = _lookup_last_modified_packages(packages)
            data['packages'] = packages

            ks_trees = data['ks_trees']
            ks_trees = _lookup_last_modified_ks_trees(channel_label, ks_trees)
            data['ks_trees'] = ks_trees

        return channel_data

    _lookup_last_modified = staticmethod(_lookup_last_modified)

    def _generate_executemany_data(label, channels, channel_data):
        """
        Convenience function to reduce duplication
        returns two arrays snapshot_channel_ids, label_ids
        where label can be source_package_ids or package_ids or errata_ids
        """
        snapshot_channel_ids = []
        obj_ids = []
        channel_ids = []
        last_modifieds = []
        for channel_label, data in channel_data.items():
            # Get the snapshot channel id
            chan = channels[channel_label]
            snapshot_channel_id = chan['snapshot_channel_id']
            channel_id = chan['channel_id']
            ids = data[label]
            for i, last_modified in ids:
                obj_ids.append(i)
                last_modifieds.append(last_modified)
                snapshot_channel_ids.append(snapshot_channel_id)
                channel_ids.append(channel_id)
        return snapshot_channel_ids, channel_ids, obj_ids, last_modifieds

    _generate_executemany_data = staticmethod(_generate_executemany_data)

    def _do_snapshot(self, label, channels, channel_data, query,
            with_channels=0):
        snapshot_channel_ids, channel_ids, obj_ids, last_modifieds = \
            self._generate_executemany_data(label, channels, channel_data)
        h = rhnSQL.prepare(query)
        if with_channels:
            h.executemany(snapshot_channel_id=snapshot_channel_ids,
                obj_id=obj_ids, channel_id=channel_ids,
                last_modified=last_modifieds)
        else:
            h.executemany(snapshot_channel_id=snapshot_channel_ids,
                obj_id=obj_ids, last_modified=last_modifieds)

    # Dumper functions here
    def dump_channel_families(self, virt_filter=0):
        log_debug(2)

        h = self.get_channel_families_statement()
        h.execute()

        writer = self._get_xml_writer()
        d = dumper.SatelliteDumper(writer,
            exportLib.ChannelFamiliesDumper(writer,
                data_iterator=h, null_max_members=0, virt_filter=virt_filter),)
        d.dump()
        writer.flush()
        log_debug(4, "OK")
        self.close()
        return 0

    def dump_channels(self, channel_labels=None):
        log_debug(2)
        channels = self._validate_channels(channel_labels=channel_labels)

        writer = self._get_xml_writer()
        d = dumper.SatelliteDumper(writer, dumper.ChannelsDumperEx(writer,
            channels=channels.values()))
        d.dump()
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
                raise dumper.ClosedConnectionError
        # We're done
        return 0

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
        d = dumper.SatelliteDumper(writer,
            dump_class(writer, packages_hash.values()))
        d.dump()
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
        d = dumper.SatelliteDumper(writer,
            dumper.ErrataDumper(writer, errata_hash.values()))
        d.dump()
        writer.flush()
        log_debug(4, "OK")
        self.close()
        return 0

    def dump_kickstartable_trees(self, kickstart_labels=None):
        log_debug(2)
        kickstarts = self._validate_kickstarts(
            kickstart_labels=kickstart_labels)

        writer = self._get_xml_writer()
        d = dumper.SatelliteDumper(writer,
            dumper.KickstartableTreesDumper(writer, kickstarts=kickstarts))
        d.dump()
        writer.flush()
        log_debug(4, "OK")
        self.close()
        return 0

    def dump_product_names(self):
        log_debug(4)
        writer = self._get_xml_writer()
        d = dumper.SatelliteDumper(writer, exportLib.ProductNamesDumper(writer))
        d.dump()
        writer.flush()
        self.close()
        return 0

    def arches(self):
        return self.dump_arches(rpm_arch_type_only=1)

    def arches_extra(self):
        return self.dump_server_group_type_server_arches(rpm_arch_type_only=1)

    def blacklist_obsoletes(self):
        return self.dump_blacklist_obsoletes()

    def product_names(self):
        return self.dump_product_names()

    def channel_families(self, channel_labels=[]):
        self.set_channel_family_query()
        return self.dump_channel_families()

    def channels(self, channel_labels, flags={}):
        if not channel_labels:
            channel_labels = []
        self.set_channel_family_query(channel_labels=channel_labels)
        return self.dump_channels(channel_labels=channel_labels)

    def get_comps(self, channel):
        return self.get_comps_file(channel)

    def channel_packages_short(self, channel_label, last_modified):
        self.set_channel_family_query(channel_labels=[channel_label])
        return self.dump_channel_packages_short(channel_label, last_modified)

    def packages(self, packages=[]):
        self.set_channel_family_query()
        return self.dump_packages(packages=packages)

    def packages_short(self, packages=[]):
        self.set_channel_family_query()
        return self.dump_packages_short(packages=packages)

    def source_packages(self, packages=[]):
        self.set_channel_family_query()
        return self.dump_source_packages(packages=packages)

    def errata(self, errata=[]):
        self.set_channel_family_query()
        return self.dump_errata(errata=errata)

    def kickstartable_trees(self, kickstart_labels=[]):
        self.set_channel_family_query()
        return self.dump_kickstartable_trees(kickstart_labels=kickstart_labels)

    def get_rpm(self, package, channel):
        log_debug(1, package, channel)
        return self._send_package_stream(package, channel)

    def get_source_rpm(self, package):
        log_debug(1, package)
        return self._send_package_stream(package, "rhn-source-package-",
            "rhnPackageSource")

    def get_comps_file(self, channel):
        comps_query = """
            select relative_filename
            from rhnChannelComps
            where channel_id = (
                select id
                from rhnChannel
                where label = :channel_label
            )
            order by id desc
        """
        channel_comps_sth = rhnSQL.prepare(comps_query)
        channel_comps_sth.execute(channel_label = channel)
        row = channel_comps_sth.fetchone_dict()
        if not row:
            raise rhnFault(3015, "No comps file for channel [%s]" % channel)
        path = os.path.join(CFG.MOUNT_POINT, row['relative_filename'])
        if not os.path.exists(path):
            log_error("Missing comps file [%s] for channel [%s]" % (path, channel))
            raise rhnFault(3016, "Unable to retrieve comps file for channel [%s]" % channel)
        return self._send_stream(path)

    def get_ks_file(self, ks_label, relative_path):
        log_debug(1, ks_label, relative_path)
        h = rhnSQL.prepare("""
            select base_path
              from rhnKickstartableTree
             where label = :ks_label
               and org_id is null
        """)
        h.execute(ks_label=ks_label)
        row = h.fetchone_dict()
        if not row:
            raise rhnFault(3003, "No such file %s in tree %s" %
                (relative_path, ks_label))
        path = os.path.join(CFG.MOUNT_POINT, row['base_path'], relative_path)
        if not os.path.exists(path):
            log_error("Missing file for satellite dumper: %s" % path)
            raise rhnFault(3007, "Unable to retrieve file %s in tree %s" %
                (relative_path, ks_label))
        return self._send_stream(path)


    # Sends a package over the wire
    # prefix is whatever we prepend to the package id (rhn-package- or
    # rhn-source-package-)
    def _send_package_stream(self, package, channel):
        log_debug(3, package, channel)
        path, dummy = self.get_package_path_by_filename(package, channel)

        log_debug(3, "Package path", path)
        if not os.path.exists(path):
            log_error("Missing package (satellite dumper): %s" % path)
            raise rhnFault(3007, "Unable to retrieve package %s" % package)
        return self._send_stream(path)

    # This query is similar to the one aove, except that we have already
    # authorized this channel (so no need for server_id)
    _query_get_package_path_by_nvra = rhnSQL.Statement("""
            select distinct
                   p.id, p.path
              from rhnPackage p,
                   rhnChannelPackage cp,
                   rhnChannel c,
                   rhnPackageArch pa
             where c.label = :channel
               and cp.channel_id = c.id
               and cp.package_id = p.id
               and p.name_id = LOOKUP_PACKAGE_NAME(:name)
               and p.evr_id = LOOKUP_EVR(:epoch, :version, :release)
               and p.package_arch_id = pa.id
               and pa.label = :arch
    """)

    def get_package_path_by_filename(self, fileName, channel):
        log_debug(3, fileName, channel)
        fileName = str(fileName)
        n, e, v, r, a = rhnLib.parseRPMFilename(fileName)

        h = rhnSQL.prepare(self._query_get_package_path_by_nvra)
        h.execute(name=n, version=v, release=r, epoch=e, arch=a, channel=channel)
        try:
            return _get_path_from_cursor(h)
        except InvalidPackageError:
            log_debug(4, "Error", "Non-existant package requested", server_id,
                fileName)
            raise rhnFault(17, _("Invalid RPM package %s requested") % fileName)
        except NullPathPackageError, e:
            package_id = e[0]
            log_error("Package path null for package id", package_id)
            raise rhnFault(17, _("Invalid RPM package %s requested") % fileName)
        except MissingPackageError, e:
            filePath = e[0]
            log_error("Package not found", filePath)
            raise rhnFault(17, _("Package not found"))



    # Opens the file and sends the stream
    def _send_stream(self, path):
        try:
            stream = open(path)
        except IOError, e:
            if e.errno == 2:
                raise rhnFault(3007, "Missing file %s" % path)
            # Let it flow so we can find it later
            raise

        stream.seek(0, 2)
        file_size = stream.tell()
        stream.seek(0, 0)
        log_debug(3, "Package size", file_size)
        self.headers_out['Content-Length'] = file_size
        self._send_headers_rpm()
        self.send_rpm(stream)
        return 0

    def _send_headers_rpm(self):
        log_debug(3, "is_closed", self._is_closed)
        if self._is_closed:
            raise Exception, "Trying to write to a closed connection"
        if self._headers_sent:
            return
        self._headers_sent = 1

        self._raw_stream.content_type = 'application/x-rpm'
        for h, v in self.headers_out.items():
            self._raw_stream.headers_out[h] = str(v)
        self._raw_stream.send_http_header()

    def send_rpm(self, stream):
        buffer_size = 65536
        while 1:
            buf = stream.read(buffer_size)
            if not buf:
                break
            try:
                self._raw_stream.write(buf)
            except IOError:
                # client closed the connection?
                log_error("Client appears to have closed connection")
                self.close_rpm()
                raise dumper.ClosedConnectionError
        self.close_rpm()

    def close_rpm(self):
        self._is_closed = 1

    def _get_package_id(package, prefix):
        """ Extracts the package id from a string rhn-package-12345 """
        log_debug(4, package, prefix)
        if package[:len(prefix)] != prefix:
            raise rhnFault(3002, "Invalid package name %s" % package)
        package_id = package[len(prefix):]
        try:
            package_id = int(package_id)
        except ValueError:
            raise rhnFault(3002, "Invalid package id %s" % package)
        return package_id

    _get_package_id = staticmethod(_get_package_id)


    def _respond_xmlrpc(self, data):
        # Marshal
        s = xmlrpclib.dumps((data, ))

        self.headers_out['Content-Length'] = len(s)
        self._raw_stream.content_type = 'text/xml'
        for h, v in self.headers_out.items():
            self._raw_stream.headers_out[h] = str(v)
        self._raw_stream.send_http_header()
        self._raw_stream.write(s)
        return 0

class ContainerWriter:
    # Same interface as an XML writer, but collects data in a hash instead
    def __init__(self):
        self._tag_stack = []
        self._cdata = []
        self._root = None

    def open_tag(self, tag_name, attributes=None):
        # print "+++", tag_name, len(self._tag_stack)
        if not attributes:
            attributes = {}
        self._cdata = []
        self._tag_stack.append((tag_name, attributes, self._cdata))

    def data(self, astring):
        self._cdata.append(astring)

    def close_tag(self, tag_name):
        # print "---", tag_name, len(self._tag_stack)
        # Extract the current item from the stack
        tag_name, attributes, cdata = self._tag_stack.pop()

        return self._add_node(tag_name, attributes, cdata)

    def empty_tag(self, tag_name, attributes=None):
        # print "+++---", tag_name, len(self._tag_stack)
        if not attributes:
            attributes = {}
        return self._add_node(tag_name, attributes, [])

    def _add_node(self, tag_name, attributes, cdata):
        node = (tag_name, attributes, cdata)
        if not self._tag_stack:
            # Parent
            self._root = node
            return self._root

        # Fetch the parent
        parent = self._tag_stack[-1]
        # Add this node as a child
        parent[2].append(node)
        return parent

    def get_data(self):
        assert self._root is not None
        return self._root

# Overwrite the ChannelsDumper class to filter packages/source packages/errata
# based on the creation date
# XXX No caching for now
class ChannelsDumper(dumper.ChannelsDumper):
    def dump_subelement(self, data):
        c = exportLib.ChannelDumper(self._writer, data)
        c.dump()

_query_lookup_last_modified_packages = rhnSQL.Statement("""
    select TO_CHAR(last_modified, 'YYYY-MM-DD HH24:MI:SS') last_modified
      from rhnPackage
     where id = :id
""")
def _lookup_last_modified_packages(package_ids):
    h = rhnSQL.prepare(_query_lookup_last_modified_packages)
    ret = []
    for pid in package_ids:
        h.execute(id=pid)
        row = h.fetchone_dict()
        assert row, "Invalid package id %s" % pid
        ret.append((pid, row['last_modified']))
    return ret

_query_lookup_last_modified_ks_trees = rhnSQL.Statement("""
    select TO_CHAR(kt.last_modified, 'YYYY-MM-DD HH24:MI:SS') last_modified
      from rhnKickstartableTree kt, rhnChannel c
     where kt.channel_id = c.id
       and c.label = :channel_label
       and kt.label = :ks_label
       and kt.org_id is null
""")
def _lookup_last_modified_ks_trees(channel_label, ks_trees):
    h = rhnSQL.prepare(_query_lookup_last_modified_ks_trees)
    ret = []
    for klabel in ks_trees:
        h.execute(channel_label=channel_label, ks_label=klabel)
        row = h.fetchone_dict()
        assert row, "Invalid kickstart label %s for channel %s" % (
            klabel, channel_label)
        ret.append((klabel, row['last_modified']))
    return ret

def _get_path_from_cursor(h):
    # Function shared between other retrieval functions
    rs = h.fetchall_dict()
    if not rs:
        raise InvalidPackageError

    # It is unlikely for this query to return more than one row,
    # but it is possible
    # (having two packages with the same n, v, r, a and different epoch in
    # the same channel is prohibited by the RPM naming scheme; but extra
    # care won't hurt)
    max_row = rs[0]
    for each in rs[1:]:
        # Compare the epoch as string
        if _none2emptyString(each['epoch']) > _none2emptyString(
                max_row['epoch']):
            max_row = each

    if max_row['path'] is None:

        raise NullPathPackageError(max_row['id'])
    filePath = "%s/%s" % (CFG.MOUNT_POINT, max_row['path'])
    pkgId = max_row['id']
    if not os.access(filePath, os.R_OK):
        # Package not found on the filesystem
        raise MissingPackageError(filePath)
    return filePath, pkgId

rpcClasses = {
    'dump'  : NonAuthenticatedDumper,
}
