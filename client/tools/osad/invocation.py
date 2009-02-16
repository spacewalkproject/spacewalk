#!/usr/bin/python
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

import os
import sys
import string

_path = "@@ROOT@@"
if _path not in sys.path:
    sys.path.append(_path)

mod_name = os.path.basename(sys.argv[0])
mod_name = string.replace(mod_name, '-', '_')
try:
    mod = __import__("osad." + mod_name)
except ImportError, e:
    sys.stderr.write("Unable to load module %s\n" % mod_name)
    sys.stderr.write(str(e) + "\n")
    sys.exit(1)
mod = getattr(mod, mod_name)

if __name__ == '__main__':
    try:
        sys.exit(mod.main() or 0)
    except KeyboardInterrupt, e:
        sys.stderr.write("\nUser interrupted process.\n")
        sys.exit(0)
    except SystemExit, e:
        sys.exit(e.code)
    except Exception, e:
        sys.stderr.write("\nERROR: unhandled exception occurred: (%s).\n" % e)
        sys.exit(-1)

