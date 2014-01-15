#!/usr/bin/python
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


import types

from spacewalk.server import rhnSQL, rhnUser

class InvalidUserError(Exception):
    pass

class InvalidOrgError(Exception):
    pass

class InvalidServerGroupError(Exception):
    pass

class ServerGroup:
    def __init__(self):
        self._row_server_group = None

    _query_lookup = rhnSQL.Statement("""
        select id
          from rhnServerGroup
         where org_id = :org_id
           and name = :name
    """)
    def load(self, org_id, name):
        org_id = self._lookup_org_id(org_id)
        h = rhnSQL.prepare(self._query_lookup)
        h.execute(org_id=org_id, name=name)
        row = h.fetchone_dict()
        if not row:
            raise InvalidServerGroupError(org_id, name)
        server_group_id = row['id']
        self._row_server_group = rhnSQL.Row("rhnServerGroup", 'id')
        self._row_server_group.load(server_group_id)

    # Setters

    def set_org_id(self, org_id):
        self._set('org_id', self._lookup_org_id(org_id))

    def _set(self, name, val):
        if self._row_server_group is None:
            self._row_server_group = rhnSQL.Row('rhnServerGroup', 'id')
            server_group_id = rhnSQL.Sequence('rhn_server_group_id_seq').next()
            self._row_server_group.create(server_group_id)

        self._row_server_group[name] = val

    # Getters

    def _get(self, name):
        return self._row_server_group[name]

    def _lookup_org_id(self, org_id):
        if isinstance(org_id, types.StringType):
            # Is it a user?
            u = rhnUser.search(org_id)

            if not u:
                raise InvalidUserError(org_id)

            return u.contact['org_id']

        t = rhnSQL.Table('web_customer', 'id')
        row = t[org_id]
        if not row:
            raise InvalidOrgError(org_id)
        return row['id']

    def save(self):
        if not self._row_server_group:
            return
        self._row_server_group.save()

    def __getattr__(self, name):
        if name.startswith('get_'):
            return CallableObj(name[4:], self._get)
        if name.startswith('set_'):
            return CallableObj(name[4:], self._set)
        raise AttributeError(name)

class CallableObj:
    def __init__(self, name, func):
        self.func = func
        self.name = name

    def __call__(self, *args, **kwargs):
        return apply(self.func, (self.name, ) + args, kwargs)

def create_new_org(username, password):
    f = rhnSQL.Procedure('create_new_org')

    username = rhnSQL.types.STRING(username)
    password = rhnSQL.types.STRING(password)
    ncl      = rhnSQL.types.NUMBER

    ret = f(username, password, ncl())
    return int(ret[2])
