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
from spacewalk.common import rhnFlags
from spacewalk.server import rhnSQL
from spacewalk.server.action_extra_data import packages, kickstart, reboot

rhnSQL.initDB('rhnuser/rhnuser@webdev')
rhnFlags.set('action_id', 11921273)
rhnFlags.set('action_status', 2)

try:
    packages.update(1003485866, 11921273, {})
    kickstart.initiate(1003485866, 11921274, {})
    reboot.reboot(1003485866, 11921275, {})
except:
    rhnSQL.rollback()
    raise
rhnSQL.rollback()
