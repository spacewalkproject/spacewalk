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

import os
import sys
from optparse import Option, OptionParser
from common import initCFG, CFG

import xmlSource
import xmlDiskSource
import xmlDiskDumper

from diskImportLib import getHandler, listChannelPackages, listChannelErrata, \
    rpmsPath, getKickstartTree, getChannelAttribute


def main(arglist):
    optionsTable = [
        Option('-m', '--mountpoint',      action='store',      help="mount point"),
        Option('-o', '--output',          action='store',      help='output directory'),
        Option('-c', '--channel',         action='append',     help='process data for this channel only'),
        Option('-p', '--printconf',       action='store_true', help='print the configuration and exit'),
        Option('-f', '--force',           action='store_true', help="force the overwrite of contents"),
        Option(      '--arches',	  action='store_true', help="copy arches only"),
        Option(      '--arches-extra',	  action='store_true', help="copy extra arches only"),
        Option(      '--blacklists',	  action='store_true', help="copy blacklists only"),
        Option(      '--channelfamilies', action='store_true', help="copy channel families only"),
        Option(      '--channels',        action='store_true', help="copy channels only"),
        Option(      '--packages',        action='store_true', help="copy package information only"),
        Option(      '--shortpackages',   action='store_true', help="copy short package information only"),
        Option(      '--sourcepackages',  action='store_true', help="copy source package information only"),
        Option(      '--errata',          action='store_true', help="copy errata only"),
        Option(      '--rpms',            action='store_true', help="copy only the rpm packages"),
        Option(      '--srpms',           action='store_true', help="copy only the source rpm packages"),
        Option(      '--ksdata',          action='store_true', help="copy only the kickstart metainformation"),
        Option(      '--ksfiles',         action='store_true', help="copy only the kickstart files"),
    ]
    optionParser = OptionParser(option_list=optionsTable)
    options, args = optionParser.parse_args()

    # Init the config
    initCFG("server.satellite")

    if options.printconf:
        CFG.show()
        return

    # Figure out which actions to execute
    allactions = ["arches", "arches_extra", "blacklists", "channelfamilies", "channels", "shortpackages", "packages", "errata", "rpms", "ksdata", "ksfiles"]
    actions = filter(lambda x, options=options: getattr(options, x), allactions)
    # If nothing specified on the command line, default to all the actions
    if not actions:
        actions = allactions

    mountPoint = options.mountpoint
    if not mountPoint:
        print "Error: mount point not specified. Please use -m or --mountpoint"
        return

    destMountPoint = options.output
    if not destMountPoint:
        print "Error: output directory not specified. Please use -o or --output"
        return

    force = options.force

    mappings = {
	'arches'    : (
	    xmlDiskSource.ArchesDiskSource,
	    xmlDiskDumper.ArchesDumper, ),
        'arches_extra'  : (
	    xmlDiskSource.ArchesExtraDiskSource,
	    xmlDiskDumper.ArchesExtraDumper, ),
	'blacklists'	: (
	    xmlDiskSource.BlacklistsDiskSource,
	    xmlDiskDumper.BlacklistsDumper, ),
	'channelfamilies'   : (
	    xmlDiskSource.ChannelFamilyDiskSource,
	    xmlDiskDumper.ChannelFamilyDumper, ),
    }
    for action in mappings.keys():
	if action in actions:
	    print "Copying %s information" % action
	    source_class, dumper_class = mappings[action]
	    source = source_class(mountPoint)
	    stream = source.load()
	    dumper = dumper_class(destMountPoint,
		compression=9, inputStream=stream)
	    dumper.dump(force=force)


    channels = options.channel
    if not channels:
        # No channel specified on the command line. Poke at the metadata
        # repository to see what we have available
        channel_source = xmlDiskSource.ChannelDiskSource(mountPoint)
        channels = channel_source.list()

    if "channels" in actions:
        print "Copying channels: %s" % (channels, )
        channel_source = xmlDiskSource.ChannelDiskSource(mountPoint)
        dumper = xmlDiskDumper.ChannelDumper(destMountPoint, compression=9)

        for channel in channels:
            channel_source.setChannel(channel)
            stream = channel_source.load()
            dumper.setChannel(channel)
            dumper.setInputStream(stream)
            dumper.dump(force=force)

    handler = getHandler()

    while 1:
        if "shortpackages" in actions:
            print "Copying short packages for channels: %s" % (channels, )
            ps = xmlDiskSource.ShortPackageDiskSource(mountPoint)
            dumper = xmlDiskDumper.ShortPackageDumper(destMountPoint, compression=9)
            actions.remove("shortpackages")
            _dump_channel_objects(dumper, ps, mountPoint, channels, handler,
                sources=0, all=1, force=force)
        elif "packages" in actions:
            print "Copying packages for channels: %s" % (channels, )
            ps = xmlDiskSource.PackageDiskSource(mountPoint)
            dumper = xmlDiskDumper.PackageDumper(destMountPoint, compression=9)
            actions.remove("packages")
            _dump_channel_objects(dumper, ps, mountPoint, channels, handler,
                sources=0, all=0, force=force)
        elif "sourcepackages" in actions:
            print "Copying source packages for channels: %s" % (channels, )
            ps = xmlDiskSource.SourcePackageDiskSource(mountPoint)
            dumper = xmlDiskDumper.SourcePackageDumper(destMountPoint,
                compression=9)
            actions.remove("sourcepackages")
            _dump_channel_objects(dumper, ps, mountPoint, channels, handler,
                sources=1, all=0, force=force)
        else:
            # We're done
            break

    while 1:
        if "rpms" in actions:
            action = "rpms"
            sources = 0
        elif "srpms" in actions:
            action = "srpms"
            sources = 1
        else:
            break
        actions.remove(action)
        
        print "Copying %s for channels: %s" % (action, channels, )

        ids = {}
        for channel in channels:
            # List the packages for this channel
            plist = listChannelPackages(mountPoint, channel, handler,
                sources=sources)
            for pkgid in plist:
                ids[pkgid] = None

        pkgIds = ids.keys()
        pkgIds.sort()
        del ids

        for pkg in pkgIds:
            srcfile = rpmsPath(pkg, mountPoint, sources=sources)
            if not os.path.exists(srcfile):
                print "File %s does not exist!" % srcfile
                continue
            destfile = rpmsPath(pkg, destMountPoint, sources=sources)
            dirname = os.path.dirname(destfile)
            if not os.path.isdir(dirname):
                os.makedirs(dirname)
        
	    if force and os.path.exists(destfile):
		os.unlink(destfile)

	    if not os.path.exists(destfile):
		# Hard-link the rpm itself, to avoid wasting disk space
		os.link(srcfile, destfile)

    if "errata" in actions:
        print "Copying errata for channels: %s" % (channels, )
        errata = {}
        for channel in channels:
            for err in listChannelErrata(mountPoint, channel, handler):
                errata[err] = None

        errata = errata.keys()
        errata.sort()
            
        errata_source = xmlDiskSource.ErrataDiskSource(mountPoint)
        dumper = xmlDiskDumper.ErrataDumper(destMountPoint, compression=9)
        dumper.prune(errata)
        for err in errata:
            errata_source.setID(err)
            stream = errata_source.load()
            dumper.setID(err)
            dumper.setInputStream(stream)
            dumper.dump(force=force)
    
    if "ksdata" in actions:
        print "Copying kickstart data: %s" % (channels, )
        ksdata_source = xmlDiskSource.KickstartDataDiskSource(mountPoint)
        dumper = xmlDiskDumper.KickstartDataDumper(destMountPoint, compression=9)

        ks_tree_labels = get_kickstart_labels(mountPoint, channels)

        for ks_tree_label in ks_tree_labels:
            ksdata_source.setID(ks_tree_label)
            stream = ksdata_source.load()
            dumper.setID(ks_tree_label)
            dumper.setInputStream(stream)
            dumper.dump(force=force)

    if "ksfiles" in actions:
        print "Copying kickstart files: %s" % (channels, )
            
        ks_files_src = xmlDiskSource.KickstartFileDiskSource(mountPoint)
        ks_files_dest = xmlDiskSource.KickstartFileDiskSource(destMountPoint)
        
        # Load data from disk

        ks_tree_labels = get_kickstart_labels(mountPoint, channels)
    
        handler = xmlSource.getHandler()

        for ks_tree_label in ks_tree_labels:
            ks_tree = getKickstartTree(mountPoint, ks_tree_label, handler)
            if ks_tree is None:
                continue

            ks_label = ks_tree['label']
            ks_files_src.setID(ks_label)
            ks_files_dest.setID(ks_label)

            for ks_file in (ks_tree.get('files') or []):
                relative_path = ks_file['relative_path']
                ks_files_src.set_relative_path(relative_path)
                src_path = ks_files_src._getFile()
                if not os.path.exists(src_path):
                    print "Could not find file %s" % src_path
                    continue

                ks_files_dest.set_relative_path(relative_path)
                dest_path = ks_files_dest._getFile(create=1)

                if force and os.path.exists(dest_path):
                    os.unlink(dest_path)

                if not os.path.exists(dest_path):
                    # Hard-link the file, to avoid wasting disk space
                    os.link(src_path, dest_path)

    handler.close()
        
def _dump_channel_objects(dumper, package_source, mountPoint, channels, 
        handler, sources=0, all=0, force=0):
    # Uniquify the items in the list too
    ids = {}
    for channel in channels:
        # List the packages for this channel
        for pkgid in listChannelPackages(mountPoint, channel, handler,
                sources=sources, all=all):
            ids[pkgid] = None

    pkgIds = ids.keys()
    pkgIds.sort()
    del ids

    dumper.prune(pkgIds)
    for pkg in pkgIds:
        package_source.setID(pkg)
        stream = package_source.load()
        dumper.setID(pkg)
        dumper.setInputStream(stream)
        dumper.dump(force=force)

# Fetch the kickstart tree labels from the list of channels
def get_kickstart_labels(mount_point, channels):
    handler = xmlSource.getHandler()
    ks_tree_labels = []
    for channel in channels:
        ks_tree_labels.extend(getChannelAttribute(mount_point, channel, 
            'kickstartable_trees', handler) or [])
    return ks_tree_labels
    
if __name__ == '__main__':
    main(sys.argv)

