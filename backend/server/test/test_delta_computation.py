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
from spacewalk.server.rhnServer import server_packages

unzip1 = ('unzip',    '1.1', '2', '')
unzip2 = ('unzip',    '1.2', '1', '')

abiword1 = ('abiword',  '1.0', '2', '1')
abiword2 = ('abiword',  '2.0', '1', '')

kernel1 = ('kernel',   '2.4', '1', '')
kernel2 = ('kernel',   '2.4', '2', '1')
kernel3 = ('kernel',   '2.4', '3', '1')

aalib1 = ('aalib',    '1.0', '1', '')
aalib2 = ('aalib',    '1.1', '2', '')

quota = ('quota',    '1.2', '3', '1')

rpm = ('rpm',      '4.1', '1', '')

perl1 = ('perl',     '1.1', '1', '')
perl2 = ('perl',     '1.01', '1', '')

list1 = [
    abiword2,
    abiword1,
    kernel2,
    kernel1,
    aalib2,
    quota,
    rpm,
    perl1,
]

list2 = [
    unzip1,
    unzip2,
    kernel3,
    aalib1,
    rpm,
    perl2,
]

i, r = server_packages.package_delta(list1, list2)
print("Install set:  ", i)
print("Remove set:   ", r)

assert i == [aalib1, kernel3, unzip1, unzip2], "Invalid install set %s" % i
assert r == [aalib2, abiword1, abiword2, kernel1, kernel2, quota], "Invalid remove set %s" % r

print("All assertions passed")
