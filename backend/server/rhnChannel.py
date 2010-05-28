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
import time
import string
import rpm
from rhn.rpclib import xmlrpclib

from types import IntType, ListType, DictType

# common module
from common import log_debug, log_error, rhnFault, rhnException, rhnCache, rhnFlags, CFG
from common.rhnTranslate import _
from spacewalk.common import rhn_rpm
from rhnServer import server_lib
from rhnDependency import MakeEvrError

# local module
import rhnUser, rhnSQL, rhnLib
from connectors import rhnChannelConnector

class NoBaseChannelError(Exception):
    pass

class InvalidServerArchError(Exception):
    pass

class BaseChannelDeniedError(Exception):
    pass

class ChannelException(Exception):
    def __init__(self, channel_id=None, *args, **kwargs):
        apply(Exception.__init__, (self, ) + args, kwargs)
        self.channel_id = channel_id
        self.channel = None

class SubscriptionCountExceeded(ChannelException):
    pass

class ModifiedError(ChannelException):
    pass

class IncompatibilityError(Exception):
    pass

class InvalidEntryError(Exception):
    pass

class InvalidDataError(Exception):
    pass

class ForceNotSpecified(Exception):
    pass

class ChannelNotFoundError(Exception):
    pass

class NoToolsChannel(Exception):
    pass

class NoChildChannels(Exception):
    pass

class InvalidChannel(Exception):
    pass

class BaseDatabaseObject:
    def __init__(self):
        self._row = None

    def __getattr__(self, name):
        if name.startswith('get_'):
            return rhnLib.CallableObj(name[4:], self._get)
        if name.startswith('set_'):
            return rhnLib.CallableObj(name[4:], self._set)
        raise AttributeError(name)

    def _set(self, name, val):
        self._new_row()
        self._row[name] = val

    def _get(self, name):
        return self._row[name]

    def _new_row(self):
        raise NotImplementedError()

    def save(self, with_updates=1):
        try:
            return self._save(with_updates=with_updates)
        except:
            rhnSQL.rollback()
            raise

    def _save(self, with_updates=1):
        try:
            self._row.save(with_updates=with_updates)
        except rhnSQL.ModifiedRowError:
            raise ModifiedError(self._row['id'])


class BaseChannelObject(BaseDatabaseObject):
    _table_name = None
    _sequence_name = None
    _generic_fields = []
    
    def load_by_label(self, label):
        self.__init__()
        self._row = rhnSQL.Row(self._table_name, 'label')
        self._row.load(label)
        return self

    def load_by_id(self, obj_id):
        self.__init__()
        self._row = rhnSQL.Row(self._table_name, 'id')
        self._row.load(obj_id)
        return self

    def load_from_dict(self, dict):
        # Re-init
        self.__init__()
        for f in self._generic_fields:
            method = getattr(self, 'set_' + f)
            method(dict.get(f))
        self._load_rest(dict)
        return self

    def _load_rest(self, dict):
        pass
    
    def exists(self):
        if not self._row:
            return 0
        return self._row.real

    def get_org_id(self):
        org_id = self._row['org_id']
        if org_id is None:
            return None
        row = self._lookup_org_id(org_id)
        if row.real:
            return row['login']
        return org_id
    
    def set_org_id(self, val):
        self._new_row()
        if val is None or isinstance(val, IntType):
            self._row['org_id'] = val
            return
        row = self._lookup_org_by_login(val)
        if not row.real:
            raise InvalidDataError("No such org", val)
        self._row['org_id'] = row['org_id']

    def _lookup_org_id(self, org_id):
        row = rhnSQL.Row('web_contact', 'org_id')
        row.load(org_id)
        return row

    def _lookup_org_by_login(self, login):
        row = rhnSQL.Row('web_contact', 'login')
        row.load(login)
        return row


    def _lookup_channel_family_by_id(self, channel_family_id):
        row = rhnSQL.Row('rhnChannelFamily', 'id')
        row.load(channel_family_id)
        return row

    def _lookup_channel_family_by_label(self, channel_family):
        row = rhnSQL.Row('rhnChannelFamily', 'label')
        row.load(channel_family)
        return row

    def _new_row(self):
        if self._row is None:
            self._row = rhnSQL.Row(self._table_name, 'id')
            channel_id = rhnSQL.Sequence(self._sequence_name).next()
            self._row.create(channel_id)

    def as_dict(self):
        ret = {}
        for f in self._generic_fields:
            method = getattr(self, 'get_' + f)
            val = method()
            ret[f] = val
        return ret

# Channel creation
class Channel(BaseChannelObject):
    _table_name = 'rhnChannel'
    _sequence_name = 'rhn_channel_id_seq'
    _generic_fields = ['label', 'name', 'summary', 'description', 'basedir',
        'org_id', 'gpg_key_url', 'gpg_key_id', 'gpg_key_fp', 'end_of_life',
        'channel_families', 'channel_arch',]

    def __init__(self):
        BaseChannelObject.__init__(self)
        self._channel_families = []
        self._dists = {}
        self._parent_channel_arch = None

    def load_by_label(self, label):
        BaseChannelObject.load_by_label(self, label)
        self._load_channel_families()
        self._load_dists()
        return self

    def load_by_id(self, label):
        BaseChannelObject.load_by_id(self, label)
        self._load_channel_families()
        self._load_dists()
        return self

    def _load_rest(self, dict):
        dists = dict.get('dists')
        if not dists:
            return
        for dist in dists:
            release = dist.get('release')
            os = dist.get('os')
            self._dists[release] = os

    _query_get_db_channel_families = rhnSQL.Statement("""
        select channel_family_id
          from rhnChannelFamilyMembers
         where channel_id = :channel_id
    """)
    def _get_db_channel_families(self, channel_id):
        if channel_id is None:
            return []
        h = rhnSQL.prepare(self._query_get_db_channel_families)
        h.execute(channel_id=channel_id)
        return map(lambda x: x['channel_family_id'], h.fetchall_dict() or [])

    def _load_channel_families(self):
        channel_id = self._row.get('id')
        self._channel_families = self._get_db_channel_families(channel_id)
        return 1

    def _load_dists(self):
        channel_id = self._row.get('id')
        dists = self._get_db_dists(channel_id)
        self.set_dists(dists)
        
    _query_get_db_dists = rhnSQL.Statement("""
        select os, release
          from rhnDistChannelMap
         where channel_id = :channel_id
    """)
    def _get_db_dists(self, channel_id):
        if channel_id is None:
            return []
        h = rhnSQL.prepare(self._query_get_db_dists)
        h.execute(channel_id=channel_id)
        return h.fetchall_dict() or []
        

    # Setters
    
    def set_channel_arch(self, val):
        self._new_row()
        arch = self._sanitize_arch(val)
        row = self._lookup_channel_arch(arch)
        if not row.real:
            raise InvalidDataError("No such architecture", arch)
        self._row['channel_arch_id'] = row['id']
        

    def _sanitize_arch(self, arch):
        if arch == 'i386':
            return 'channel-ia32'
        p = 'channel-'
        if arch[:len(p)] != p:
            return p + arch
        return arch

    def set_parent_channel(self, val):
        self._new_row()
        if val is None:
            self._row['parent_channel'] = None
            return
        row = self._lookup_channel_by_label(val)
        if not row.real:
            raise InvalidDataError("Invalid parent channel", val)
        self._row['parent_channel'] = row['id']
        self._parent_channel_arch = row['channel_arch_id']

    def set_channel_families(self, val):
        self._new_row()
        self._channel_families = []
        for cf_label in val:
            self.add_channel_family(cf_label)

    def set_end_of_life(self, val):
        self._new_row()
        if val is None:
            self._row['end_of_life'] = None
            return
        t = time.strptime(val, "%Y-%m-%d")
        seconds = time.mktime(t)
        t = rhnSQL.TimestampFromTicks(seconds)
        self._row['end_of_life'] = t

    def add_channel_family(self, name):
        self._new_row()
        cf = self._lookup_channel_family_by_label(name)
        if not cf.real:
            raise InvalidDataError("Invalid channel family", name)
        self._channel_families.append(cf['id'])

    def add_dist(self, release, os=None):
        if os is None:
            os = 'Red Hat Linux'
        self._dists[release] = os

    def set_dists(self, val):
        self._dists.clear()
        for h in val:
            release = h['release']
            os = h['os']
            self.add_dist(release, os)

    # Getters

    def get_parent_channel(self):
        pc_id = self._row['parent_channel']
        if pc_id is None:
            return None
        return self._lookup_channel_by_id(pc_id)['label']

    def get_channel_families(self):
        cf_labels = []
        for cf_id in self._channel_families:
            row = self._lookup_channel_family_by_id(cf_id)
            if row.real:
                cf_labels.append(row['label'])
        return cf_labels

    def get_channel_arch(self):
        channel_arch_id = self._row['channel_arch_id']
        row = self._lookup_channel_arch_by_id(channel_arch_id)
        assert row.real
        return row['label']

    def get_end_of_life(self):
        date_obj = self._row['end_of_life']
        if date_obj is None:
            return None
        return "%s-%02d-%02d %02d:%02d:%02d" % (
            date_obj.year, date_obj.month, date_obj.day, 
            date_obj.hour, date_obj.minute, date_obj.second)

    def get_dists(self):
        ret = []
        for release, os in self._dists.items():
            ret.append({'release' : release, 'os' : os})
        return ret

    def _lookup_channel_by_id(self, channel_id):
        row = rhnSQL.Row('rhnChannel', 'id')
        row.load(channel_id)
        return row

    def _lookup_channel_by_label(self, channel):
        row = rhnSQL.Row('rhnChannel', 'label')
        row.load(channel)
        return row

    def _lookup_channel_arch(self, channel_arch):
        row = rhnSQL.Row('rhnChannelArch', 'label')
        row.load(channel_arch)
        return row

    def _lookup_channel_arch_by_id(self, channel_arch_id):
        row = rhnSQL.Row('rhnChannelArch', 'id')
        row.load(channel_arch_id)
        return row

    def _save(self, with_updates=1):
        if self._parent_channel_arch:
            if not self._compatible_channel_arches(self._parent_channel_arch,
                    self._row['channel_arch_id']):
                raise IncompatibilityError("Incompatible channel arches")
        BaseChannelObject._save(self, with_updates=with_updates)
        # Save channel families now
        self._save_channel_families()
        self._save_dists()

    _query_remove_channel_families = rhnSQL.Statement("""
        delete from rhnChannelFamilyMembers
         where channel_id = :channel_id
           and channel_family_id = :channel_family_id
    """)
    _query_add_channel_families = rhnSQL.Statement("""
        insert into rhnChannelFamilyMembers (channel_id, channel_family_id)
        values (:channel_id, :channel_family_id)
    """)
    def _save_channel_families(self):
        channel_id = self._row['id']
        db_cfids = self._get_db_channel_families(channel_id)
        h = {}
        for db_cfid in db_cfids:
            h[db_cfid] = None
        to_add = []
        for cfid in self._channel_families:
            if h.has_key(cfid):
                del h[cfid]
                continue
            to_add.append(cfid)
        to_delete = h.keys()
        if to_delete:
            h = rhnSQL.prepare(self._query_remove_channel_families)
            cids = [channel_id] * len(to_delete)
            h.executemany(channel_id=cids, channel_family_id=to_delete)
        if to_add:
            h = rhnSQL.prepare(self._query_add_channel_families)
            cids = [channel_id] * len(to_add)
            h.executemany(channel_id=cids, channel_family_id=to_add)

    def _save_dists(self):
        channel_id = self._row['id']
        db_dists = self._get_db_dists(channel_id)
        d = self._dists.copy()
        to_add = [[], []]
        to_remove = []
        to_update = [[], []]
        for h in db_dists:
            release = h['release']
            os = h['os']
            if not d.has_key(release):
                to_remove.append(release)
                continue
            # Need to update?
            m_os = d[release]
            if m_os == os:
                # Nothing to do
                del d[release]
                continue
            to_update[0].append(release)
            to_update[1].append(os)
        # Everything else should be added
        for release, os in d.items():
            to_add[0].append(release)
            to_add[1].append(os)
        self._remove_dists(to_remove)
        self._update_dists(to_update[0], to_update[1])
        self._add_dists(to_add[0], to_add[1])
                
    _query_add_dists = rhnSQL.Statement("""
        insert into rhnDistChannelMap 
               (channel_id, channel_arch_id, release, os)
        values (:channel_id, :channel_arch_id, :release, :os)
        """)
    def _add_dists(self, releases, oses):
        if not releases:
            return
        count = len(releases)
        channel_ids = [self._row['id']] * count
        channel_arch_ids = [self._row['channel_arch_id']] * count
        h = rhnSQL.prepare(self._query_add_dists)
        h.executemany(channel_id=channel_ids, channel_arch_id=channel_arch_ids,
            release=releases, os=oses)
    
    _query_update_dists = rhnSQL.Statement("""
        update rhnDistChannelMap
           set channel_arch_id = :channel_arch_id,
               os = :os
         where channel_id = :channel_id
           and release = :release
    """)
    def _update_dists(self, releases, oses):
        if not releases:
            return
        count = len(releases)
        channel_ids = [self._row['id']] * count
        channel_arch_ids = [self._row['channel_arch_id']] * count
        h = rhnSQL.prepare(self._query_update_dists)
        h.executemany(channel_id=channel_ids, channel_arch_id=channel_arch_ids,
            release=releases, os=oses)

    _query_remove_dists = rhnSQL.Statement("""
        delete from rhnDistChannelMap
         where channel_id = :channel_id
           and release = :release
    """)
    def _remove_dists(self, releases):
        if not releases:
            return
        count = len(releases)
        channel_ids = [self._row['id']] * count
        h = rhnSQL.prepare(self._query_remove_dists)
        h.executemany(channel_id=channel_ids, release=releases)

    def _compatible_channel_arches(self, parent_channel_arch, channel_arch):
        # This could get more complicated later
        return (parent_channel_arch == channel_arch)
        
    def as_dict(self):
        ret = BaseChannelObject.as_dict(self)
        ret['dists'] = self.get_dists()
        return ret

class ChannelFamily(BaseChannelObject):
    _table_name = 'rhnChannelFamily'
    _sequence_name = 'rhn_channel_family_id_seq'
    _generic_fields = ['label', 'name', 'product_url']


def create_channels(entries, update=0):
    if not isinstance(entries, ListType):
        raise InvalidEntryError(entries, "Not a list")
    mandatory_fields = Channel._generic_fields + ['channel_arch']
    for e in entries:
        if not isinstance(e, DictType):
            raise InvalidEntryError(e, "Entry is not a dictionary")

        for f in mandatory_fields:
            if not e.has_key(f):
                raise InvalidEntryError(e, "Missing required field %s" % f)

        parent_channel = e.get('parent_channel')
        release = e.get('release')
        if parent_channel and not release:
            raise InvalidEntryError(e, "Attempting to create a base channel "
                "without a distribution release")

        c = Channel()
        c.load_from_dict(e)
        c.save(with_updates=update)
    
def create_channel_families(entries, update=0):
    if not isinstance(entries, ListType):
        raise InvalidEntryError(entries, "Not a list")
    mandatory_fields = ChannelFamily._generic_fields
    for e in entries:
        if not isinstance(e, DictType):
            raise InvalidEntryError(e, "Entry is not a dictionary")

        for f in mandatory_fields:
            if not e.has_key(f):
                raise InvalidEntryError(e, "Missing required field %s" % f)

        c = ChannelFamily()
        c.load_from_dict(e)
        c.save(with_updates=update)

def delete_channels(entries):
    if not isinstance(entries, ListType):
        raise InvalidEntryError(entries, "Not a list")
    ret = []
    for e in entries:
        if not isinstance(e, DictType):
            raise InvalidEntryError(e, "Entry is not a dictionary")

        label = e.get('label')
        if not label:
            raise InvalidEntryError(e, "Missing required field label")

        c = Channel()
        c.load_by_label(label)
        if not c.exists():
            ret.append(label)
            continue
        msg = _delete_channel(c)
        if msg is not None:
            ret.append(msg)
    return ret

def delete_channel_families(entries):
    if not isinstance(entries, ListType):
        raise InvalidEntryError(entries, "Not a list")
    ret = []
    for e in entries:
        if not isinstance(e, DictType):
            raise InvalidEntryError(e, "Entry is not a dictionary")

        label = e.get('label')
        if not label:
            raise InvalidEntryError(e, "Missing required field label")

        c = ChannelFamily()
        c.load_by_label(label)
        if not c.exists():
            ret.append(label)
            continue
        msg = _delete_channel_family(c)
        if msg is not None:
            ret.append(msg)
    return ret

def _delete_channel(channel):
    channel_id = channel.get_id()
    tables = [
        ['rhnDistChannelMap', 'channel_id'],
        ['rhnChannelFamilyMembers', 'channel_id'],
        ['rhnServerChannel', 'channel_id'],
        ['rhnChannelNewestPackage', 'channel_id'],
        ['rhnChannelPackage', 'channel_id'],
        ['rhnChannel', 'id']
    ]
    for table_name, col in tables:
        h = rhnSQL.prepare("delete from %s where %s = :channel_id" % 
            (table_name, col))
        try:
            h.execute(channel_id=channel_id)
        except rhnSQL.SQLError, e:
            if e.args[0] != 2292:
                raise
            label = channel.get_label()
            return("Unable to delete channel %s: child records found for "
                "table %s, column %s" % (label, table_name, col))
    return None


_query_delete_channel_family = rhnSQL.Statement("""
    delete from rhnChannelFamily where id = :channel_family_id
""")
def _delete_channel_family(channel_family):
    channel_family_id = channel_family.get_id()
    h = rhnSQL.prepare(_query_delete_channel_family)
    try:
        h.execute(channel_family_id=channel_family_id)
    except rhnSQL.SQLError, e:
        if e.args[0] != 2292:
            raise
        label = channel_family.get_label()
        return "Unable to delete channel family %s: child records found" % label

    return None

def list_channel_families(pattern=None):
    if pattern:
        query = """
            select id 
              from rhnChannelFamily 
             where org_id is null
               and label like :pattern
        """
        h = rhnSQL.prepare(query)
        h.execute(pattern=pattern)
    else:
        query = "select id from rhnChannelFamily where org_id is null"
        h = rhnSQL.prepare(query)
        h.execute()
    ret = []
    while 1:
        row = h.fetchone_dict()
        if not row:
            break
        channel_family_id = row['id']
        c = ChannelFamily().load_by_id(channel_family_id)
        ret.append(c.as_dict()) 
    return ret
    
def list_channels(pattern=None):
    if pattern:
        query = """
            select id 
              from rhnChannel
             where label like :pattern
        """
        h = rhnSQL.prepare(query)
        h.execute(pattern=pattern)
    else:
        query = "select id from rhnChannel"
        h = rhnSQL.prepare(query)
        h.execute()
    ret = []
    while 1:
        row = h.fetchone_dict()
        if not row:
            break
        channel_id = row['id']
        c = Channel().load_by_id(channel_id)
        ret.append(c.as_dict()) 
    return ret

# makes sure there are no None values in dictionaries, etc.
def __stringify(object):
    if object is None:
        return ""
    if type(object) == type([]):
        return map(__stringify, object)
    # We need to know __stringify converts immutable types into immutable
    # types
    if type(object) == type(()):
        return tuple(map(__stringify, object))
    if type(object) == type({}):
        ret = {}
        for k, v in object.items():
            ret[__stringify(k)] = __stringify(v)
        return ret
    # by default, we just str() it
    return str(object)
            

# return the channel information
def channel_info(channel):
    log_debug(3, channel)
    
    # get the channel information
    h = rhnSQL.prepare("""
    select
        ca.label arch,
        c.id,
        c.parent_channel,
        c.org_id,
        c.label,
        c.name,
        c.summary,
        c.description,
        to_char(c.last_modified, 'YYYYMMDDHH24MISS') last_modified
    from
        rhnChannel c,
        rhnChannelArch ca
    where
          c.channel_arch_id = ca.id
      and c.label = :channel
    """)
    h.execute(channel = str(channel))
    ret = h.fetchone_dict()
    return __stringify(ret)

# return information about a base channel for a server_id
def get_base_channel(server_id, none_ok = 0):
    log_debug(3, server_id)
    h = rhnSQL.prepare("""
    select
        ca.label arch,
        c.id,
        c.parent_channel,
        c.org_id,
        c.label,
        c.name,
        c.summary,
        c.description,
        to_char(c.last_modified, 'YYYYMMDDHH24MISS') last_modified
    from rhnChannel c, rhnChannelArch ca, rhnServerChannel sc
    where sc.server_id = :server_id
      and sc.channel_id = c.id
      and c.channel_arch_id = ca.id
      and c.parent_channel is NULL
    """)
    h.execute(server_id = str(server_id))
    ret = h.fetchone_dict()
    if not ret:
        if not none_ok:
            log_error("Server not subscribed to a base channel!", server_id)
        return None
    return __stringify(ret)
    
# list the available channels for an org_id
# We DO NOT want to cache this one because we depend on getting
# accurate information and the caching would only introduce more
# overhead on an otherwise very fast query
def channels_for_org(org_id):
    if not org_id:
        org_id = ''
    org_id = string.strip(str(org_id))
    log_debug(3, org_id)

    # select channels this org can access
    h = rhnSQL.prepare("""
    select
        ca.label arch,
        c.id,
        c.parent_channel,
        c.org_id,
        c.label,
        c.name,
        c.summary,
        c.description,
        to_char(c.last_modified, 'YYYYMMDDHH24MISS') last_modified      
    from
        rhnChannelArch ca
        rhnChannel c,
        rhnChannelPermissions cp
    where
      cp.org_id = :org_id
      and cp.channel_id = c.id
      and c.channel_arch_id = ca.id
    """)
    h.execute(org_id = org_id)
    ret = h.fetchall_dict()
    if not ret:
        return []
    # stringify for xmlrpc return
    return __stringify(ret)

def channels_for_server(server_id):
    """channel info list for all channels accessible by this server.

    list channels a server_id is subscribed to
    We DO NOT want to cache this one because we depend on getting
    accurate information and the caching would only introduce more
    overhead on an otherwise very fast query
    """
    log_debug(3, server_id)
    try:
        server_id = int(server_id)
    except:
        raise rhnFault(8, server_id) # Invalid rhnServer.id
    # XXX: need to return unsubsubcribed channels and a way to indicate
    #        they arent already subscribed

    # list all the channels this server is subscribed to. We also want
    # to know if any of those channels has local packages in it... A
    # local package has a org_id set.
    h = rhnSQL.prepare("""
    select 
        ca.label arch,
        c.id,
        c.parent_channel,
        c.org_id,
        c.label,
        c.name,
        c.summary,
        c.description,
        c.gpg_key_url,
        decode(s.org_id, c.org_id, 1, 0) local_channel,
        TO_CHAR(c.last_modified, 'YYYYMMDDHH24MISS') last_modified
    from
        rhnChannelArch ca,
        rhnChannel c,
        rhnServerChannel sc,
        rhnServer s
    where
            c.id = sc.channel_id
        and sc.server_id = :server_id
        and s.id = :server_id
        and ca.id = c.channel_arch_id
    order by c.parent_channel nulls first
    """)
    h.execute(server_id = str(server_id))
    channels = h.fetchall_dict()
    if not channels: 
        log_error("Server not subscribed to any channels", server_id)
        channels = []
    return __stringify(channels)


def isCustomChannel(channel_id):
    """
    Input:      channel_id  (from DB Table rhnChannel.id)
    Returns:    True if this is a custom channel
            False if this is not a custom channel
    """
    log_debug(3, channel_id)
    h = rhnSQL.prepare("""
    select
        rcf.label
    from 
        rhnChannelFamily rcf,
        rhnChannelFamilyMembers rcfm
    where
        rcfm.channel_id = :channel_id
        and rcfm.channel_family_id = rcf.id
        and rcf.org_id is not null
    """)
    h.execute(channel_id = str(channel_id))
    label = h.fetchone();
    if label:
        if label[0].startswith("private-channel-family"):
            log_debug(3, channel_id, "is a custom channel")
            return True
    return False



# Fetch base channel for a given release and arch
def base_channel_for_rel_arch(release, server_arch, org_id=-1, 
            user_id=None):
    log_debug(4, release, server_arch, org_id, user_id)

    query = """
        select ca.label arch,
               c.id,
               c.parent_channel,
               c.org_id,
               c.label,
               c.name,
               c.summary,
               c.description,
               to_char(c.last_modified, 'YYYYMMDDHH24MISS') last_modified,
               rhn_channel.available_chan_subscriptions(c.id, :org_id) available_subscriptions
          from rhnChannel c,
               rhnChannelArch ca
        where c.channel_arch_id = ca.id
          and c.id = rhn_channel.base_channel_for_release_arch(
                :release, :server_arch, :org_id, :user_id)
    """
    h = rhnSQL.prepare(query)
    try:
        h.execute(release = str(release), server_arch = str(server_arch),
                  org_id=org_id, user_id=user_id)
    except rhnSQL.SQLSchemaError, e:
        if e.errno == 20263:
            # Insufficient permissions for subscription
            log_debug(4,'BaseChannelDeniedError')
            raise BaseChannelDeniedError()
        if e.errno == 20244:
            # Server architecture could not be found
            log_debug(4,'InvalidServerArchError')
            raise InvalidServerArchError(str(server_arch))
        # Re-raise unknown eceptions
        log_debug(4,'unkown exception')
        raise e

    log_debug(4, 'got past exceptions')
    return h.fetchone_dict()

def base_eus_channel_for_ver_rel_arch(version, release, server_arch,
                                      org_id=-1, user_id=None):
    """
    given a redhat-release version, release, and server arch, return a list
    of dicts containing the details of the channel z streams either match the
    version/release pair, or are greater.
    """

    log_debug(4, version, release, server_arch, org_id, user_id)

    eus_channels_query = """
        select c.id,
               c.label,
               c.name,
               rcm.release,
               c.receiving_updates
        from
            rhnChannelPermissions cp,
            rhnChannel c,
            rhnServerArch sa,
            rhnServerChannelArchCompat scac,
            rhnReleaseChannelMap rcm
        where
                rcm.version = :version
            and scac.server_arch_id = sa.id
            and sa.label = :server_arch
            and scac.channel_arch_id = rcm.channel_arch_id
            and rcm.channel_id = c.id
            and cp.channel_id = c.id
            and cp.org_id = :org_id
            and rhn_channel.loose_user_role_check(c.id, :user_id,
                                                     'subscribe') = 1
    """

    eus_channels_prepared = rhnSQL.prepare(eus_channels_query)
    eus_channels_prepared.execute(version = version,
                                  server_arch = server_arch,
                                  user_id = user_id,
                                  org_id = org_id)

    channels = []
    while True:
        channel = eus_channels_prepared.fetchone_dict()
        if channel is None:
            break

        # the release part of redhat-release for rhel 4 is like
        # 6.1 or 7; we just look at the first digit.
        # for rhel 5 and up it's the full release number of rhel, followed by
        # the true release number of the rpm, like 5.0.0.9 (for the 9th
        # version of the redhat-release rpm, for RHEL GA)
        db_release = channel['release']
        if version in ['4AS', '4ES']:
            parts = 1
        else:
            parts = 3

        server_rel = '.'.join(release.split('.')[:parts])
        channel_rel = '.'.join(db_release.split('.')[:parts])

        # XXX we're no longer using the is_default column from the db
        if rpm.labelCompare(('0', server_rel, '0'),
                ('0', channel_rel, '0')) == 0:
            channel['is_default'] = 'Y'
            channels.append(channel)
        if rpm.labelCompare(('0', server_rel, '0'),
                ('0', channel_rel, '0')) < 0:
            channel['is_default'] = 'N'
            channels.append(channel)

    return channels


def get_channel_for_release_arch(release, server_arch):
    log_debug(3, release, server_arch)

    server_arch = rhnLib.normalize_server_arch(str(server_arch))
    log_debug(3, 'normalized arch as %s' % server_arch)

    query = """
        select distinct
               ca.label arch,
               c.id,
               c.parent_channel,
               c.org_id,
               c.label,
               c.name,
               c.summary,
               c.description,
               to_char(c.last_modified, 'YYYYMMDDHH24MISS') last_modified
          from rhnDistChannelMap dcm,
               rhnChannel c,
               rhnChannelArch ca,
               rhnServerChannelArchCompat scac,
               rhnServerArch sa
         where scac.server_arch_id = sa.id
           and sa.label = :server_arch
           and scac.channel_arch_id = dcm.channel_arch_id
           and dcm.release = :release
           and dcm.channel_id = c.id
           and dcm.channel_arch_id = c.channel_arch_id
           and c.parent_channel is null
           and c.org_id is null
           and c.channel_arch_id = ca.id
    """
    h = rhnSQL.prepare(query)
    h.execute(release=str(release), server_arch=server_arch)
    row = h.fetchone_dict()
    if not row:
        # No channles for this guy
        log_debug(3,'No channles for this guy')
        return None
    log_debug(3,'row is %s' % str(row))
    return row

def applet_channels_for_uuid(uuid):
    log_debug(3, uuid)

    query = """
        select distinct
               ca.label arch,
               c.id,
               c.parent_channel,
               c.org_id,
               c.label,
               c.name,
               c.summary,
               c.description,
               to_char(c.last_modified, 'YYYYMMDDHH24MISS') last_modified,
               to_char(s.channels_changed, 'YYYYMMDDHH24MISS') server_channels_changed
          from rhnChannelArch ca,
               rhnChannel c,
               rhnServerChannel sc,
               rhnServer s,
               rhnServerUuid su
         where su.uuid = :uuid
           and su.server_id = s.id
           and su.server_id = sc.server_id
           and sc.channel_id = c.id
           and c.channel_arch_id = ca.id
    """
    h = rhnSQL.prepare(query)
    h.execute(uuid=uuid)
    rows = h.fetchall_dict() or []
    return rows

# retrieve a list of public channels for a given release and architecture
# we cannot cache this if it involves an org_id
# If a user_id is passed to this function, and all the available base channels
# for this server_arch/release combination are denied by the org admin, this
# function raises BaseChannelDeniedError
def channels_for_release_arch(release, server_arch, org_id=-1, user_id=None):
    if not org_id:
        org_id = -1

    org_id = string.strip(str(org_id))
    log_debug(3, release, server_arch, org_id)

    # Can raise BaseChannelDeniedError or InvalidServerArchError
    base_channel = base_channel_for_rel_arch(release, server_arch,
        org_id=org_id, user_id=user_id)

    if not base_channel:
        raise NoBaseChannelError()

    # At this point, base_channel is not null

    # We assume here that subchannels are compatible with the base channels,
    # so there would be no need to check for arch compatibility from this
    # point
    h = rhnSQL.prepare("""
    select
        ca.label arch,
        c.id,
        c.parent_channel,
        c.org_id,
        c.label,
        c.name,
        c.summary,
        c.description,
        to_char(c.last_modified, 'YYYYMMDDHH24MISS') last_modified,
        -- If user_id is null, then the channel is subscribable
        rhn_channel.loose_user_role_check(c.id, :user_id, 'subscribe')
            subscribable,
        rhn_channel.available_chan_subscriptions(c.id, :org_id) available_subscriptions
    from
        rhnChannelPermissions cp,
        rhnDistChannelMap dcm,
        rhnChannel c,
        rhnChannelArch ca
    where
        c.id = dcm.channel_id
    and dcm.os in (
        'Powertools'
    )
    and c.channel_arch_id = ca.id
    and cp.channel_id = c.id
    and cp.org_id = :org_id
    and c.parent_channel = :parent_channel
    """)
    h.execute(org_id = org_id, 
        parent_channel=base_channel['id'], user_id=user_id)

    channels = [base_channel]
    while 1:
        row = h.fetchone_dict()
        if not row:
            break
        subscribable = row['subscribable']
        del row['subscribable']

        if not subscribable:
            # Not allowed to subscribe to this channel
            continue

        channels.append(row)
    
    return __stringify(channels)


_query_get_source_packages_from_ids = rhnSQL.Statement("""
    select srpm.name
      from rhnChannelPackage cp,
           rhnPackage p,
           rhnSourceRPM srpm
     where cp.channel_id = :channel_id
       and cp.package_id = p.id
       and p.source_rpm_id = srpm.id
""")

def list_packages_source(channel_id):
    ret = []
    h = rhnSQL.prepare(_query_get_source_packages_from_ids)
    h.execute(channel_id=channel_id)
    results = h.fetchall_dict()
    if results: 
        for r in results:
            r = r['name']
            if string.find(r, ".rpm") != -1:
                r = string.replace(r, ".rpm", "")
                new_evr = make_evr(r,source=1)
                new_evr_list = [new_evr['name'], new_evr['version'], new_evr['release'],new_evr['epoch']]
            ret.append(new_evr_list)

    return ret

# This function executes the SQL call for listing packages
def list_packages_sql(channel_id):
    log_debug(3, channel_id)
    # return the latest packages from the specified channel
    h = rhnSQL.prepare("""
    select
        pn.name,  
        pevr.version,  
        pevr.release,  
        pevr.epoch,  
        pa.label arch,  
        full_channel.package_size 
    from  
        rhnPackageArch pa,
        ( select 
            p.name_id,
            max(pe.evr) evr
          from
            rhnChannelPackage cp,
            rhnPackage p,
            rhnPackageEVR pe
          where
              cp.channel_id = :channel_id
          and cp.package_id = p.id
          and p.evr_id = pe.id
          group by p.name_id
        ) listall,
        ( select distinct
            p.package_size,
            p.name_id,
            p.evr_id,
            p.package_arch_id
          from
            rhnChannelPackage cp,
            rhnPackage p
          where
              cp.channel_id = :channel_id
          and cp.package_id = p.id
        ) full_channel,
        -- Rank the package's arch
        ( select
            package_arch_id, 
            count(*) rank
          from
            rhnServerPackageArchCompat
          group by package_arch_id
        ) arch_rank,
        rhnPackageName pn,
        rhnPackageEVR pevr
    where
        pn.id = listall.name_id
        -- link back to the specific package
    and full_channel.name_id = listall.name_id
    and full_channel.evr_id = pevr.id
    and pevr.evr = listall.evr
    and pa.id = full_channel.package_arch_id
    and pa.id = arch_rank.package_arch_id
    order by pn.name, arch_rank.rank desc
    """)
    h.execute(channel_id = str(channel_id))
    # XXX This query has to order the architectures somehow; the 7.2 up2date
    # client was broken and was selecting the wrong architecture if athlons
    # are passed first. The rank ordering here should make sure that i386
    # kernels appear before athlons.
    ret = h.fetchall_dict()
    if not ret:
        return []
    # process the results
    ret = map(lambda a: (a["name"], a["version"], a["release"], a["epoch"],
                         a["arch"], a["package_size"]),
              __stringify(ret))
    return ret

# This function executes the SQL call for listing packages
def list_all_packages_sql(channel_id):
    log_debug(3, channel_id)
    # return the latest packages from the specified channel
    h = rhnSQL.prepare("""
    select
        pn.name,  
        pevr.version,  
        pevr.release,  
        pevr.epoch,  
        pa.label arch,  
        p.package_size 
    from  
        rhnChannelPackage cp,
        rhnPackage p,
        rhnPackageName pn,
        rhnPackageEVR pevr,
        rhnPackageArch pa
    where
        cp.channel_id = :channel_id
    and cp.package_id = p.id
    and p.name_id = pn.id
    and p.evr_id = pevr.id
    and p.package_arch_id = pa.id
    order by pn.name, pevr.evr desc, pa.label
    """)
    h.execute(channel_id = str(channel_id))
    # XXX This query has to order the architectures somehow; the 7.2 up2date
    # client was broken and was selecting the wrong architecture if athlons
    # are passed first. The rank ordering here should make sure that i386
    # kernels appear before athlons.
    ret = h.fetchall_dict()
    if not ret:
        return []
    # process the results
    ret = map(lambda a: (a["name"], a["version"], a["release"], a["epoch"],
                         a["arch"], a["package_size"]),
              __stringify(ret))
    return ret


# This function executes the SQL call for listing packages with all the 
# dep information for each package also
def list_all_packages_complete_sql(channel_id):
    log_debug(3, channel_id)
    # return the latest packages from the specified channel
    h = rhnSQL.prepare("""
    select
        p.id,
        pn.name,  
        pevr.version,  
        pevr.release,  
        pevr.epoch,  
        pa.label arch,  
        p.package_size 
    from  
        rhnChannelPackage cp,
        rhnPackage p,
        rhnPackageName pn,
        rhnPackageEVR pevr,
        rhnPackageArch pa
    where
        cp.channel_id = :channel_id
    and cp.package_id = p.id
    and p.name_id = pn.id
    and p.evr_id = pevr.id
    and p.package_arch_id = pa.id
    order by pn.name, pevr.evr desc, pa.label
    """)
    # This gathers the provides, requires, conflicts, obsoletes info  
    g = rhnSQL.prepare("""
    select
       pp.package_id,
       'provides',
       pp.capability_id,
       pp.sense,
       pc.name,
       pc.version
    from
       rhnPackageProvides pp,
       rhnPackageCapability pc
    where
       pp.package_id = :package_id
       and pp.capability_id = pc.id
    union all
    select
       pr.package_id,
       'requires',
       pr.capability_id,
       pr.sense,
       pc.name,
       pc.version
    from
       rhnPackageRequires pr,
       rhnPackageCapability pc
    where
       pr.package_id = :package_id
       and pr.capability_id = pc.id
    union all
    select
       pcon.package_id,
       'conflicts',
       pcon.capability_id,
       pcon.sense,
       pc.name,
       pc.version
    from
       rhnPackageConflicts pcon,
       rhnPackageCapability pc
    where
       pcon.package_id = :package_id
       and pcon.capability_id = pc.id
    union all
    select
       po.package_id,
       'obsoletes',
       po.capability_id,
       po.sense,
       pc.name,
       pc.version
    from
       rhnPackageObsoletes po,
       rhnPackageCapability pc
    where
       po.package_id = :package_id
       and po.capability_id = pc.id
    """)

    h.execute(channel_id = str(channel_id))
    # XXX This query has to order the architectures somehow; the 7.2 up2date
    # client was broken and was selecting the wrong architecture if athlons
    # are passed first. The rank ordering here should make sure that i386
    # kernels appear before athlons.
    ret = h.fetchall_dict()
    if not ret:
        return []
    for pkgi in ret:
        pkgi['provides'] = []
        pkgi['requires'] = []
        pkgi['conflicts'] = []
        pkgi['obsoletes'] = []
        g.execute(package_id = pkgi["id"])
        deps = g.fetchall_dict() or []
        for item in deps:
            version = item['version'] or ""
            relation = ""
            if version:
                sense = item['sense'] or 0
                if sense & 2: relation = relation + "<"
                if sense & 4: relation = relation + ">"
                if sense & 8: relation = relation + "="
                if relation: relation = " " + relation
                if version: version = " " + version
            dep = item['name'] + relation + version
            pkgi[item["'provides'"]].append(dep)
    # process the results
    ret = map(lambda a: (a["name"], a["version"], a["release"], a["epoch"],
                         a["arch"], a["package_size"], a['provides'], 
                         a['requires'], a['conflicts'], a['obsoletes']),
              __stringify(ret))
    return ret

def list_packages_path(channel_id):
    log_debug(3, channel_id)
    # return the latest packages from the specified channel
    h = rhnSQL.prepare("""
    select
        p.path
    from  
        rhnPackage p,
        rhnChannelPackage cp
    where
        cp.channel_id = :channel_id
    and cp.package_id = p.id
    """)
    h.execute(channel_id = str(channel_id))
    ret = h.fetchall()
    if not ret:
        return []
    # process the results
    # ret = map(lambda a: (a["path"]),
              # __stringify(ret))
    return ret


# list the latest packages for a channel
def list_packages(channel):
    return _list_packages(channel, cache_prefix="list_packages",
        function=list_packages_sql)

# list _all_ the packages for a channel
def list_all_packages(channel):
    return _list_packages(channel, cache_prefix="list_all_packages",
        function=list_all_packages_sql)

# list _all_ the packages for a channel
def list_all_packages_complete(channel):
    return _list_packages(channel, cache_prefix="list_all_packages_complete",
        function=list_all_packages_complete_sql)

# Common part of list_packages and list_all_packages*
# cache_prefix is the prefix for the file name we're caching this request as
# function is the generator function
def _list_packages(channel, cache_prefix, function):
    log_debug(3, channel, cache_prefix)
    
    # try the caching thing first
    c_info = channel_info(channel)
    if not c_info: # unknown channel
        raise rhnFault(40, "could not find any data on channel '%s'" % channel)
    cache_entry = "%s-%s" % (cache_prefix, channel)
    ret = rhnCache.get(cache_entry, c_info["last_modified"])
    if ret: # we scored a cache hit
        log_debug(4, "Scored cache hit", channel)
        # Mark the response as being already XMLRPC-encoded
        rhnFlags.set("XMLRPC-Encoded-Response", 1)
        return ret
    
    ret = function(c_info["id"])
    if not ret:
        # we assume that channels with no packages are very fast to list,
        # so we don't bother caching...
        log_error("No packages found in channel",
                  c_info["id"], c_info["label"])
        return []
    # we need to append the channel label to the list
    ret = map(lambda a, c = channel: a + (c,), ret)
    ret = xmlrpclib.dumps((ret, ), methodresponse=1)
    # Mark the response as being already XMLRPC-encoded
    rhnFlags.set("XMLRPC-Encoded-Response", 1)
    # set the cache
    rhnCache.set(cache_entry, ret, c_info["last_modified"])
    return ret

# list packages in a channel list and compute the latest packages
# across the whole selection
# channel_list is an array of hashes as returned by channel_info
def list_packages_from_channels(channel_list):
    if not channel_list:
        return []
    
    # look it up in the cache first
    labels = map(lambda a: a["label"], channel_list)
    labels.sort()
    log_debug(3, labels)
    labels = string.join(labels, "-")
    # get the latest channel timestamp and use it as a cache entry timestamp
    timestamp = max(map(lambda a: a["last_modified"], channel_list))
    cache_entry = "list_packages_from_channels-%s" % labels
    ret = rhnCache.get(cache_entry, timestamp)   
    if ret: # we scored a cache hit
        log_debug(4, "Scored cache hit", labels)
        return ret

    # select the latest version of a package from the union of all channels
    # this server is subscribed to
    ret = {}   
    for c in channel_list:
        packages = list_packages_sql(c["id"])
        for pkg in packages:
            p = list(pkg[:4])
            # Old client versions expect the size to be sent as an integer,
            # not as a string; so make sure we convert it to int
            p.append(int(pkg[5]))
            package_name = p[0] # for readability
            if ret.has_key(package_name):
                # already there, need to do a version compare
                # Compare the current package with the already stored one
                # XXX: do we really need to use this here instead of having
                #      the DB do the dirty work?
                if rhn_rpm.nvre_compare(ret[package_name], p) < 0:
                    ret[package_name] = p # Replace the stored package
            else:
                ret[package_name] = p
            # XXX Should try to pick the matching architecture but this is
            # a PITA; otherwise, for multiarched packages, we may return
            # the wrong size. If we really care this can be done
    # return the package list in a sorted order
    packages = ret.values()
    packages.sort(lambda a, b: cmp(a[0], b[0]))
    # Save to cache and return
    rhnCache.set(cache_entry, packages, timestamp)
    return packages 

         
                
        
        
    


# build the listall variants for the channels a server is subscribed to
# this one uses list_packages_from_channels, which does its own caching
def list_packages_for_server(server_id, need_size = 0):
    log_debug(3, server_id, "need_size = %s" % need_size)
    channel_list = channels_for_server(server_id)
    if not channel_list:
        return []
    ret = list_packages_from_channels(channel_list)
    if not ret:
        return []
    if need_size:
        return ret
    # we don't need the size in there, take it out
    ret = map(lambda a: a[:-1], ret)
    return ret

# list the obsoletes for a channel
def list_obsoletes(channel):
    log_debug(3, channel)

    # try the caching thing first
    c_info = channel_info(channel)
    if not c_info: # unknown channel
        raise rhnFault(40, "could not find any data on channel '%s'" % channel)
    cache_entry = "list_obsoletes-%s" % channel
    ret = rhnCache.get(cache_entry, c_info["last_modified"])
    if ret: # we scored a cache hit
        log_debug(4, "Scored cache hit", channel)
        return ret

    # Get the obsoleted packages
    h = rhnSQL.prepare("""
        select  distinct
                pn.name,
                pe.version, pe.release, pe.epoch,
                pa.label arch,
                pc.name obsolete_name,
                pc.version obsolete_version,
                p_info.sense
        from    rhnPackageCapability pc,
                rhnPackageArch pa,
                rhnPackageEVR pe,
                rhnPackageName pn,
                rhnPackage p,
                (   select  cp.channel_id,
                            po.package_id, po.capability_id, po.sense
                    from    rhnPackageObsoletes po,
                            rhnChannelPackage cp,
                            rhnChannel c
                    where   1=1
                        and c.label = :channel
                        and c.id = cp.channel_id
                        and cp.package_id = po.package_id
                    minus
                    -- obsoletes that are blacklisted follow
                    select  cp.channel_id,
                            po.package_id, po.capability_id, po.sense
                    from    rhnPackageName pni,
                            rhnPackageCapability pc,
                            rhnBlacklistObsoletes bo,
                            rhnPackage p,
                            rhnPackageObsoletes po,
                            rhnChannelPackage cp,
                            rhnChannel c
                    where   1=1
                        and c.label = :channel
                        and c.id = cp.channel_id
                        -- find all the packages we have obsoletes for
                        and cp.package_id = po.package_id
                        -- now find the name, and get the blacklists that apply
                        and po.package_id = p.id
                        and p.name_id = bo.name_id
                        and p.evr_id = bo.evr_id
                        and p.package_arch_id = bo.package_arch_id
                        -- now match the blacklisted names to the caps
                        and po.capability_id = pc.id
                        and pc.name = pni.name
                        and bo.ignore_name_id = pni.id
                ) p_info
        where   1=1
            and p_info.package_id = p.id
            and p.name_id = pn.id
            and p.evr_id = pe.id
            and p.package_arch_id = pa.id
            and p_info.capability_id = pc.id
    """)
    h.execute(channel = str(channel))
    # Store stuff in a dictionary to makes things simpler
    hash = {}
    while 1:
        row = h.fetchone_dict()
        if not row:
            break
        row = __stringify(row)
        key = (row['name'], row['version'], row['release'],
               row["epoch"], row['arch'])
        value = key + (row['obsolete_name'], row['obsolete_version'],
                       row['sense'])
        if not hash.has_key(key):
            hash[key] = []
        hash[key].append(value)

    # Now grab a listall and match it against what we got
    pkglist = list_packages_sql(c_info["id"])
    result = []
    for pkg in pkglist:
        key = tuple(pkg[:5])
        if hash.has_key(key):
            for p in hash[key]:
                result.append(p)
    # we can cache this now
    rhnCache.set(cache_entry, result, c_info["last_modified"])
    return result

def __auth_user(server_id, username, password):
    """ Auth if user can add/remove channel from given server """
    log_debug(3, server_id, username)
    # check the username and password for compliance
    user = rhnUser.auth_username_password(username, password)
    # The user's password checks, verify that they have perms on that
    # server.
    h = rhnSQL.prepare("""
    select count(*)
    from rhnUserServerPerms usp
    where usp.user_id = :user_id
    and   usp.server_id = :server_id
    """)
    h.execute(user_id = str(user.getid()), server_id = str(server_id))
    res = h.fetchone_dict()
    if not res:
        # Not allowed to perform administrative tasks on this server
        raise rhnFault(37)
    return 1

# list the obsoletes blacklist for a channel
def get_obsoletes_blacklist(channel):
    log_debug(3, channel)

    # try the caching thing first
    c_info = channel_info(channel)
    if not c_info: # unknown channel
        raise rhnFault(40, "could not find any data on channel '%s'" % channel)
    cache_entry = "blacklist_obsoletes-%s" % channel
    ret = rhnCache.get(cache_entry, c_info["last_modified"])
    if ret: # we scored a cache hit
        log_debug(4, "Scored cache hit", channel)
        return ret

    # Get the obsoleted packages
    h = rhnSQL.prepare("""
        select unique 
            pnsrc.name src_name, 
            bo.src_epoch,
            bo.src_version,
            bo.src_release,
            cdst.label dst_channel,
            pndst.name dst_name,
            bo.dst_epoch,
            bo.dst_version,
            bo.dst_release
        from 
            rhnChannel csrc, rhnChannel cdst, 
            rhnPackageName pnsrc, rhnPackageName pndst,
            rhnBlacklistObsoletes bo
        where bo.src_channel_id = csrc.id
            and csrc.label = :channel
            and bo.dst_channel_id = cdst.id (+)
            and bo.src_name_id = pnsrc.id
            and bo.dst_name_id = pndst.id
        order by pnsrc.name, pndst.name
    """)
    h.execute(channel = str(channel))
    result = []
    keys = ['name', 'version', 'release', 'epoch']
    while 1:
        row = h.fetchone_dict()
        if not row:
            break
        src = map(lambda k, row=row: row[k],
            map(lambda k: "src_" + k, keys))
        for i in [1, 2, 3]:
            if src[i] is None:
                src[i] = ''
        dst = map(lambda k, row=row: row[k],
            map(lambda k: "dst_" + k, keys))
        for i in [1, 2, 3]:
            if dst[i] is None:
                dst[i] = ''
        dst_channel = row['dst_channel'] or ''
        result.append([src, dst, dst_channel])
        
    # we can cache this now
    rhnCache.set(cache_entry, result, c_info["last_modified"])
    return result


# small wrapper around a PL/SQL function
def _subscribe_sql(server_id, channel_id, commit = 1):
    log_debug(3, server_id, channel_id, commit)
    try:
        # don't run the EC yet
       rhnChannelConnector.subscribe(server_id, channel_id)
    except rhnSQL.SQLSchemaError, e:
        if e.errno == 20235: # channel_family_no_subscriptions
            raise SubscriptionCountExceeded(channel_id=channel_id)
        if e.errno == 20102: # channel_server_one_base
            log_error("Channel subscribe failed, "\
                  "%s already subscribed to %s (?)" % (server_id, channel_id))
            raise rhnFault(38, "Server already subscribed to %s" % channel_id)
        # If we got here, it's an unknown error; ISE (for now)
        log_error("SQLSchemaError", e)
        raise rhnException(e)
    except rhnSQL.SQLError, e:
        # If we got here, it's an unknown error; ISE (for now)
        log_error("SQLError", e)
        raise rhnException(e)
    if commit:
        rhnSQL.commit()
    return 1


# Wrapper around _subscribe_sql, raises rhnFault instead of
# SubscriptionCountExceeded
def subscribe_sql(server_id, channel_id, commit=1):
    try:
        _subscribe_sql(server_id, channel_id, commit=commit)
    except SubscriptionCountExceeded:
        log_error("Subscription count exceeded for channel id %s" %
            channel_id)
        raise rhnFault(70, "Subscription count for the target channel exceeded")


_query_can_subscribe = rhnSQL.Statement("""
select rhn_channel.user_role_check(:cid, wc.id, 'subscribe') as can_subscribe
  from web_contact wc
 where wc.login_uc = upper(:username)
""")

# subscribe a server to a channel with authentication
def subscribe_channel(server_id, channel, username, password):
    log_debug(3, server_id, channel, username)
    # If auth doesn't blow up we're fine
    __auth_user(server_id, username, password)

    # get the channel_id
    h = rhnSQL.prepare("select id from rhnChannel where label = :channel")
    h.execute(channel = str(channel))
    ret = h.fetchone_dict()
    if not ret:
        log_error("Channel %s does not exist?" % channel)
        raise rhnFault(40, "Channel %s does not exist?" % channel)

    channel_id = ret['id']

    # check specific channel subscription permissions
    h = rhnSQL.prepare(_query_can_subscribe)
    h.execute(cid=channel_id, username=username)
    ret = h.fetchone_dict()

    if ret and ret['can_subscribe']:
        subscribe_sql(server_id, channel_id)
        return 1

    raise rhnFault(71)

def _map_install_num_chan_2_label(system_id, version,
                          server_arch, install_num_chan):
    q = rhnSQL.prepare(
        """
        select
            distinct
            c.id,
            c.label,
            c.parent_channel
        from
            rhnServerChannelArchCompat scac,
            rhnChannelArch ca,
            rhnServerArch sa,
            rhnChannel c,
            rhnServerChannel sc,
            rhnReleaseChannelMap rcm,
            rhnDistChannelMap dcm
        where
            rcm.product = :product
            and rcm.version = :version
            and rcm.channel_arch_id = ca.id
            and ca.id = scac.channel_arch_id
            and sa.id = scac.server_arch_id
            and sa.label = :server_arch
            and (rcm.channel_id = c.id or dcm.channel_id = c.id)
            and sc.server_id = :server_id
            and sc.channel_id = c.parent_channel
            and dcm.release = :version
            and dcm.channel_arch_id = ca.id
            and dcm.os = :product
        """)
    q.execute(product = install_num_chan, version = version,
              server_arch = server_arch,
              server_id = system_id)

    data = q.fetchone_dict()

    if not data:
        raise ChannelNotFoundError(
                 "Could not lookup channel for %s, " % install_num_chan + \
                 "version: %s, " % version + \
                 "architecture: %s, " % server_arch)
    else:
        log_debug(4, 'looked up channel %s' % data['label'])
        return data

def subscribe_child_channels(system_id, version, server_arch,
                             install_num_chan_list):
    """
    Attemt to subscribe a system to the channels in install_num_chan_list
    
    Return successful channel labels, failed channel labels and unknown 
    options we couldn't look up labels for.

    There is no need to wrap this in a try, except block.
    subscribe_child_channels swallows known exceptions which is what we want.
    Unkown exceptions will propogate up.
    """

    channels = []
    successes = []
    failures = []
    unknowns = []

    for install_num_chan in install_num_chan_list:

        # Look up the channel id.
        try:
            install_num_chan_data = _map_install_num_chan_2_label(
                                                     system_id,
                                                     version,
                                                     server_arch,
                                                     install_num_chan)
        except ChannelNotFoundError, c:
            unknowns.append(install_num_chan)
            continue
        channels.append(install_num_chan_data)

    # Try to subscribe the system.
    # Hmm, for whatever reason, subscribe_channels doesn't commit, call
    # _subscribe_sql directly.
    # subscribe_channels(system_id, channels)
    if len(channels) > 0:
        for channel in channels:
            try:
                _subscribe_sql(system_id, channel['id'], 1)
                successes.append(channel['label']) 
            except SubscriptionCountExceeded:
                log_error("Subscription count exceeded for channel id %s" %
                           channel['id'])
                failures.append(channel['label'])


    return successes, failures, unknowns


# This class is only a convenient encapsulation of a server's attributes:
# server_id, org_id, release, arch, user_id. Sometimes we only pass the
# server_id, and later down the road we have to message "no channel for
# release foo, arch bar", but we don't know the release and arch anymore
class LiteServer:
    _attributes = ['id', 'org_id', 'release', 'arch']
    def __init__(self, **kwargs):
        # Initialize attributes from **kwargs (set to None if value is not
        # present)
        for attr in self._attributes:
            setattr(self, attr, kwargs.get(attr))

    def init_from_server(self, server):
        self.id = server.getid()
        self.org_id = server.server['org_id']
        self.release = server.server['release']
        self.arch = server.archname
        return self

    def __repr__(self):
        dict = {}
        for attr in self._attributes:
            dict[attr] = getattr(self, attr)
        return "<%s instance at %s: attributes=%s>" % (
            self.__class__.__name__, id(self), dict)


# If raise_exceptions is set, BaseChannelDeniedError, NoBaseChannelError are
# raised
def guess_channels_for_server(server, user_id=None, none_ok=0,
        raise_exceptions=0):
    log_debug(3, server)
    if not isinstance(server, LiteServer):
        raise rhnException("Server object is not a LiteServer")
    if None in (server.org_id, server.release, server.arch):
        # need to obtain the release and/or arch and/or org_id
        h = rhnSQL.prepare("""
        select s.org_id, s.release, sa.label arch
        from rhnServer s, rhnServerArch sa
        where s.id = :server_id and s.server_arch_id = sa.id
        """)
        h.execute(server_id=server.id)
        ret = h.fetchone_dict()
        if not ret:
            log_error("Could not get the release/arch "\
                      "for server %s" % server.id)
            raise rhnFault(8, "Could not find the release/arch "\
                           "for server %s" % server.id)
        if server.org_id is None:
            server.org_id = ret["org_id"]
        if server.release is None:
            server.release = ret["release"]
        if server.arch is None:
            server.arch = ret["arch"]        

    if raise_exceptions and not none_ok:
        # Let exceptions pass through
        return channels_for_release_arch(server.release, server.arch, 
            server.org_id, user_id=user_id)

    try:
        return channels_for_release_arch(server.release, server.arch, 
            server.org_id, user_id=user_id)
    except NoBaseChannelError:
        if none_ok:
            return []
        
        log_error("No available channels for (server, org)",
                  (server.id, server.org_id), server.release, server.arch)
        msg = _("Your account does not have access to any channels matching "
              "(release='%(release)s', arch='%(arch)s')%(www_activation)s")
        
        error_strings = {
            'release'        : server.release, 
            'arch'           : server.arch, 
            'www_activation' : ''
        }
        
        if CFG.REFER_TO_WWW:
            error_strings['www_activation'] = _("\nIf you have a "
                "registration number, please register with it first at "
                "http://www.redhat.com/apps/activate/ and then try again.\n\n")
            
        raise rhnFault(19, msg % error_strings)
    except BaseChannelDeniedError:
        if none_ok:
            return []

        raise rhnFault(71, 
                _("Insufficient subscription permissions for release (%s, %s") 
                    % (server.release, server.arch))
            
# Subscribes the server to channels
# can raise SubscriptionCountExceeded, BaseChannelDeniedError, NoBaseChannelError
# Only used for new server registrations
def subscribe_server_channels(server, user_id=None, none_ok=0): 
    s = LiteServer().init_from_server(server)

    # bretm 02/19/2007 -- have to leave none_ok in here for now due to how
    # the code is setup for reg token crap; it'd be very nice to clean up that
    # path to eliminate any chance for a server to be registered and not have base
    # channels, excluding expiration of channel entitlements
    channels = guess_channels_for_server(s, user_id=user_id, none_ok=none_ok,
            raise_exceptions=1)
    rhnSQL.transaction('subscribe_server_channels')
    for c in channels:
        try:
            _subscribe_sql(s.id, c["id"], 0)
        except SubscriptionCountExceeded, e:
            rhnSQL.rollback('subscribe_server_channels')
            # Re-raise the exception
            e.channel = c
            raise
        
    return channels

# small wrapper around a PL/SQL function
def unsubscribe_sql(server_id, channel_id, commit = 1):
    log_debug(3, server_id, channel_id, commit)
    unsubscribe_channel = rhnSQL.Procedure("rhn_channel.unsubscribe_server")
    try:
        # don't run the EC yet
        unsubscribe_channel(server_id, channel_id, 0)
    except rhnSQL.SQLError:
        log_error("Channel unsubscribe from %s failed for %s" % (
            channel_id, server_id))
        return 0
    if commit:
        rhnSQL.commit()
    return 1

# unsubscribe a server from a channel
def unsubscribe_channel(server_id, channel, username, password):
    log_debug(3, server_id, channel, username)
    # If auth doesn't blow up we're fine
    __auth_user(server_id, username, password)

    # now get the id of the channel
    h = rhnSQL.prepare("""
    select id, parent_channel from rhnChannel where label = :channel
    """)
    h.execute(channel = channel)
    ret = h.fetchone_dict()
    if not ret:
        log_error("Asked to unsubscribe server %s from non-existent channel %s" % (
            server_id, channel))
        raise rhnFault(40, "The specified channel '%s' does not exist." % channel)
    if not ret["parent_channel"]:
        log_error("Cannot unsubscribe %s from base channel %s" % (
            server_id, channel))
        raise rhnFault(72, "You can not unsubscribe %s from base channel %s." % (
            server_id, channel))
    # we're fine
    return unsubscribe_sql(server_id, ret["id"])

# unsubscribe from all channels
def unsubscribe_all_channels(server_id):           
    log_debug(3, server_id)
    # We need to unsubscribe the children channels before the base ones.
    rhnSQL.transaction("unsub_all_channels")
    h = rhnSQL.prepare("""
    select
        sc.channel_id id
    from
        rhnChannel c,
        rhnServerChannel sc
    where
        sc.server_id = :server_id
    and sc.channel_id = c.id
    order by c.parent_channel nulls last
    """)
    h.execute(server_id = str(server_id))
    while 1:
        c = h.fetchone_dict()
        if not c:
            break
        ret = unsubscribe_sql(server_id, c["id"], 0)
        if not ret:
            rhnSQL.rollback("unsub_all_channels")
            raise rhnFault(36, "Could not unsubscribe server %s "\
                           "from existing channels" % (server_id,))
    # finished unsubscribing
    return 1

# Unsubscribe the server from the channels in the list
# A channel is a hash containing at least the keys:
# [id, label, parent_channel]
def unsubscribe_channels(server_id, channels):
    log_debug(4, server_id, channels)
    if not channels:
        # Nothing to do
        return 1

    # We need to unsubscribe the children channels before the base ones.
    rhnSQL.transaction("unsub_channels")

    base_channels = filter(lambda x: not x['parent_channel'], channels)
    child_channels = filter(lambda x: x['parent_channel'], channels)

    for channel in child_channels + base_channels:
        ret = unsubscribe_sql(server_id, channel["id"], 0)
        if not ret:
            rhnSQL.rollback("unsub_all_channels")
            raise rhnFault(36, "Could not unsubscribe server %s "\
                           "from channel %s" % (server_id, channel["label"]))

    # finished unsubscribing
    return 1

# Subscribe the server to the channels in the list
# A channel is a hash containing at least the keys:
# [id, label, parent_channel]
def subscribe_channels(server_id, channels):
    log_debug(4, server_id, channels)
    if not channels:
        # Nothing to do
        return 1

    # We need to subscribe the base channel before the child ones.
    base_channels = filter(lambda x: not x['parent_channel'], channels)
    child_channels = filter(lambda x: x['parent_channel'], channels)

    for channel in base_channels + child_channels:
        subscribe_sql(server_id, channel["id"], 0)

    # finished subscribing
    return 1


# check if a server is subscribed to a channel
def is_subscribed(server_id, channel):
    log_debug(3, server_id, channel)
    h = rhnSQL.prepare("""
    select 1 subscribed
    from rhnServerChannel sc, rhnChannel c
    where
        sc.channel_id = c.id
    and c.label = :channel
    and sc.server_id = :server_id
    """)
    h.execute(server_id = str(server_id), channel = str(channel))
    ret = h.fetchone_dict()
    if not ret:
        # System not subscribed to channel
        return 0
    return 1

# Returns 0, "", "" if system does not need any message, or 
# (error_code, message_title, message) otherwise
def system_reg_message(server):
    server_id = server.server['id']
    # Is this system subscribed to a channel?
    h = rhnSQL.prepare("""
        select sc.channel_id
          from rhnServerChannel sc
         where sc.server_id = :server_id
    """)
    h.execute(server_id=server_id)
    ret = h.fetchone_dict()
    if not ret:
        # System not subscribed to any channel
        #
        return (-1, s_invalid_channel_title, 
                s_invalid_channel_message % 
                (server.server["release"], server.archname))


    # System does have a base channel; check entitlements
    entitlements = server_lib.check_entitlement(server_id)
    if not entitlements:
        # No entitlement
        # We don't have an autoentitle preference for now, so display just one
        # message
        templates = rhnFlags.get('templateOverrides')
        if templates and templates.has_key('hostname'):
            hostname = templates['hostname']
        else:
            # Default to www
            hostname = "rhn.redhat.com"
        params = {
            'entitlement_url'   : "https://%s"
                "/network/systems/details/edit.pxt?sid=%s" %
                    (hostname, server_id)
        }
        return -1, no_entitlement_title, no_entitlement_message % params
    return 0, "", ""

# IN: 'e:name-version-release' or 'name-version-release:e'
# OUT: {'name':name, 'version':version, 'release':release, 'epoch':epoch }
def make_evr(nvre, source=False):
    import re
    if ":" in nvre:
        nvr, epoch = nvre.rsplit(":", 1)
        if "-" in epoch:
            nvr, epoch = epoch, nvr
    else:
        nvr, epoch = nvre, ""

    nvr_parts = nvr.rsplit("-", 2)
    if len(nvr_parts) != 3:
        raise rhnFault(err_code = 21, err_text = \
                       "NVRE is missing name, version, or release.")

    result = dict(zip(["name", "version", "release"], nvr_parts))
    result["epoch"] = epoch

    if source and result["release"].endswith(".src"):
        result["release"] = result["release"][:-4]

    return result


def subscribe_to_tools_channel(server_id):
    """
        Subscribes server_id to the RHN Tools channel associated with its base channel, if one exists.
    """
    base_channel_dict = get_base_channel(server_id, none_ok=1)

    if base_channel_dict is None:
       raise NoBaseChannelError("Server %s has no base channel." % \
           str(server_id))
    
    lookup_child_channels = rhnSQL.Statement("""
        select  id, label, parent_channel
          from  rhnChannel
         where  parent_channel = :id
    """)

    child_channel_data = rhnSQL.prepare(lookup_child_channels)
    child_channel_data.execute(id=base_channel_dict['id'])
    child_channels = child_channel_data.fetchall_dict()

    if child_channels is None:
        raise NoChildChannels("Base channel id %s has no child channels associated with it." % \
                              base_channel_dict['id'])
    
    tools_channel = None
    for channel in child_channels:
        if channel.has_key('label'):
            if 'rhn-tools' in channel['label']:
                tools_channel = channel

    if tools_channel is None:
        raise NoToolsChannel("Base channel id %s does not have a RHN Tools channel as a child channel." % \
                              base_channel_dict['id'])
    else:
        if not tools_channel.has_key('id'):
            raise InvalidChannel("RHN Tools channel has no id.")
        if not tools_channel.has_key('label'):
            raise InvalidChannel("RHN Tools channel has no label.")
        if not tools_channel.has_key('parent_channel'):
            raise InvalidChannel("RHN Tools channel has no parent_channel.")
        
        subscribe_channels(server_id, [tools_channel])

# Various messages that can be reused
#
# bretm 02/07/2007 -- when we have better old-client documentation, probably
# will be safe to get rid of all this crap

h_invalid_channel_title = _("System Registered but Inactive")
h_invalid_channel_message = _("""
Invalid Architecture and OS release combination (%s, %s).
Your system has been registered, but will not receive updates 
because it is not subscribed to a channel. If you have not yet
activated your product for service, please visit our website at:
  
     http://www.redhat.com/apps/activate/

...to activate your product.""")

s_invalid_channel_title = _("System Registered but Inactive")
s_invalid_channel_message = _("""
Invalid Architecture and OS release combination (%s, %s).
Your system has been registered, but will not receive updates
because it could not be subscribed to a base channel.
Please contact your organization administrator for assistance.
""")

no_autoentitlement_message = _("""
  This system has been successfully registered, but is not yet entitled
  to service.  To entitle this system to service, login to the web site at:

  %(entitlement_url)s
""")

no_entitlement_title = _("System Registered but Inactive")
no_entitlement_message = _("""
  This system has been successfully registered, but no service entitlements
  were available.  To entitle this system to service, login to the web site at:

  %(entitlement_url)s
""")

subscription_count_exceeded_title = _("System Registered but Inactive")
subscription_count_exceeded_message = _("""
  This system has been successfully registered, but the channel subscriptions
  were exhausted
""")


