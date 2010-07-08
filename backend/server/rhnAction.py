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

from common import log_debug
from server import rhnSQL

def schedule_action(action_type, action_name=None, delta_time=0,
                    scheduler=None, org_id=None, prerequisite=None):
    action_id = rhnSQL.Sequence('rhn_event_id_seq').next()
    
    at = rhnSQL.Table('rhnActionType', 'label')
    if not at.has_key(action_type):
        raise ValueError("Unknown action type %s" % action_type)


    params = {
        'action_id'         : action_id,
        'org_id'            : org_id,
        'action_type_id'    : at[action_type]['id'],
        'action_name'       : action_name,
        'delta'             : delta_time,   
        'scheduler'         : scheduler,
        'prerequisite'      : prerequisite,
    }

    h = rhnSQL.prepare("""
        insert into rhnAction 
               (id, org_id, action_type, name, scheduler, earliest_action, prerequisite)
        values (:action_id, :org_id, :action_type_id, :action_name, :scheduler, 
                sysdate + :delta / 86400, :prerequisite) 
    """)
    apply(h.execute, (), params)

    return action_id


def schedule_server_action(server_id, action_type, action_name=None,
        delta_time=0, scheduler=None, org_id=None, prerequisite=None):
    if not org_id:
        h = rhnSQL.prepare("select org_id from rhnServer where id = :id")
        h.execute(id=server_id)
        row = h.fetchone_dict()
        if not row:
            raise ValueError("Invalid server id %s" % server_id)
        org_id = row['org_id']

    action_id = schedule_action(action_type,
                                action_name,
                                delta_time=delta_time,
                                scheduler=scheduler,
                                org_id=org_id,
                                prerequisite=prerequisite,
                                )


    # Insert an action as Queued
    h = rhnSQL.prepare("""
        insert into rhnServerAction (server_id, action_id, status)
        values (:server_id, :action_id, 0)
    """)
    h.execute(server_id=server_id, action_id=action_id)

    return action_id

def update_server_action(server_id, action_id, status, result_code=None,
            result_message=""):
    log_debug(4, server_id, action_id, status, result_code, result_message)
    h = rhnSQL.prepare("""
    update rhnServerAction
        set status = :status,
            result_code = :result_code,
            result_msg  = :result_message,
            completion_time = SYSDATE
    where action_id = :action_id
      and server_id = :server_id
    """)
    h.execute(action_id=action_id, server_id=server_id,
              status=status, result_code=result_code,
              result_message=result_message[:1024])


_query_lookup_action = rhnSQL.Statement("""
    select sa.action_id, sa.status
      from rhnServerAction sa,
         (
          select id
            from rhnAction
           start with id = :action_id
                 connect by prior id = prerequisite
         ) a
     where sa.server_id = :server_id
       and sa.action_id = a.id
""")

def invalidate_action(server_id, action_id):
    log_debug(4, server_id, action_id)
    h = rhnSQL.prepare(_query_lookup_action)
    h.execute(server_id=server_id, action_id=action_id)

    # Data structures for the update
    a_ids = []
    while 1:
        row = h.fetchone_dict()
        if not row:
            break

        if row['status'] == 3:
            # Already failed
            continue
        c_action_id = row['action_id']
        a_ids.append(c_action_id)
        update_server_action(server_id=server_id, action_id=c_action_id,
            status=3, result_code=-100, result_message="Prerequisite failed")

    return a_ids

_query_schedule_server_packages_update = rhnSQL.Statement("""
    insert into rhnActionPackage (id, action_id, name_id, parameter)
    values (sequence_nextval('rhn_act_p_id_seq'), :action_id, :name_id, 'upgrade')
""")

def schedule_server_packages_update(server_id, package_ids, org_id = None,
        prerequisite = None, action_name = "Package update"):
    action_id = schedule_server_action(server_id, 
            action_type = 'packages.update', action_name = action_name,
            org_id = org_id, prerequisite = prerequisite)

    h = rhnSQL.prepare(_query_schedule_server_packages_update)

    h.execute_bulk({
        'action_id' : [action_id] * len(package_ids),
        'name_id'   : package_ids,
    })

_query_schedule_server_packages_update_by_arch = rhnSQL.Statement("""
    insert into rhnActionPackage (id, action_id, name_id, package_arch_id, \
           parameter)
    values (sequence_nextval('rhn_act_p_id_seq'), :action_id, :name_id, :arch_id, \
           'upgrade')
""")

def schedule_server_packages_update_by_arch(server_id, package_arch_ids, org_id = None, prerequisite = None, action_name = "Package update"):
    action_id = schedule_server_action(server_id,
            action_type = 'packages.update', action_name = action_name,
            org_id = org_id, prerequisite = prerequisite)
    h = rhnSQL.prepare(_query_schedule_server_packages_update_by_arch)

    for name_id, arch_id in package_arch_ids:
        h.execute(action_id=action_id, name_id=name_id, arch_id=arch_id)

