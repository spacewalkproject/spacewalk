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

symbols = [
    'F_RDLCK', 'F_WRLCK', 'F_UNLCK', 'F_SETLKW',
    'F_SETFD', 'F_GETFD',
]

import fcntl
if hasattr(fcntl, symbols[0]):
    module = fcntl
else:
    import FCNTL
    module = FCNTL
    del FCNTL
del fcntl

dict = globals()
for symbol in symbols:
    dict[symbol] = getattr(module, symbol)

del dict
del symbol
del symbols
del module
