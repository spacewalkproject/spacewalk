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

# system module imports
import os
import stat

from rhn import rpclib

# common modules imports
from common import log_debug, CFG, rhnFault
from common import rhnRepository, rhnFlags, rhnCache, redirectException
from common.rhnLib import rfc822time, timestamp

# local modules imports
import rhnChannel, rhnPackage
from rhnServer import server_lib
from repomd import repository

# Cache class to perform RHN server file system and DB actions.
class Repository(rhnRepository.Repository):
    # This class gets all data from the file system and oracle.
    # All the functions that are performed upon GET requests are here (and
    # since proxies perform these functions as well, a good chunk of code is
    # in common/rhnRepository.py)
    #
    # The listall code is here too, because it performs a lot of disk caching
    # and here's the appropriate location for it
    #
    # The dependency solving code is not handled in this repository -
    # all the code we need is already in xmlrpc/up2date
    def __init__(self, channelName = None, server_id = None, username = None):
        #"""Initialize the class, setting channel name and server
        #
        #ID, that serial number (w/o ID-), if necessary.
        #NOTE: server_id is a string.
        #"""
        log_debug(3, channelName, server_id)
        rhnRepository.Repository.__init__(self, channelName)
        self.server_id = server_id
        self.username = username
        self.functions.append('listPackages')
        self.functions.append('getObsoletes')
        self.functions.append('getObsoletesBlacklist')
        self.functions.append('listAllPackages')
        self.functions.append('listAllPackagesComplete')
        self.functions.append('repodata')
        self.set_compress_headers(CFG.COMPRESS_HEADERS)
        self.redirect_location = None

    def getPackageHeader(self, pkgFilename):
        ret = rhnRepository.Repository.getPackageHeader(self, pkgFilename)
        # Clean up the download-accelerator flag
        rhnFlags.set("Download-Accelerator-Path", None)
        return ret

    # Clients v2+
    # returns a list of the channels the server is subscribed to, or
    # could subscribe to.
    def listChannels(self):
        return rhnChannel.channels_for_server(self.server_id)
           
    # Clients v2+.
    # Creates and/or serves up a cached copy of the package list for
    # this channel.
    def listPackages(self, version):
        log_debug(3, self.channelName, version)
        # Check to see if the version they are requesting is the latest
        
        # check the validity of what the client thinks about this channel
        # or blow up
        self.__check_channel(version)        
        
        packages = rhnChannel.list_packages(self.channelName)

        # transport options...
        transportOptions = rhnFlags.get('outputTransportOptions')
        transportOptions['Last-Modified'] = rfc822time(timestamp(version))
        rhnFlags.set("compress_response", 1)
        return packages

    # Returns a list of packages that obsolete other packages
    def getObsoletes(self, version):
        log_debug(3, self.channelName, version)
        # Check to see if the version they are requesting is the latest
        
        # check the validity of what the client thinks about this channel
        # or blow up
        self.__check_channel(version)        
        
        obsoletes = rhnChannel.list_obsoletes(self.channelName)

        # Set the transport options
        transportOptions = rhnFlags.get('outputTransportOptions')
        transportOptions['Last-Modified'] = rfc822time(timestamp(version))
        rhnFlags.set("compress_response", 1)
        return obsoletes

    # Returns a list of packages that obsolete other packages
    # XXX Obsoleted
    def getObsoletesBlacklist(self, version):
        log_debug(3, self.channelName, version)
        # Check to see if the version they are requesting is the latest
        
        # check the validity of what the client thinks about this channel
        # or blow up
        self.__check_channel(version)        
        
        # Set the transport options
        transportOptions = rhnFlags.get('outputTransportOptions')
        transportOptions['Last-Modified'] = rfc822time(timestamp(version))
        rhnFlags.set("compress_response", 1)
        # Return nothing
        return []

    # Creates and/or serves up a cached copy of all the packages for
    # this channel.
    def listAllPackages(self, version):
        log_debug(3, self.channelName, version)
        # Check to see if the version they are requesting is the latest
        
        # check the validity of what the client thinks about this channel
        # or blow up
        self.__check_channel(version)        
        
        packages = rhnChannel.list_all_packages(self.channelName)

        # transport options...
        transportOptions = rhnFlags.get('outputTransportOptions')
        transportOptions['Last-Modified'] = rfc822time(timestamp(version))
        rhnFlags.set("compress_response", 1)
        return packages

    # Creates and/or serves up a cached copy of all the packages for
    # this channel including requires, obsoletes, conflicts, etc.
    def listAllPackagesComplete(self, version):
        log_debug(3, self.channelName, version)
        # Check to see if the version they are requesting is the latest
        
        # check the validity of what the client thinks about this channel
        # or blow up
        self.__check_channel(version)        
        
        packages = rhnChannel.list_all_packages_complete(self.channelName)

        # transport options...
        transportOptions = rhnFlags.get('outputTransportOptions')
        transportOptions['Last-Modified'] = rfc822time(timestamp(version))
        rhnFlags.set("compress_response", 1)
        return packages


    def repodata(self, file_name):
        log_debug(3, 'repodata', file_name)
        c_info = rhnChannel.channel_info(self.channelName)
        repo = repository.get_repository(c_info)

        output = None
        content_type = "application/x-gzip"

        if file_name == "repomd.xml":
            content_type = "text/xml"
            output = repo.get_repomd_file()
        elif file_name == "primary.xml.gz":
            output = repo.get_primary_xml_file()
        elif file_name == "other.xml.gz":
            output = repo.get_other_xml_file() 
        elif file_name == "filelists.xml.gz":
            output = repo.get_filelists_xml_file()
        elif file_name == "updateinfo.xml.gz":
            output = repo.get_updateinfo_xml_file()
        elif file_name == "comps.xml":
            content_type = "text/xml"
            output = repo.get_comps_file()
      
        output = rpclib.File(output, name=file_name)

        rhnFlags.set('Content-Type', content_type)

        return output

    # Helper functions
    # These functions are not private, they should be defined as 'protected',
    # since the code that handles v2 package retrieval (plus headers) is in
    # common/rhnRepository, and expects a definition for these functions to
    # know where to take stuff from

    # Retrieves package path 
    def getPackagePath(self, pkgFilename, redirect_capable=0):
        """
        Overloads getPackagePath in common/rhnRepository.
        checks if redirect and hosted;
        makes a call to query the db for pkg_location
        """

        log_debug(2, pkgFilename, redirect_capable)
        #check for re-direct check flag from header to issue package
        #request from client in order to avoid failover loops.
        skip_redirect = rhnFlags.get('x-rhn-redirect')
        log_debug(3,"check flag for X-RHN-REDIRECT  ::",skip_redirect)

        #get the redirect and local paths
        remotepath, localpath = self.getAllPackagePaths(pkgFilename)

        #check for redirect conditions and fail over checks
        if redirect_capable and not CFG.SATELLITE and not skip_redirect \
            and remotepath is not None:
            self.redirect_location = remotepath
            # We've set self.redirect_location, we're done here
            #we throw a redirectException in _getFile method.
            return None
            # Package cannot be served from the edge, we serve it ourselves
        return localpath
    
    
    def _getFile(self, path):
        """
        overwrites the common/rhnRepository._getFile to check for redirect
        """
        if self.redirect_location:
            raise redirectException(self.redirect_location)
        return rhnRepository.Repository._getFile(self, path)

    def getAllPackagePaths(self,pkgFilename):
        """
        retrives the package location if edge network location available
        and its local path.
        """
        log_debug(3, pkgFilename)
        return rhnPackage.get_all_package_paths(self.server_id, pkgFilename,
            self.channelName)

    # Retrieves package source path
    def getSourcePackagePath(self, pkgFilename):
        """Overloads getSourcePackagePath in common/rhnRepository.
        """
        return rhnPackage.get_source_package_path(self.server_id, pkgFilename,
            self.channelName)

    
    ### Private methods

    # check if the current channel version matches that of the client
    def __check_channel(self, version):
        channel_list = rhnChannel.channels_for_server(self.server_id)
        # Check the subscription to this channel
        for channel in channel_list:
            if channel['label'] == self.channelName:
                # Okay, we verified the subscription
                # Check the version too
                if channel['last_modified'] == version:
                    # Great
                    break
                # Old version; should re-login to get the new version
                raise rhnFault(41, "Invalid channel version")
        else:
            # Not subscribed
            raise rhnFault(39, "No subscription to the specified channel")
        return 1
    
    def set_qos(self):
        server_lib.set_qos(self.server_id)

    # Wraps around common.rhnRepository's method, adding a caching layer
    # If stat_info was already passed, don't re-stat the file
    def _getHeaderFromFile(self, filePath, stat_info=None):
        log_debug(3, filePath)
        if not CFG.CACHE_PACKAGE_HEADERS:
            return rhnRepository.Repository._getHeaderFromFile(self, filePath,
                stat_info=stat_info)
        # Ignore stat_info for now - nobody sets it anyway
        stat_info = None
        try:
            stat_info = os.stat(filePath)
        except:
            raise rhnFault(17, "Unable to read package %s"
                               % os.path.basename(filePath))
        lastModified = stat_info[stat.ST_MTIME]

        # OK, file exists, check the cache
        cache_key = os.path.normpath("headers/" + filePath)
        header = rhnCache.get(cache_key, modified=lastModified, raw=1,
            compressed=1)
        if header:
            # We're good to go
            log_debug(2, "Header cache HIT for %s" % filePath)
            extra_headers = {
                'X-RHN-Package-Header' : os.path.basename(filePath),
            }
            self._set_last_modified(lastModified, extra_headers=extra_headers)
            return header
        log_debug(3, "Header cache MISS for %s" % filePath)
        header = rhnRepository.Repository._getHeaderFromFile(self, filePath,
            stat_info=stat_info)
        if header:
            rhnCache.set(cache_key, header, modified=lastModified, raw=1,
                compressed=1)
        return header
