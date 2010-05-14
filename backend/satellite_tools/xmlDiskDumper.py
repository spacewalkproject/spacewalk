#!/usr/bin/python
#
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
import time
import gzip
import stat
import tempfile

from common import rhnLib
import xmlSource
import xmlDiskSource

from rhn import rpclib

class Dumper:
    _loader_class = None
    _timestamp_field = 'last_modified'
    def __init__(self, mountPoint, compression=0, server=None,
            inputStream=None):
        self.mountPoint = mountPoint
        self.compression = compression
        self.server = server
        self.setMixin()
        self.inputStream = inputStream
        self.buffer_size = 65536

    def setMixin(self):
        self._mixin = None

    def _getInputStream(self):
        # If we've been passed an input stream, this is what we are using
        if self.inputStream:
            return self.inputStream

        # Otherwise, generate the input stream
        return apply(self._getMethod(), self._getArgs())

    def setInputStream(self, inputStream):
        self.inputStream = inputStream

    def _getMethod(self):
        # Virtual
        return None

    def _getArgs(self):
        # Virtual
        return ()

    def _getFile(self, create=0):
        return self._mixin._getFile(create=create)
    
    def getOutputStream(self, force=0, timestamp=None):
        if not force:
            # Do we already have the file on the disk?
            filename = self._getFile()
            if self.compression:
                fn = filename + ".gz"
                if os.path.isfile(fn) and os.path.getsize(fn):
                    # gzip-compressed file
                    if self._check_file_timestamp(fn, timestamp):
                        # Already exists
                        return None, fn
            else: # Plain dump
                if os.path.isfile(filename) and os.path.getsize(filename):
                    if self._check_file_timestamp(filename, timestamp):
                        # Already exists
                        return None, filename

        # Need to re-create the file
        filename = self._mixin._getFile(create=1)
        if self.compression:
            dfilename = filename + ".gz"
            f = gzip.open(dfilename, "wb", self.compression)
        else:
            dfilename = filename
            f = open(filename, "w+")
        return f, dfilename

    def _check_file_timestamp(self, filename, timestamp):
        if timestamp is None:
            # No timestamp specified
            return 1
        timestamp = rhnLib.timestamp(timestamp)
        file_timestamp = os.stat(filename)[stat.ST_MTIME]
        if timestamp == file_timestamp:
            return 1
        return 0

    def _set_file_timestamp(self, filename, timestamp):
        if timestamp is None:
            return
        timestamp = rhnLib.timestamp(timestamp)
        os.utime(filename, (timestamp, timestamp))

    def load_object(self, stream):
        "Loads an object from the specified stream"
        return _load_object_from_stream(stream, self._loader_class)

    def dump(self, force=0, timestamp=None):
        # Dumps the requested stream into a file
        # if force is not set, it does nothing if the file already exists
        dstream, dfilename = self.getOutputStream(force=force, timestamp=timestamp)
        if not dstream:
            # nothing to do
            return None

        tries = 5
        while 1:
            try:
                stream = self._getInputStream()
            except rpclib.ProtocolError:
                if tries == 0:
                    # No more tries
                    raise
                print "Connection lost, retrying %s more time(s)..." % tries
                tries = tries - 1
                time.sleep(1.5)
                continue
            else:
                break
                    

        # Open a temporary file
        # Hopefully, this reduces the window of time when errors can occur and
        # leave incomplete dumps in the final location
        f = tempfile.TemporaryFile()
        while 1:
            buff = stream.read(self.buffer_size)
            if not buff:
                break
            f.write(buff)

        # Try to find a timestamp
        if self._loader_class:
            f.seek(0, 0)
            try:
                obj = self.load_object(f)
            except xmlSource.SAXParseException:
                # XXX
                raise
            # Look for a timestamp object
            obj_timestamp = obj[self._timestamp_field]
            if timestamp and timestamp != obj_timestamp:
                # Hmm. Loaded object with a specific timestamp requested, yet
                # the timestamp inside the object is different.
                raise ValueError("Mismatching timestamps", timestamp,
                    obj_timestamp)
        else:
            obj_timestamp = None

        # Everything should be there now (if an error occured, we should not
        # reach this point)
        f.seek(0, 0)
        while 1:
            buff = f.read(self.buffer_size)
            if not buff:
                break
            dstream.write(buff)
        f.close()
        dstream.close()
        self._set_file_timestamp(dfilename, obj_timestamp)
        return dfilename

class ArchesDumper(Dumper):
    
    def setMixin(self):
        self._mixin = xmlDiskSource.ArchesDiskSource(self.mountPoint)

    def _getMethod(self):
        return self.server.dump.arches

class ArchesExtraDumper(Dumper):
    def setMixin(self):
        self._mixin = xmlDiskSource.ArchesExtraDiskSource(self.mountPoint)

    def _getMethod(self):
        return self.server.dump.arches_extra


class ChannelFamilyDumper(Dumper):

    def setChannels(self, channel_labels):
        self.channel_labels = channel_labels or []
    
    def setMixin(self):
        self._mixin = xmlDiskSource.ChannelFamilyDiskSource(self.mountPoint)
        self.channel_labels = []

    def _getMethod(self):
        return self.server.dump.channel_families

    def _getArgs(self):
        return (self.channel_labels, )

class ChannelDumper(Dumper):
    _loader_class = xmlSource.ChannelContainer

    def setMixin(self):
        self._mixin = xmlDiskSource.ChannelDiskSource(self.mountPoint)

    def setChannel(self, channel):
        return self._mixin.setChannel(channel)

    def _getMethod(self):
        return self.server.dump.channels

    def _getArgs(self):
        # Virtual
        snapshot = self.snapshot
        flags = self.flags
        return ([self._mixin.channel], snapshot, flags)
        
class ShortPackageDumper(Dumper):
    _loader_class = xmlSource.IncompletePackageContainer

    def setMixin(self):
        self._mixin = xmlDiskSource.ShortPackageDiskSource(self.mountPoint)

    def setID(self, id):
        return self._mixin.setID(id)

    def _getMethod(self):
        return self.server.dump.packages_short

    def _getArgs(self):
        return ([self._mixin.id], )

    def prune(self, objlist):
        # Prunes the repository of all the objects BUT the ones in objlist
        # First, get the list of all the objects
        dirname = self._mixin._getDir()
        if not (os.path.exists(dirname) and os.path.isdir(dirname)):
            # Nothing to do - all the objects are missing
            print "Dir does not exist", dirname
            return objlist
        diskfiles = findFiles(self._mixin._getDir())
        missing = []
        for obj in objlist:
            self._mixin.setID(obj)
            filename = self._mixin._getFile(create = 0)
            if self.compression:
                filename = filename + '.gz'

            if filename in diskfiles:
                # The file is on the disk
                del diskfiles[filename]
            else:
                # Missing file
                missing.append(obj)

        # Whatever is left in diskfiles are extra files that have to be pruned
        for filename in diskfiles.keys():
            print "Pruning %s" % filename
            os.unlink(filename)
            try:
                os.removedirs(os.path.dirname(filename))
            except OSError, e:
                if e.errno == 39: # Directory not empty
                    pass
                else:
                    raise e
                
        return missing
        

class PackageDumper(ShortPackageDumper):
    _loader_class = xmlSource.PackageContainer

    def setMixin(self):
        self._mixin = xmlDiskSource.PackageDiskSource(self.mountPoint)

    def _getMethod(self):
        return self.server.dump.packages

class SourcePackageDumper(ShortPackageDumper):
    _loader_class = xmlSource.SourcePackageContainer

    def setMixin(self):
        self._mixin = xmlDiskSource.SourcePackageDiskSource(self.mountPoint)

    def _getMethod(self):
        return self.server.dump.source_packages

class ErrataDumper(ShortPackageDumper):
    _loader_class = xmlSource.ErrataContainer

    def setMixin(self):
        self._mixin = xmlDiskSource.ErrataDiskSource(self.mountPoint)

    def _getMethod(self):
        return self.server.dump.errata

class BlacklistsDumper(Dumper):

    def setMixin(self):
        self._mixin = xmlDiskSource.BlacklistsDiskSource(self.mountPoint)

    def _getMethod(self):
        return self.server.dump.blacklist_obsoletes

class ProductNamesDumper(Dumper):
    
    def setMixin(self):
        self._mixin = xmlDiskSource.ProductNamesDiskSource(self.mountPoint)

    def _getMethod(self):
        return self.server.dump.product_names


class BinaryRPMDumper(ShortPackageDumper):
    _loader_class = None

    def setMixin(self):
        self._mixin = xmlDiskSource.BinaryRPMDiskSource(self.mountPoint)

    def _getArgs(self):
        return (self._mixin.id, )

    def _getMethod(self):
        return self.server.dump.get_rpm

    def set_utime(self, last_modified):
        self._last_modified = last_modified

    def dump(self, force=0):
        # Turn off compression
        self.compression = 0
        filename = self._getFile()
        try:
            ShortPackageDumper.dump(self, force=force)
        except rpclib.Fault, e:
            if e.faultCode in (-3003, -3007):
                # Missing file
                print "Missing package", self._mixin.id
                # Clean up the file if we have to
                if os.path.isfile(filename) and os.path.getsize(filename) == 0:
                    os.unlink(filename)
                return
            raise
        # Fix the timestaps for this file
        lm = self._last_modified
        os.utime(filename, (lm, lm))

class SourceRPMDumper(BinaryRPMDumper):

    def setMixin(self):
        self._mixin = xmlDiskSource.SourceRPMDiskSource(self.mountPoint)

    def _getMethod(self):
        return self.server.dump.get_source_rpm

class KickstartDataDumper(Dumper):
    _loader_class = xmlSource.KickstartableTreesContainer

    def setMixin(self):
        self._mixin = xmlDiskSource.KickstartDataDiskSource(self.mountPoint)

    def setID(self, ks_label):
        return self._mixin.setID(ks_label)

    def _getMethod(self):
        return self.server.dump.kickstartable_trees

    def _getArgs(self):
        # Virtual
        return ([self._mixin.id], )
    
class KickstartFilesDumper(KickstartDataDumper):
    _loader_class = None

    def setMixin(self):
        self._mixin = xmlDiskSource.KickstartFileDiskSource(self.mountPoint)

    def set_relative_path(self, relative_path):
        return self._mixin.set_relative_path(relative_path)

    def _getArgs(self):
        return (self._mixin.id, self._mixin.relative_path, )

    def _getMethod(self):
        return self.server.dump.get_ks_file

    def dump(self, force=0):
        # Turn off compression
        self.compression = 0
        try:
            return Dumper.dump(self, force=force)
        except rpclib.Fault, e:
            if e.faultCode in (-3003, -3007):
                # Missing file
                print "Missing file", self._mixin.relative_path
                # Clean up the file if we have to
                filename = self._getFile()
                if os.path.isfile(filename) and os.path.getsize(filename) == 0:
                    os.unlink(filename)
                return
            raise e


# The visitfunc argument for os.path.walk
def __visitfunc(arg, dirname, names):
     for f in names:
        filename = os.path.normpath("%s/%s" % (dirname, f))
        if os.path.isdir(filename):
            # walk will process it later
            continue
        # Add the filename to the dict
        arg[filename] = None
    
# Given a directory name, returns the paths of all the files from that
# directory, together with the file size
def findFiles(start):
    a = {}
    os.path.walk(start, __visitfunc, a)
    return a

def load_short_package(stream):
    return _load_object_from_stream(stream,
        xmlSource.IncompletePackageContainer)

def _load_object_from_stream(stream, container_class):
    # Loads an object from the specified stream, using the container class
    handler = xmlSource.SatelliteDispatchHandler()
    container = container_class()
    handler.set_container(container)
    handler.process(stream)
    item = container.batch[0]
    handler.clear()
    handler.reset()
    return item

