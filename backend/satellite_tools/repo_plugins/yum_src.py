#
# Copyright (c) 2008--2015 Red Hat, Inc.
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
import os.path
from shutil import rmtree
from os import mkdir

import yum
from spacewalk.common import fileutils
from yum.Errors import RepoMDError
from yum.config import ConfigParser
from yum.packageSack import ListPackageSack
from yum.update_md import UpdateMetadata, UpdateNoticeException, UpdateNotice
from yum.yumRepo import YumRepository
from urlgrabber.grabber import URLGrabError

try:
    from yum.misc import cElementTree_iterparse as iterparse
except ImportError:
    try:
        from xml.etree import cElementTree
    except ImportError:
        # pylint: disable=F0401
        import cElementTree
    iterparse = cElementTree.iterparse
from spacewalk.satellite_tools.repo_plugins import ContentPackage
from spacewalk.common.rhnConfig import CFG, initCFG

CACHE_DIR = '/var/cache/rhn/reposync/'
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
                if not self._notices.has_key(key):
                    self._notices[key] = un
                    for pkg in un['pkglist']:
                        for pkgfile in pkg['packages']:
                            self._cache['%s-%s-%s' % (pkgfile['name'],
                                                      pkgfile['version'],
                                                      pkgfile['release'])] = un
                            no = self._no_cache.setdefault(pkgfile['name'], set())
                            no.add(un)


class ContentSource(object):

    def __init__(self, url, name, yumsrc_conf=YUMSRC_CONF):
        self.url = url
        self.name = name
        self.yumbase = yum.YumBase()
        self.yumbase.preconf.fn = yumsrc_conf
        if not os.path.exists(yumsrc_conf):
            self.yumbase.preconf.fn = '/dev/null'
        self.configparser = ConfigParser()
        self._clean_cache(CACHE_DIR + name)

        # read the proxy configuration in /etc/rhn/rhn.conf
        initCFG('server.satellite')
        self.proxy_addr = CFG.http_proxy
        self.proxy_user = CFG.http_proxy_username
        self.proxy_pass = CFG.http_proxy_password
        self._authenticate(url)
        if name in self.yumbase.repos.repos:
            repo = self.yumbase.repos.repos[name]
        else:
            repo = yum.yumRepo.YumRepository(name)
            repo.populate(self.configparser, name, self.yumbase.conf)
        self.repo = repo
        self.sack = None

        self.setup_repo(repo)
        self.num_packages = 0
        self.num_excluded = 0

    def _authenticate(self, url):
        pass

    def setup_repo(self, repo):
        """Fetch repository metadata"""
        repo.cache = 0
        repo.metadata_expire = 0
        repo.mirrorlist = self.url
        repo.baseurl = [self.url]
        repo.basecachedir = CACHE_DIR
        # base_persistdir have to be set before pkgdir
        if hasattr(repo, 'base_persistdir'):
            repo.base_persistdir = CACHE_DIR
        if (self.url.find("file://") < 0):
            pkgdir = os.path.join(CFG.MOUNT_POINT, CFG.PREPENDED_DIR, '1', 'stage')
            if not os.path.isdir(pkgdir):
                fileutils.makedirs(pkgdir, user='apache', group='apache')
        else:
            pkgdir = self.url[7:]
        repo.pkgdir = pkgdir

        yb_cfg = self.yumbase.conf.cfg
        if not ((yb_cfg.has_section(self.name) and yb_cfg.has_option(self.name, 'proxy')) or
                (yb_cfg.has_section('main') and yb_cfg.has_option('main', 'proxy'))) and \
                self.proxy_addr is not None:
            repo.proxy = "http://%s" % self.proxy_addr
            repo.proxy_username = self.proxy_user
            repo.proxy_password = self.proxy_pass

        warnings = YumWarnings()
        warnings.disable()
        try:
            repo.baseurlSetup()
        except:
            warnings.restore()
            raise
        warnings.restore()
        repo.setup(False)
        self.sack = self.repo.getPackageSack()

    def list_packages(self, filters, latest):
        """ list packages"""
        self.sack.populate(self.repo, 'metadata', None, 0)
        pkglist = ListPackageSack(self.sack.returnPackages())
        self.num_packages = len(pkglist)
        if latest:
             pkglist = pkglist.returnNewestByNameArch()
        pkglist = yum.misc.unique(pkglist)
        pkglist.sort(self.sortPkgObj)

        if not filters:
            # if there's no include/exclude filter on command line or in database
            for p in self.repo.includepkgs:
                filters.append(('+', [p]))
            for p in self.repo.exclude:
                filters.append(('-', [p]))

        if filters:
            pkglist = self._filter_packages(pkglist, filters)
            pkglist = self._get_package_dependencies(self.sack, pkglist)

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

    def sortPkgObj(self, pkg1 ,pkg2):
        """sorts a list of yum package objects by name"""
        if pkg1.name > pkg2.name:
            return 1
        elif pkg1.name == pkg2.name:
            return 0
        else:
            return -1

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
                if not exclude_only:
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
                raise UpdateNoticeException
        return selected

    def _get_package_dependencies(self, sack, packages):
        self.yumbase.pkgSack = sack
        resolved_deps = self.yumbase.findDeps(packages)
        for (_pkg, deps) in resolved_deps.items():
            for (_dep, dep_packages) in deps.items():
                packages.extend(dep_packages)
        return yum.misc.unique(packages)

    def get_package(self, package):
        """ get package """
        check = (self.verify_pkg, (package.unique_id, 1), {})
        return self.repo.getPackage(package.unique_id, checkfunc=check)

    @staticmethod
    def verify_pkg(_fo, pkg, _fail):
        return pkg.verifyLocalPkg()

    @staticmethod
    def _clean_cache(directory):
        rmtree(directory, True)

    def get_updates(self):
        if not self.repo.repoXML.repoData.has_key('updateinfo'):
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

    def set_ssl_options(self, ca_cert, client_cert, client_key):
        repo = self.repo
        ssldir = os.path.join(repo.basecachedir, self.name, '.ssl-certs')
        mkdir(ssldir, 0750)
        repo.sslcacert = os.path.join(ssldir, 'ca.pem')
        f = open(repo.sslcacert, "w")
        f.write(str(ca_cert))
        f.close()
        if client_cert is not None:
            repo.sslclientcert = os.path.join(ssldir, 'cert.pem')
            f = open(repo.sslclientcert, "w")
            f.write(str(client_cert))
            f.close()
        if client_key is not None:
            repo.sslclientkey = os.path.join(ssldir, 'key.pem')
            f = open(repo.sslclientkey, "w")
            f.write(str(client_key))
            f.close()

    def clear_ssl_cache(self):
        repo = self.repo
        ssldir = os.path.join(repo.basecachedir, self.name, '.ssl-certs')
        try:
            self._clean_cache(ssldir)
        except (OSError, IOError):
            pass

    def get_file(self, path, local_base=None):
        try:
            if local_base is not None:
                target_file = os.path.join(local_base, path)
                target_dir = os.path.dirname(target_file)
                if not os.path.exists(target_dir):
                    os.makedirs(target_dir, 0755)
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
