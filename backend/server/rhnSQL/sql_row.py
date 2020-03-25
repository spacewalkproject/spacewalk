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
# a class used to handle a row of data in a particular table
#

import string

from rhn.UserDictCase import UserDictCase
from spacewalk.common.rhnException import rhnException

from . import sql_base
from . import sql_lib


class Row(UserDictCase):

    """ This class allows one to work with the columns of a particular row in a more
        convenient manner (ie, using a disctionary interface). It allows for the row
        data to be loaded and saved and is generally easier to use than the Table
        class which is really designed for bulk updates and stuff like that.

        The easiest way to separate what these things are for is to remember that
        the Table class indexes by KEY, while the Row class indexes by column
    """

    def __init__(self, db, table, hashname, hashval=None):
        UserDictCase.__init__(self)
        if not isinstance(db, sql_base.Database):
            raise rhnException("Argument db is not a database instance", db)
        self.db = db
        self.table = table
        self.hashname = string.lower(hashname)

        # and the data dictionary
        self.data = {}
        # is this a real entry (ie, use insert or update)
        self.real = 0
        if hashval is not None:  # if we have to load an entry already...
            self.load(hashval)

    def __repr__(self):
        return "<%s instance at 0x%0x on (%s, %s, %s)>" % (
            self.__class__.__name__, abs(id(self)),
            self.table, self.hashname, self.get(self.hashname))
    __str__ = __repr__

    def __setitem__(self, name, value):
        """ make it work like a dictionary """
        x = string.lower(name)
        # forbid setting the value of the hash column because of the
        # ambiguity of the operation (is it a "save as new id" or
        # "load from new id"?). We provide interfaces for load, save
        # and create instead.
        if x == self.hashname:
            raise AttributeError("Can not reset the value of the hash key")
        if x not in self.data or self.data[x][0] != value:
            self.data[x] = (value, 1)

    def __getitem__(self, name):
        x = string.lower(name)
        if x in self.data:
            return self.data[x][0]
        raise KeyError("Key %s not found in the Row dictionary" % name)

    def get(self, name):
        x = string.lower(name)
        if x in self.data:
            return self.data[x][0]
        return None

    def reset(self, val=0):
        """ reset the changed status for these entries """
        for k, v in list(self.data.items()):
            # tuples do not support item assignement
            self.data[k] = (v[0], val)

    def create(self, hashval):
        """ create it as a new entry """
        self.data[self.hashname] = (hashval, 0)
        self.real = 0
        self.save()

    def load(self, hashval):
        """ load an entry """
        return self.load_sql("%s = :hashval" % self.hashname, {'hashval': hashval})

    def load_sql(self, sql, pdict={}):
        """ load from a sql clause """
        h = self.db.prepare("select * from %s where %s" % (self.table, sql))
        h.execute(**pdict)
        ret = h.fetchone_dict()
        self.data = {}
        if not ret:
            self.real = 0
            return 0
        for k, v in list(ret.items()):
            self.data[k] = (v, 0)
        self.real = 1
        return 1

    def save(self, with_updates=1):
        """ now save an entry """
        if self.hashname not in self.data:
            raise AttributeError("Table does not have a hash `%s' key" % self.hashname)
        # get a list of fields to be set
        items = [(a[0], a[1][0]) for a in [b for b in list(self.data.items()) if b[1][1] == 1]]
        if not items:  # if there is nothing for us to do, avoid doing it.
            return
        # and now build the SQL statements
        if self.real:  # Update
            if not with_updates:
                raise sql_base.ModifiedRowError()
            sql, pdict = sql_lib.build_sql_update(self.table, self.hashname, items)
        else:
            sql, pdict = sql_lib.build_sql_insert(self.table, self.hashname, items)
        h = self.db.prepare(sql)
        pdict["p0"] = self.data[self.hashname][0]
        # and now do it
        h.execute(**pdict)
        self.real = 1
        return
