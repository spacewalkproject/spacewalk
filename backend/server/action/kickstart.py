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
#

from common import log_debug
from server import rhnSQL
from server.rhnLib import InvalidAction, ShadowAction
from server.rhnServer import server_kickstart, server_packages

# the "exposed" functions
__rhnexport__ = ['initiate', 'schedule_sync']

_query_initiate = rhnSQL.Statement("""
    select ak.append_string, ak.static_device, ak.kickstart_host, ak.cobbler_system_name
      from rhnActionKickstart ak, rhnKickstartableTree kst 
     where ak.action_id = :action_id
""")

_query_file_list_initiate= rhnSQL.Statement("""
    select distinct rcfn.path
      from rhnActionKickstartFileList akfl,
           rhnFileListMembers rflm,
           rhnConfigFileName rcfn,
           rhnActionKickstart ak
     where rcfn.id = rflm.config_file_name_id
       and akfl.file_list_id = rflm.file_list_id
       and akfl.action_ks_id = ak.id
       and ak.action_id = :action_id
""")

def initiate(server_id, action_id, dry_run=0):
    log_debug(3)
    h = rhnSQL.prepare(_query_initiate)
    h.execute(action_id=action_id)
    row = h.fetchone_dict()
    if not row:
        raise InvalidAction("Kickstart action without an associated kickstart")
    boot_image, append_string = ('spacewalk-koan', row['append_string'])
    static_device = row['static_device'] or ""
    kickstart_host = row['kickstart_host']
    system_record = row['cobbler_system_name']
    if system_record == None:
       system_record = ''
    if not boot_image:
        raise InvalidAction("Boot image missing")
    if not kickstart_host:
        raise InvalidAction("Kickstart_host missing")
        
    h = rhnSQL.prepare(_query_file_list_initiate)
    h.execute(action_id=action_id)
    files = map(lambda x: x['path'], h.fetchall_dict() or [])
    
    return (kickstart_host, boot_image, append_string, static_device, system_record, files)

def schedule_sync(server_id, action_id, dry_run=0):
    log_debug(3, server_id, action_id)
    if dry_run:
        raise ShadowAction("dry run requested - skipping")

    kickstart_session_id = server_kickstart.get_kickstart_session_id(server_id, 
        action_id)
    
    if kickstart_session_id is None:
        raise InvalidAction("Could not find kickstart session ID")

    row = server_kickstart.get_kickstart_session_info(kickstart_session_id, server_id)
    deploy_configs = (row['deploy_configs'] == 'Y')
    
    ks_package_profile = server_kickstart.get_kisckstart_session_package_profile(kickstart_session_id)
    #if the session doesn't have a pkg profile, try from the ks profile itself
    if not ks_package_profile:
        ks_package_profile = server_kickstart.get_kickstart_profile_package_profile(kickstart_session_id)

    if not ks_package_profile:
        log_debug(4, "No kickstart package profile")
        # No profile to bring this system to
        if deploy_configs:
            # We have to deploy configs, so pass in a server profile
            server_profile = server_kickstart.get_server_package_profile(server_id)
        else:
            # No configs to be deployed
            server_profile = None

        server_kickstart.schedule_config_deploy(server_id,
            action_id, kickstart_session_id, server_profile=server_profile)
        raise ShadowAction("Package sync not scheduled, missing kickstart "
            "package profile; proceeding with configfiles.deploy")

    server_profile = server_kickstart.get_server_package_profile(server_id)

    installs, removes = server_packages.package_delta(server_profile,
        ks_package_profile)

    if not (installs or removes):
        log_debug(4, "No packages to be installed/removed")
        if not deploy_configs:
            server_profile = None
        
        server_kickstart.schedule_config_deploy(server_id,
            action_id, kickstart_session_id, server_profile=None)
        raise ShadowAction("Package sync not scheduled, nothing to do")

    log_debug(4, "Scheduling kickstart delta")
    server_kickstart.schedule_kickstart_delta(server_id, 
        kickstart_session_id, installs, removes)

    raise ShadowAction("Package sync scheduled")
