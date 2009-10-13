#!/usr/bin/python
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
# Package import code on the app side
#

from common import rhnFault, rhn_rpm, log_debug

from server import rhnChannel, taskomatic, rhnSQL
from server.importlib.headerSource import createPackage
from server.importlib.importLib import Collection
from server.importlib.packageImport import packageImporter
from server.importlib.backendOracle import OracleBackend
from server.importlib.errataCache import schedule_errata_cache_update

def uploadPackages(info, source=0, force=0, caller=None):
    log_debug(4, source, force, caller)
    batch = Collection()
    packageList = info.get("packages") or []
    if not packageList:
        raise Exception("Nothing to do")

    org_id = info.get('orgId')
    if org_id == '':
        org_id = None

    if source:
        channelList = []
    else:
        channelList = info.get("channels") or []

    for package in packageList:
        p = __processPackage(package, org_id, channelList, source)
        batch.append(p)

    backend = OracleBackend()
    backend.init()
    importer = packageImporter(batch, backend, source, caller=caller)

    importer.setIgnoreUploaded(1)
    importer.setUploadForce(force)

    importer.run()
    if not source:
        importer.subscribeToChannels()

    # Split the result in two lists - already uploaded and new packages
    newpkgs = []
    uploaded = []
    for pkg in importer.status():
        if pkg.ignored or pkg.diff:
            uploaded.append(pkg)
        else:
            newpkgs.append(pkg)

    # Schedule an errata cache update only if we touched the channels
    if not source:
        # makes sense only for binary packages
        schedule_errata_cache_update(importer.affected_channels)
        taskomatic.add_to_repodata_queue_for_channel_package_subscription(
                importer.affected_channels, batch, caller)
        rhnSQL.commit()

    return _formatStatus(uploaded), _formatStatus(newpkgs)

def __processPackage(package, org_id, channels, source):
    log_debug(4, org_id, channels, source)
    if not package.has_key('checksum'):
        raise rhnFault(50, "The package's checksum digest has not been specified")
    if not package.has_key('packageSize'):
        raise rhnFault(50, "The package size has not been specified")

    header = rhn_rpm.headerLoad(package['header'].data)
    if not header:
        raise rhnFault(50)
    checksum = package['checksum']
    packageSize = package['packageSize']
    relpath = package.get('relativePath')
    
    if package.has_key('header_start'):
        header_start = package['header_start']
    else:
        header_start = 0
    if package.has_key('header_end'):
        header_end = package['header_end']
    else:
        # Just say the whole package
        header_end = packageSize

    p = createPackage(header, packageSize, checksum, relpath, org_id,
        header_start, header_end, channels)
    return p

def _formatStatus(status):
    objlist = []
    for pkg in status:
        name = pkg.name
        epoch = pkg.evr[0]
        if epoch is None:
            epoch = ""
        else:
            epoch = str(epoch)
        version = pkg.evr[1]
        release = pkg.evr[2]
        arch = pkg.arch
        hash = {}
        ignored = pkg.ignored
        if ignored is None:
            ignored = 0
        hash['ignored'] = ignored
        hash['diff'] = _dump(pkg.diff)
        objlist.append([name, version, release, epoch, arch, hash])
    return objlist
        

def _dump(object):
    if object is None:
        return ''
    from types import IntType, StringType, FloatType
    if type(object) in (IntType, StringType, FloatType):
        return object
    from types import ListType
    if isinstance(object, ListType):
        return map(_dump, object)
    from types import TupleType
    if isinstance(object, TupleType):
        return tuple(map(_dump, object))
    from types import DictType
    if isinstance(object, DictType):
        dict = {}
        for h, v in object.items():
            dict[_dump(h)] = _dump(v)
        return dict
    return str(object)
           

 
def listChannelsSource(channelList):
    # Lists the packages from these channels
    # Uniquify the channels
    channelHash = {}
    channels = []
    for channel in channelList:
        if channelHash.has_key(channel):
            # Already seen
            continue
        channels.append(channel)
        channelHash[channel] = None
    # channels is the unique list of channels now
    rez = []
    for channel in channels:
        c_info = rhnChannel.channel_info(channel)
        if not c_info:
            # No packages in this channel
            continue

        packageList = rhnChannel.list_packages_source(c_info['id'])
        for p in packageList:
            for pkg in range(len(p)):
                if p[pkg] is None:
                    p[pkg] = ""
            print p
            rez.append([p[0], p[1], p[2], p[3], channel])
    return rez

def listChannels(channelList):
    # Lists the packages from these channels
    # Uniquify the channels
    channelHash = {}
    channels = []
    for channel in channelList:
        if channelHash.has_key(channel):
            # Already seen
            continue
        channels.append(channel)
        channelHash[channel] = None
    # channels is the unique list of channels now
    rez = []
    for channel in channels:
        c_info = rhnChannel.channel_info(channel)
        if not c_info:
            # No packages in this channel
            continue

        packageList = rhnChannel.list_packages_sql(c_info['id'])
        for p in packageList:
            # We don't care about the size for now, even if we all know size
            # matters :-)
            rez.append([p[0], p[1], p[2], p[3], p[4], channel])
    return rez
