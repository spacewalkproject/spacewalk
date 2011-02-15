#
# Copyright (c) 2008--2010 Red Hat, Inc.
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
from spacewalk.common import rhnCache

key = "/var/goo/goo"

data = "0123456789" * 1024 * 1024

rhnCache.set(key, data, compressed=1, raw=1)
assert data == rhnCache.get(key, compressed=1, raw=1)

rhnCache.set(key, "12345", raw=1)
# Should return None, opening uncompressed data as compressed
assert None == rhnCache.get(key, compressed=1, raw=1)

# Should return None, opening raw data as pickled
assert None == rhnCache.get(key, raw=0)
