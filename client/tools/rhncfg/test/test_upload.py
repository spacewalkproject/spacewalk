#!/usr/bin/python
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

from rhn import rpclib

#systemid_file = '/home/devel/misa/playpen/systemid-devel'
systemid_file = '/home/devel/misa/cvs/rhn/test/backend/checks/systemid-farm06'
server = "coyote.devel.redhat.com"
#server = "rhnxml.back-webdev.redhat.com"

s = rpclib.Server("http://%s/CONFIG-MANAGEMENT" % server)

files = [
    {
       'path'           : '/etc/motd',
       'file_contents'  : 'This system will not work today\nCause I like it so\n',
       'delim_start'    : '{|',
       'delim_end'      : '|}',
       'file_stat'      : {
            'size'  : 1234,
            'mode'  : int("0755", 8),
            'user'  : 'misa',
            'group' : 'misa',
       },
    },
    {
       'path'           : '/etc/voodoo',
       'file_contents'  : 'If you read this file, your computer will reboot',
       'delim_start'    : '{|',
       'delim_end'      : '|}',
       'file_stat'      : {
            'size'  : 1234,
            'mode'  : int("0755", 8),
            'user'  : 'misa',
            'group' : 'misa',
       },
    },
]


systemid = open(systemid_file).read()

s.config.client.upload_files(systemid, 11921200, files)
