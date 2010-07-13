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
# implements a bunch of functions needed by rhnServer modules
#

import os
import hashlib
import time
import string

from common import rhnFault, rhnException, log_error, log_debug
from common import CFG, rhnFlags
from common.rhnTranslate import _

from server import rhnSQL

# Do not import server.apacheAuth in this module, or the secret generation
# script will traceback - since it would try to import rhnSecret which doesn't
# exist


class rhnSystemEntitlementException(rhnException):
    pass

class rhnNoSystemEntitlementsException(rhnSystemEntitlementException):
    pass

# Given a textual digitalid (old style or new style) or simply an ID
# try to search in the database and return the numeric id (thus doing
# validation in case you pass a numeric ID already)
#
# If found, it will return a dictionary with at least an "id" member
#
# Additional fields can be requested by passing an array of strings
# with field names from rhnServer
# check if all chars of a string are in a set
def getServerID(server, fields = []):
    def check_chars(s):
        return reduce(lambda a, b: a and b in "0123456789", s, 1)

    log_debug(4, server, fields)
    if not type(server) in [ type(""), type(0) ]:
        return None

    if type(server) == type(0):
        search_id = server # will search by number
    elif server[:7] == "SERVER-": # old style certificate
        search_id = server
    elif server[:3] == "ID-": # new style id, extract the numeric id
        tmp_id = server[3:]
        if not tmp_id or check_chars(tmp_id) == 0:
            # invalid certificate, after ID- we have non numbers
            return None
        search_id = int(tmp_id)
    else:
        # this is string. if all are numbers, then try to convert to int
        if check_chars(server) == 0:
            # throughly invalid id, whet the heck do we do?
            log_error("Invalid server ID passed in search: %s" % server)
            return None
        # otherwise try as int
        try:
            search_id = int(server)
        except ValueError:
            return None

    # Now construct the extra stuff for the case when additional fields
    # are requested
    xfields = ""
    archdb = ""
    archjoin = ""
    # look at the fields
    fields = map(string.lower, fields)
    for k in fields:
        if k == "id": # already there
            continue
        if k == 'arch':
            archdb = ", rhnServerArch sa"
            archjoin = "and s.server_arch_id = sa.id"
            xfields = "%s, a.label arch" % xfields
            continue
        xfields = "%s, s.%s" % (xfields, k)
    # ugliness is over

    # Now build the search
    if type(search_id) == type(0):
        h = rhnSQL.prepare("""
        select s.id %s from rhnServer s %s
        where s.id = :p1 %s
        """ % (xfields, archdb, archjoin))
    else: # string
        h = rhnSQL.prepare("""
        select s.id %s from rhnServer s %s
        where s.digital_server_id = :p1 %s
        """ % (xfields, archdb, archjoin))
    h.execute(p1 = search_id)
    row = h.fetchone_dict()
    if row is None or row["id"] is None: # not found
        return None
    return row


# retrieve the server secret using the great getServerID function
def getServerSecret(server):
    row = getServerID(server, ["secret"])
    if row is None:
        return None
    return row["secret"]


###############################
# Server Class Helper functions
###############################
# create the initial server groups for a new server
def __create_server_group(group_label, org_id, maxnum = ''):
    # Add this new server to the pending group
    h = rhnSQL.prepare("""
    select sg.id, sg.current_members
    from rhnServerGroup sg
    where sg.group_type = ( select id from rhnServerGroupType
                            where label = :group_label )
    and sg.org_id = :org_id
    """)
    h.execute(org_id = org_id, group_label = group_label)
    data = h.fetchone_dict()
    if not data:
        # create the requested group
        ret_id = rhnSQL.Sequence("rhn_server_group_id_seq")()
        h = rhnSQL.prepare("""
        insert into rhnServerGroup
        ( id, name, description, max_members,
          group_type, org_id)
        select
            :new_id, sgt.name, sgt.name, :maxnum,
            sgt.id, :org_id
        from rhnServerGroupType sgt
        where sgt.label = :group_label
        """)
        rownum = h.execute(new_id = ret_id, org_id = org_id,
                  group_label = group_label, maxnum = str(maxnum))
        if rownum == 0:
            # No rows were created, probably invalid label
            raise rhnException("Could not create new group for org=`%s'"
                               % org_id, group_label)
    else:
        ret_id = data["id"]
    return ret_id


# Adds a server to a server group
def join_server_group(server_id, server_group_id):
    # avoid useless reparses caused by different arg types
    server_id = str(server_id)
    server_group_id = str(server_group_id)

    insert_call = rhnSQL.Function("rhn_server.insert_into_servergroup_maybe",
        rhnSQL.types.NUMBER())
    ret = insert_call(server_id, server_group_id)
    # return the number of rows inserted - feel free to ignore
    return ret


# This function makes sure the necessary server groups are in place
# for a new server entry and also adds a new server to the required
# groups and channels
def create_server_setup(server_id, org_id):
    # create the rhnServerInfo record
    h = rhnSQL.prepare("""
    insert into rhnServerInfo (server_id, checkin, checkin_counter)
                       values (:server_id, sysdate, :checkin_counter)
    """)
    h.execute(server_id = server_id, checkin_counter = 0)

    # make sure we create the sw_mgr_entitled server group
    # bugzilla #203973 No longer grant the free demo entitlement
    sm_grp_id = __create_server_group('sw_mgr_entitled', org_id, 0)
    # XXX: What other groups do we need to create?

    # Do not entitle the server yet
    return 1


# checks if this server is a special kind so that we don't raise an
# abuse error for it
def __special_server(server_id):
    # if a proxy or a satellite we don't enforce this. thanks chip.
    h = rhnSQL.prepare("""
    select 1 from rhnProxyInfo where server_id = :server_id
    union
    select 1 from rhnSatelliteInfo where server_id = :server_id
    """)
    h.execute(server_id = server_id)
    ret = h.fetchone_dict()
    if ret:
        return 1
    return 0


# checkin - update the last checkin time
#         - check for abuse of service.
def checkin(server_id, commit=1, check_for_abuse=1):
    log_debug(3, server_id)
    h = rhnSQL.prepare("""
    update rhnServerInfo
    set checkin = sysdate, checkin_counter = checkin_counter + 1
    where server_id = :server_id
    """)
    h.execute(server_id = server_id)
    if commit:
        rhnSQL.commit()
    # If not checking for abuse, short-circuit the rest.
    if not CFG.ABUSE_CHECK or not check_for_abuse:
        return 1
    # now check for abusers
    h = rhnSQL.prepare("""
    select s.name, si.checkin_counter - ((sysdate - s.created) * 100) ticks
    from rhnServer s, rhnServerInfo si
    where s.id = si.server_id
    and sysdate - s.created > 7
    and s.id = :server_id
    """)
    h.execute(server_id = server_id)
    ret = h.fetchone_dict()
    if not ret:
        return 1
    # we only allow a threshold of 1500 extra connections above what we
    # think is the absolute max.
    if ret["ticks"] > 1500:
        # special servers are exempt
        if __special_server(server_id):
            return 1
        log_error("Abuse of Service", server_id)
        rhnSQL.commit() # don't leave uncommited stuff behind
        raise rhnFault(49, "Abuse of Service detected for server %s (%s)"
                           % (ret["name"], server_id), 0)
    return 1

def set_qos(server_id):
    pass

# throttle - limits access to free users if a throttle file exists
#            NOTE: current check allows for a x-hour long grace-period.
def throttle(server):
    server_id = server['id']
    log_debug(3, server_id)

    # Are we throttling?
    throttlefile = "%s/throttle" % rhnFlags.get("RootDir")
    if not os.path.exists(throttlefile):
        # We don't throttle anybody
        return
    return 

def join_rhn(org_id):
    # Stub
    return

# Given a dbiDate object, returns the UNIX representation (seconds since
# epoch)
def dbiDate2timestamp(dateobj):
    timeString = '%s %s %s %s %s %s' % (dateobj.year, dateobj.month, 
        dateobj.day, dateobj.hour, dateobj.minute, dateobj.second)
    return time.mktime(time.strptime(timeString, '%Y %m %d %H %M %S'))
    

def snapshot_server(server_id, reason):
    if CFG.ENABLE_SNAPSHOTS:
       return rhnSQL.Procedure("rhn_server.snapshot_server")(server_id, reason)


def check_entitlement(server_id):
    h = rhnSQL.prepare("""select server_id, label from rhnServerEntitlementView where server_id = :server_id""")
    h.execute(server_id = server_id)

    # if I read the old code correctly, this should do about the same thing. Basically "entitled? yay/nay" -akl.  UPDATE 12/08/06: akl says "nay".  It's official
    rows = h.fetchall_dict()
    ents = {}

    if rows:
	    for row in rows:
	        ents[row['label']] = row['label']
	    return ents

    # Empty dictionary - will act as False
    return ents

def entitlement_grants_service(entitlement, service):
    egs = rhnSQL.Function("rhn_entitlements.entitlement_grants_service",
        rhnSQL.types.STRING())
    return egs(entitlement, service)

# Push client related
# XXX should be moved to a different file?
_query_update_push_client_registration = rhnSQL.Statement("""
declare
    pragma autonomous_transaction;
begin
    update rhnPushClient 
       set name = :name,
           shared_key = :shared_key,
           state_id = :state_id,
           next_action_time = NULL,
           last_ping_time = NULL
     where server_id = :server_id;
    if sql%rowcount = 1 then
        -- Entry successfully updated
        commit;
        return;
    end if;

    insert into rhnPushClient 
           (id, server_id, name, shared_key, state_id)
    values (sequence_nextval('rhn_pclient_id_seq'), :server_id, :name, 
            :shared_key, :state_id);
    commit;
end;
""")
def update_push_client_registration(server_id):
    # Generate a new a new client name and shared key
    client_name = generate_random_string(16)
    shared_key = generate_random_string(40)
    t = rhnSQL.Table('rhnPushClientState', 'label')
    row = t['offline']
    assert row is not None
    state_id = row['id']
    
    h = rhnSQL.prepare(_query_update_push_client_registration)
    h.execute(server_id=server_id, name=client_name,
        shared_key=shared_key, state_id=state_id)
    # Get the server's (database) time
    # XXX
    timestamp = int(time.time())
    # Autonomous transaction, so no need to commit
    return timestamp, client_name, shared_key
        
_query_update_push_client_jid = rhnSQL.Statement("""
declare
    pragma autonomous_transaction;
begin
    update rhnPushClient
       set jabber_id = :jid,
           next_action_time = NULL,
           last_ping_time = NULL
     where server_id = :server_id;
    commit;
end;
""")
def update_push_client_jid(server_id, jid):
    h = rhnSQL.prepare(_query_update_push_client_jid)
    h.execute(server_id=server_id, jid=jid)
    return jid

def generate_random_string(length=20):
    if not length:
        return ''
    random_bytes = 16
    length = int(length)
    s = hashlib.new('sha1')
    s.update("%.8f" % time.time())
    s.update(str(os.getpid()))
    devrandom = open('/dev/urandom')
    result = []
    cur_length = 0
    while 1:
        s.update(devrandom.read(random_bytes))
        buf = s.hexdigest()
        result.append(buf)
        cur_length = cur_length + len(buf)
        if cur_length >= length:
            break

    devrandom.close()

    result = string.join(result, '')[:length]
    return string.lower(result)

if __name__ == '__main__':
    rhnSQL.initDB('rhnuser/rhnuser@webdev')
    print update_push_client_registration(1000102174)
