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
# Activation key related queuing functions
#

from common import log_debug
from server import rhnSQL, rhnAction, rhnServer
from server.rhnLib import ShadowAction
from server.rhnServer import server_kickstart

# the "exposed" functions
__rhnexport__ = ['schedule_deploy', 'schedule_pkg_install', ]


# queries
_query_copy_pkgs_from_shadow_action = rhnSQL.Statement("""
    insert into rhnActionPackage (id, action_id, name_id, parameter)
    select sequence_nextval('rhn_act_p_id_seq'), :new_action_id, name_id, parameter
      from rhnActionPackage
     where action_id = :action_id
""")

_query_copy_revs_from_shadow_action = rhnSQL.Statement("""
    insert into rhnActionConfigRevision (id, action_id, server_id, config_revision_id)
    select sequence_nextval('rhn_actioncr_id_seq'), :new_action_id, server_id, config_revision_id
      from rhnActionConfigRevision
     where action_id = :action_id
       and server_id = :server_id
""")

def schedule_deploy(server_id, action_id):
    log_debug(2, server_id, action_id)
    s = rhnServer.search(server_id)

    # Schedule an rhncfg install
    new_action_id = server_kickstart.schedule_rhncfg_install(server_id,
        action_id, scheduler=None)
        
    new_action_id_2 = rhnAction.schedule_server_action(
        server_id,
        action_type='configfiles.deploy',
        action_name="Activation Key Config Auto-Deploy",
        delta_time=0, scheduler=None,
        org_id=s.server['org_id'],
        prerequisite=new_action_id,
        )

    h = rhnSQL.prepare(_query_copy_revs_from_shadow_action)
    h.execute(action_id=action_id, new_action_id=new_action_id_2, 
        server_id=server_id)

    log_debug(4, "scheduled config deploy for activation key")

    raise ShadowAction("Config deploy scheduled")


# XXX this duplicates rhnAction.schedule_server_packages_update. fix that.
def schedule_pkg_install(server_id, action_id):
    s = rhnServer.search(server_id)

    new_action_id = rhnAction.schedule_server_action(
        server_id,
        action_type='packages.update',
        action_name="Activation Key Package Auto-Install",
        delta_time=0, scheduler=None,
        org_id=s.server['org_id'],
        )

    h = rhnSQL.prepare(_query_copy_pkgs_from_shadow_action)
    h.execute(action_id=action_id, new_action_id=new_action_id)

    log_debug(4, "scheduled pkg install for activation key")

    raise ShadowAction("Package install scheduled")
