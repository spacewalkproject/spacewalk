"""
Copyright (C) 2014 Oracle and/or its affiliates. All rights reserved.

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation, version 2


This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
02110-1301, USA. 

ULN plugin for spacewalk-repo-sync.
"""
import sys
import gzip
import os.path
from shutil import rmtree
from os import mkdir, makedirs
sys.path.append('/usr/share/rhn/up2date_client')
from rpcServer import RetryServer

import yum
from spacewalk.common import fileutils
from yum.Errors import RepoMDError
from yum.config import ConfigParser
from yum.update_md import UpdateMetadata, UpdateNoticeException, UpdateNotice
from yum.yumRepo import YumRepository
from urlgrabber.grabber import URLGrabError

try:
    from yum.misc import cElementTree_iterparse as iterparse
except ImportError:
    try:
        from xml.etree import cElementTree
    except ImportError:
        import cElementTree
    iterparse = cElementTree.iterparse
from spacewalk.satellite_tools.reposync import ContentPackage
from spacewalk.common.rhnConfig import CFG, initCFG

CACHE_DIR   = '/var/cache/rhn/reposync/'
ULNSRC_CONF = '/etc/rhn/spacewalk-repo-sync/uln.conf'
DEFAULT_UP2DATE_URL = "linux-update.oracle.com"

class YumWarnings:
    def __init__(self):
        self.saved_stdout = None
    def write(self, s):
        pass
    def disable(self):
        self.saved_stdout = sys.stdout
        sys.stdout = self
    def restore(self):
        sys.stdout = self.saved_stdout

class YumUpdateMetadata(UpdateMetadata):
    """The root update metadata object supports getting all updates"""

    def add(self, obj, mdtype='updateinfo', all=False):
        """ Parse a metadata from a given YumRepository, file, or filename. """
        if not obj:
            raise UpdateNoticeException
        if type(obj) in (type(''), type(u'')):
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
                if all:
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
    def __init__(self, url, name):
        if url[:6] != "uln://":
            print "url format error, url must start with uln://"
            return -1
        self.name = name
        self.yumbase = yum.YumBase()
        self.yumbase.preconf.fn = ULNSRC_CONF
        if not os.path.exists(ULNSRC_CONF):
            self.yumbase.preconf.fn = '/dev/null'
        self.configparser = ConfigParser()
        self._clean_cache(CACHE_DIR + name)

        # read the proxy configuration in /etc/rhn/rhn.conf
        initCFG('server.satellite')
        self.proxy_addr = CFG.http_proxy
        self.proxy_user = CFG.http_proxy_username
        self.proxy_pass = CFG.http_proxy_password
        if url.startswith("uln:///"):
            self.uln_url = "https://" + DEFAULT_UP2DATE_URL
            label = url[7:]
        elif url.startswith("uln://"):
            parts = url[6:].split("/")
            self.uln_url = "https://" + parts[0]
            label = parts[1]
        else:
            print "url format error, url must start with uln://"
            return -1
        self.uln_user = self.yumbase.conf.username
        self.uln_pass = self.yumbase.conf.password
        self.url = self.uln_url + "/XMLRPC/GET-REQ/" + label
        print "The download URL is: " + self.url
        if self.proxy_addr:
            print "Trying proxy " + self.proxy_addr
        s = RetryServer(self.uln_url+"/rpc/api",
                    refreshCallback = None,
                    proxy = self.proxy_addr,
                    username = self.proxy_user,
                    password = self.proxy_pass,
                    timeout = 5)
        self.key = s.auth.login(self.uln_user, self.uln_pass)

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

    def setup_repo(self, repo):
        """Fetch repository metadata"""
        repo.cache = 0
        repo.metadata_expire = 0
        repo.mirrorlist = self.url
        repo.baseurl = [self.url]
        repo.basecachedir = CACHE_DIR
        repo.http_headers = {'X-ULN-Api-User-Key': self.key}
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

    def list_packages(self, filters):
        """ list packages"""
        self.sack.populate(self.repo, 'metadata', None, 0)
        pkglist = self.sack.returnPackages()
        self.num_packages = len(pkglist)
        if filters:
            pkglist = self._filter_packages(pkglist, filters)
            pkglist = self._get_package_dependencies(self.sack, pkglist)
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
            new_pack.checksum      = pack.checksums[0][1]
            to_return.append(new_pack)
        return to_return

    def _filter_packages(self, packages, filters):
        """ implement include / exclude logic
            filters are: [ ('+', includelist1), ('-', excludelist1),
                           ('+', includelist2), ... ]
        """
        if filters is None:
            return

        selected = []
        excluded = []
        if filters[0][0] == '-':
            # first filter is exclude, start with full package list
            # and then exclude from it
            selected = packages
        else:
            excluded = packages

        for filter_item in filters:
            sense, pkg_list = filter_item
            if sense == '+':
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

    def verify_pkg(self, fo, pkg, fail):
        return pkg.verifyLocalPkg()

    def _clean_cache(self, directory):
        rmtree(directory, True)

    def get_updates(self):
        if not self.repo.repoXML.repoData.has_key('updateinfo'):
            return []
        um = YumUpdateMetadata()
        um.add(self.repo, all=True)
        return um.notices

    def get_groups(self):
        try:
            groups = self.repo.getGroups()
        except RepoMDError:
            groups = None
        return groups

    def set_ssl_options(self, ca_cert, client_cert, client_key):
        repo = self.repo
        dir = os.path.join(repo.basecachedir, self.name, '.ssl-certs')
        mkdir(dir, 0750)
        repo.sslcacert = os.path.join(dir, 'ca.pem')
        f = open(repo.sslcacert, "w")
        f.write(str(ca_cert))
        f.close
        if client_cert is not None:
            repo.sslclientcert = os.path.join(dir, 'cert.pem')
            f = open(repo.sslclientcert, "w")
            f.write(str(client_cert))
            f.close
        if client_key is not None:
            repo.sslclientkey = os.path.join(dir, 'key.pem')
            f = open(repo.sslclientkey, "w")
            f.write(str(client_key))
            f.close

    def clear_ssl_cache(self):
        repo = self.repo
        dir = os.path.join(repo.basecachedir, self.name, '.ssl-certs')
        try:
            self._clean_cache(dir)
        except:
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
