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

from actions import configfiles

print(configfiles.diff([
    {
        'path'          : "/etc/googah",
        'namespace'     : "foo1",
        'file_contents' : "This is 1 and this is 2\nAnd this is 3",
        'md5sum'        : "0abcabcabcabc",
        'delim_start'   : "[|",
        'delim_end'     : "|]",
    },
    {
        'path'          : "/var/tmp/ggg",
        'namespace'     : "foo1",
        'file_contents' : "That is 1 and this is 2\nAnd this is 3",
        'md5sum'        : "0abcabcabcabc",
        'delim_start'   : "[|",
        'delim_end'     : "|]",
    },
    {
        'path'          : "/etc/issue",
        'namespace'     : "foo1",
        'file_contents' : "Red Hat Linux release 7.3 Evaluation (Valhalla)\nKernel \\r on an \\m",
        'md5sum'        : "0abcabcabcabc",
        'delim_start'   : "[|",
        'delim_end'     : "|]",
    },
]))
