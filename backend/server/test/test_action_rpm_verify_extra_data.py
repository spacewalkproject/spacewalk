#
# Copyright (c) 2008--2016 Red Hat, Inc.
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

if len(sys.argv) != 3:
    print("Usage: %s server_id action_id" % sys.argv[0])
    sys.exit(1)

system_id = sys.argv[1]
action_id = sys.argv[2]

from spacewalk.common.rhnLog import initLOG
from spacewalk.server import rhnSQL

from spacewalk.server.action_extra_data import packages

initLOG("stderr", 4)
rhnSQL.initDB("rhnuser/rhnuser@webdev")

try:
    packages.verify(system_id, action_id, {
        'verify_info': [
            [['up2date', '2.9.1', '1.2.1AS', '', 'i386'], [
                'SM5..UGT c /etc/sysconfig/rhn/up2date',
                '..?..... c /etc/sysconfig/rhn/up2date-keyring.gpg',
                'S.5....T   /usr/share/rhn/up2date_client/bootloadercfg.pyc',
                'S.5....T   /usr/share/rhn/up2date_client/capabilities.pyc',
                'S.5....T   /usr/share/rhn/up2date_client/checkbootloader.pyc',
                'S.5....T   /usr/share/rhn/up2date_client/clap.pyc',
                'S.5....T   /usr/share/rhn/up2date_client/clientCaps.pyc',
                'SM5....T   /usr/share/rhn/up2date_client/config.pyc',
                'S.5....T   /usr/share/rhn/up2date_client/depSolver.pyc',
                'S.5....T   /usr/share/rhn/up2date_client/getMethod.pyc',
                'S.5....T   /usr/share/rhn/up2date_client/gpgUtils.pyc',
                'S.5....T   /usr/share/rhn/up2date_client/hardware.pyc',
                'S.5....T   /usr/share/rhn/up2date_client/headers.pyc',
                'S.5....T   /usr/share/rhn/up2date_client/iutil.pyc',
                'S.5....T   /usr/share/rhn/up2date_client/lilo.pyc',
                'S.5....T   /usr/share/rhn/up2date_client/newelilocfg.pyc',
                'S.5....T   /usr/share/rhn/up2date_client/newgrubcfg.pyc',
                'S.5....T   /usr/share/rhn/up2date_client/newlilocfg.pyc',
                'S.5....T   /usr/share/rhn/up2date_client/packageList.pyc',
                'S.5....T   /usr/share/rhn/up2date_client/rhnChannel.pyc',
                'S.5....T   /usr/share/rhn/up2date_client/rhnDefines.pyc',
                'S.5....T   /usr/share/rhn/up2date_client/rhnErrata.pyc',
                'S.5....T   /usr/share/rhn/up2date_client/rhnHardware.pyc',
                'S.5....T   /usr/share/rhn/up2date_client/rhnPackageInfo.pyc',
                'S.5....T   /usr/share/rhn/up2date_client/rpcServer.pyc',
                'S.5....T   /usr/share/rhn/up2date_client/rpmSource.pyc',
                'S.5....T   /usr/share/rhn/up2date_client/rpmUtils.pyc',
                'S.5....T   /usr/share/rhn/up2date_client/translate.pyc',
                'S.5....T   /usr/share/rhn/up2date_client/up2date.pyc',
                'S.5....T   /usr/share/rhn/up2date_client/up2dateAuth.pyc',
                'S.5....T   /usr/share/rhn/up2date_client/up2dateBatch.pyc',
                'S.5....T   /usr/share/rhn/up2date_client/up2dateErrors.pyc',
                'S.5....T   /usr/share/rhn/up2date_client/up2dateLog.pyc',
                'S.5....T   /usr/share/rhn/up2date_client/up2dateMessages.pyc',
                'S.5....T   /usr/share/rhn/up2date_client/up2dateUtils.pyc',
                'S.5....T   /usr/share/rhn/up2date_client/wrapper.pyc',
                'S.5.X..T   /usr/share/rhn/up2date_client/wrapperUtils.pyc',
                '.....UG.   /var/spool/up2date',
                '.....UG.   /var/spool/up2date',
            ]],
        ],
    })
except:
    rhnSQL.rollback()
    raise

rhnSQL.commit()
