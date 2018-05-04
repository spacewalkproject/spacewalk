#
# Copyright (c) 2016--2017 Red Hat, Inc.
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
import os.path
from shutil import rmtree
import time
import re
import fnmatch
import requests
from spacewalk.common import fileutils
from spacewalk.satellite_tools.download import get_proxies
from spacewalk.satellite_tools.repo_plugins import ContentPackage, CACHE_DIR
from spacewalk.satellite_tools.syncLib import log2
from spacewalk.common.rhnConfig import CFG, initCFG
try:
    #  python 2
    import urlparse
except ImportError:
    #  python3
    import urllib.parse as urlparse # pylint: disable=F0401,E0611

RETRIES = 10
RETRY_DELAY = 1
FORMAT_PRIORITY = ['.xz', '.gz', '']


class DebPackage(object):
    def __init__(self):
        self.name = None
        self.epoch = None
        self.version = None
        self.release = None
        self.arch = None
        self.relativepath = None
        self.checksum_type = None
        self.checksum = None

    def __getitem__(self, key):
        return getattr(self, key)

    def __setitem__(self, key, value):
        return setattr(self, key, value)

    def is_populated(self):
        return all([attribute is not None for attribute in (self.name, self.epoch, self.version, self.release,
                                                            self.arch, self.relativepath, self.checksum_type,
                                                            self.checksum)])


class DebRepo(object):
    # url example - http://ftp.debian.org/debian/dists/jessie/main/binary-amd64/
    def __init__(self, url, cache_dir, pkg_dir):
        self.url = url
        parts = url.split('/dists')
        self.base_url = [parts[0]]
        # Make sure baseurl ends with / and urljoin will work correctly
        if self.base_url[0][-1] != '/':
            self.base_url[0] += '/'
        self.urls = self.base_url
        self.sslclientcert = self.sslclientkey = self.sslcacert = None
        self.proxy = self.proxy_username = self.proxy_password = None
        self.basecachedir = cache_dir
        if not os.path.isdir(self.basecachedir):
            fileutils.makedirs(self.basecachedir, user='apache', group='apache')
        self.includepkgs = []
        self.exclude = []
        self.pkgdir = pkg_dir
        self.http_headers = {}

    def _download(self, url):
        for _ in range(0, RETRIES):
            try:
                data = requests.get(url, cert=(self.sslclientcert, self.sslclientkey), verify=self.sslcacert)
                if not data.ok:
                    return ''
                filename = self.basecachedir + '/' + os.path.basename(url)
                fd = open(filename, 'wb')
                try:
                    for chunk in data.iter_content(chunk_size=1024):
                        fd.write(chunk)
                finally:
                    if fd is not None:
                        fd.close()
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
            package = DebPackage()
            package.epoch = ""
            lines = chunk.split("\n")
            checksums = {}
            for line in lines:
                pair = line.split(" ", 1)
                if pair[0] == "Package:":
                    package.name = pair[1]
                elif pair[0] == "Architecture:":
                    package.arch = pair[1] + '-deb'
                elif pair[0] == "Version:":
                    package['epoch'] = ''
                    version = pair[1]
                    if version.find(':') != -1:
                        package['epoch'], version = version.split(':')
                    if version.find('-') != -1:
                        tmp = version.split('-')
                        package['version'] = '-'.join(tmp[:-1])
                        package['release'] = tmp[-1]
                    else:
                        package['version'] = version
                        package['release'] = 'X'
                elif pair[0] == "Filename:":
                    package.relativepath = pair[1]
                elif pair[0] == "SHA256:":
                    checksums['sha256'] = pair[1]
                elif pair[0] == "SHA1:":
                    checksums['sha1'] = pair[1]
                elif pair[0] == "MD5sum:":
                    checksums['md5'] = pair[1]

            # Pick best available checksum
            if 'sha256' in checksums:
                package.checksum_type = 'sha256'
                package.checksum = checksums['sha256']
            elif 'sha1' in checksums:
                package.checksum_type = 'sha1'
                package.checksum = checksums['sha1']
            elif 'md5' in checksums:
                package.checksum_type = 'md5'
                package.checksum = checksums['md5']

            if package.is_populated():
                to_return.append(package)

        return to_return


class ContentSource(object):

    def __init__(self, url, name, org=1, channel_label="", ca_cert_file=None, client_cert_file=None,
                 client_key_file=None):
        # pylint: disable=W0613
        self.url = url
        self.name = name
        if org:
            self.org = org
        else:
            self.org = "NULL"

        # read the proxy configuration in /etc/rhn/rhn.conf
        initCFG('server.satellite')
        self.proxy_addr = CFG.http_proxy
        self.proxy_user = CFG.http_proxy_username
        self.proxy_pass = CFG.http_proxy_password
        self.authtoken = None

        self.repo = DebRepo(url, os.path.join(CACHE_DIR, self.org, name),
                            os.path.join(CFG.MOUNT_POINT, CFG.PREPENDED_DIR, self.org, 'stage'))

        self.num_packages = 0
        self.num_excluded = 0

        # keep authtokens for mirroring
        (_scheme, _netloc, _path, query, _fragid) = urlparse.urlsplit(url)
        if query:
            self.authtoken = query

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
            pkglist = self._filter_packages(pkglist, filters)
            self.num_excluded = self.num_packages - len(pkglist)

        to_return = []
        for pack in pkglist:
            new_pack = ContentPackage()
            new_pack.setNVREA(pack.name, pack.version, pack.release,
                              pack.epoch, pack.arch)
            new_pack.unique_id = pack
            new_pack.checksum_type = pack.checksum_type
            new_pack.checksum = pack.checksum
            to_return.append(new_pack)
        return to_return

    @staticmethod
    def _sort_packages(pkg1, pkg2):
        """sorts a list of deb package dicts by name"""
        if pkg1.name > pkg2.name:
            return 1
        elif pkg1.name == pkg2.name:
            return 0
        else:
            return -1
    @staticmethod
    def _filter_packages(packages, filters):
        """ implement include / exclude logic
            filters are: [ ('+', includelist1), ('-', excludelist1),
                           ('+', includelist2), ... ]
        """
        if filters is None:
            return

        selected = []
        excluded = []
        allmatched_include = []
        allmatched_exclude = []
        if filters[0][0] == '-':
            # first filter is exclude, start with full package list
            # and then exclude from it
            selected = packages
        else:
            excluded = packages

        for filter_item in filters:
            sense, pkg_list = filter_item
            regex = fnmatch.translate(pkg_list[0])
            reobj = re.compile(regex)
            if sense == '+':
                # include
                for excluded_pkg in excluded:
                    if (reobj.match(excluded_pkg['name'])):
                        allmatched_include.insert(0,excluded_pkg)
                        selected.insert(0,excluded_pkg)
                for pkg in allmatched_include:
                    if pkg in excluded:
                        excluded.remove(pkg)
            elif sense == '-':
                # exclude
                for selected_pkg in selected:
                    if (reobj.match(selected_pkg['name'])):
                        allmatched_exclude.insert(0,selected_pkg)
                        excluded.insert(0,selected_pkg)

                for pkg in allmatched_exclude:
                    if pkg in selected:
                        selected.remove(pkg)
                excluded = (excluded + allmatched_exclude)
            else:
                raise IOError("Filters are malformed")
        return selected

    def clear_cache(self, directory=None):
        if directory is None:
            directory = os.path.join(CACHE_DIR, self.org, self.name)
        # remove content in directory
        for item in os.listdir(directory):
            path = os.path.join(directory, item)
            if os.path.isfile(path):
                os.unlink(path)
            elif os.path.isdir(path):
                rmtree(path)

    @staticmethod
    def get_updates():
        # There isn't any update info in the repository
        return []

    @staticmethod
    def get_groups():
        # There aren't any
        return None

    # Get download parameters for threaded downloader
    def set_download_parameters(self, params, relative_path, target_file, checksum_type=None, checksum_value=None,
                                bytes_range=None):
        # Create directories if needed
        target_dir = os.path.dirname(target_file)
        if not os.path.exists(target_dir):
            os.makedirs(target_dir, int('0755', 8))

        params['urls'] = self.repo.urls
        params['relative_path'] = relative_path
        params['authtoken'] = self.authtoken
        params['target_file'] = target_file
        params['ssl_ca_cert'] = self.repo.sslcacert
        params['ssl_client_cert'] = self.repo.sslclientcert
        params['ssl_client_key'] = self.repo.sslclientkey
        params['checksum_type'] = checksum_type
        params['checksum'] = checksum_value
        params['bytes_range'] = bytes_range
        params['proxy'] = self.repo.proxy
        params['proxy_username'] = self.repo.proxy_username
        params['proxy_password'] = self.repo.proxy_password
        params['http_headers'] = self.repo.http_headers
        # Older urlgrabber compatibility
        params['proxies'] = get_proxies(self.repo.proxy, self.repo.proxy_username, self.repo.proxy_password)

    @staticmethod
    def get_file(path, local_base=None):
        # pylint: disable=W0613
        # Called from import_kickstarts, not working for deb repo
        log2(0, 0, "Unable to download path %s from deb repo." % path, stream=sys.stderr)
        return None

