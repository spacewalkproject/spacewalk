#
# Copyright (c) 2016 Red Hat, Inc.
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

import os.path
from shutil import rmtree
import requests
import time
from spacewalk.common import fileutils
from spacewalk.satellite_tools.repo_plugins import ContentPackage
from spacewalk.common.rhnConfig import CFG, initCFG
from spacewalk.common.checksum import getFileChecksum

CACHE_DIR = '/var/cache/rhn/reposync/'
RETRIES = 10
RETRY_DELAY = 1
FORMAT_PRIORITY = ['.xz', '.gz', '']


class DebRepo(object):
    # url example - http://ftp.debian.org/debian/dists/jessie/main/binary-amd64/
    def __init__(self, url, cache_dir):
        self.url = url
        parts = url.split('/dists')
        self.base_url = parts[0]
        self.sslclientcert = self.sslclientkey = self.sslcacert = None
        self.basecachedir = cache_dir
        if not os.path.isdir(self.basecachedir):
            fileutils.makedirs(self.basecachedir, user='apache', group='apache')
        self.includepkgs = []
        self.exclude = []

    def _download(self, url):
        for _ in range(0, RETRIES):
            try:
                data = requests.get(url, cert=(self.sslclientcert, self.sslclientkey), verify=self.sslcacert)
                if not data.ok:
                    return ''
                filename = self.basecachedir + '/' + os.path.basename(url)
                with open(filename, 'wb') as fd:
                    for chunk in data.iter_content(chunk_size=1024):
                        fd.write(chunk)
                return filename
            except requests.exceptions.RequestException:
                print "ERROR: requests.exceptions.RequestException occured"
                time.sleep(RETRY_DELAY)

        return ''

    def get_package_list(self):
        decompressed = None
        packages_raw = []
        to_return = []

        for extension in FORMAT_PRIORITY:
            url = self.url + '/Packages' + extension
            filename = self._download(url)
            if filename:
                decompressed = fileutils.decompress_open(filename)
                break

        if decompressed:
            for pkg in decompressed.read().split("\n\n"):
                packages_raw.append(pkg)
            decompressed.close()
        else:
            print("ERROR: Download of package list failed.")

        # Parse and format package metadata
        for chunk in packages_raw:
            package = {}
            package['epoch'] = ""
            lines = chunk.split("\n")
            checksums = {}
            for line in lines:
                pair = line.split(" ", 1)
                if pair[0] == "Package:":
                    package['name'] = pair[1]
                elif pair[0] == "Architecture:":
                    package['arch'] = pair[1] + '-deb'
                elif pair[0] == "Version:":
                    version = pair[1].split('-', 1)
                    if len(version) == 1:
                        package['version'] = version[0]
                        package['release'] = 'X'
                    else:
                        package['version'] = version[0]
                        package['release'] = version[1]
                elif pair[0] == "Filename:":
                    package['path'] = pair[1]
                elif pair[0] == "SHA256:":
                    checksums['sha256'] = pair[1]
                elif pair[0] == "SHA1:":
                    checksums['sha1'] = pair[1]
                elif pair[0] == "MD5sum:":
                    checksums['md5'] = pair[1]

            # Pick best available checksum
            if 'sha256' in checksums:
                package['checksum_type'] = 'sha256'
                package['checksum'] = checksums['sha256']
            elif 'sha1' in checksums:
                package['checksum_type'] = 'sha1'
                package['checksum'] = checksums['sha1']
            elif 'md5' in checksums:
                package['checksum_type'] = 'md5'
                package['checksum'] = checksums['md5']

            if all(k in package for k in ('name', 'epoch', 'version', 'release', 'arch', 'path',
                                          'checksum_type', 'checksum')):
                to_return.append(package)

        return to_return

    def get_package(self, pack):
        url = self.base_url + '/' + pack['path']
        file_path = self._download(url)
        if getFileChecksum(pack['checksum_type'], filename=file_path) != pack['checksum']:
            raise IOError("Package file does not match intended download.")
        return file_path


class ContentSource(object):

    def __init__(self, url, name):
        self.url = url
        self.name = name
        self._clean_cache(CACHE_DIR + name)

        # read the proxy configuration in /etc/rhn/rhn.conf
        initCFG('server.satellite')
        self.proxy_addr = CFG.http_proxy
        self.proxy_user = CFG.http_proxy_username
        self.proxy_pass = CFG.http_proxy_password

        self.repo = DebRepo(url, CACHE_DIR + name)
        
        self.num_packages = 0
        self.num_excluded = 0

    def list_packages(self, filters, latest):
        """ list packages"""

        pkglist = self.repo.get_package_list()
        self.num_packages = len(pkglist)
        if latest:
            # TODO
            pass
        pkglist.sort(self._sort_packages)

        if not filters:
            # if there's no include/exclude filter on command line or in database
            for p in self.repo.includepkgs:
                filters.append(('+', [p]))
            for p in self.repo.exclude:
                filters.append(('-', [p]))

        if filters:
            # TODO
            pass

        to_return = []
        for pack in pkglist:
            new_pack = ContentPackage()
            new_pack.setNVREA(pack['name'], pack['version'], pack['release'],
                              pack['epoch'], pack['arch'])
            new_pack.unique_id = pack
            new_pack.checksum_type = pack['checksum_type']
            new_pack.checksum = pack['checksum']
            to_return.append(new_pack)
        return to_return

    @staticmethod
    def _sort_packages(pkg1, pkg2):
        """sorts a list of deb package dicts by name"""
        if pkg1['name'] > pkg2['name']:
            return 1
        elif pkg1['name'] == pkg2['name']:
            return 0
        else:
            return -1

    def get_package(self, package, metadata_only=False):
        """ get package """
        if metadata_only:
            raise NotImplementedError()
        pack = package.unique_id
        return self.repo.get_package(pack)

    @staticmethod
    def _clean_cache(directory):
        rmtree(directory, True)

    @staticmethod
    def get_updates():
        # There isn't any update info in the repository
        return []

    @staticmethod
    def get_groups():
        # There aren't any
        return None

    def set_ssl_options(self, ca_cert, client_cert, client_key):
        # TODO
        pass

    def clear_ssl_cache(self):
        repo = self.repo
        ssldir = os.path.join(repo.basecachedir, self.name, '.ssl-certs')
        try:
            self._clean_cache(ssldir)
        except (OSError, IOError):
            pass

    @staticmethod
    def get_file(path, local_base=None):
        # Called from import_kickstarts, not working for deb repo
        return None
