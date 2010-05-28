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

class NonAuthenticatedDumper(rhnHandler, dumper.XML_DumperEx):
    def __init__(self, req):
        rhnHandler.__init__(self)
        dumper.XML_DumperEx.__init__(self, req)
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
class ChannelsDumper(exportLib.ChannelsDumper):
    def __init__(self, writer, channels, snapshot=None, incremental=0):
        # if snapshot is None, then all the objects from the channel are
        # returned - this is useful for snapshotting
        exportLib.ChannelsDumper.__init__(self, writer, channels)
        self.snapshot = snapshot
        self.incremental = incremental

    def set_iterator(self):
        if not self._channels:
            # Nothing to do
            return

        # Import the query from the dumper.ChannelsDumper class
        h = rhnSQL.prepare(dumper.ChannelsDumper._query_list_channels)
        return dumper.QueryIterator(statement=h, params=self._channels)

    def dump_subelement(self, data):
        if self.snapshot:
            c = _ChannelDumper(self._writer, data, self.snapshot,
                    self.incremental)
        else:
            c = _ChannelSnapshotter(self._writer, data)
        try:
            c.dump()
        except:
            raise

class _ChannelSnapshotter(exportLib.ChannelDumper):
    pass

class _ChannelDumper(exportLib.ChannelDumper):
    def __init__(self, writer, data, snapshot, incremental=0):
        exportLib.ChannelDumper.__init__(self, writer, data)
        self.snapshot = snapshot
        assert self.snapshot is not None, \
                "Programmer error: wrong class for snapshotting"
        self.channel_id = None
        self.channel_label = None
        self.snapshot_id = None
        self.snapshot_channel_id = None
        self.incremental = incremental
        # Initialize snapshot_id and snapshot_channel_id
        self.init()
        log_debug(4, snapshot, incremental, self.snapshot_id,
            self.snapshot_channel_id)

    def init(self):
        self.channel_id = self._row['id']
        self.channel_label = self._row['label']
        h = rhnSQL.prepare(self._query_get_snapshot_ids)
        h.execute(snapshot=self.snapshot, channel_id=self.channel_id)
        row = h.fetchone_dict()
        self.snapshot_id = row['snapshot_id']
        self.snapshot_channel_id = row['snapshot_channel_id']
        self._all_packages = None

    def set_attributes(self):
        ret = exportLib.ChannelDumper.set_attributes(self)

        if self.incremental:
            # create all-packages
            # self._get_package_ids() will populate self._all_packages
            all_packages = [ "rhn-package-%s" % x for x in self._all_packages ]
            ret['all-packages'] = " ".join(all_packages)
        return ret

    def _get_package_ids(self):
        # this function has a side-effect of populating self._all_packages
        # if we are doing an incremental
        # It will return:
        # - all packages in the snapshot if we are trying to generate a
        #   baseline
        # - all packages in the channel minus all packages in the snapshot if
        #   we are generating an incremental

        snapshot_packages = self.__get_snapshot_packages()
        if not self.incremental:
            # All we need is the snapshotted packages
            # Drop last_modified
            return [ x[0] for x in snapshot_packages ]

        # Get a list of all packages in this channel
        self._all_packages = exportLib.ChannelDumper._get_package_ids(self)
        all_packages = _lookup_last_modified_packages(self._all_packages)

        # need to return self._all_packages minus snapshot_packages
        minus = list_minus(all_packages, snapshot_packages)
        return [ x[0] for x in minus ]

    def __get_statement_data(self, statement):
        h = rhnSQL.prepare(statement)
        h.execute(snapshot_channel_id=self.snapshot_channel_id)
        data = h.fetchall()
        data.sort()
        return data

    def __get_snapshot_errata(self):
        return self.__get_statement_data(self._query_get_snapshot_errata)

    def __get_snapshot_ks_tree(self):
        return self.__get_statement_data(self._query_get_snapshot_ks_tree)

    def _get_cursor_source_packages(self):
        snapshot_source_packages = self.__get_snapshot_source_packages()
        if not self.incremental:
            # If a baseline, return objects from snapshot
            return exportLib.ArrayIterator(snapshot_source_packages)

        h = exportLib.ChannelDumper._get_cursor_source_packages(self)
        all_source_packages = h.fetchall_dict() or []

        new_objs = list_minus(all_source_packages, snapshot_source_packages,
            lambda x: (x['id'], x['last_modified']))
        return exportLib.ArrayIterator(new_objs)

    def _get_errata_ids(self):
        snapshot_errata = self.__get_snapshot_errata()
        if not self.incremental:
            # If a baseline, return objects from snapshot
            return [  x[0] for x in snapshot_errata ]

        all_errata = exportLib.ChannelDumper._get_errata_ids(self)
        all_errata = _lookup_last_modified_errata(all_errata)
        minus = list_minus(all_errata, snapshot_errata)
        return [ x[0] for x in minus ]

    def _get_kickstartable_trees(self):
        snapshot_ks_trees = self.__get_snapshot_ks_tree()
        if not self.incremental:
            # If a baseline, return objects from snapshot
            return [  x[0] for x in snapshot_ks_trees ]

        all_ks_trees = exportLib.ChannelDumper._get_kickstartable_trees(self)
        all_ks_trees = _lookup_last_modified_ks_trees(self.channel_label,
            all_ks_trees)

        minus = list_minus(all_ks_trees, snapshot_ks_trees)
        return [ x[0] for x in minus ]

def list_minus(l1, l2, comp_func=lambda x: x):
    """
    Returns l1 minus l2, comparing each item of l1 and l2 after filtering
    them through comp_func
    """
    h = {}
    for i in l2:
        index = comp_func(i)
        h[index] = i

    ret = []
    for i in l1:
        index = comp_func(i)
        if not h.has_key(index):
            ret.append(i)
    return ret

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

_query_lookup_last_modified_errata = rhnSQL.Statement("""
    select TO_CHAR(last_modified, 'YYYY-MM-DD HH24:MI:SS') last_modified
      from rhnErrata
     where id = :id
""")
def _lookup_last_modified_errata(errata_ids):
    h = rhnSQL.prepare(_query_lookup_last_modified_errata)
    ret = []
    for eid in errata_ids:
        h.execute(id=eid)
        row = h.fetchone_dict()
        assert row, "Invalid errata id %s" % eid
        ret.append((eid, row['last_modified']))
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
