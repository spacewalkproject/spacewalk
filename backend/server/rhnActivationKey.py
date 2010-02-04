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
#
# $Id$

import os
import hashlib
import time
import types

from server import rhnSQL

class InvalidTokenError(Exception):
    pass

class InvalidChannelError(Exception):
    pass

class InvalidEntitlementError(Exception):
    pass

class ActivationKey:
    def __init__(self):
        self._row_reg_token = None
        self._row_activ_key = None
        
        self._server_groups = {}
        self._channels = {}
        self._token = None

    def load(self, token):
        t = rhnSQL.Table('rhnActivationKey', 'token')
        row = t[token]
        if not row:
            raise InvalidTokenError(token)
        self._row_activ_key = row
        reg_token_id = row['reg_token_id']
        t = rhnSQL.Table('rhnRegToken', 'id')
        row = t[reg_token_id]
        if not row:
            raise Exception("Invalid data in DB: missing foreign key")
        self._row_reg_token = row
        self._server_groups = self._load_server_groups()
        self._channels = self._load_channels()

    _query_fetch_server_groups = rhnSQL.Statement("""
        select rtsg.server_group_id
          from rhnRegTokenGroups rtsg
         where rtsg.token_id = :token_id
    """)
    def _load_server_groups(self):
        # Get groups
        h = rhnSQL.prepare(self._query_fetch_server_groups)
        reg_token_id = self._row_reg_token['id']
        h.execute(token_id=reg_token_id)
        ret = {}
        while 1:
            row = h.fetchone_dict()
            if not row:
                break
            server_group_id = row['server_group_id']
            ret[server_group_id] = None
        return ret

    _query_fetch_channels = rhnSQL.Statement("""
        select rtc.channel_id, c.label
          from rhnRegTokenChannels rtc, rhnChannel c
         where rtc.token_id = :token_id
           and rtc.channel_id = c.id
    """)
    def _load_channels(self):
        # Get groups
        h = rhnSQL.prepare(self._query_fetch_channels)
        reg_token_id = self._row_reg_token['id']
        h.execute(token_id=reg_token_id)
        ret = {}
        while 1:
            row = h.fetchone_dict()
            if not row:
                break
            channel_id = row['channel_id']
            ret[channel_id] = row['label']
        return ret

    # Setters
    
    def set_entitlement_level(self, val):
        entitlements = {}
        for k, v in val.items():
            entitlement_level_id = self._lookup_entitlement_level(k)
            entitlements[entitlement_level_id] = k

        self._set('entitlement_level', entitlements)

    def set_server_groups(self, groups):
        assert(isinstance(groups, types.ListType))

        ret = {}
        for g in groups:
            ret[g] = None

        self._server_groups.clear()
        self._server_groups.update(ret)

    def set_channels(self, channels):
        assert(isinstance(channels, types.ListType))

        t = rhnSQL.Table('rhnChannel', 'label')

        ret = {}
        for ch in channels:
            row = t[ch]
            if not row:
                raise InvalidChannelError(ch)
            ret[row['id']] = None

        self._channels.clear()
        self._channels.update(ret)

    def _set(self, name, val):
        if self._row_reg_token is None:
            self._row_reg_token = rhnSQL.Row('rhnRegToken', 'id')
            token_id = rhnSQL.Sequence('rhn_reg_token_seq').next()
            self._row_reg_token.create(token_id)
            self._row_reg_token['usage_limit'] = None

        self._row_reg_token[name] = val

    # Getters
    
    _query_get_reg_token_entitlements = rhnSQL.Statement("""
        select sgt.label
          from rhnServerGroupType sgt,
               rhnRegTokenEntitlement rte
         where rte.reg_token_id = :reg_token_id
           and rte.server_group_type_id = sgt.id
    """)
    def get_entitlement_level(self):
        reg_token_id = self._row_reg_token['id']
        h = rhnSQL.prepare(self._query_get_reg_token_entitlements)
        h.execute(reg_token_id=reg_token_id)

        ret = {}
        while 1:
            row = h.fetchone_dict()
            if not row:
                break
            ret[row['label']] = None
        return ret

    def get_server_groups(self):
        return self._server_groups.keys()

    def get_channels(self):
        return self._channels.values()

    def get_token(self):
        return self._token

    def _get(self, name):
        return self._row_reg_token[name]

    # Fix various things

    def _lookup_entitlement_level(self, entitlement_level):
        t = rhnSQL.Table('rhnServerGroupType', 'label')
        row = t[entitlement_level]
        if not row:
            raise InvalidEntitlementError(entitlement_level)
        return row['id']
        

    def generate_token(self):
        s = hashlib.new('sha1')
        s.update(str(os.getpid()))
        for field in ['org_id', 'user_id', 'server_id']:
            if self._row_reg_token.has_key(field):
                val = self._row_reg_token[field]
            s.update(str(val))
        s.update("%.8f" % time.time())
        self._token = s.hexdigest()
        return self._token

    def save(self):
        if self._token is None:
            self.generate_token()

        try:
            return self._save()
        except:
            rhnSQL.rollback()
            raise

    def _save(self):
        h = self._row_reg_token
        k = 'entitlement_level'
        if h.has_key(k):
            entitlements = h[k]
            del h.data[k]
        else:
            entitlements = {}

        self._row_reg_token.save()

        if not self._row_activ_key:
            self._row_activ_key = rhnSQL.Row('rhnActivationKey', 'token')
            self._row_activ_key.create(self._token)
            self._row_activ_key['reg_token_id'] = self._row_reg_token['id']
            self._row_activ_key.save()

        self._store_server_groups()
        self._store_channels()

        self._store_entitlements(entitlements)

    _query_delete_reg_token_entitlements = rhnSQL.Statement("""
        delete from rhnRegTokenEntitlement
         where reg_token_id = :reg_token_id
    """)
    _query_insert_reg_token_entitlements = rhnSQL.Statement("""
        insert into rhnRegTokenEntitlement
               (reg_token_id, server_group_type_id)
        values (:reg_token_id, :server_group_type_id)
    """)
    def _store_entitlements(self, entitlements):
        # entitlements: hash keyed on the entitlement id
        if not entitlements:
            return
        entitlements = entitlements.keys()

        reg_token_id = self._row_reg_token['id']
        reg_token_ids = [ reg_token_id ] * len(entitlements)

        h = rhnSQL.prepare(self._query_delete_reg_token_entitlements)
        h.execute(reg_token_id=reg_token_id)

        h = rhnSQL.prepare(self._query_insert_reg_token_entitlements)
        h.executemany(reg_token_id=reg_token_ids, 
            server_group_type_id=entitlements)

    _query_delete_groups = rhnSQL.Statement("""
        delete from rhnRegTokenGroups
         where token_id = :token_id
           and server_group_id = :server_group_id
    """)
    _query_insert_groups = rhnSQL.Statement("""
        insert into rhnRegTokenGroups (token_id, server_group_id)
        values (:token_id, :server_group_id)
    """)

    def _store_server_groups(self):
        db_server_groups = self._load_server_groups()
        token_id = self._row_reg_token['id']

        inserts, deletes = self._diff_hashes(db_server_groups,
            self._server_groups)

        if deletes:
            token_ids = [ token_id ] * len(deletes)
            h = rhnSQL.prepare(self._query_delete_groups)
            h.executemany(token_id=token_ids, server_group_id=deletes)
        if inserts:
            token_ids = [ token_id ] * len(inserts)
            h = rhnSQL.prepare(self._query_insert_groups)
            h.executemany(token_id=token_ids, server_group_id=inserts)

    _query_delete_channels = rhnSQL.Statement("""
        delete from rhnRegTokenChannels
         where token_id = :token_id
           and channel_id = :channel_id
    """)
    _query_insert_channels = rhnSQL.Statement("""
        insert into rhnRegTokenChannels(token_id, channel_id)
        values (:token_id, :channel_id)
    """)
    def _store_channels(self):
        db_channels = self._load_channels()
        token_id = self._row_reg_token['id']

        inserts, deletes = self._diff_hashes(db_channels, 
            self._channels)

        if deletes:
            token_ids = [ token_id ] * len(deletes)
            h = rhnSQL.prepare(self._query_delete_channels)
            h.executemany(token_id=token_ids, channel_id=deletes)
        if inserts:
            token_ids = [ token_id ] * len(inserts)
            h = rhnSQL.prepare(self._query_insert_channels)
            h.executemany(token_id=token_ids, channel_id=inserts)
    
    def _diff_hashes(self, h1, h2):
        "diffs src and dst; returns a list of (inserts, deletes)"
        inserts = []
        h1 = h1.copy()
        for k in h2.keys():
            if not h1.has_key(k):
                inserts.append(k)
                continue
            del h1[k]
        deletes = h1.keys()
        return inserts, deletes

    def __getattr__(self, name):
        if startswith(name, 'get_'):
            return CallableObj(name[4:], self._get)
        if startswith(name, 'set_'):
            return CallableObj(name[4:], self._set)
        raise AttributeError(name)


def startswith(s, prefix):
    return s[:len(prefix)] == prefix


class CallableObj:
    def __init__(self, name, func):
        self.func = func
        self.name = name

    def __call__(self, *args, **kwargs):
        return apply(self.func, (self.name, ) + args, kwargs)
