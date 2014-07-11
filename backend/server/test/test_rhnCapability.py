#
# Copyright (c) 2008--2013 Red Hat, Inc.
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
import rhnSQL
from rhnCapability import set_client_capabilities, update_client_capabilities

if __name__ == '__main__':
    rhnSQL.initDB('rhnuser/rhnuser@webdev')

    set_client_capabilities([
        "caneatCheese(1)=1", "caneatMeat(22)=3", "a(3)=4", "b(3)=5",
    ])
    update_client_capabilities(1000102174)
