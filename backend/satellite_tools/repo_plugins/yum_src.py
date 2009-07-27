#!/usr/bin/python -u
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
import yum
from yum import config
from reposync import ContentPackage

class ContentSource:
    url = None
    name = None
    repo = None

    def __init__(self, url, name):
        self.url = url
        self.name = name

    def list_packages(self):
        """ list packages"""
        repo = yum.yumRepo.YumRepository(self.name)
        self.repo = repo
        repo.cache = 0
        repo.metadata_expire = 0
        repo.baseurl = [self.url]
        repo.basecachedir = '/var/cache/rhn/reposync/'
#        repo.cachedir = '/var/cache/rhn/reposync/'
        repo.setup(False)
        sack = repo.getPackageSack()
        sack.populate(repo, 'metadata', None, 0)
        list = sack.returnPackages()
        to_return = []
        for pack in list:
            new_pack = ContentPackage()
            new_pack.setNVREA(pack.name, pack.version, pack.release, 
                              pack.epoch, pack.arch)
            new_pack.unique_id = pack
            for cs in pack.checksums:
                new_pack.checksums[cs[0]] = cs[1]
            to_return.append(new_pack)
        return to_return

    def get_package(self, package):
        """ get package """
        return self.repo.getPackage(package.unique_id)
