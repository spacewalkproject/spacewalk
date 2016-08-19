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
# A collection of classes and functions for handy data manipulation
# This file includes common classes and functions that are used by
# misc parts of the RHN backend
#
# Before changing any of this stuff, please grep through the sources to
# check how the function/class you are about to modify is used first.
# Or ask gafton.
#

import string


def build_sql_insert(table, hash_name, items):
    """ This statement builds a sql statement for an insert
        of 'items' into "table" indexed by "hash_name"
    """
    sql = "insert into %s ( %s, %s ) values ( :p0, %s )" % (
        table, hash_name,
        string.join([a[0] for a in items], ", "),
        string.join([":p_%s" % a[0] for a in items], ", "))
    pdict = {"p0": None}  # This must be reset after we return from this call
    list(map(pdict.update, [{"p_%s" % a[0]: a[1]} for a in items]))
    return sql, pdict


def build_sql_update(table, hash_name, items):
    """ This statement builds a sql statement for an update
        of 'items' into "table" indexed by "hash_name"
    """
    sql = "update %s set %s where %s = :p0" % (
        table,
        string.join(["%s = :p_%s" % (a, a) for a in [a[0] for a in items]],
                    ", "),
        hash_name)
    pdict = {"p0": None}  # This must be reset after we return from this call
    list(map(pdict.update, [{"p_%s" % a[0]: a[1]} for a in items]))
    return sql, pdict
