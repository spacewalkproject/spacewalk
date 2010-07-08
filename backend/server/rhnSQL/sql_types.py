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
#
# Database types we support for out variables
#
# $Id$

# Data types
class DatabaseDataType:
    type_name = None
    def __init__(self, value=None, size=None):
        self.size = size or 1
        self.set_value(value)
    
    def get_value(self):
        return self.value

    def set_value(self, value):
        self.value = value

    def __str__(self):
        return self.type_name


class NUMBER(DatabaseDataType):
    type_name = "NUMBER"

class STRING(DatabaseDataType):
    type_name = "STRING"
    def __init__(self, value=None, size=None):
        DatabaseDataType.__init__(self, value=value, size=size)
        if not size:
            self.size = 4000

class BINARY(DatabaseDataType):
    type_name = "BINARY"

class LONG_BINARY(DatabaseDataType):
    type_name = "LONG_BINARY"

# XXX More data types to be added as we find need for them

