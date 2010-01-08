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

import sys
rhn_path = '/usr/share/rhn'
if rhn_path not in sys.path:
    sys.path.append(rhn_path)

from server import rhnSQL
from server.importlib.backendOracle import OracleBackend
from server.importlib.packageImport import PackageImport

from server.importlib.mpmSource import mpmBinaryPackage

solaris_pkgs = [
    mpmBinaryPackage().populate(
        header={
            'arch': 'sparc-solaris',
            'build_host': 'test01-sol.rhndev.redhat.com',
            'build_time': '2005-05-13 20:16:12',
            'conflicts': [],
            'cookie': None,
            'description': None,
            'epoch': 0,
            'intonly': 'N',
            'license': None,
            'name': 'SMCossh4',
            'obsoletes': [],
            'package_group': 'application',
            'package_type': 'solaris',
            'payload_format': None,
            'payload_size': None,
            'pkginfo': '',
            'pkgmap': '',
            'provides': [{'version': '4.0p1', 'flags': 0, 'name': 'SMCossh4'}],
            'release': 1,
            'requires': [],
            'rpm_version': None,
            'sigmd5': None,
            'sigsize': 0,
            'sourcerpm': None,
            'summary': 'openssh',
            'vendor': 'The OpenSSH Group',
            'version': '4.0p1'
        },
        size=1024,
        checksum_type='md5',
        checksum='somecrap',
        path='/dev/null',
        org_id=1,
        channels=['solaris']
    )
]

solaris_patches = [
    mpmBinaryPackage().populate(
        header = {
            'arch': 'solaris-patch',
            'build_host': 'shaggy.rdu.redhat.com',
            'build_time': '2005-05-10 14:36:26',
            'conflicts': [],
            'cookie': None,
            'date': 1100062800.0,
            'description': None,
            'epoch': 0,
            'license': None,
            'name': 'patch-solaris-111713',
            'obsoletes': [],
            'package_group': 'Patches',
            'package_type': 'solaris',
            'packages': [{'arch': 'i386-solaris',
                          'name': 'SUNWlibC',
                          'epoch': '0',
                          'release': '2002.08.23',
                          'version': '5.9'}],
            'patch_order': 0,
            'patch_set': None,
            'patch_type': 1,
            'payload_format': None,
            'payload_size': None,
            'provides': [{'version': '09', 'flags': 0, 'name': 'patch-solaris-111713'}],
            'readme': 'Patch-ID# 111713-09',
            'release': 1,
            'requires': [],
            'rpm_version': None,
            'sigmd5': None,
            'sigsize': 0,
            'solaris_rel': '9_x86',
            'sourcerpm': None,
            'summary': 'Solaris Patch',
            'sunos_rel': '5.9_x86',
            'target_arch': 'i386',
            'vendor': 'Red Hat, Inc',
            'version': '09',
        },
        size=1024,
        checksum_type='md5',
        checksum='somecrap',
        path='/dev/null',
        org_id=1,
        channels=['solaris-patches']
    ),
    mpmBinaryPackage().populate(
        header = {
            'arch': 'solaris-patch',
            'build_host': 'shaggy.rdu.redhat.com',
            'build_time': '2005-05-10 14:36:26',
            'conflicts': [],
            'cookie': None,
            'date': 1110949200.0,
            'description': None,
            'epoch': 0,
            'license': None,
            'name': 'patch-solaris-112786',
            'obsoletes': [{'version': '02', 'flags': 10, 'name': '113763'}],
            'package_group': 'Patches',
            'package_type': 'solaris',
            'packages': [{'arch': 'i386-solaris',
                          'name': 'SUNWlibC',
                          'epoch': '0',
                          'release': '2002.08.23',
                          'version': '5.9'},
                         {'arch': 'i386-solaris',
                          'name': 'SUNWxwacx',
                          'epoch': '0',
                          'release': '0.2002.10.16',
                          'version': '6.6.1.6400'},
                         {'arch': 'i386-solaris',
                          'name': 'SUNWxwfnt',
                          'epoch': '0',
                          'release': '0.2002.10.16',
                          'version': '6.6.1.6400'},
                         {'arch': 'i386-solaris',
                          'name': 'SUNWxwinc',
                          'epoch': '0',
                          'release': '0.2002.10.16',
                          'version': '6.6.1.6400'},
                         {'arch': 'i386-solaris',
                          'name': 'SUNWxwman',
                          'epoch': '0',
                          'release': '0.2002.10.16',
                          'version': '6.6.1.6400'},
                         {'arch': 'i386-solaris',
                          'name': 'SUNWxwopt',
                          'epoch': '0',
                          'release': '0.2002.10.16',
                          'version': '6.6.1.6400'},
                         {'arch': 'i386-solaris',
                          'name': 'SUNWxwplt',
                          'epoch': '0',
                          'release': '0.2002.10.16',
                          'version': '6.6.1.6400'},
                         {'arch': 'i386-solaris',
                          'name': 'SUNWxwpmn',
                          'epoch': '0',
                          'release': '0.2002.10.16',
                          'version': '6.6.1.6400'},
                         {'arch': 'i386-solaris',
                          'name': 'SUNWxwslb',
                          'epoch': '0',
                          'release': '0.2002.10.16',
                          'version': '6.6.1.6400'},
                         {'arch': 'i386-solaris',
                          'name': 'SUNWxwsrv',
                          'epoch': '0',
                          'release': '0.2002.10.16',
                          'version': '6.6.1.6400'}],
            'patch_order': 0,
            'patch_set': None,
            'patch_type': 1,
            'payload_format': None,
            'payload_size': None,
            'provides': [{'version': '36', 'flags': 0, 'name': 'patch-solaris-112786'}],
            'readme': 'Patch-ID# 112786-36n',
            'release': 1,
            'requires': [{'version': '06', 'flags': 12, 'name': '113986'}],
            'rpm_version': None,
            'sigmd5': None,
            'sigsize': 0,
            'solaris_rel': '9_x86',
            'sourcerpm': None,
            'summary': 'Solaris Patch',
            'sunos_rel': '5.9_x86',
            'target_arch': 'i386',
            'vendor': 'Red Hat, Inc',
            'version': '36',
        },
        size=1024,
        checksum_type='md5',
        checksum='somemorecrap',
        path='/dev/null',
        org_id=1,
        channels=['solaris-patches']
    ),
]

solaris_patch_sets = [
    mpmBinaryPackage().populate(
        header = {
            'arch': 'solaris-patch-cluster',
            'build_host': 'shaggy.rdu.redhat.com',
            'build_time': '2005-05-10 14:36:26',
            'conflicts': [],
            'cookie': None,
            'date': 1111554000.0,
            'description': 'These Solaris Recommended patches are considered the most important and\nhighly recommended patches that avoid the most critical system, user, or\nsecurity related bugs which have been reported and fixed to date.',
            'epoch': 0,
            'license': None,
            'name': 'patch-cluster-solaris-J2SE_Solaris_9_x86_Recommended',
            'obsoletes': [],
            'package_group': 'Patch Clusters',
            'package_type': 'solaris',
            'patches': [{'version': '09', 'patch_order': 3, 'name': '111713'},
                        {'version': '36', 'patch_order': 2, 'name': '112786'},
                        {'version': '15', 'patch_order': 1, 'name': '113986'}],
            'payload_format': None,
            'payload_size': None,
            'provides': [{'flags': 0,
                          'name': 'patch-cluster-solaris-J2SE_Solaris_9_x86_Recommended',
                          'version': '20050323'}],
            'readme': '# CLUSTER_README',
            'release': 1,
            'requires': [],
            'rpm_version': None,
            'sigmd5': None,
            'sigsize': 0,
            'sourcerpm': None,
            'summary': 'J2SE Solaris 9_x86 Recommended Patch Cluster',
            'vendor': 'Red Hat, Inc',
            'version': '20050323',
        },
        size=1024,
        checksum_type='md5',
        checksum='somecrap',
        path='/dev/null',
        org_id=1,
        channels=['solaris']
    )
]

if __debug__: print "-" * 75

#rhnSQL.initDB("rhnuser/rhnuser@webdev")
rhnSQL.initDB("shughes1/shughes1@shughes1")

backend = OracleBackend()
backend.init()

pi = PackageImport(solaris_pkgs, backend, update_last_modified=1)
pi.setIgnoreUploaded(1)
pi.run()

# vim:sw=4:ts=4:et:mouse=a
