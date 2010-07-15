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
from server.rhnLib import InvalidAction, ShadowAction
from server.action.utils import SubscribedChannel, \
                                ChannelPackage, \
                                PackageInstallScheduler, \
                                NoActionInfo, \
                                PackageNotFound
from server.rhnChannel import subscribe_to_tools_channel
                                 

__rhnexport__ = ['initiate', 'schedule_virt_guest_pkg_install', 'add_tools_channel']

_query_initiate_guest = rhnSQL.Statement("""
 select  ksd.label as profile_name, akg.kickstart_host, kvt.label as virt_type, 
       akg.mem_kb, akg.vcpus, akg.disk_path, akg.virt_bridge, akg.cobbler_system_name, 
       akg.disk_gb, akg.append_string, 
       akg.guest_name, akg.ks_session_id from rhnActionKickstartGuest akg, 
        rhnKSData ksd, rhnKickstartSession ksess,
       rhnKickstartDefaults ksdef, rhnKickstartVirtualizationType kvt
     where akg.action_id = :action_id
       and ksess.kickstart_id = ksd.id
       and ksess.id = akg.ks_session_id
       and ksdef.kickstart_id = ksd.id
       and ksdef.virtualization_type = kvt.id       
""")

def schedule_virt_guest_pkg_install(server_id, action_id, dry_run=0):
    """
        ShadowAction that schedules a package installation action for the
        rhn-virtualization-guest package.
    """
    log_debug(3)
    
    virt_host_package_name = "rhn-virtualization-guest"
    tools_channel = SubscribedChannel(server_id, "rhn-tools")
    found_tools_channel = tools_channel.is_subscribed_to_channel()

    if not found_tools_channel:
        raise InvalidAction("System not subscribed to the RHN Tools channel.")

    rhn_v12n_package = ChannelPackage(server_id, virt_host_package_name)

    if not rhn_v12n_package.exists():
        raise InvalidAction("Could not find the rhn-virtualization-guest package.")

    try:
        install_scheduler = PackageInstallScheduler(server_id, action_id, rhn_v12n_package)
        if (not dry_run):
            install_scheduler.schedule_package_install()
        else:
            log_debug(4, "dry run requested")
    except NoActionInfo, nai:
        raise InvalidAction(str(nai))
    except PackageNotFound, pnf:
        raise InvalidAction(str(pnf))
    except Exception, e:
        raise InvalidAction(str(e))

    log_debug(3, "Completed scheduling install of rhn-virtualization-guest!")
    raise ShadowAction("Scheduled installation of RHN Virtualization Guest packages.")

def initiate(server_id, action_id, dry_run=0):
    log_debug(3)
    h = rhnSQL.prepare(_query_initiate_guest)
    h.execute(action_id=action_id)
    row = h.fetchone_dict()

    if not row:
        raise InvalidAction("Kickstart action without an associated kickstart")
    
    kickstart_host  = row['kickstart_host']
    virt_type       = row['virt_type']
    name            = row['guest_name']
    boot_image      = "spacewalk-koan"
    append_string   = row['append_string']
    vcpus           = row['vcpus']
    disk_gb         = row['disk_gb']
    mem_kb          = row['mem_kb']
    ks_session_id   = row['ks_session_id']
    virt_bridge     = row['virt_bridge']
    disk_path       = row['disk_path']
    cobbler_system_name = row['cobbler_system_name'] 
    
    if not boot_image:
        raise InvalidAction("Boot image missing")

    return (kickstart_host, cobbler_system_name, virt_type, ks_session_id, name,
                mem_kb, vcpus, disk_gb, virt_bridge, disk_path, append_string)

def add_tools_channel(server_id, action_id, dry_run=0):
    log_debug(3)
    if (not dry_run):
        subscribe_to_tools_channel(server_id)
    else:
        log_debug(4, "dry run requested")
    raise ShadowAction("Subscribed guest to tools channel.")
