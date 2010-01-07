#
# Copyright (c) 2008--2009 Red Hat, Inc.
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
#   Classes for generating repository metadata from RHN info.
#

import hashlib
import time
import StringIO
import shutil
import os.path

from gzip import GzipFile
from gzip import write32u

from common import log_debug
from common import rhnCache
from common import CFG

import mapper
import view
from domain import Comps
from server import rhnChannel

# One meg
CHUNK_SIZE = 1048576

comps_mapping = {
    'rhel-x86_64-client-5' : 'rhn/kickstart/ks-rhel-x86_64-client-5/Client/repodata/comps-rhel5-client-core.xml',
    'rhel-x86_64-client-vt-5' : 'rhn/kickstart/ks-rhel-x86_64-client-5/VT/repodata/comps-rhel5-vt.xml',
    'rhel-x86_64-client-workstation-5' : 'rhn/kickstart/ks-rhel-x86_64-client-5/Workstation/repodata/comps-rhel5-client-workstation.xml',
    'rhel-x86_64-server-5' : 'rhn/kickstart/ks-rhel-x86_64-server-5/Server/repodata/comps-rhel5-server-core.xml',
    'rhel-x86_64-server-vt-5' : 'rhn/kickstart/ks-rhel-x86_64-server-5/VT/repodata/comps-rhel5-vt.xml',
    'rhel-x86_64-server-cluster-5' : 'rhn/kickstart/ks-rhel-x86_64-server-5/Cluster/repodata/comps-rhel5-cluster.xml',
    'rhel-x86_64-server-cluster-storage-5' : 'rhn/kickstart/ks-rhel-x86_64-server-5/ClusterStorage/repodata/comps-rhel5-cluster-st.xml',
}
for k in comps_mapping.keys():
    for arch in ('i386', 'ia64', 's390x', 'ppc'):
        comps_mapping[k.replace('x86_64', arch)] = comps_mapping[k].replace('x86_64', arch)

class Repository(object):

    """
    Representation of RHN channels as repository metadata.

    This class can generate primary.xml, filelists.xml, and other.xml
    """

    def __init__(self, channel):
        self.channel_id = channel['id']
        self.last_modified = channel['last_modified']

        self.primary_prefix = "repomd_primary.xml"
        self.other_prefix = "repomd_other.xml"
        self.filelists_prefix = "repomd_filelists.xml"
        self.updateinfo_prefix = "repomd_updateinfo.xml"

        self._channel = None
        
        cache = rhnCache.Cache()
        self.cache = rhnCache.NullCache(cache)

    def get_primary_xml_file(self):
        """ Return a file-like object of the primarl.xml for this channel. """
        ret = self.get_primary_cache()

        if not ret:
            viewobj = self.get_primary_view()

            self.generate_files([viewobj])
            ret = self.get_primary_cache()

        return ret

    def get_other_xml_file(self):
        """ Return a file-like object of the other.xml for this channel. """
        ret = self.get_other_cache()

        if not ret:
            viewobj = self.get_other_view()

            self.generate_files([viewobj])
            ret = self.get_other_cache()

        return ret

    def get_filelists_xml_file(self):
        """ Return a file-like object of the filelists.xml for this channel. """
        ret = self.get_filelists_cache()

        if not ret:
            viewobj = self.get_filelists_view()

            self.generate_files([viewobj])
            ret = self.get_filelists_cache()

        return ret

    def get_updateinfo_xml_file(self):
        """ Return a file-like object of the updateinfo.xml for the channel. """
        ret = self.get_cache_file(self.updateinfo_prefix)

        if not ret:
            viewobj = self.get_cache_view(self.updateinfo_prefix,
                view.UpdateinfoView)

            viewobj.write_updateinfo()
            viewobj.fileobj.close()
            ret = self.get_cache_file(self.updateinfo_prefix)

        return ret

    def get_cache_entry_name(self, cache_prefix):
        return "%s-%s" % (cache_prefix, self.channel_id)

    def get_cache_file(self, cache_prefix):
        cache_entry = self.get_cache_entry_name(cache_prefix)
        ret = self.cache.get_file(cache_entry, self.last_modified)
        return ret

    def get_cache_view(self, cache_prefix, view_class):
        cache_entry = self.get_cache_entry_name(cache_prefix)
        ret = self.cache.set_file(cache_entry, self.last_modified)
        viewobj = view_class(self.channel, ret)
        return viewobj

    def get_primary_cache(self):
        return self.get_cache_file(self.primary_prefix)

    def get_other_cache(self):
        return self.get_cache_file(self.other_prefix)

    def get_filelists_cache(self):
        return self.get_cache_file(self.filelists_prefix)

    def get_primary_view(self):
        return self.get_cache_view(self.primary_prefix, view.PrimaryView)

    def get_other_view(self):
        return self.get_cache_view(self.other_prefix, view.OtherView)

    def get_filelists_view(self):
        return self.get_cache_view(self.filelists_prefix, view.FilelistsView)

    def get_comps_file(self):
        """ Return a file-like object of the comps.xml for the channel. """
        if self.channel.comps:
            comps_view = view.CompsView(self.channel.comps)
            return comps_view.get_file()
        elif comps_mapping.has_key(self.channel.label):
            comps_view = view.CompsView(Comps(None, 
                os.path.join(CFG.mount_point, comps_mapping[self.channel.label])))
            return comps_view.get_file()
        else:
            if self.channel.cloned_from_id is not None:
                log_debug(1, "No comps and no comps_mapping for [%s] cloned from [%s] trying to get comps from the original one." \
                          % ( self.channel.id, self.channel.cloned_from_id ))
                cloned_from_channel = rhnChannel.Channel().load_by_id(self.channel.cloned_from_id)
                cloned_from_channel_label = cloned_from_channel._row['label']
                return Repository(rhnChannel.channel_info(cloned_from_channel_label)).get_comps_file()
        return None

    def generate_files(self, views):
        for view in views:
            view.write_start()

        for package in self.channel.packages:
            for view in views:
                view.write_package(package)

        for view in views:
            view.write_end()
            view.fileobj.close()

    def __get_channel(self):
        """ Late binding for the channel. """
        if self._channel == None:
            channel_mapper = mapper.get_channel_mapper()
            self._channel = channel_mapper.get_channel(self.channel_id)
        return self._channel

    channel = property(__get_channel)


class CompressedRepository:

    """ Decorator for Repositories adding gzip compression of the output. """
    
    def __init__(self, repository):
        self.repository = repository

        self.primary_prefix = self.repository.primary_prefix + ".gz"
        self.other_prefix = self.repository.other_prefix + ".gz"
        self.filelists_prefix = self.repository.filelists_prefix + ".gz"
        self.updateinfo_prefix = self.repository.updateinfo_prefix + ".gz"

    def get_primary_xml_file(self):
        xml_file = self.repository.get_primary_xml_file()
        return self.__get_compressed_file(xml_file)

    def get_other_xml_file(self):
        """ Return gzipped other.xml file """
        xml_file = self.repository.get_other_xml_file()
        return self.__get_compressed_file(xml_file)

    def get_filelists_xml_file(self):
        """ Return gzipped filelists.xml file """
        xml_file = self.repository.get_filelists_xml_file()
        return self.__get_compressed_file(xml_file)

    def get_updateinfo_xml_file(self):
        """ Return gzipped updateinfo.xml file """
        xml_file = self.repository.get_updateinfo_xml_file()
        return self.__get_compressed_file(xml_file)

    def __getattr__(self, x):
        return getattr(self.repository, x)

    def __get_compressed_file(self, uncompressed_file):
        string_file = StringIO.StringIO()
        gzip_file = NoTimeStampGzipFile(mode = "wb", fileobj = string_file)
        
        shutil.copyfileobj(uncompressed_file, gzip_file)
        
        gzip_file.close()

        string_file.seek(0,0)

        return string_file


class CachedRepository:

    """ Decorator for Repositories adding caching. """

    def __init__(self, repository):
        self.repository = repository
        
        cache = rhnCache.Cache()
        self.cache = rhnCache.NullCache(cache)

    def get_primary_xml_file(self):
        """ Return the cached primary metadata file, if it exists. """
        return self._cached(self.primary_prefix,
            self.repository.get_primary_xml_file)

    def get_other_xml_file(self):
        return self._cached(self.other_prefix,
            self.repository.get_other_xml_file)

    def get_filelists_xml_file(self):
        return self._cached(self.filelists_prefix,
            self.repository.get_filelists_xml_file)
   
    def get_updateinfo_xml_file(self):
        return self._cached(self.updateinfo_prefix,
            self.repository.get_updateinfo_xml_file)
   
    def _cached(self, cache_prefix, fallback_method):
        """
        Return the cached results if they are new enough, else get new results. 
    
        cache_prefix is a unique string that will identify the cached data.
        fallback_method is the method to call if the cached data doesn't exist
        or isn't new enough.
        """
        cache_entry = "%s-%s" % (cache_prefix, self.channel_id)
        ret = self.cache.get_file(cache_entry, self.last_modified)
        if ret:
            log_debug(4, "Scored cache hit", self.channel_id)
        else:
            ret = fallback_method()
            cache_file = self.cache.set_file(cache_entry, self.last_modified)

            shutil.copyfileobj(ret, cache_file)
            
            ret.close
            cache_file.close()
            ret = self.cache.get_file(cache_entry, self.last_modified)
        return ret
        
    def __getattr__(self, x):
        return getattr(self.repository, x)


class MetadataRepository:

    """
    A repository that can provide repomd data.

    A Metadata Repository is composed of a repository and a
    CompressedRepository, as both are required to generate the repomd file.
    """
    
    def __init__(self, repository, compressed_repository):
        self.repository = repository
        self.compressed_repository = compressed_repository

        self.repomd_prefix = "repomd.xml"

    def get_repomd_file(self):
        """ Return uncompressed repomd.xml file """
 
        cache_entry = "%s-%s" % (self.repomd_prefix, self.channel_id)
        ret = self.cache.get_file(cache_entry, self.last_modified)

        if not ret:
            # We need the time in seconds since the epoch for the xml file.
            timestamp = int(time.mktime(time.strptime(self.last_modified,
                "%Y%m%d%H%M%S")))

            to_generate = []
            
            if not self.repository.get_primary_cache():
                to_generate.append(self.repository.get_primary_view())
            if not self.repository.get_other_cache():
                to_generate.append(self.repository.get_other_view())
            if not self.repository.get_filelists_cache():
                to_generate.append(self.repository.get_filelists_view())

            self.repository.generate_files(to_generate)

            primary = self.__compute_checksums(timestamp,
                self.repository.get_primary_xml_file(),
                self.compressed_repository.get_primary_xml_file())

            filelists = self.__compute_checksums(timestamp,
                self.repository.get_filelists_xml_file(),
                self.compressed_repository.get_filelists_xml_file())

            other = self.__compute_checksums(timestamp,
                self.repository.get_other_xml_file(),
                self.compressed_repository.get_other_xml_file())

            updateinfo = self.__compute_checksums(timestamp,
                self.repository.get_updateinfo_xml_file(),
                self.compressed_repository.get_updateinfo_xml_file())

            # Comps might not exist on disc
            comps = None
            comps_file = None
            try:
                comps_file = self.repository.get_comps_file()
            except IOError:
                pass
            if comps_file:
                comps = self.__compute_open_checksum(timestamp, comps_file)


            ret = self.cache.set_file(cache_entry, self.last_modified)
            repomd_view = view.RepoView(primary, filelists, other, updateinfo,
                comps, ret, self.__get_checksumtype())

            repomd_view.write_repomd()
            ret.close()
            ret = self.cache.get_file(cache_entry, self.last_modified)

        return ret

    def __get_file_checksum(self, xml_file):
        hash_computer = hashlib.new(self.__get_checksumtype())

        chunk = xml_file.read(CHUNK_SIZE)
        while chunk:
            hash_computer.update(chunk)
            chunk = xml_file.read(CHUNK_SIZE)

        return hash_computer.hexdigest()

    def __compute_open_checksum(self, timestamp, xml_file):
        template_hash = {}

        template_hash['open_checksum'] = self.__get_file_checksum(xml_file)
        template_hash['timestamp'] = timestamp

        return template_hash

    def __compute_checksums(self, timestamp, xml_file, xml_gz_file):
        template_hash = self.__compute_open_checksum(timestamp, xml_file)

        template_hash['gzip_checksum'] = self.__get_file_checksum(xml_gz_file)

        return template_hash

    def __get_checksumtype(self):
        return self.repository.channel.checksumtype

    def __getattr__(self, x):
        return getattr(self.compressed_repository, x)
     

def get_repository(channel):
    """ Factory Method-ish function to create a repository from a channel. """
    repository = Repository(channel)

    compressed_repository = CompressedRepository(repository)
    compressed_repository = CachedRepository(compressed_repository)

    meta_repository = MetadataRepository(repository, compressed_repository)

    return meta_repository


class NoTimeStampGzipFile(GzipFile):

    def _write_gzip_header(self):
        self.fileobj.write('\037\213')
        self.fileobj.write('\010')
        # no flags
        self.fileobj.write('\x00')
        write32u(self.fileobj, long(0))
        self.fileobj.write('\002')
        self.fileobj.write('\377')
