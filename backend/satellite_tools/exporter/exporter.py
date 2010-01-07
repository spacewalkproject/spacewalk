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

import sys
import string
import urlparse
from optparse import Option, OptionParser

from common import rhnLib, initCFG
from satellite_tools import xmlSource, xmlDiskSource, xmlDiskDumper, \
    diskImportLib, connection

def main():
    optionsTable = [
        Option('-s','--server',          action='store',
            help="Server to take the dumps from"),
        Option('-m','--mountpoint',      action='store',
            help="Mount point for saving data"),
        Option(     '--snapshot-tag',    action='store',
            help='Use this snapshot tag (for snapshotting or dumping channels'),
        Option(     '--incremental',     action='store_true',
            help='Incremental channel dump (relative to the snapshot)'),
        Option('-c','--channel',         action='append',
            help='Process packages for this channel only'),
        Option('-f','--force',           action='store_true',
            help="Force the overwrite of contents"),
        Option(     '--blacklists',      action='store_true',
            help="Dump blacklists only"),
        Option(     '--arches',          action='store_true',
            help="Dump arches only"),
        Option(     '--channelfamilies', action='store_true',
            help="Dump channel families only"),
        Option(     '--snapshot',        action='store_true',
            help="Snapshot only"),
        Option(     '--no-snapshot',     action='store_true',
            help="Do _not_ re-snapshot"),
        Option(     '--channels',        action='store_true',
            help="Dump channels only"),
        Option(     '--shortpackages',   action='store_true',
            help="Dump short package information only"),
        Option(     '--packages',        action='store_true',
            help="Dump package information only"),
        Option(     '--source-packages', action='store_true', 
            help="Dump source package information only",  
            dest="source_packages"),
        Option(     '--rpms',            action='store_true',
            help="Dump binary rpms"),
        Option(     '--srpms',           action='store_true',
            help="Dump source rpms"),
        Option(     '--errata',          action='store_true',
            help="Dump errata only"),
        Option(     '--ksdata',          action='store_true',
            help='Dump kickstart data only'),
        Option(     '--ksfiles',         action='store_true',
            help='Dump kickstart files only'),
    ]
    initCFG('server')
    optionParser = OptionParser(option_list=optionsTable)
    options, args = optionParser.parse_args()

    if not options.server:
        print "Error: --server not specified"
        return

    mountPoint = options.mountpoint
    if not mountPoint:
        print "Error: mount point not specified. Please use -m or --mountpoint"
        return

    options.channel = options.channel or all_channels()
    
    # Max compression
    compression = 9

    # Figure out which actions to execute
    all_actions = {
        "arches"            : None,
        "blacklists"        : None,
        "channelfamilies"   : None,
        "snapshot"          : None,
        "channels"          : None,
        "packages"          : ["channels", "shortpackages"],
        "shortpackages"     : ["channels"],
        "source_packages"   : ["channels"],
        "errata"            : ["channels"],
        "rpms"              : ["channels", "shortpackages"],
        "srpms"             : ["channels"],
        "ksdata"            : ["channels"],
        "ksfiles"           : ["ksdata"],
    }
    # Get the list of actions they've checked
    cmdline_actions = filter(lambda x, options=options: getattr(options, x), 
        all_actions.keys())
    if cmdline_actions:
        actions = {}
        while cmdline_actions:
            action = cmdline_actions.pop()
            if actions.has_key(action):
                # We've processed this action already
                continue
            # Add all the actions this one depends upon
            cmdline_actions.extend(all_actions[action] or [])
            actions[action] = all_actions[action]
    else:
        # No action specified, default to all
        actions = all_actions

    if (options.incremental or options.no_snapshot) and 'snapshot' in actions:
        # Explicitly required not to snapshot
        del actions['snapshot']

    if 'channels' in actions or 'snapshot' in actions:
        # Did we get a snapshot?
        if not options.snapshot_tag:
            print "Error: need to specify a snapshot tag"
            return
            
    dumper = Dumper(options.server, actions, options=options,
        compression=compression)

    dumper.init()
    dumper.run()

def all_channels():
    # Default channels
    return [
        'redhat-linux-i386-9',
        'redhat-linux-i386-8.0',
        'redhat-linux-i386-7.3',
        'redhat-linux-i386-7.2',
        'redhat-advanced-server-i386',
        'redhat-ent-linux-i386-es-2.1',
        'redhat-ent-linux-i386-ws-2.1',
    ]


class Dumper:
    buffer_size = 65536

    def __init__(self, server_url, actions, compression=9, options=None):
        self.server_url = patch_url(server_url, path="/SAT-DUMP-INTERNAL")
        self.actions = actions
        self.server = None
        self.options = options
        self.compression = compression

    def init(self):
        print "Connecting to", self.server_url
        self.server = connection.StreamConnection(self.server_url)
        
    # Run all the actions specified on the command line
    def run(self):
        ordered_actions = self._order_actions()
        # XXX hack - snapshots have to happen before channels
        snp = 'snapshot'
        chn = 'channels'
        if snp in ordered_actions:
            if chn in ordered_actions:
                ordered_actions.remove(snp)
                # Insert snapshot before channels
                ordered_actions.insert(ordered_actions.index(chn), snp)

        for action in ordered_actions:
            method = getattr(self, "dump_%s" % action)
            method()
    
    def dump_arches(self):
        print "Dumping arches"
        dumper = xmlDiskDumper.ArchesDumper(self.options.mountpoint,
            server=self.server, compression=self.compression)
        dumper.dump(force=self.options.force)
        dumper = xmlDiskDumper.ArchesExtraDumper(self.options.mountpoint,
            server=self.server, compression=self.compression)
        dumper.dump(force=self.options.force)

    def dump_blacklists(self):
        print "Dumping blacklists"
        dumper = xmlDiskDumper.BlacklistsDumper(self.options.mountpoint,
            server=self.server, compression=self.compression)
        dumper.dump(force=self.options.force)

    def dump_channelfamilies(self):
        print "Dumping channel families"
        dumper = xmlDiskDumper.ChannelFamilyDumper(self.options.mountpoint,
            server=self.server, compression=self.compression)
        dumper.setChannels(self.options.channel or [])
        dumper.dump(force=self.options.force)

    def snapshot_channels(self):
        snapshot = self.options.snapshot_tag
        print "Snapshotting using tag '%s'" % snapshot
        channels = self.options.channel or []
        flags = {'force' : 1}
        self.server.dump.snapshot_channels(snapshot, channels, flags)
    
    # XXX This allows not to special-case run() for snapshots
    dump_snapshot = snapshot_channels

    def dump_channels(self):
        print "Dumping channels"
        dumper = xmlDiskDumper.ChannelDumper(self.options.mountpoint,
            server=self.server, compression=self.compression)

        flags = {}
        if self.options.incremental:
            flags['incremental'] = 1

        dumper.flags = flags
        dumper.snapshot = self.options.snapshot_tag

        for channel in (self.options.channel or []):
            dumper.setChannel(channel)
            dumper.dump(force=self.options.force)

    # Loads the required channels from disk (to retrieve package ids and such)
    def _load_channels(self):
        channels = []
        channel_source = xmlDiskSource.ChannelDiskSource(
            self.options.mountpoint)
        handler = xmlSource.SatelliteDispatchHandler()
        channel_container = xmlSource.ChannelContainer()
        handler.set_container(channel_container)
        for channel in (self.options.channel or []):
            # Get the channel stream
            channel_source.setChannel(channel)

            stream = channel_source.load()
            handler.process(stream)
            for c in channel_container.batch:
                channels.append(c)
            handler.clear()
            handler.reset()
        return channels

    # Load one short package
    def _load_short_package(self, package_id):
        s = xmlDiskSource.ShortPackageDiskSource(self.options.mountpoint)
        s.setID(package_id)
        stream = s.load()
        return xmlDiskDumper.load_short_package(stream)

    # Extract the package ids from the channels
    def _get_channel_object_ids(self, channels, object_name):
        object_ids = {}
        for c in channels:
            objs = c.get(object_name)
            for p in (objs or []):
                object_ids[p] = None
        object_ids = object_ids.keys()
        object_ids.sort()
        return object_ids
    
    # special case - errata listed in channels are objects
    def _get_channel_errata(self, channels):
        object_ids = {}
        for c in channels:
            objs = c.get('errata_timestamps')
            for p in (objs or []):
                object_ids[p['id']] = p['last_modified']
        objs = object_ids.items()
        objs.sort()
        return objs

    def _get_all_packages(self, channels):
        object_ids = {}
        for c in channels:
            objs = c.get('all-packages')
            if not objs:
                objs = c.get('packages')
            for p in (objs or []):
                object_ids[p] = None
        object_ids = object_ids.keys()
        object_ids.sort()
        return object_ids

    def dump_shortpackages(self):
        print "Dumping short packages"
        dumper = xmlDiskDumper.ShortPackageDumper(self.options.mountpoint,
            server=self.server, compression=self.compression)
        channels = self._load_channels()
        packages = self._get_all_packages(channels)
        for package in packages:
            print "Dumping short package", package
            dumper.setID(package)
            # We need this information to be accurate, so always force short
            # packages
            ret = dumper.dump(force=1)
            if ret:
                print "    Wrote", ret

    def dump_packages(self):
        print "Dumping packages"
        dumper = xmlDiskDumper.PackageDumper(self.options.mountpoint,
            server=self.server, compression=self.compression)
        channels = self._load_channels()
        packages = self._get_all_packages(channels)
        for package in packages:
            # Load the source package first, to get the timestamp
            p = self._load_short_package(package)
            last_modified = p['last_modified']
            print "Dumping package", package
            dumper.setID(package)
            ret = dumper.dump(force=self.options.force,
                timestamp=last_modified)
            if ret:
                print "    Wrote", ret

    def dump_source_packages(self):
        print "Dumping source packages"
        dumper = xmlDiskDumper.SourcePackageDumper(self.options.mountpoint,
            server=self.server, compression=self.compression)
        channels = self._load_channels()
        packages = self._get_channel_object_ids(channels, 'source-packages')
        for package in packages:
            print "Dumping source package", package
            dumper.setID(package)
            ret = dumper.dump(force=self.options.force)
            if ret:
                print "    Wrote", ret

    def dump_errata(self):
        print "Dumping errata"
        dumper = xmlDiskDumper.ErrataDumper(self.options.mountpoint,
            server=self.server, compression=self.compression)
        channels = self._load_channels()
        errata = self._get_channel_errata(channels)
        for erratum, timestamp in errata:
            print "Dumping errata", erratum
            dumper.setID(erratum)
            ret = dumper.dump(force=self.options.force, timestamp=timestamp)
            if ret:
                print "    Wrote", ret

    def dump_rpms(self):
        print "Dumping rpms"
        dumper = xmlDiskDumper.BinaryRPMDumper(self.options.mountpoint,
            server=self.server, compression=self.compression)
        channels = self._load_channels()
        packages = self._get_channel_object_ids(channels, 'packages')
        for package in packages:
            print "Dumping rpm", package
            p = self._load_short_package(package)
            last_modified = p['last_modified']
            last_modified = rhnLib.timestamp(last_modified)
            dumper.setID(package)
            dumper.set_utime(last_modified)
            dumper.dump(force=self.options.force)

    def dump_srpms(self):
        print "Dumping srpms"
        dumper = xmlDiskDumper.SourceRPMDumper(self.options.mountpoint,
            server=self.server, compression=self.compression)
        channels = self._load_channels()
        packages = self._get_channel_object_ids(channels, 'source-packages')
        for package in packages:
            print "Dumping srpm", package
            last_modified = package['last_modified']
            last_modified = rhnLib.timestamp(last_modified)
            dumper.setID(package)
            dumper.set_utime(last_modified)
            dumper.dump(force=self.options.force)

    # Outputs the actions sorted in a meaningful way (topological sort most of
    # the times)
    def _order_actions(self):
        actions = {}
        depends = {}
        depcount = map(lambda x: {}, self.actions.keys())
        for act, adep in self.actions.items():
            hash = {}
            for d in (adep or []):
                hash[d] = None

                # Now mark act as depending on d
                if depends.has_key(d):
                    dlist = depends[d]
                else:
                    dlist = depends[d] = []
                dlist.append(act)
                
            actions[act] = hash
            # Now update the list of counts
            depcount[len(hash.keys())][act] = None

        indep = depcount[0]
        result = []
        while 1:
            if not actions:
                # Done
                break
            if not indep:
                raise Exception, "List cannot be t-sorted"
            act = indep.keys()[0]
            del indep[act]
            # This node no longer depends on anybody
            del actions[act]
            result.append(act)
            # Now update the count for everybody that depends on this one
            if not depends.has_key(act):
                # Nothing to do
                continue
            for d in depends[act]:
                current_dep_count = len(actions[d].keys())
                del depcount[current_dep_count][d]
                del actions[d][act]
                depcount[current_dep_count - 1][d] = None
            del depends[act]

        return result

    def dump_ksdata(self):
        print "Dumping kickstart data"
        dumper = xmlDiskDumper.KickstartDataDumper(self.options.mountpoint,
            server=self.server, compression=self.compression)
        
        channels = self._load_channels()
        ks_labels = self._get_channel_object_ids(channels, 'kickstartable_trees')

        for ks_label in ks_labels:
            dumper.setID(ks_label)
            ret = dumper.dump(force=self.options.force)
            if ret:
                print "    Wrote", ret

    def dump_ksfiles(self):
        print "Dumping kickstart files"
        dumper = xmlDiskDumper.KickstartFilesDumper(self.options.mountpoint,
            server=self.server, compression=self.compression)
        
        # Load data from disk
        handler = xmlSource.getHandler()

        channels = self._load_channels()
        ks_labels = self._get_channel_object_ids(channels, 'kickstartable_trees')
        for ks_label in ks_labels:
            ks_tree = diskImportLib.getKickstartTree(
                self.options.mountpoint, ks_label, handler)
            if ks_tree is None:
                continue

            dumper.setID(ks_label)

            for ks_file in (ks_tree.get('files') or []):
                relative_path = ks_file['relative_path']
                dumper.set_relative_path(relative_path)
                dumper.dump(force=self.options.force)


def patch_url(url, scheme='http', path=None):
    _scheme, netloc, _path, params, query, fragment = urlparse.urlparse(url)
    if not netloc:
        # No schema - trying to patch it up ourselves?
        nu = "%s://%s" % (scheme, url)
        _scheme, netloc, _path, params, query, fragment = urlparse.urlparse(nu)

    if not netloc:
        raise ValueError("Invalid URL: %s" % url)
    if _path == '' and path is not None:
        _path = path
    if string.lower(_scheme) not in ('http', 'https'):
        raise ValueError("Unknown URL scheme %s" % _scheme)
    return urlparse.urlunparse((_scheme, netloc, _path, params, query,
        fragment))

def validate_time(s):
    if s is None:
        return None
    return rhnLib.timestamp(s)

if __name__ == '__main__':
    sys.exit(main() or 0)
