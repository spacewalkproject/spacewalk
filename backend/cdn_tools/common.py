# Copyright (c) 2016--2017 Red Hat, Inc.
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

from spacewalk.common import fileutils
import constants


def verify_mappings():
    args = ['rpm', '-q', constants.MAPPINGS_RPM_NAME]
    ret = fileutils.rhn_popen(args)
    # Package installed, exitcode is 0
    if not ret[0]:
        args = ['rpm', '-V', constants.MAPPINGS_RPM_NAME]
        ret = fileutils.rhn_popen(args)
        if ret[0]:
            raise CdnMappingsLoadError("CDN mappings changed on disk. Please re-install '%s' package."
                                       % constants.MAPPINGS_RPM_NAME)


# Up to terabytes, should be enough
def human_readable_size(file_size):
    for count in ['B', 'K', 'M', 'G']:
        if file_size < 1024.0:
            return "%3.1f%s" % (file_size, count)
        file_size /= 1024.0
    return "%3.1f%s" % (file_size, 'T')


class CdnMappingsLoadError(Exception):
    pass


class CustomChannelSyncError(Exception):
    pass


class CountingPackagesError(Exception):
    pass
