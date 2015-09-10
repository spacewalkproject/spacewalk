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

"""
Non-authenticated dumper
"""

import os
import xmlrpclib
import gzip
import sys

from rhn.UserDictCase import UserDictCase
from spacewalk.common.rhnLog import log_debug, log_error
from spacewalk.common.rhnConfig import CFG
from spacewalk.server import rhnSQL, rhnLib
from spacewalk.server.rhnHandler import rhnHandler
from spacewalk.server.importlib.backendLib import localtime
from spacewalk.common.rhnException import rhnFault

from spacewalk.common.rhnTranslate import _

from spacewalk.satellite_tools.exporter import exportLib
from spacewalk.satellite_tools.disk_dumper import dumper


class InvalidPackageError(Exception):
    pass


class NullPathPackageError(Exception):
    pass


class MissingPackageError(Exception):
    pass


class NonAuthenticatedDumper(rhnHandler, dumper.XML_Dumper):
    # pylint: disable=E1101,W0102,W0613,R0902,R0904

    def __init__(self, req):
        rhnHandler.__init__(self)
        dumper.XML_Dumper.__init__(self)
        self.headers_out = UserDictCase()
        self._raw_stream = req
        self._raw_stream.content_type = 'application/octet-stream'
        self.compress_level = 0
        # State machine
        self._headers_sent = 0
        self._is_closed = 0
        self._compressed_stream = None

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
            'kickstartable_trees',
            'get_ks_file',
            'orgs',
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
               and (cf.org_id in (%s)
                   or cf.org_id is null)
            union
            select id channel_family_id, NULL quantity
              from rhnChannelFamily
             where label = 'rh-public'
        """
        self._channel_family_query_public = """
            select id channel_family_id, 0 quantity
              from rhnChannelFamily
             where org_id in (%s)
                or org_id is null
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
            raise dumper.ClosedConnectionError, None, sys.exc_info()[2]
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

            self._compressed_stream = None
        self._is_closed = 1
        log_debug(3, "Closed")

    def set_channel_family_query(self, channel_labels=[]):
        if not channel_labels:
            # All null-pwned channel families
            self._channel_family_query = self._channel_family_query_public % self.exportable_orgs
            return self

        self._channel_family_query = self._channel_family_query_template % (
            ', '.join(["'%s'" % x for x in channel_labels]),
            self.exportable_orgs)
        return self

    def _get_channel_data(self, channels):
        writer = ContainerWriter()
        d = ChannelsDumper(writer, params=channels.values())
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
            packages = [int(x[prefix_len:]) for x in packages]

            channel_entry['packages'] = packages

            ks_trees = attributes['kickstartable-trees'].split()

            channel_entry['ks_trees'] = ks_trees

            # Clean up to reduce memory footprint if possible
            attributes.clear()

            # tag name to object prefix
            maps = {
                'source-packages': ('source_packages', 'rhn-source-package-'),
                'rhn-channel-errata': ('errata', 'rhn-erratum-'),
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

    # Dumper functions here
    def dump_channel_families(self):
        log_debug(2)

        h = self.get_channel_families_statement()
        h.execute()

        writer = self._get_xml_writer()
        d = dumper.SatelliteDumper(writer,
                                   exportLib.ChannelFamiliesDumper(writer,
                                                                   data_iterator=h, null_max_members=0,),)
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
                                                                   params=channels.values()))
        d.dump()
        writer.flush()
        log_debug(4, "OK")
        self.close()
        return 0

    def dump_channel_packages_short(self, channel_label, last_modified):
        return dumper.XML_Dumper.dump_channel_packages_short(
            self, channel_label, last_modified, filepath=None,
            validate_channels=True, send_headers=True, open_stream=False)

    def _packages(self, packages, prefix, dump_class, sources=0):
        return dumper.XML_Dumper._packages(self, packages, prefix, dump_class, sources,
                                           verify_packages=True)

    def dump_errata(self, errata):
        return dumper.XML_Dumper.dump_errata(self, errata, verify_errata=True)

    def dump_kickstartable_trees(self, kickstart_labels=None):
        return dumper.XML_Dumper.dump_kickstartable_trees(self, kickstart_labels,
                                                          validate_kickstarts=True)

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

    def orgs(self):
        return self.dump_orgs()

    def kickstartable_trees(self, kickstart_labels=[]):
        self.set_channel_family_query()
        return self.dump_kickstartable_trees(kickstart_labels=kickstart_labels)

    def get_rpm(self, package, channel):
        log_debug(1, package, channel)
        return self._send_package_stream(package, channel)

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
        channel_comps_sth.execute(channel_label=channel)
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
            log_debug(4, "Error", "Non-existent package requested", fileName)
            raise rhnFault(17, _("Invalid RPM package %s requested") % fileName), None, sys.exc_info()[2]
        except NullPathPackageError, e:
            package_id = e[0]
            log_error("Package path null for package id", package_id)
            raise rhnFault(17, _("Invalid RPM package %s requested") % fileName), None, sys.exc_info()[2]
        except MissingPackageError, e:
            filePath = e[0]
            log_error("Package not found", filePath)
            raise rhnFault(17, _("Package not found")), None, sys.exc_info()[2]

    # Opens the file and sends the stream
    def _send_stream(self, path):
        try:
            stream = open(path)
        except IOError, e:
            if e.errno == 2:
                raise rhnFault(3007, "Missing file %s" % path), None, sys.exc_info()[2]
            # Let it flow so we can find it later
            raise

        stream.seek(0, 2)
        file_size = stream.tell()
        stream.seek(0, 0)
        log_debug(3, "Package size", file_size)
        self.headers_out['Content-Length'] = file_size
        self.compress_level = 0
        self._raw_stream.content_type = 'application/x-rpm'
        self._send_headers()
        self.send_rpm(stream)
        return 0

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
                raise dumper.ClosedConnectionError, None, sys.exc_info()[2]
        self.close_rpm()

    def close_rpm(self):
        self._is_closed = 1

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


def _get_path_from_cursor(h):
    # Function shared between other retrieval functions
    rs = h.fetchall_dict()
    if not rs:
        raise InvalidPackageError

    max_row = rs[0]

    if max_row['path'] is None:

        raise NullPathPackageError(max_row['id'])
    filePath = "%s/%s" % (CFG.MOUNT_POINT, max_row['path'])
    pkgId = max_row['id']
    if not os.access(filePath, os.R_OK):
        # Package not found on the filesystem
        raise MissingPackageError(filePath)
    return filePath, pkgId

rpcClasses = {
    'dump': NonAuthenticatedDumper,
}
