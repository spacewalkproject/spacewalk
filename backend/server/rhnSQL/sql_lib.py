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

# Check for a package spec correctness
# Each package should be a list or a tuple of three or four members,
# name, version, release, [epoch]
# in case of lack of epoch we assume "" string
# WARNING: we need to make sure we bound ALL values as strings because
# the lack of epoch is suggested by the empty string (''), which is going
# to cause problems if epoch gets bound as an integer
def check_package_spec(package):
    # This one checks for sane values for name, version, release
    def __check_Int_String(name, value, package = package):
        if type(value) not in  (StringType, IntType):
            log_error("Field %s (%s) = `%s' in %s does not pass type checks" % (
                name, type(value), str(value), str(package)))
            raise rhnFault(30, _("Invalid value for %s in package tuple: %s (%s)") % 
                           (name, value, type(value)))
        value = str(value)
        if not len(value):
            log_error("Field %s has an EMPTY value in %s" % (value, package))
        return value

    log_debug(4, package)
    # Checks if package is a proper package spec
    if type(package) not in (ListType, TupleType) or len(package) < 3:
        log_error("Package argument %s (len = %d) does not pass type checks" % (
            str(package), len(package)))
        raise rhnFault(30, _("Invalid package parameter %s (%s)") % 
                       (package, type(package)))
    name, version, release = package[0], package[1], package[2]
    # figure out the epoch
    if len(package) > 3:
        epoch = package[3]
        if epoch in ["(none)", "None", None]:
            epoch = ""
        epoch = str(epoch)
    else:
        epoch = ""
    # impose some validity checks on name, version, release
    name = __check_Int_String("name", name)
    version = __check_Int_String("version", version)
    release = __check_Int_String("release", release)
    # Fix up for safety
    return [name, version, release, epoch]

