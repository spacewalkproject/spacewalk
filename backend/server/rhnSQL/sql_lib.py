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
# A collection of classes and functions for handy data manipulation
# This file includes common classes and functions that are used by
# misc parts of the RHN backend
#
# Before changing any of this stuff, please grep through the sources to
# check how the function/class you are about to modify is used first.
# Or ask gafton.
#
# $Id$

import string
from types import IntType, ListType, TupleType, StringType

from common import rhnFault, log_error, log_debug
from common.rhnTranslate import _

################
## FUNCTIONS
################
    
# build a list of :pN arguments and a dictionary for complex SQL selects
def build_sql_args(l):
    args = map(lambda a: "p%d" % a, range(len(l)))
    ret_dict = {}
    ret_str = string.join(map(lambda a: ":%s" % a, args), ", ")
    map(ret_dict.update, map(lambda a, b: { a: b }, args, l))
    return ret_str, ret_dict

# This statement builds a sql statement for an insert
# of 'items' into "table" indexed by "hash_name"
def build_sql_insert(table, hash_name, items):
    sql = "insert into %s ( %s, %s ) values ( :p0, %s )" % (
        table, hash_name,
        string.join(map(lambda a: a[0], items), ", "),
        string.join(map(lambda a: ":p_%s" % a[0], items), ", "))
    pdict = { "p0" : None } # This must be reset after we return from this call
    map(pdict.update, map(lambda a : { "p_%s" % a[0] : a[1] }, items))
    return sql, pdict

# This statement builds a sql statement for an update
# of 'items' into "table" indexed by "hash_name"
def build_sql_update(table, hash_name, items):
    sql = "update %s set %s where %s = :p0" % (
        table,
        string.join(map(lambda a: "%s = :p_%s" % (a, a),
                        map(lambda a: a[0], items)),
                    ", "),
        hash_name)
    pdict = { "p0" : None } # This must be reset after we return from this call
    map(pdict.update, map(lambda a : { "p_%s" % a[0] : a[1] }, items))
    return sql, pdict

