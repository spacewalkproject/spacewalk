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

import os
import fnmatch

from actions import configfiles
from config_common import local_config, rhn_log

local_config.init("rhncfg")
rhn_log.set_debug_level(local_config.get('debug'))

def test(msg, test):
    ok_str = 'NOT OK'
    if test:
        ok_str = 'ok'

    print("%s: %s" % (msg, ok_str))

def stray_files(path):
    (directory, filename) = os.path.split(path)
    for path in os.listdir(directory):
        if fnmatch.fnmatch(path, "%s*" % filename):
            return 1
    return 0

files = { 'files' : [
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
    ]}

try:
    for file in files['files']:
        os.unlink(file['path'])

except OSError:
    pass

test("testing a clean new deployment",
     configfiles.deploy(files)[0] == 0)


file = files['files'][0]['path']
os.system("chattr +i %s" % file)
test("testing deployment over read-only file (no files deployed, remove backups)",
     configfiles.deploy(files)[0] == 43)
os.system("chattr -i %s" % file)


test("testing redeployment w/ backups",
     configfiles.deploy(files)[0] == 0)


file = files['files'][1]['path']
os.system("chattr +i %s" % file)
test("testing deployment over read-only file (partial deployment, restore from then remove backups)",
     configfiles.deploy(files)[0] == 43 and os.path.exists(file))
os.system("chattr -i %s" % file)


test("testing redeployment w/ backups (again)",
     configfiles.deploy(files)[0] == 0)

