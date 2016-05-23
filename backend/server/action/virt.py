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

import sys
from spacewalk.common.rhnLog import log_debug
from spacewalk.server import rhnSQL
from spacewalk.server.rhnLib import InvalidAction
from spacewalk.common.usix import raise_with_tb

__rhnexport__ = ['refresh',
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

    if 'uuid' not in row:
        raise NoUUIDException()

    uuid = row['uuid']
    return uuid

# Returns an empty tuple, since the virt.refresh action has no params.


def refresh(server_id, action_id, dry_run=0):
    log_debug(3, dry_run)

    prepared_query = rhnSQL.prepare(_query_refresh)
    prepared_query.execute(action_id=action_id)
    row = prepared_query.fetchone_dict()

    if not row:
        raise NoRowFoundException()

    # Sanity check. If this doesn't pass then something is definitely screwed up.
    if not row['action_id']:
        raise InvalidAction("Refresh action is missing an action_id.")

    return ()

# Returns a uuid


def action(action_name, query, server_id, action_id, dry_run=0):
    log_debug(3, action_name, dry_run)
    try:
        uuid = _get_uuid(query, action_id)
    except NoRowFoundException:
        raise_with_tb(InvalidAction("No %s actions found." % action_name.lower()), sys.exc_info()[2])
    except NoUUIDException:
        raise_with_tb(InvalidAction("%s action %s has no uuid associated with it." %
                            (action_name, str(action_id))), sys.exc_info()[2])
    return (uuid,)


def start(server_id, action_id, dry_run=0):
    return action("Start", _query_start, server_id, action_id, dry_run=0)


def shutdown(server_id, action_id, dry_run=0):
    return action("Shutdown", _query_shutdown, server_id, action_id, dry_run=0)


def suspend(server_id, action_id, dry_run=0):
    return action("Suspend", _query_suspend, server_id, action_id, dry_run=0)


def resume(server_id, action_id, dry_run=0):
    return action("Resume", _query_resume, server_id, action_id, dry_run=0)


def reboot(server_id, action_id, dry_run=0):
    return action("Reboot", _query_reboot, server_id, action_id, dry_run=0)


def destroy(server_id, action_id, dry_run=0):
    return action("Destroy", _query_destroy, server_id, action_id, dry_run=0)

# Returns a uuid and the amount of memory to allocate to the domain.


def setMemory(server_id, action_id, dry_run=0):
    log_debug(3, dry_run)

    prepared_query = rhnSQL.prepare(_query_setMemory)
    prepared_query.execute(action_id=action_id)
    row = prepared_query.fetchone_dict()

    if not row:
        raise InvalidAction("No setMemory actions found.")

    if 'uuid' not in row:
        raise InvalidAction("Set Memory action %s has no uuid." % str(action_id))

    if 'memory' not in row:
        raise InvalidAction("setMemory action %s has no memory set." % str(action_id))

    uuid = row['uuid']
    memory = row['memory']

    return (uuid, memory)

# Returns a uuid and the amount of VCPUs to allocate to the domain.


def setVCPUs(server_id, action_id, dry_run=0):
    log_debug(3, dry_run)

    prepared_query = rhnSQL.prepare(_query_getVCPUs)
    prepared_query.execute(action_id=action_id)
    row = prepared_query.fetchone_dict()

    if not row:
        raise InvalidAction("No VCPU actions found.")

    return row['uuid'], row['vcpu']


# Returns the minute, hour, dom, month, and dow to call schedulePoller with.
def schedulePoller(server_id, action_id, dry_run=0):
    log_debug(3, dry_run)

    prepared_query = rhnSQL.prepare(_query_schedulePoller)
    prepared_query.execute(action_id=action_id)
    row = prepared_query.fetchone_dict()

    if not row:
        raise InvalidAction("No schedulePoller actions found.")

    if 'minute' not in row:
        raise InvalidAction("schedulePoller action %s has no minute associated with it." % str(action_id))

    if 'hour' not in row:
        raise InvalidAction("schedulePoller action %s has no hour associated with it." % str(action_id))

    if 'dom' not in row:
        raise InvalidAction("schedulePoller action %s has no day of the month associated with it." % str(action_id))

    if 'month' not in row:
        raise InvalidAction("schedulePoller action %s has no month associated with it." % str(action_id))

    if 'dow' not in row:
        raise InvalidAction("schedulePoller action %s has no day of the week associated with it." % str(action_id))

    return (row['minute'], row['hour'], row['dom'], row['month'], row['dow'])
