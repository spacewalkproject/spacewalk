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

import os
from config_common import file_utils

filepath, fd = file_utils.maketemp("/tmp/my-file-", mode=int("0700", 8))

buf = "0123456789" * 100

print("Writing", len(buf), "to", filepath)
os.write(fd, buf)
assert(len(buf) == f.tell())

os.close(fd)
os.unlink(filepath)


filepath, fd = file_utils.maketemp()
os.close(fd)
os.unlink(filepath)
