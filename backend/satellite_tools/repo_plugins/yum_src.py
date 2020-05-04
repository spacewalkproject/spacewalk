#
# Copyright (c) 2008--2020 Red Hat, Inc.
# Copyright (c) 2010--2011 SUSE LINUX Products GmbH, Nuernberg, Germany.
# Copyright (c) 2020 Stefan Bluhm, Germany.
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

import hashlib
import logging
import re
import sys
import os.path
from os import makedirs
from shutil import rmtree
from custom_update_md import UpdateMetadata
from custom_update_md import UpdateNotice
from custom_update_md import UpdateNoticeException
from libdnf.conf import ConfigParser
import dnf
from dnf.exceptions import Error
from dnf.exceptions import RepoError
from spacewalk.common import fileutils #pylint: disable=ungrouped-imports
from spacewalk.common import checksum #pylint: disable=ungrouped-imports
from spacewalk.common.rhnConfig import CFG #pylint: disable=ungrouped-imports
from spacewalk.common.rhnConfig import initCFG #pylint: disable=ungrouped-imports
from spacewalk.satellite_tools.download import get_proxies #pylint: disable=ungrouped-imports
from spacewalk.satellite_tools.repo_plugins import ContentPackage #pylint: disable=ungrouped-imports
from spacewalk.satellite_tools.repo_plugins import CACHE_DIR #pylint: disable=ungrouped-imports
from urlgrabber.grabber import URLGrabError


try:
    from xml.etree import cElementTree
except ImportError:
    # pylint: disable=F0401
    import cElementTree
iterparse = cElementTree.iterparse
try:
    #  python 2
    import urlparse
except ImportError:
    #  python3
    import urllib.parse as urlparse # pylint: disable=F0401,E0611


YUMSRC_CONF = '/etc/rhn/spacewalk-repo-sync/yum.conf'

logging.basicConfig()
log = logging.getLogger(__name__)


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
        elif isinstance(obj, dnf.repo.Repo):
            if obj.id not in self._repos:
                self._repos.append(obj.id)
                md = obj.get_metadata_path(mdtype)
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
        name = re.sub('[^a-zA-Z0-9_.:-]+', '_', name)
        self.url = url
        self.name = name
        self.dnfbase = dnf.Base()
        self.dnfbase.conf.read(yumsrc_conf)
        if not os.path.exists(yumsrc_conf):
            self.dnfbase.conf.read('/dev/null')
        self.configparser = ConfigParser()      # Reading config file directly as dnf only ready MAIN section.
        self.configparser.setSubstitutions( dnf.Base().conf.substitutions)
        self.configparser.read(yumsrc_conf)
        if org:
            self.org = org
        else:
            self.org = "NULL"
        self.dnfbase.conf.cachedir = os.path.join(CACHE_DIR, self.org)

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
            db_cfg = self.configparser
            section_name = None

            if db_cfg.has_section(self.name):
                section_name = self.name
            elif db_cfg.has_section(channel_label):
                section_name = channel_label
            elif db_cfg.has_section('main'):
                section_name = 'main'

            if section_name:
                if db_cfg.has_option(section_name, option='proxy'):
                    self.proxy_addr = db_cfg.get(section_name, option='proxy')

                if db_cfg.has_option(section_name, 'proxy_username'):
                    self.proxy_user = db_cfg.get(section_name, 'proxy_username')

                if db_cfg.has_option(section_name, 'proxy_password'):
                    self.proxy_pass = db_cfg.get(section_name, 'proxy_password')

        self._authenticate(url)

        # Check for settings in yum configuration files (for custom repos/channels only)
        if org:
            repos = self.dnfbase.repos
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
            repo = dnf.repo.Repo(name,self.dnfbase.conf)
            repo.repofile = yumsrc_conf
            # pylint: disable=W0212
            repo._populate(self.configparser, name, yumsrc_conf)
        self.repo = repo

        self.yumbase = self.dnfbase # for compatibility

        self.setup_repo(repo, no_mirrors, ca_cert_file, client_cert_file, client_key_file)
        self.num_packages = 0
        self.num_excluded = 0
        self.groupsfile = None
        self.repo = self.dnfbase.repos[self.repoid]
        self.get_metadata_paths()

    def __del__(self):
        # close log files for yum plugin
        for handler in logging.getLogger("dnf").handlers:
            handler.close()
        self.dnfbase.close()

    def _authenticate(self, url):
        pass

    def setup_repo(self, repo, no_mirrors, ca_cert_file, client_cert_file, client_key_file):
        """Fetch repository metadata"""
        repo.metadata_expire=0
        repo.mirrorlist = self.url
        repo.baseurl = [self.url]
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

        if self.proxy_addr:
            repo.proxy = self.proxy_addr if '://' in self.proxy_addr else 'http://' + self.proxy_addr
            repo.proxy_username = self.proxy_user
            repo.proxy_password = self.proxy_pass

        if no_mirrors:
            repo.mirrorlist = ""
        self.digest=hashlib.sha256(self.url.encode('utf8')).hexdigest()[:16]
        self.dnfbase.repos.add(repo)
        self.repoid = repo.id
        try:
            logger = logging.getLogger('dnf')
            logger.setLevel(logging.ERROR)
            self.yumbase.repos[self.repoid].load()
            logger.setLevel(logging.WARN)
        except RepoError:
            # Dnf bug workaround. Mirrorlist was provided but none worked. Fallback to baseurl and load again.
            # Remove once dnf is fixed and add detection if mirrors failed.
            logger.setLevel(logging.WARN)
            repo.mirrorlist = ""
            no_mirrors = True
            self.dnfbase.repos[self.repoid].load()

        # Do not try to expand baseurl to other mirrors
        if no_mirrors:
            self.dnfbase.repos[self.repoid].urls = repo.baseurl
            # Make sure baseurl ends with / and urljoin will work correctly
            if self.dnfbase.repos[self.repoid].urls[0][-1] != '/':
                self.dnfbase.repos[self.repoid].urls[0] += '/'
        else:
            self.dnfbase.repos[self.repoid].urls = self.clean_urls(self.dnfbase.repos[self.repoid]._repo.getMirrors()) # pylint: disable=W0212
            self.dnfbase.repos[self.repoid].urls=[url for url in self.dnfbase.repos[self.repoid].urls if '?' not in url]
        self.dnfbase.repos[self.repoid].basecachedir = os.path.join(CACHE_DIR, self.org)
        repoXML = type('', (), {})()
        repoXML.repoData = {}
        self.dnfbase.repos[self.repoid].repoXML = repoXML

    @staticmethod
    def clean_urls(urls):
        """
        Filters a url schema for http, https, ftp, file only.
        :return: urllist (string)
        """
        cleaned = []
        for url in urls:
            s = dnf.pycomp.urlparse.urlparse(url)[0]
            if s in ('http', 'ftp', 'file', 'https'):
                cleaned.append(url)
        return cleaned

    def number_of_packages(self):
        for dummy_index in range(3):
            try:
                self.dnfbase.fill_sack(load_system_repo=False)
                break
            except RepoError:
                pass
        return len(self.dnfbase.sack)

    def raw_list_packages(self, filters=None):
        for dummy_index in range(3):
            try:
                self.dnfbase.fill_sack(load_system_repo=False,load_available_repos=True)
                break
            except RepoError:
                pass

        rawpkglist = self.dnfbase.sack.query().run()
        self.num_packages = len(rawpkglist)

        if not filters:
            filters = []
            # if there's no include/exclude filter on command line or in database
            for p in self.dnfbase.repos[self.repoid].includepkgs:
                filters.append(('+', [p]))
            for p in self.dnfbase.repos[self.repoid].exclude:
                filters.append(('-', [p]))

        if filters:
            rawpkglist = self._filter_packages(rawpkglist, filters)
            rawpkglist = self._get_package_dependencies(self.dnfbase.sack, rawpkglist)
            self.num_excluded = self.num_packages - len(rawpkglist)

        for pack in rawpkglist:
            pack.packagesize = pack.downloadsize
            pack.checksum_type = pack.returnIdSum()[0]
            pack.checksum = pack.returnIdSum()[1]

        return rawpkglist

    def list_packages(self, filters, latest):
        """ list packages"""
        self.dnfbase.fill_sack(load_system_repo=False,load_available_repos=True)
        pkglist = self.dnfbase.sack.query()
        self.num_packages = len(pkglist)
        if latest:
            pkglist = pkglist.latest()
        pkglist = list(dict.fromkeys(pkglist))                          # Filter out duplicates

        if not filters:
            # if there's no include/exclude filter on command line or in database
            # check repository config file
            for p in self.dnfbase.repos[self.repoid].includepkgs:
                filters.append(('+', [p]))
            for p in self.dnfbase.repos[self.repoid].exclude:
                filters.append(('-', [p]))

        filters = self._expand_package_groups(filters)

        if filters:
            pkglist = self._filter_packages(pkglist, filters)
            pkglist = self._get_package_dependencies(self.dnfbase.sack, pkglist)

            self.num_excluded = self.num_packages - len(pkglist)
        to_return = []
        for pack in pkglist:
            if pack.arch == 'src':
                continue
            new_pack = ContentPackage()
            new_pack.setNVREA(pack.name, pack.version, pack.release,
                              pack.epoch, pack.arch)
            new_pack.unique_id = pack
            new_pack.checksum_type = pack.returnIdSum()[0]
            if new_pack.checksum_type == 'sha':
                new_pack.checksum_type = 'sha1'
            new_pack.checksum = pack.returnIdSum()[1]
            to_return.append(new_pack)
        return to_return

    @staticmethod
    def _find_comps_type(comps_type, environments, groups, name):
        # Finds environment or regular group by name or label
        found = None
        if comps_type == "environment":
            for e in environments:
                if e.id == name or e.name == name:
                    found = e
                    break
        elif comps_type == "group":
            for g in groups:
                if g.id == name or g.name == name:
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
                        new_pkg_list.extend(['@' + grp.name for grp in found.groups_iter()])
                    elif found and comps_type == "group":
                        # Replace with package list, simplified to not evaluate if packages are default, optional etc.
                        for package in found.packages:
                            new_pkg_list.append(str(package.name))
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
        comps = dnf.comps.Comps()
        # pylint: disable=W0212
        comps._add_from_xml_filename(self.groupsfile)
        groups = comps.groups

        if hasattr(comps, 'environments'):
            # First expand environment groups, then regular groups
            environments = comps.environments
            filters = self._expand_comps_type("environment", environments, groups, filters)
        else:
            environments = []
        filters = self._expand_comps_type("group", environments, groups, filters)
        return filters

    @staticmethod
    def __parsePackages(pkgSack, pkgs):
        """
         Substitute for yum's parsePackages.
         The function parses a list of package names and returns their Hawkey
         list if it exists in the package sack. Inputs are a package sack and
         a list of packages. Returns a list of latest existing packages in
         Hawkey format.
        """

        matches = set()
        for pkg in pkgs:
            hkpkgs = set()
            subject = dnf.subject.Subject(pkg)
            hkpkgs |= set(subject.get_best_selector(pkgSack, obsoletes=True).matches())
            if len(matches) == 0:
                matches = hkpkgs
            else:
                matches |= hkpkgs
        result = list(matches)
        a = pkgSack.query().available() # Load all available packages from the repository
        result = a.filter(pkg=result).latest().run()
        return result

    def _filter_packages(self, packages, filters):
        """ implement include / exclude logic
            filters are: [ ('+', includelist1), ('-', excludelist1),
                           ('+', includelist2), ... ]
        """
        if filters is None:
            return []

        selected = []
        excluded = []
        if filters[0][0] == '-':
            # first filter is exclude, start with full package list
            # and then exclude from it
            selected = packages
        else:
            excluded = packages

        sack = self.dnfbase.sack
        for filter_item in filters:
            sense, pkg_list = filter_item
            convertFilterToPackagelist = self.__parsePackages(
                sack, pkg_list)
            if sense == '+':
                # include
                matched = list()
                for v1 in convertFilterToPackagelist:          # Use only packages that are in pkg_list
                    for v2 in excluded:
                        if v1 == v2 and v1 not in matched:
                            matched.append(v1)
                allmatched = list(dict.fromkeys( matched ))    # remove duplicates
                selected = list(dict.fromkeys( selected + allmatched ) )   # remove duplicates
                for pkg in allmatched:
                    if pkg in excluded:
                        excluded.remove(pkg)
            elif sense == '-':
                # exclude
                matched = list()
                for v1 in convertFilterToPackagelist:          # Use only packages that are in pkg_list
                    for v2 in selected:
                        if v1 == v2 and v1 not in matched:
                            matched.append(v1)
                allmatched = list(dict.fromkeys(matched))      # remove duplicates
                for pkg in allmatched:
                    if pkg in selected:
                        selected.remove(pkg)
                allmatched = list(allmatched)
                excluded = excluded + allmatched
                excluded = list(dict.fromkeys(excluded)) # Filter out duplicates
            else:
                raise Error("Invalid filter sense: '%s'" % sense)
        return selected

    @staticmethod
    def __findDeps(pkgSack, pkgs):
#
#        Input: Sack, list of packages
#        Output: List of packages
#
        results = {}
        a = pkgSack.query().available()
        for pkg in pkgs:
            results[pkg] = {}
            reqs = pkg.requires
            pkgresults = results[pkg]
            for req in reqs:
                if str(req).startswith('rpmlib('):
                    continue
                satisfiers = []
                for po in a.filter(provides = req).latest():
                    satisfiers.append(po)
                pkgresults[req] = satisfiers
        return results

    def _get_package_dependencies(self, sack, packages):
        self.dnfbase.pkgSack = sack
        known_deps = set()
        resolved_deps = self.__findDeps(self.dnfbase.pkgSack, packages)
        while resolved_deps:
            next_level_deps = []
            for deps in resolved_deps.values():
                for _dep, dep_packages in deps.items():
                    if _dep not in known_deps:
                        next_level_deps.extend(dep_packages)
                        packages.extend(dep_packages)
                        known_deps.add(_dep)

            resolved_deps = self.__findDeps(self.dnfbase.pkgSack,next_level_deps)

        return list(dict.fromkeys(packages))

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
            directory = os.path.join(CACHE_DIR, self.org, self.name+"-"+self.digest)

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
        makedirs(directory + "/repodata", int('0755', 8))
        self.dnfbase.repos[self.repoid].load()

    def get_updates(self):
        if not self.dnfbase.repos[self.repoid].get_metadata_content("updateinfo"):
            return []
        um = YumUpdateMetadata()
        um.add(self.dnfbase.repos[self.repoid], all_versions=True)
        return um.notices

    def get_groups(self):
        groups = self.repo.get_metadata_path("group_gz")
        if groups == "":
            groups = self.repo.get_metadata_path("group")
        if groups == "":
            groups = None
        return groups

    def get_modules(self):
        modules = self.repo.get_metadata_path('modules')
        if modules == "":
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
                return None
        finally:
            if os.path.exists(temp_file):
                os.unlink(temp_file)
        return None

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

        params['urls'] = self.dnfbase.repos[self.repoid].urls
        params['relative_path'] = relative_path
        params['authtoken'] = self.authtoken
        params['target_file'] = target_file
        params['ssl_ca_cert'] = self.dnfbase.repos[self.repoid].sslcacert
        params['ssl_client_cert'] = self.dnfbase.repos[self.repoid].sslclientcert
        params['ssl_client_key'] = self.dnfbase.repos[self.repoid].sslclientkey
        params['checksum_type'] = checksum_type
        params['checksum'] = checksum_value
        params['bytes_range'] = bytes_range
        params['proxy'] = self.dnfbase.repos[self.repoid].proxy
        params['proxy_username'] = self.dnfbase.repos[self.repoid].proxy_username
        params['proxy_password'] = self.dnfbase.repos[self.repoid].proxy_password
        params['http_headers'] = dict( self.dnfbase.repos[self.repoid].get_http_headers() )
        # Older urlgrabber compatibility
        params['proxies'] = get_proxies(self.dnfbase.repos[self.repoid].proxy,
                                        self.dnfbase.repos[self.repoid].proxy_username,
                                        self.dnfbase.repos[self.repoid].proxy_password )

    # Simply load primary and updateinfo path from repomd
    def get_metadata_paths(self):
        def get_location(data_item):
            for sub_item in data_item:
                if sub_item.tag.endswith("location"):
                    return sub_item.attrib.get("href")
            return None

        def get_checksum(data_item):
            for sub_item in data_item:
                if sub_item.tag.endswith("checksum"):
                    return sub_item.attrib.get("type"), sub_item.text
            return None

        def get_timestamp(data_item):
            for sub_item in data_item:
                if sub_item.tag.endswith("timestamp"):
                    return sub_item.text
            return None

        repomd_path = os.path.join(self.dnfbase.repos[self.repoid].basecachedir,
                                   self.name + "-" + self.digest, "repodata", "repomd.xml")
        if not os.path.isfile(repomd_path):
            raise RepoMDNotFound(repomd_path)
        repomd = open(repomd_path, 'rb')
        files = {}
        for _event, elem in iterparse(repomd):
            if elem.tag.endswith("data"):
                repoData = type('', (), {})()
                if elem.attrib.get("type") == "primary_db":
                    files['primary'] = (get_location(elem), get_checksum(elem))
                    repoData.timestamp = get_timestamp(elem)
                elif elem.attrib.get("type") == "primary" and 'primary' not in files:
                    files['primary'] = (get_location(elem), get_checksum(elem))
                    repoData.timestamp = get_timestamp(elem)
                elif elem.attrib.get("type") == "updateinfo":
                    files['updateinfo'] = (get_location(elem), get_checksum(elem))
                    repoData.timestamp = get_timestamp(elem)
                elif elem.attrib.get("type") == "group_gz":
                    files['group'] = (get_location(elem), get_checksum(elem))
                    repoData.timestamp = get_timestamp(elem)
                elif elem.attrib.get("type") == "group" and 'group' not in files:
                    files['group'] = (get_location(elem), get_checksum(elem))
                    repoData.timestamp = get_timestamp(elem)
                elif elem.attrib.get("type") == "modules":
                    files['modules'] = (get_location(elem), get_checksum(elem))
                    repoData.timestamp = get_timestamp(elem)
                self.dnfbase.repos[self.repoid].repoXML.repoData[elem.attrib.get("type")] = repoData
        repomd.close()
        return files.values()
