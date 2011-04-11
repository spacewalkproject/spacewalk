#
# Copyright (c) 2008--2011 Red Hat, Inc.
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

import rhn_rpm
import rhn_mpm
import rhn_deb

def rhn_pkg(filename=None, file=None, fd=None):
    if filename:
        if filename.endswith('.deb'):
            return rhn_deb
        elif filename.endswith('.rpm'):
            return rhn_rpm
        else:
            return rhn_mpm
    # XXX recognize backend also by file/fd
    return rhn_rpm

def get_package_header(filename=None, file=None, fd=None):
    return rhn_pkg(filename=filename, file=file, fd=fd) \
        .get_package_header(filename=filename, file=file, fd=fd)
