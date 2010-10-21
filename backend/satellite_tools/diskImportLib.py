#
# Common dumper stuff
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
#

import os

from xml.sax import SAXParseException

from spacewalk.common import Traceback, CFG
from spacewalk.server.rhnSQL.const import ORACLE, POSTGRESQL

import xmlSource
import xmlDiskSource
from spacewalk.server.importlib.channelImport import ChannelImport, ChannelFamilyImport
from spacewalk.server.importlib.packageImport import PackageImport, SourcePackageImport
from spacewalk.server.importlib import archImport
from spacewalk.server.importlib import blacklistImport
from spacewalk.server.importlib import productNamesImport

class Backend:
    __backend = None

    def get_backend(self):
        if self.__backend:
            return self.__backend


        if CFG.DB_BACKEND == ORACLE:
            from spacewalk.server.importlib.backendOracle import OracleBackend
            Backend.__backend = OracleBackend()
        elif CFG.DB_BACKEND == POSTGRESQL:
            from spacewalk.server.importlib.backendOracle import PostgresqlBackend
            Backend.__backend = PostgresqlBackend()
        Backend.__backend.init()
        return Backend.__backend
        
# get_backend() returns a shared instance of an Oracle backend
def get_backend():
    return Backend().get_backend()

# Retrieves an attribute for a channel dumped in XML
def getChannelAttribute(mountPoint, channel, attribute, handler):
    dumper = xmlDiskSource.ChannelDiskSource(mountPoint=mountPoint)
    dumper.setChannel(channel)
    f = dumper.load()

    # save the previous container
    oldContainer = handler.get_container(xmlSource.ChannelContainer.container_name)
    # And replace it with the default one - only saves stuff in the batch
    newContainer = xmlSource.ChannelContainer()
    handler.set_container(newContainer)

    # Process the information
    handler.process(f)

    channel = newContainer.batch[0]

    # Cleanup
    handler.reset()

    # Restore the old container
    handler.set_container(oldContainer)

    return channel.get(attribute)


# Lists the packages linked to a specific channel
def listChannelPackages(mountPoint, channel, handler, sources=0, all=0):
    if sources:
        return getChannelAttribute(mountPoint, channel, 'source-packages', 
            handler)
    if all:
        # All packages requested
        ret = getChannelAttribute(mountPoint, channel, 'all-packages', handler)
        if ret:
            return ret
    return getChannelAttribute(mountPoint, channel, 'packages', handler)


# Lists the errata linked to a specific channel
def listChannelErrata(mountPoint, channel, handler):
    return getChannelAttribute(mountPoint, channel, 'errata', handler)


# Retrieves an attribute for a channel dumped in XML
def getKickstartTree(mountPoint, ks_label, handler):
    ds = xmlDiskSource.KickstartDataDiskSource(mountPoint=mountPoint)
    ds.setID(ks_label)
    f = ds.load()

    # save the previous container
    oldContainer = handler.get_container(xmlSource.KickstartableTreesContainer.container_name)
    # And replace it with the default one - only saves stuff in the batch
    newContainer = xmlSource.KickstartableTreesContainer()
    handler.set_container(newContainer)

    # Process the information
    handler.process(f)

    if not newContainer.batch:
        return None

    kstree = newContainer.batch[0]

    # Cleanup
    handler.reset()

    # Restore the old container
    handler.set_container(oldContainer)

    return kstree


# Functions for dumping packages
def rpmsPath(obj_id, mountPoint, sources=0):
    # returns the package path (for exporter/importer only)
    # not to be confused with where the package lands on the satellite itself.
    if not sources:
        template = "%s/rpms/%s/%s.rpm"
    else:
        template = "%s/srpms/%s/%s.rpm"
    return os.path.normpath(template % (
        mountPoint, xmlDiskSource.hashPackageId(obj_id, mod=100, padding=2), obj_id))


class BlacklistObsoletesContainer(xmlSource.BlacklistObsoletesContainer):
    def endContainerCallback(self):
        if not self.batch:
            return
        importer = blacklistImport.BlacklistObsoletesImport(
            self.batch, get_backend())
        importer.run()
        self.batch = []

class ProductNamesContainer(xmlSource.ProductNamesContainer):
    def endContainerCallback(self):
        if not self.batch:
            return
        importer = productNamesImport.ProductNamesImport(
            self.batch, get_backend())
        importer.run()
        self.batch = []

class diskImportLibContainer:
    """virtual class - redefines endContainerCallback"""
    importer_class = None
    def endContainerCallback(self):
        importer = importer_class(self.batch, get_backend())
        importer.run()
        self.batch = []

class ChannelArchContainer(diskImportLibContainer, xmlSource.ChannelArchContainer):
    importer_class = archImport.ChannelArchImport

class PackageArchContainer(diskImportLibContainer, xmlSource.PackageArchContainer):
    importer_class = archImport.PackageArchImport

class ServerArchContainer(diskImportLibContainer, xmlSource.ServerArchContainer):
    importer_class = archImport.ServerArchImport

class CPUArchContainer(diskImportLibContainer, xmlSource.CPUArchContainer):
    importer_class = archImport.CPUArchImport

class ServerPackageArchCompatContainer(diskImportLibContainer, xmlSource.ServerPackageArchCompatContainer):
    importer_class = archImport.ServerPackageArchCompatImport

class ServerChannelArchCompatContainer(diskImportLibContainer, xmlSource.ServerChannelArchCompatContainer):
    importer_class = archImport.ServerChannelArchCompatImport

class ChannelPackageArchCompatContainer(diskImportLibContainer, xmlSource.ChannelPackageArchCompatContainer):
    importer_class = archImport.ChannelPackageArchCompatImport

class ServerGroupServerArchCompatContainer(diskImportLibContainer, xmlSource.ServerGroupServerArchCompatContainer):
    importer_class = archImport.ServerGroupServerArchCompatImport

class ChannelFamilyContainer(diskImportLibContainer, xmlSource.ChannelFamilyContainer):
    importer_class = ChannelFamilyImport

class ChannelContainer(diskImportLibContainer, xmlSource.ChannelContainer):
    importer_class = ChannelImport


class PackageContainer(diskImportLibContainer, xmlSource.PackageContainer):
    importer_class = PackageImport

class SourcePackageContainer(diskImportLibContainer, xmlSource.SourcePackageContainer):
    importer_class = SourcePackageImport

# Handy function that returns a new handler object (so we can parse XML
# streams)
def getHandler():
    handler = xmlSource.getHandler()
    handler.set_container(ChannelArchContainer())
    handler.set_container(PackageArchContainer())
    handler.set_container(ServerArchContainer())
    handler.set_container(ServerPackageArchCompatContainer())
    handler.set_container(ServerChannelArchCompatContainer())
    handler.set_container(ChannelPackageArchCompatContainer())
    handler.set_container(CPUArchContainer())
    handler.set_container(ChannelFamilyContainer())
    handler.set_container(ChannelContainer())
    handler.set_container(PackageContainer())
    handler.set_container(BlacklistObsoletesContainer())
    handler.set_container(ProductNamesContainer())
    return handler

