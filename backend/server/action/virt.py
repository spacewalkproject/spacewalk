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


from common import log_debug
from server import rhnSQL
from server.rhnLib import InvalidAction

__rhnexport__ = [   'refresh',
                    'shutdown',
                    'reboot',
                    'resume',
                    'start',
                    'schedulePoller',
                    'suspend',
                    'destroy',
                    'setMemory',
                    'setVCPUs'
                ]

###########################################################################
# SQL Queries for each virtualization action type.
###########################################################################
_query_refresh = rhnSQL.Statement("""
    select  avf.action_id,
    from    rhnActionVirtRefresh
    where   avf.action_id = :action_id
""")

_query_shutdown = rhnSQL.Statement("""
    select  avs.action_id, 
            avs.uuid
    from    rhnActionVirtShutdown avs
    where   avs.action_id = :action_id
""")

_query_suspend = rhnSQL.Statement("""
    select  avs.action_id,
            avs.uuid
    from    rhnActionVirtSuspend avs    
    where   avs.action_id = :action_id
""")

_query_resume = rhnSQL.Statement("""
    select  avr.action_id,
            avr.uuid
    from    rhnActionVirtResume avr
    where   avr.action_id = :action_id
""")

_query_reboot = rhnSQL.Statement("""
    select  avr.action_id,
            avr.uuid
    from    rhnActionVirtReboot avr
    where   avr.action_id = :action_id

""")

_query_destroy = rhnSQL.Statement("""
    select  avd.action_id,
            avd.uuid
    from    rhnActionVirtDestroy avd
    where   avd.action_id = :action_id
""")

_query_start = rhnSQL.Statement("""
    select  avs.action_id,
            avs.uuid
    from    rhnActionVirtStart avs
    where   avs.action_id = :action_id
""")

_query_setMemory = rhnSQL.Statement("""
    select  asm.action_id,
            asm.uuid,
            asm.memory
    from    rhnActionVirtSetMemory asm
    where   asm.action_id = :action_id
""")

_query_getVCPUs = rhnSQL.Statement("""
    select  av.action_id,
            av.uuid,
            av.vcpu
    from    rhnActionVirtVCPU av
    where   av.action_id = :action_id
""")

_query_schedulePoller = rhnSQL.Statement("""
    select  asp.action_id,
            asp.minute,
            asp.hour,
            asp.dom,
            asp.month,
            asp.dow
    from    rhnActionVirtSchedulePoller asp
    where   asp.action_id = :action_id
""")

##########################################################################
# Functions that return the correct parameters that the actions are
# called with. They all take in the server_id and action_id as params.
##########################################################################
class NoUUIDException(Exception):
    def __init__(self):
        Exception.__init__(self)

class NoRowFoundException(Exception):
    def __init__(self):
        Exception.__init__(self)

def _get_uuid(query_str, action_id):
    log_debug(3)

    prepared_query = rhnSQL.prepare(query_str)
    prepared_query.execute(action_id=action_id)
    row = prepared_query.fetchone_dict()

    if not row:
        raise NoRowFoundException()

    if not row.has_key('uuid'):
        raise NoUUIDException()

    uuid = row['uuid']
    return uuid

#Returns an empty tuple, since the virt.refresh action has no params.
def refresh(server_id, action_id, dry_run=0):
    log_debug(3, dry_run)

    prepared_query = rhnSQL.prepare(_query_refresh)
    prepared_query.execute(action_id=action_id)
    row = prepared_query.fetchone_dict()

    if not row:
        raise NoRowFoundException()

    #Sanity check. If this doesn't pass then something is definitely screwed up.
    if not row['action_id']:
        raise InvalidAction("Refresh action is missing an action_id.")

    return ()

#Returns a uuid
def start(server_id, action_id, dry_run=0):
    log_debug(3, dry_run)
    try:
        uuid = _get_uuid(_query_start, action_id)
    except NoRowFoundException:
        raise InvalidAction("No start actions found.")
    except NoUUIDException:
        raise InvalidAction("Start action %s has no uuid associated with it." % str(action_id))
    return (uuid,)

#Returns a uuid.
def shutdown(server_id, action_id, dry_run=0):
    log_debug(3, dry_run)
    try:
        uuid = _get_uuid(_query_shutdown, action_id)
    except NoRowFoundException:
        raise InvalidAction("No shutdown actions found.")
    except NoUUIDException:
        raise InvalidAction("Shutdown action %s has no uuid associated with it." % str(action_id))
    return (uuid,)

#Returns a uuid.
def suspend(server_id, action_id, dry_run=0):
    log_debug(3, dry_run)
    try:
        uuid = _get_uuid(_query_suspend, action_id)
    except NoRowFoundException:
        raise InvalidAction("No suspend actions found.")
    except NoUUIDException:
        raise InvalidAction("Suspend action %s has no uuid associated with it." % str(action_id))
    return (uuid,)


#Returns a uuid.
def resume(server_id, action_id, dry_run=0):
    log_debug(3, dry_run)
    try:
        uuid = _get_uuid(_query_resume, action_id)
    except NoRowFoundException:
        raise InvalidAction("No resume actions found.")
    except NoUUIDException:
        raise InvalidAction("Resume action %s has no uuid associated with it." % str(action_id))
    return (uuid,)

#Returns a uuid.
def reboot(server_id, action_id, dry_run=0):
    log_debug(3, dry_run)
    try:
        uuid = _get_uuid(_query_reboot, action_id)
    except NoRowFoundException:
        raise InvalidAction("No reboot actions found.")
    except NoUUIDException:
        raise InvalidAction("Reboot action %s has no uuid associated with it." % str(action_id))
    return (uuid,)

#Returns a uuid.
def destroy(server_id, action_id, dry_run=0):
    log_debug(3, dry_run)
    try:
        uuid = _get_uuid(_query_destroy, action_id)
    except NoRowFoundException:
        raise InvalidAction("No destroy actions found.")
    except NoUUIDException:
        raise InvalidAction("Destroy action %s has no uuid associated with it." % str(action_id))
    return (uuid,)

#Returns a uuid and the amount of memory to allocate to the domain.
def setMemory(server_id, action_id, dry_run=0):
    log_debug(3, dry_run)

    prepared_query = rhnSQL.prepare(_query_setMemory)
    prepared_query.execute(action_id=action_id)
    row = prepared_query.fetchone_dict()

    if not row:
        raise InvalidAction("No setMemory actions found.")

    if not row.has_key('uuid'):
        raise InvalidAction("Set Memory action %s has no uuid." % str(action_id))

    if not row.has_key('memory'):
        raise InvalidAction("setMemory action %s has no memory set." % str(action_id))

    uuid = row['uuid']
    memory = row['memory']

    return (uuid, memory)

#Returns a uuid and the amount of VCPUs to allocate to the domain.
def setVCPUs(server_id, action_id, dry_run=0):
    log_debug(3, dry_run)

    prepared_query = rhnSQL.prepare(_query_getVCPUs)
    prepared_query.execute(action_id=action_id)
    row = prepared_query.fetchone_dict()

    if not row:
        raise InvalidAction("No VCPU actions found.")

    return row['uuid'], row['vcpu']


#Returns the minute, hour, dom, month, and dow to call schedulePoller with.
def schedulePoller(server_id, action_id, dry_run=0):
    log_debug(3, dry_run)

    prepared_query = rhnSQL.prepare(_query_schedulePoller)
    prepared_query.execute(action_id=action_id)
    row = prepared_query.fetchone_dict()

    if not row:
        raise InvalidAction("No schedulePoller actions found.")

    if not row.has_key('minute'):
        raise InvalidAction("schedulePoller action %s has no minute associated with it." % str(action_id))

    if not row.has_key('hour'):
        raise InvalidAction("schedulePoller action %s has no hour associated with it." % str(action_id))

    if not row.has_key('dom'):
        raise InvalidAction("schedulePoller action %s has no day of the month associated with it." % str(action_id))

    if not row.has_key('month'):
        raise InvalidAction("schedulePoller action %s has no month associated with it." % str(action_id))

    if not row.has_key('dow'):
        raise InvalidAction("schedulePoller action %s has no day of the week associated with it." % str(action_id))

    return (row['minute'], row['hour'], row['dom'], row['month'], row['dow'])

