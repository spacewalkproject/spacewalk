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
#
# Copy files
#

from kickstart import kickstart

if __name__ == '__main__':
    c = kickstart.FileCopier(["/etc/passwd", "/etc/shadow",
        "/etc/sysconfig", "/a/b", "/etc/rc", "/dev/null", "/etc/rmt",
        "/etc/tnsnames.ora", ],
        "/tmp/googah",
        quota=1000000)
    c.copy()
