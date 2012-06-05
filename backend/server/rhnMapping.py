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

from spacewalk.server import rhnSQL

# checks if an arch is for real
def check_package_arch(name):
    name = str(name)
    if name is None or len(name) == 0:
        return None
    h = rhnSQL.prepare("select id from rhnPackageArch where label = :label")
    h.execute(label=name)
    ret = h.fetchone_dict()
    if not ret:
        return None
    return name

if __name__ == '__main__':
    """Test code.
    """
    rhnSQL.initDB()
    print check_package_arch('i386')

