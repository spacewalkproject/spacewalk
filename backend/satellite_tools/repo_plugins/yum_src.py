#
# Copyright (c) 2008--2018 Red Hat, Inc.
# Copyright (c) 2010--2011 SUSE LINUX Products GmbH, Nuernberg, Germany.
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
import logging
import os.path
from os import makedirs
from shutil import rmtree

import yum
from yum.Errors import RepoMDError
from yum.comps import Comps
from yum.config import ConfigParser
from yum.packageSack import ListPackageSack
from yum.update_md import UpdateMetadata, UpdateNoticeException, UpdateNotice
from yum.yumRepo import YumRepository
from yum.yumRepo import Errors as YumErrors
try:
    from yum.misc import cElementTree_iterparse as iterparse
except ImportError:
    try:
        from xml.etree import cElementTree
    except ImportError:
        # pylint: disable=F0401
        import cElementTree
    iterparse = cElementTree.iterparse
from urlgrabber.grabber import URLGrabError
try:
    #  python 2
    import urlparse
except ImportError:
    #  python3
    import urllib.parse as urlparse # pylint: disable=F0401,E0611

from spacewalk.common import fileutils, checksum
from spacewalk.satellite_tools.download import get_proxies
from spacewalk.satellite_tools.repo_plugins import ContentPackage, CACHE_DIR
from spacewalk.common.rhnConfig import CFG, initCFG

YUMSRC_CONF = '/etc/rhn/spacewalk-repo-sync/yum.conf'


class YumWarnings:

    def __init__(self):
        self.saved_stdout = None
        self.errors = None

    def write(self, s):
        pass

    def disable(self):
        self.saved_stdout = sys.stdout
        sys.stdout = self

    def restore(self):
        sys.stdout = self.saved_stdout


class YumUpdateMetadata(UpdateMetadata):

    """The root update metadata object supports getting all updates"""

# pylint: disable=W0221
    def add(self, obj, mdtype='updateinfo', all_versions=False):
        """ Parse a metadata from a given YumRepository, file, or filename. """
        if not obj:
            raise UpdateNoticeException
        if isinstance(obj, (type(''), type(u''))):
            infile = fileutils.decompress_open(obj)
        elif isinstance(obj, YumRepository):
            if obj.id not in self._repos:
                self._repos.append(obj.id)
                md = obj.retrieveMD(mdtype)
                if not md:
                    raise UpdateNoticeException()
                infile = fileutils.decompress_open(md)
        else:   # obj is a file object
            infile = obj

        for _event, elem in iterparse(infile):
            if elem.tag == 'update':
                un = UpdateNotice(elem)
                key = un['update_id']
                if all_versions:
                    key = "%s-%s" % (un['update_id'], un['version'])
                if key not in self._notices:
                    self._notices[key] = un
                    for pkg in un['pkglist']:
                        for pkgfile in pkg['packages']:
                            self._cache['%s-%s-%s' % (pkgfile['name'],
                                                      pkgfile['version'],
                                                      pkgfile['release'])] = un
                            no = self._no_cache.setdefault(pkgfile['name'], set())
                            no.add(un)


class RepoMDNotFound(Exception):
    pass


class ContentSource(object):

    def __init__(self, url, name, yumsrc_conf=YUMSRC_CONF, org="1", channel_label="",
                 no_mirrors=False, ca_cert_file=None, client_cert_file=None,
                 client_key_file=None):
        self.url = url
        self.name = name
        self.yumbase = yum.YumBase()
        self.yumbase.preconf.fn = yumsrc_conf
        if not os.path.exists(yumsrc_conf):
            self.yumbase.preconf.fn = '/dev/null'
        self.configparser = ConfigParser()
        if org:
            self.org = org
        else:
            self.org = "NULL"

        self.proxy_addr = None
        self.proxy_user = None
        self.proxy_pass = None
        self.authtoken = None

        # read the proxy configuration
        # /etc/rhn/rhn.conf has more priority than yum.conf
        initCFG('server.satellite')

        # keep authtokens for mirroring
        (_scheme, _netloc, _path, query, _fragid) = urlparse.urlsplit(url)
        if query:
            self.authtoken = query

        if CFG.http_proxy:
            self.proxy_addr = CFG.http_proxy
            self.proxy_user = CFG.http_proxy_username
            self.proxy_pass = CFG.http_proxy_password
        else:
            yb_cfg = self.yumbase.conf.cfg
            section_name = None

            if yb_cfg.has_section(self.name):
                section_name = self.name
            elif yb_cfg.has_section('main'):
                section_name = 'main'

            if section_name:
                if yb_cfg.has_option(section_name, option='proxy'):
                    self.proxy_addr = yb_cfg.get(section_name, option='proxy')

                if yb_cfg.has_option(section_name, 'proxy_username'):
                    self.proxy_user = yb_cfg.get(section_name, 'proxy_username')

                if yb_cfg.has_option(section_name, 'proxy_password'):
                    self.proxy_pass = yb_cfg.get(section_name, 'proxy_password')

        self._authenticate(url)

        # Check for settings in yum configuration files (for custom repos/channels only)
        if org:
            repos = self.yumbase.repos.repos
        else:
            repos = None
        if repos and name in repos:
            repo = repos[name]
        elif repos and channel_label in repos:
            repo = repos[channel_label]
            # In case we are using Repo object based on channel config, override it's id to name of the repo
            # To not create channel directories in cache directory
            repo.id = name
        else:
            # Not using values from config files
            repo = yum.yumRepo.YumRepository(name)
            repo.populate(self.configparser, name, self.yumbase.conf)
        self.repo = repo

        self.setup_repo(repo, no_mirrors, ca_cert_file, client_cert_file, client_key_file)
        self.num_packages = 0
        self.num_excluded = 0
        self.groupsfile = None

    def __del__(self):
        # close log files for yum plugin
        for handler in logging.getLogger("yum.filelogging").handlers:
            handler.close()
        self.repo.close()

    def _authenticate(self, url):
        pass

    @staticmethod
    def interrupt_callback(*args, **kwargs):  # pylint: disable=W0613
        # Just re-raise
        e = sys.exc_info()[1]
        raise e

    def setup_repo(self, repo, no_mirrors, ca_cert_file, client_cert_file, client_key_file):
        """Fetch repository metadata"""
        repo.cache = 0
        repo.mirrorlist = self.url
        repo.baseurl = [self.url]
        repo.basecachedir = os.path.join(CACHE_DIR, self.org)
        # base_persistdir have to be set before pkgdir
        if hasattr(repo, 'base_persistdir'):
            repo.base_persistdir = repo.basecachedir

        pkgdir = os.path.join(CFG.MOUNT_POINT, CFG.PREPENDED_DIR, self.org, 'stage')
        if not os.path.isdir(pkgdir):
            fileutils.makedirs(pkgdir, user='apache', group='apache')
        repo.pkgdir = pkgdir
        repo.sslcacert = ca_cert_file
        repo.sslclientcert = client_cert_file
        repo.sslclientkey = client_key_file
        repo.proxy = None
        repo.proxy_username = None
        repo.proxy_password = None

        if "file://" in self.url:
            repo.copy_local = 1

        if self.proxy_addr:
            repo.proxy = "http://%s" % self.proxy_addr
            repo.proxy_username = self.proxy_user
            repo.proxy_password = self.proxy_pass

        # Do not try to expand baseurl to other mirrors
        if no_mirrors:
            repo.urls = repo.baseurl
            # Make sure baseurl ends with / and urljoin will work correctly
            if repo.urls[0][-1] != '/':
                repo.urls[0] += '/'
        else:
            warnings = YumWarnings()
            warnings.disable()
            try:
                repo.baseurlSetup()
            except:
                warnings.restore()
                raise
            warnings.restore()
            # if self.url is metalink it will be expanded into
            # real urls in repo.urls and also save this metalink
            # in begin of the url list ("for repolist -v ... or anything else wants to know the baseurl")
            # Remove it from the list, we don't need it to download content of repo
            repo.urls = [url for url in repo.urls if '?' not in url]
        repo.interrupt_callback = self.interrupt_callback
        repo.setup(0)

    def number_of_packages(self):
        for dummy_index in range(3):
            try:
                self.repo.getPackageSack().populate(self.repo, 'metadata', None, 0)
                break
            except YumErrors.RepoError:
                pass
        return len(self.repo.getPackageSack().returnPackages())

    def raw_list_packages(self, filters=None):
        for dummy_index in range(3):
            try:
                self.repo.getPackageSack().populate(self.repo, 'metadata', None, 0)
                break
            except YumErrors.RepoError:
                pass

        rawpkglist = self.repo.getPackageSack().returnPackages()
        self.num_packages = len(rawpkglist)

        if not filters:
            filters = []
            # if there's no include/exclude filter on command line or in database
            for p in self.repo.includepkgs:
                filters.append(('+', [p]))
            for p in self.repo.exclude:
                filters.append(('-', [p]))

        if filters:
            rawpkglist = self._filter_packages(rawpkglist, filters)
            rawpkglist = self._get_package_dependencies(self.repo.getPackageSack(), rawpkglist)

            # do not pull in dependencies if they're explicitly excluded
            rawpkglist = self._filter_packages(rawpkglist, filters, True)
            self.num_excluded = self.num_packages - len(rawpkglist)

        return rawpkglist

    def list_packages(self, filters, latest):
        """ list packages"""
        self.repo.getPackageSack().populate(self.repo, 'metadata', None, 0)
        pkglist = ListPackageSack(self.repo.getPackageSack().returnPackages())
        self.num_packages = len(pkglist)
        if latest:
            pkglist = pkglist.returnNewestByNameArch()
        pkglist = yum.misc.unique(pkglist)
        pkglist.sort(self._sort_packages)

        if not filters:
            # if there's no include/exclude filter on command line or in database
            # check repository config file
            for p in self.repo.includepkgs:
                filters.append(('+', [p]))
            for p in self.repo.exclude:
                filters.append(('-', [p]))

        filters = self._expand_package_groups(filters)

        if filters:
            pkglist = self._filter_packages(pkglist, filters)
            pkglist = self._get_package_dependencies(self.repo.getPackageSack(), pkglist)

            # do not pull in dependencies if they're explicitly excluded
            pkglist = self._filter_packages(pkglist, filters, True)
            self.num_excluded = self.num_packages - len(pkglist)
        to_return = []
        for pack in pkglist:
            if pack.arch == 'src':
                continue
            new_pack = ContentPackage()
            new_pack.setNVREA(pack.name, pack.version, pack.release,
                              pack.epoch, pack.arch)
            new_pack.unique_id = pack
            new_pack.checksum_type = pack.checksums[0][0]
            if new_pack.checksum_type == 'sha':
                new_pack.checksum_type = 'sha1'
            new_pack.checksum = pack.checksums[0][1]
            to_return.append(new_pack)
        return to_return

    @staticmethod
    def _sort_packages(pkg1 ,pkg2):
        """sorts a list of yum package objects by name"""
        if pkg1.name > pkg2.name:
            return 1
        elif pkg1.name == pkg2.name:
            return 0
        else:
            return -1

    @staticmethod
    def _find_comps_type(comps_type, environments, groups, name):
        # Finds environment or regular group by name or label
        found = None
        if comps_type == "environment":
            for e in environments:
                if e.environmentid == name or e.name == name:
                    found = e
                    break
        elif comps_type == "group":
            for g in groups:
                if g.groupid == name or g.name == name:
                    found = g
                    break
        return found

    def _expand_comps_type(self, comps_type, environments, groups, filters):
        new_filters = []
        # Rebuild filter list
        for sense, pkg_list in filters:
            new_pkg_list = []
            for pkg in pkg_list:
                # Package group id
                if pkg and pkg[0] == '@':
                    group_name = pkg[1:].strip()
                    found = self._find_comps_type(comps_type, environments, groups, group_name)
                    if found and comps_type == "environment":
                        # Save expanded groups to the package list
                        new_pkg_list.extend(['@' + grp for grp in found.allgroups])
                    elif found and comps_type == "group":
                        # Replace with package list, simplified to not evaluate if packages are default, optional etc.
                        new_pkg_list.extend(found.packages)
                    else:
                        # Invalid group, save group id back
                        new_pkg_list.append(pkg)
                else:
                    # Regular package
                    new_pkg_list.append(pkg)
            if new_pkg_list:
                new_filters.append((sense, new_pkg_list))
        return new_filters

    def _expand_package_groups(self, filters):
        if not self.groupsfile:
            return filters
        comps = Comps()
        comps.add(self.groupsfile)
        groups = comps.get_groups()

        if hasattr(comps, 'get_environments'):
            # First expand environment groups, then regular groups
            environments = comps.get_environments()
            filters = self._expand_comps_type("environment", environments, groups, filters)
        else:
            environments = []
        filters = self._expand_comps_type("group", environments, groups, filters)
        return filters

    @staticmethod
    def _filter_packages(packages, filters, exclude_only=False):
        """ implement include / exclude logic
            filters are: [ ('+', includelist1), ('-', excludelist1),
                           ('+', includelist2), ... ]
        """
        if filters is None:
            return

        selected = []
        excluded = []
        if exclude_only or filters[0][0] == '-':
            # first filter is exclude, start with full package list
            # and then exclude from it
            selected = packages
        else:
            excluded = packages

        for filter_item in filters:
            sense, pkg_list = filter_item
            if sense == '+':
                if exclude_only:
                    continue
                # include
                exactmatch, matched, _unmatched = yum.packages.parsePackages(
                    excluded, pkg_list)
                allmatched = yum.misc.unique(exactmatch + matched)
                selected = yum.misc.unique(selected + allmatched)
                for pkg in allmatched:
                    if pkg in excluded:
                        excluded.remove(pkg)
            elif sense == '-':
                # exclude
                exactmatch, matched, _unmatched = yum.packages.parsePackages(
                    selected, pkg_list)
                allmatched = yum.misc.unique(exactmatch + matched)
                for pkg in allmatched:
                    if pkg in selected:
                        selected.remove(pkg)
                excluded = yum.misc.unique(excluded + allmatched)
            else:
                raise UpdateNoticeException("Invalid filter sense: '%s'" % sense)
        return selected

    def _get_package_dependencies(self, sack, packages):
        self.yumbase.pkgSack = sack
        known_deps = set()
        resolved_deps = self.yumbase.findDeps(packages)
        while resolved_deps:
            next_level_deps = []
            for deps in resolved_deps.values():
                for _dep, dep_packages in deps.items():
                    if _dep not in known_deps:
                        next_level_deps.extend(dep_packages)
                        packages.extend(dep_packages)
                        known_deps.add(_dep)

            resolved_deps = self.yumbase.findDeps(next_level_deps)

        return yum.misc.unique(packages)

    def get_package(self, package, metadata_only=False):
        """ get package """
        pack = package.unique_id
        check = (self.verify_pkg, (pack, 1), {})
        if metadata_only:
            # Include also data before header section
            pack.hdrstart = 0
            data = self.repo.getHeader(pack, checkfunc=check)
        else:
            data = self.repo.getPackage(pack, checkfunc=check)
        return data

    @staticmethod
    def verify_pkg(_fo, pkg, _fail):
        return pkg.verifyLocalPkg()

    def clear_cache(self, directory=None, keep_repomd=False):
        if directory is None:
            directory = os.path.join(CACHE_DIR, self.org, self.name)

        # remove content in directory
        for item in os.listdir(directory):
            path = os.path.join(directory, item)
            if os.path.isfile(path) and not (keep_repomd and item == "repomd.xml"):
                os.unlink(path)
            elif os.path.isdir(path):
                rmtree(path)

        # restore empty directories
        makedirs(directory + "/packages", int('0755', 8))
        makedirs(directory + "/gen", int('0755', 8))

    def get_updates(self):
        if 'updateinfo' not in self.repo.repoXML.repoData:
            return []
        um = YumUpdateMetadata()
        um.add(self.repo, all_versions=True)
        return um.notices

    def get_groups(self):
        try:
            groups = self.repo.getGroups()
        except RepoMDError:
            groups = None
        return groups

    def get_modules(self):
        try:
            modules = self.repo.retrieveMD('modules')
        except RepoMDError:
            modules = None
        return modules

    def get_file(self, path, local_base=None):
        try:
            try:
                temp_file = ""
                if local_base is not None:
                    target_file = os.path.join(local_base, path)
                    target_dir = os.path.dirname(target_file)
                    if not os.path.exists(target_dir):
                        os.makedirs(target_dir, int('0755', 8))
                    temp_file = target_file + '..download'
                    if os.path.exists(temp_file):
                        os.unlink(temp_file)
                    downloaded = self.repo.grab.urlgrab(path, temp_file)
                    os.rename(downloaded, target_file)
                    return target_file
                else:
                    return self.repo.grab.urlread(path)
            except URLGrabError:
                return
        finally:
            if os.path.exists(temp_file):
                os.unlink(temp_file)

    def repomd_up_to_date(self):
        repomd_old_path = os.path.join(self.repo.basecachedir, self.name, "repomd.xml")
        # No cached repomd?
        if not os.path.isfile(repomd_old_path):
            return False
        repomd_new_path = os.path.join(self.repo.basecachedir, self.name, "repomd.xml.new")
        # Newer file not available? Don't do anything. It should be downloaded before this.
        if not os.path.isfile(repomd_new_path):
            return True
        return (checksum.getFileChecksum('sha256', filename=repomd_old_path) ==
                checksum.getFileChecksum('sha256', filename=repomd_new_path))

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

    # Simply load primary and updateinfo path from repomd
    def get_metadata_paths(self):
        def get_location(data_item):
            for sub_item in data_item:
                if sub_item.tag.endswith("location"):
                    return sub_item.attrib.get("href")

        def get_checksum(data_item):
            for sub_item in data_item:
                if sub_item.tag.endswith("checksum"):
                    return sub_item.attrib.get("type"), sub_item.text

        repomd_path = os.path.join(self.repo.basecachedir, self.name, "repomd.xml")
        if not os.path.isfile(repomd_path):
            raise RepoMDNotFound(repomd_path)
        repomd = open(repomd_path, 'rb')
        files = {}
        for _event, elem in iterparse(repomd):
            if elem.tag.endswith("data"):
                if elem.attrib.get("type") == "primary_db":
                    files['primary'] = (get_location(elem), get_checksum(elem))
                elif elem.attrib.get("type") == "primary" and 'primary' not in files:
                    files['primary'] = (get_location(elem), get_checksum(elem))
                elif elem.attrib.get("type") == "updateinfo":
                    files['updateinfo'] = (get_location(elem), get_checksum(elem))
                elif elem.attrib.get("type") == "group_gz":
                    files['group'] = (get_location(elem), get_checksum(elem))
                elif elem.attrib.get("type") == "group" and 'group' not in files:
                    files['group'] = (get_location(elem), get_checksum(elem))
                elif elem.attrib.get("type") == "modules":
                    files['modules'] = (get_location(elem), get_checksum(elem))
        repomd.close()
        return files.values()
