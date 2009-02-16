#!/usr/bin/python
# Copyright (c) 2005, Red Hat Inc.
#
# This module makes FCNTL obsolete in the RHN codebase
#
# $Id: rhn_fcntl.py 70876 2005-06-30 02:03:38Z wregglej $

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
