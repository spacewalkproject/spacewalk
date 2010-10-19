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
from spacewalk.server import rhnSQL
from spacewalk.common import rhnLog
from spacewalk.server.action_extra_data import solarispkgs

if __name__ == '__main__':
    rhnSQL.initDB('satdev/satdev@citisat')
    rhnLog.initLOG(log_file="stderr", level=5)

    solarispkgs.install(1000010033, 69, {
        'name'      : 'XXX',
        'version'   : 0,
        'status'    : [
            [['SMCsudo', '1.6.7p5', '0', 'sparc-solaris',], 
                [1, "", ""]],
            [['SFWungif', '4.1.0', '2001.05.21.04.41', 'sparc-solaris',], 
                [1, "out1", "error1"]],
            [['SMCtracer', '1.4a12', '0', 'sparc-solaris',], 
                [1, "out1", "error1"]],
            [['SMCrcs', '5.7', '0', 'sparc-solaris',],
                [2, "out2", "error2"]],
            [['SMCngrep', '1.40.1', '0', 'sparc-solaris',],
                [3, "out3", "error3"]],
            [['SMCwuftpd', '2.6.2', '0', 'sparc-solaris',],
                [4, "out4", "error4"]],
            [['GNUwget', '1.8', '0', 'sparc-solaris',],
                [5, "out5", "error5"]],
            [['SMCrecode', '3.6', '0', 'sparc-solaris',],
                [6, "out6", "error6"]],
            [['SMCzip', '2.3', '0', 'sparc-solaris',],
                [7, "out7", "error7"]],
            [['SMCman2h', '3.0.1', '0', 'sparc-solaris',],
                [8, "out8", "error8"]],
            [['nocpulsed', '2.3', '0', 'sparc-solaris',],
                [9, "out9", "error9"]],
            [['SMCmake', '3.80', '0', 'sparc-solaris',],
                [1, "out1", "error1"]],
            [['SMCwget', '1.9.1', '0', 'sparc-solaris',],
                [2, "out2", "error2"]],
            [['SMCpine', '4.10', '0', 'sparc-solaris',],
                [3, "out3", "error3"]],
            [['SMCzoo', '2.10', '0', 'sparc-solaris',],
                [4, "out4", "error4"]],
        ]
    })
    rhnSQL.commit()

