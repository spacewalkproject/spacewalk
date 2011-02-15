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
import yum
import shutil
import sys
from spacewalk.satellite_tools.reposync import ContentPackage
from spacewalk.common import CFG, initCFG

class YumWarnings:
    def write(self, s):
        pass
    def disable(self):
        self.saved_stdout = sys.stdout
        sys.stdout = self
    def restore(self):
        sys.stdout = self.saved_stdout

class ContentSource:
    url = None
    name = None
    repo = None
    cache_dir = '/var/cache/rhn/reposync/'
    def __init__(self, url, name):
        self.url = url
        self.name = name
        self._clean_cache(self.cache_dir + name)

        # read the proxy configuration in /etc/rhn/rhn.conf
        initCFG('server.satellite')
        self.proxy_addr = CFG.http_proxy
        self.proxy_user = CFG.http_proxy_username
        self.proxy_pass = CFG.http_proxy_password

        if (self.proxy_user is not None and self.proxy_pass is not None and self.proxy_addr is not None):
            self.proxy_url = "http://%s:%s@%s" %(self.proxy_user, self.proxy_pass, self.proxy_addr)
        elif (self.proxy_addr is not None):
            self.proxy_url = "http://%s" %(self.proxy_addr)
        else:
            self.proxy_url = None

    def list_packages(self):
        """ list packages"""
        repo = yum.yumRepo.YumRepository(self.name)
        self.repo = repo
        repo.cache = 0
        repo.metadata_expire = 0
        repo.mirrorlist = self.url
        repo.baseurl = [self.url]
        repo.basecachedir = self.cache_dir
        if self.proxy_url is not None:
            repo.proxy = self.proxy_url

        warnings = YumWarnings()
        warnings.disable()
        repo.baseurlSetup()
        warnings.restore()

        repo.setup(False)
        sack = repo.getPackageSack()
        sack.populate(repo, 'metadata', None, 0)
        list = sack.returnPackages()
        to_return = []
        for pack in list:
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

    def get_package(self, package):
        """ get package """
        check = (self.verify_pkg, (package.unique_id ,1), {})
        return self.repo.getPackage(package.unique_id, checkfunc=check)

    def verify_pkg(self, fo, pkg, fail):
        return pkg.verifyLocalPkg()

    def _clean_cache(self, directory):
        shutil.rmtree(directory, True)
