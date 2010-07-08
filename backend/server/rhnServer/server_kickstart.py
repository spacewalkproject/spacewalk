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
# Kickstart-related operations
#

from common import rhnException, rhnFlags, log_debug
from server import rhnSQL, rhnAction, rhnLib, rhnChannel

def update_kickstart_session(server_id, action_id, action_status, 
        kickstart_state, next_action_type):
    log_debug(3, server_id, action_id, action_status, kickstart_state, next_action_type)
    
    # Is this a kickstart-related action?
    ks_session_id = get_kickstart_session_id(server_id, action_id)
    if ks_session_id is None:
        # Nothing more to do
        log_debug(4, "Kickstart session not found")
        return None

    # Check the current action state
    if action_status == 2:
        # Completed
        ks_status = kickstart_state
        # Get the next action - it has to be of the right type
        next_action_id = get_next_action_id(action_id, next_action_type)
    elif action_status == 3:
        # Failed
        ks_status = 'failed'
        next_action_id = None
    else:
        raise rhnException("Invalid action state %s" % action_status)

    update_ks_session_table(ks_session_id, ks_status, next_action_id,
        server_id)
    return ks_session_id

_query_update_ks_session_table = rhnSQL.Statement("""
    update rhnKickstartSession
       set action_id = :action_id,
           state_id = :ks_status_id,
           new_server_id = :server_id
     where id = :ks_session_id
""")

def update_ks_session_table(ks_session_id, ks_status, next_action_id,
        server_id):
    log_debug(4, ks_session_id, ks_status, next_action_id, server_id)
    ks_table = rhnSQL.Table('rhnKickstartSessionState', 'label')
    ks_status_id = ks_table[ks_status]['id']

    h = rhnSQL.prepare(_query_update_ks_session_table)
    h.execute(ks_session_id=ks_session_id, ks_status_id=ks_status_id,
        action_id=next_action_id, server_id=server_id)

    if ks_status == 'complete':
        delete_guests(server_id)

_query_lookup_guests_for_host = rhnSQL.Statement("""
    select virtual_system_id from rhnVirtualInstance 
        where host_system_id = :server_id
""")
_query_delete_virtual_instances = rhnSQL.Statement("""
    delete from rhnVirtualInstance where host_system_id = :server_id
""")


def delete_guests(server_id):
    """
    Callback used after a successful kickstart to remove any guest virtual
    instances, as well as their associated servers.
    """
    # First delete all the guest server objects:
    h = rhnSQL.prepare(_query_lookup_guests_for_host)
    h.execute(server_id=server_id)
    delete_server = rhnSQL.Procedure("delete_server")
    log_debug(4, "Deleting guests")
    while 1:
        row = h.fetchone_dict()
        if not row:
            break
        guest_id = row['virtual_system_id']
        log_debug(4, 'Deleting guest server: %s'% guest_id)
        try:
            if guest_id != None:
                delete_server(guest_id)
        except rhnSQL.SQLError:
            log_error("Error deleting server: %s" % guest_id)

    # Finally delete all the virtual instances:
    log_debug(4, "Deleting all virtual instances for host")
    h = rhnSQL.prepare(_query_delete_virtual_instances)
    h.execute(server_id=server_id)

    # Commit all changes:
    try:
        rhnSQL.commit()
    except rhnSQL.SQLError, e:
        log_error("Error committing transaction: %s" % e)
        rhnSQL.rollback()



_query_get_next_action_id = rhnSQL.Statement("""
    select a.id
      from rhnAction a, rhnActionType at
     where a.prerequisite = :action_id
       and a.action_type = at.id
       and at.label = :next_action_type
""")

def get_next_action_id(action_id, next_action_type = None):
    if not next_action_type:
        return None
    h = rhnSQL.prepare(_query_get_next_action_id)
    h.execute(action_id=action_id, next_action_type=next_action_type)
    row = h.fetchone_dict()
    if not row:
        return None
    return row['id']

_query_lookup_kickstart_session_id = rhnSQL.Statement("""
    select ks.id
      from rhnKickstartSession ks
     where (
             (ks.old_server_id = :server_id and ks.new_server_id is NULL) 
             or ks.new_server_id = :server_id
             or ks.host_server_id = :server_id
           )
       and ks.action_id = :action_id
""")

def get_kickstart_session_id(server_id, action_id):
    h = rhnSQL.prepare(_query_lookup_kickstart_session_id)
    h.execute(server_id=server_id, action_id=action_id)

    row = h.fetchone_dict()
    if not row:
        # Nothing to do
        return None
    return row['id']

_query_lookup_kickstart_label = rhnSQL.Statement("""
    select k.label
      from rhnKickstartSession ks, rhnKSData k
     where (
             (ks.old_server_id = :server_id and ks.new_server_id is NULL) 
             or ks.new_server_id = :server_id
             or ks.host_server_id = :server_id
           )
       and ks.action_id = :action_id
       and k.id = ks.kickstart_id
""")

def get_kickstart_label(server_id, action_id):
    h = rhnSQL.prepare(_query_lookup_kickstart_label)
    h.execute(server_id=server_id, action_id=action_id)

    row = h.fetchone_dict()
    if not row:
        # Nothing to do
        return None
    return row['label']



_query_insert_package_delta = rhnSQL.Statement("""
    insert into rhnPackageDelta (id, label)
    values (:package_delta_id, 'ks-delta-' || :package_delta_id)
""")
_query_insert_action_package_delta = rhnSQL.Statement("""
    insert into rhnActionPackageDelta (action_id, package_delta_id)
    values (:action_id, :package_delta_id)
""")
_query_insert_package_delta_element = rhnSQL.Statement("""
    insert into rhnPackageDeltaElement
           (package_delta_id, transaction_package_id)
    values 
           (:package_delta_id, 
            lookup_transaction_package(:operation, :n, :e, :v, :r, :a))
""")

def schedule_kickstart_delta(server_id, kickstart_session_id, 
        installs, removes):
    log_debug(3, server_id, kickstart_session_id)
    row = get_kickstart_session_info(kickstart_session_id, server_id)
    org_id = row['org_id']
    scheduler = row['scheduler']

    action_id = rhnAction.schedule_server_action(
        server_id,
        action_type='packages.runTransaction', action_name="Package delta",
        delta_time=0, scheduler=scheduler, org_id=org_id,
    )

    package_delta_id = rhnSQL.Sequence('rhn_packagedelta_id_seq').next()

    h = rhnSQL.prepare(_query_insert_package_delta)
    h.execute(package_delta_id=package_delta_id)

    h = rhnSQL.prepare(_query_insert_action_package_delta)
    h.execute(action_id=action_id, package_delta_id=package_delta_id)

    h = rhnSQL.prepare(_query_insert_package_delta_element)
    col_names = [ 'n', 'v', 'r', 'e']
    __execute_many(h, installs, col_names, operation='insert', a=None,
        package_delta_id=package_delta_id)
    __execute_many(h, removes, col_names, operation='delete', a=None,
        package_delta_id=package_delta_id)

    update_ks_session_table(kickstart_session_id, 'package_synch_scheduled', 
        action_id, server_id)

    return action_id
    
def schedule_kickstart_sync(server_id, kickstart_session_id):
    row = get_kickstart_session_info(kickstart_session_id, server_id)
    org_id = row['org_id']
    scheduler = row['scheduler']

    # Create a new action
    action_id = rhnAction.schedule_server_action(
        server_id,
        action_type='kickstart.schedule_sync', 
        action_name="Schedule a package sync",
        delta_time=0, scheduler=scheduler, org_id=org_id,
    )
    return action_id

def _get_ks_virt_type(type_id):
    _query_kickstart_virt_type = rhnSQL.Statement("""
        select  kvt.label label
        from    rhnKickstartVirtualizationType kvt
        where   kvt.id = :id
    """)
    prepared_query = rhnSQL.prepare(_query_kickstart_virt_type)
    prepared_query.execute(id=type_id)
    row = prepared_query.fetchone_dict()

    # XXX: we should have better constraints on the db so this doesn't happen.
    if not row:
        kstype = 'auto'
    else:
        kstype = row['label']
    log_debug(1, "KS_TYPE: %s" % kstype)
    return kstype

def get_kickstart_session_type(server_id, action_id):
    ks_session_id = get_kickstart_session_id(server_id, action_id)
    ks_session_info = get_kickstart_session_info(ks_session_id, server_id)
    ks_type_id = ks_session_info['virtualization_type']
    ks_type = _get_ks_virt_type(ks_type_id)
    return ks_type

def subscribe_to_tools_channel(server_id, kickstart_session_id):
    log_debug(3)
    row = get_kickstart_session_info(kickstart_session_id, server_id)
    org_id = row['org_id']
    scheduler = row['scheduler']
    ks_type_id = row['virtualization_type']
    ks_type = _get_ks_virt_type(ks_type_id)    

    if ks_type == 'para_host':
        action_id = rhnAction.schedule_server_action(
            server_id,
            action_type='kickstart_host.add_tools_channel',
            action_name='Subscribe server to RHN Tools channel.',
            delta_time=0, scheduler=scheduler, org_id=org_id,
        )
    elif ks_type == 'para_guest':
        action_id = rhnAction.schedule_server_action(
            server_id,
            action_type='kickstart_guest.add_tools_channel',
            action_name='Subscribe guest to RHN Tools channel.',
            delta_time=0, scheduler=scheduler, org_id=org_id,
        )
    else:
        action_id = None
    return action_id
    


def schedule_virt_pkg_install(server_id, kickstart_session_id):
    log_debug(3)
    row = get_kickstart_session_info(kickstart_session_id, server_id)
    org_id = row['org_id']
    scheduler = row['scheduler']
    ks_type_id = row['virtualization_type']
    log_debug(1, "VIRTUALIZATION_TYPE: %s" % str(ks_type_id))
    ks_type = _get_ks_virt_type(ks_type_id)
    log_debug(1, "VIRTUALZIATION_TYPE_LABEL: %s" % str(ks_type))
    
    if ks_type == 'para_host':
        log_debug(1, "SCHEDULING VIRT HOST PACKAGE INSTALL...")
        action_id = rhnAction.schedule_server_action(
            server_id,
            action_type='kickstart_host.schedule_virt_host_pkg_install',
            action_name="Schedule install of rhn-virtualization-host package.",
            delta_time=0, scheduler=scheduler, org_id=org_id,
        )
    elif ks_type == 'para_guest':
        log_debug(1, "SCHEDULING VIRT GUEST PACKAGE INSTALL...")
        action_id = rhnAction.schedule_server_action(
            server_id,
            action_type='kickstart_guest.schedule_virt_guest_pkg_install',
            action_name="Schedule install of rhn-virtualization-guest package.",
            delta_time=0, scheduler=scheduler, org_id=org_id,
        )
    else:
        log_debug(1, "NOT A VIRT KICKSTART")
        action_id = None

    return action_id
        
_query_schedule_config_files = rhnSQL.Statement("""
    insert into rhnActionConfigRevision 
           (id, action_id, server_id, config_revision_id)
    select sequence_nextval('rhn_actioncr_id_seq'), :action_id, 
           server_id, config_revision_id
      from (
            select distinct scc.server_id, 
                   cf.latest_config_revision_id config_revision_id
              from rhnServerConfigChannel scc,
                   rhnConfigChannelType cct,
                   rhnConfigChannel cc,
                   rhnConfigFile cf,
                   rhnConfigFileState cfs
             where scc.server_id = :server_id
               and scc.config_channel_id = cf.config_channel_id
               and cf.config_channel_id = cc.id
               and cc.confchan_type_id = cct.id
               and cct.label in ('normal', 'local_override')
               and cf.latest_config_revision_id is not null
               and cf.state_id = cfs.id
               and cfs.label = 'alive'
            )
""")
# schedule a configfiles.deploy action dependent on the current action
def schedule_config_deploy(server_id, action_id, kickstart_session_id,
        server_profile):
    log_debug(3, server_id, action_id, kickstart_session_id)
    row = get_kickstart_session_info(kickstart_session_id, server_id)
    org_id = row['org_id']
    scheduler = row['scheduler']
    deploy_configs = (row['deploy_configs'] == 'Y')

    if not deploy_configs:
        # Nothing more to do here
        update_ks_session_table(kickstart_session_id, 'complete',
            next_action_id=None, server_id=server_id)
        return None

    if server_profile:
        # Have to schedule a package deploy action
        aid = schedule_rhncfg_install(server_id, action_id, scheduler,
            server_profile)
    else:
        aid = action_id

    next_action_id = rhnAction.schedule_server_action(
        server_id,
        action_type='configfiles.deploy',
        action_name='Deploy config files',
        delta_time=0, scheduler=scheduler, org_id=org_id,
        prerequisite=aid,
    )
    # Deploy all of the config files that are part of this server's config
    # channels
    h = rhnSQL.prepare(_query_schedule_config_files)
    h.execute(server_id=server_id, action_id=next_action_id)
    update_ks_session_table(kickstart_session_id, 'configuration_deploy',
        next_action_id, server_id)
    return next_action_id

class MissingBaseChannelError(Exception):
    pass

def schedule_rhncfg_install(server_id, action_id, scheduler,
        server_profile=None):
    capability = 'rhn-config-action'
    try:
        packages = _subscribe_server_to_capable_channels(server_id, scheduler, 
            capability)
    except MissingBaseChannelError:
        log_debug(2, "No base channel", server_id)
        return action_id

    if not packages:
        # No channels offer this capability
        log_debug(3, server_id, action_id, 
            "No channels to provide %s found" % capability)
        # No new action needed here
        return action_id

    if not server_profile:
        server_profile = get_server_package_profile(server_id)

    # Make the package profile a hash, for easier checking
    sphash = {}
    for p in server_profile:
        sphash[tuple(p)] = None

    packages_to_install = []
    for p in packages:
        key = (p['name'], p['version'], p['release'], p['epoch'])
        if not sphash.has_key(key):
            packages_to_install.append(p['package_id'])

    if not packages_to_install:
        # We already have these pacakges installed
        log_debug(4, "No packages needed to be installed")
        return action_id
        
    log_debug(4, "Scheduling package install action")
    new_action_id = schedule_package_install(server_id, action_id, scheduler, 
        packages_to_install)
    return new_action_id

_query_lookup_subscribed_server_channels = rhnSQL.Statement("""
    select sc.channel_id, NVL2(c.parent_channel, 0, 1) is_base_channel
      from rhnServerChannel sc, rhnChannel c
     where sc.server_id = :server_id
       and sc.channel_id = c.id
""")
_query_lookup_unsubscribed_server_channels = rhnSQL.Statement("""
select c.id
  from 
      -- Get all the channels available to this org
      ( select cfm.channel_id
          from rhnChannelFamilyMembers cfm,
               rhnPrivateChannelFamily pcf
         where pcf.org_id = :org_id
           and pcf.channel_family_id = cfm.channel_family_id
           and pcf.current_members < nvl(pcf.max_members, 
                  pcf.current_members + 1)
        union
        select cfm.channel_id
          from rhnChannelFamilyMembers cfm,
               rhnPublicChannelFamily pcf
         where pcf.channel_family_id = cfm.channel_family_id) ac,
       rhnChannel c
 where c.parent_channel = :base_channel_id
   and c.id = ac.channel_id
   and  not exists (
        select 1 
          from rhnServerChannel 
         where server_id = :server_id
         and channel_id = c.id)
""")

def _subscribe_server_to_capable_channels(server_id, scheduler, capability):
    log_debug(4, server_id, scheduler, capability)
    # Look through the channels this server is already subscribed to
    h = rhnSQL.prepare(_query_lookup_subscribed_server_channels)
    h.execute(server_id=server_id)
    base_channel_id = None
    channels = []
    while 1:
        row = h.fetchone_dict()
        if not row:
            break
        channel_id = row['channel_id']
        if row['is_base_channel']:
            base_channel_id = channel_id
        channels.append((channel_id, 1))
    if base_channel_id is None:
        raise MissingBaseChannelError()

    org_id = rhnSQL.Table('rhnServer', 'id')[server_id]['org_id']
        
    # Get the child channels this system is *not* subscribed to
    h = rhnSQL.prepare(_query_lookup_unsubscribed_server_channels)
    h.execute(server_id=server_id, org_id=org_id,
        base_channel_id=base_channel_id)
    l = map(lambda x: (x['id'], 0), h.fetchall_dict() or [])
    channels.extend(l)
    # We now have a list of channels; look for one that provides the
    # capability
    for channel_id, is_subscribed in channels:
        log_debug(5, "Checking channel:", channel_id, "; subscribed:",
            is_subscribed)
        packages = _channel_provides_capability(channel_id, capability)
        if packages:
            if is_subscribed:
                log_debug(4, "Already subscribed; found packages", packages)
                return packages

            # Try to subscribe to it
            try:
                rhnChannel._subscribe_sql(server_id, channel_id, 0)
            except rhnChannel.SubscriptionCountExceeded:
                # Try another one
                continue
            log_debug(4, "Subscribed to", channel_id, 
                "Found packages", packages)
            # We subscribed to this channel - we're done
            return packages
            
    # No channels provide this capability - we're done
    log_debug(4, "No channels to provide capability", capability)
    return None

_query_channel_provides_capability = rhnSQL.Statement("""
    select distinct pp.package_id, pn.name, pe.version, pe.release, pe.epoch
      from rhnChannelNewestPackage cnp,
           rhnPackageProvides pp,
           rhnPackageCapability pc,
           rhnPackageName pn,
           rhnPackageEVR pe
     where cnp.channel_id = :channel_id
       and cnp.package_id = pp.package_id
       and pp.capability_id = pc.id
       and pc.name = :capability
       and cnp.name_id = pn.id
       and cnp.evr_id = pe.id
""")

def _channel_provides_capability(channel_id, capability):
    log_debug(4, channel_id, capability)
    h = rhnSQL.prepare(_query_channel_provides_capability)
    h.execute(channel_id=channel_id, capability=capability)
    ret = h.fetchall_dict()
    if not ret:
        return ret
    return ret
    
_query_insert_action_packages = rhnSQL.Statement("""
    insert into rhnActionPackage 
           (id, action_id, name_id, evr_id, package_arch_id, parameter)
    select sequence_nextval('rhn_act_p_id_seq'), :action_id, name_id, evr_id,
           package_arch_id, 'upgrade'
      from rhnPackage
     where id = :package_id
""")
def schedule_package_install(server_id, action_id, scheduler, packages):
    if not packages:
        # Nothing to do
        return action_id
    new_action_id = rhnAction.schedule_server_action(
        server_id, action_type='packages.update', 
        action_name="Package update to enable configuration deployment",
        delta_time=0, scheduler=scheduler, prerequisite=action_id,
    )
    # Add entries to rhnActionPackage
    action_ids = [ new_action_id ] * len(packages)
    h = rhnSQL.prepare(_query_insert_action_packages)
    h.executemany(action_id=action_ids, package_id=packages)
    return new_action_id

# Execute the cursor, with arguments extracted from the array
# The array is converted into a hash having col_names as keys, and adds
# whatever kwarg was specified too.
def __execute_many(cursor, array, col_names, **kwargs):
    linecount = len(array)
    if not linecount:
        return
    # Transpose the array into a hash with col_names as keys
    params = rhnLib.transpose_to_hash(array, col_names)
    for k, v in kwargs.items():
        params[k] = [ v ] * linecount

    apply(cursor.executemany, (), params)

def _packages_from_cursor(cursor):
    result = []
    while 1:
        row = cursor.fetchone_dict()
        if not row:
            break
        p_name = row['name']
        if p_name == 'gpg-pubkey':
            # We ignore GPG public keys since they are too weird to schedule
            # as a package delta
            continue
        result.append((p_name, row['version'], row['release'],
            row['epoch'] or ''))
    return result

_query_lookup_pending_kickstart_sessions = rhnSQL.Statement("""
    select ks.id, ks.action_id, NULL other_server_id
      from rhnKickstartSessionState kss,
           rhnKickstartSession ks
     where (
             (ks.old_server_id = :server_id and ks.new_server_id is null)
             or ks.new_server_id = :server_id
           )
       and ks.state_id = kss.id
       and kss.label not in ('complete', 'failed')
       and (:ks_session_id is null or ks.id != :ks_session_id)
""")

_query_terminate_pending_kickstart_sessions = rhnSQL.Statement("""
    update rhnKickstartSession
       set action_id = NULL,
           state_id = :state_id
     where id = :kickstart_session_id
""")

def terminate_kickstart_sessions(server_id):
    log_debug(3, server_id)
    history = []
    tokens_obj = rhnFlags.get('registration_token')
    current_ks_session_id = tokens_obj.get_kickstart_session_id()
    # ks_session_id can be null
    h = rhnSQL.prepare(_query_lookup_pending_kickstart_sessions)
    h.execute(server_id=server_id, ks_session_id=current_ks_session_id)
    log_debug(4, "current_ks_session_id", current_ks_session_id)
    ks_session_ids = []
    action_ids = []
    while 1:
        row = h.fetchone_dict()
        if not row:
            break
        ks_session_ids.append(row['id'])
        action_ids.append(row['action_id'])

    if not ks_session_ids:
        # Nothing to do
        log_debug(4, "Nothing to do", server_id, current_ks_session_id)
        return []

    ks_session_table = rhnSQL.Table('rhnKickstartSessionState', 'label')
    state_id_failed = ks_session_table['failed']['id']
    state_ids = [state_id_failed] * len(ks_session_ids)

    # Add a history item
    for ks_session_id in ks_session_ids:
        log_debug(4, "Adding history entry for session id", ks_session_id)
        history.append(("Kickstart session canceled", 
            "A kickstart session for this system was canceled because "
            "the system was re-registered with token <strong>%s</strong>" %
            tokens_obj.get_names()))

    h = rhnSQL.prepare(_query_terminate_pending_kickstart_sessions)

    params = {
        'kickstart_session_id' : ks_session_ids,
        'state_id'      : state_ids,
    }
    # Terminate pending actions
    log_debug(4, "Terminating sessions", params)
    h.execute_bulk(params)

    # Invalidate pending actions
    for action_id in action_ids:
        if action_id is None:
            continue
        rhnAction.invalidate_action(server_id, action_id)
    return history


# Fetches the package profile from the kickstart session
def get_kisckstart_session_package_profile(kickstart_session_id):
    h = rhnSQL.prepare("""
        select pn.name, pe.version, pe.release, pe.epoch, pa.label
          from rhnKickstartSession ks,
               rhnServerProfilePackage spp,
               rhnPackageName pn,
               rhnPackageEVR pe,
               rhnPackageArch pa
         where ks.id = :kickstart_session_id
           and ks.server_profile_id = spp.server_profile_id
           and spp.name_id = pn.id
           and spp.evr_id = pe.id
           and spp.package_arch_id = pa.id
    """)
    h.execute(kickstart_session_id=kickstart_session_id)
    return _packages_from_cursor(h)

def get_server_package_profile(server_id):
    # XXX misa 2005-05-25  May need to look at package arches too
    h = rhnSQL.prepare("""
        select pn.name, pe.version, pe.release, pe.epoch, pa.label
          from rhnServerPackage sp,
               rhnPackageName pn,
               rhnPackageEVR pe,
               rhnPackageArch pa
         where sp.server_id = :server_id
           and sp.name_id = pn.id
           and sp.evr_id = pe.id
           and sp.package_arch_id = pa.id
    """)
    h.execute(server_id=server_id)
    return _packages_from_cursor(h)

_query_get_kickstart_session_info = rhnSQL.Statement("""
    select org_id, scheduler, deploy_configs, virtualization_type
      from rhnKickstartSession
     where id = :kickstart_session_id
""")

def get_kickstart_session_info(kickstart_session_id, server_id):
    h = rhnSQL.prepare(_query_get_kickstart_session_info)
    h.execute(kickstart_session_id=kickstart_session_id)
    row = h.fetchone_dict()
    if not row:
        raise rhnException("Could not fetch kickstart session id %s "
            "for server %s" % (kickstart_session_id, server_id))

    return row

_query_lookup_ks_server_profile = rhnSQL.Statement("""
    select kss.server_profile_id
      from rhnServerProfileType spt,
           rhnServerProfile sp,
           rhnKickstartSession kss
     where kss.id = :ks_session_id
       and kss.server_profile_id = sp.id
       and sp.profile_type_id = spt.id
       and spt.label = :profile_type_label
""")
_query_delete_server_profile = rhnSQL.Statement("""
    delete from rhnServerProfile where id = :server_profile_id
""")

def cleanup_profile(server_id, action_id, ks_session_id, action_status):
    if ks_session_id is None:
        log_debug(4, "No kickstart session")
        return
    if action_status != 2:
        log_debug(4, "Action status: %s; nothing to do" % action_status)
        return

    h = rhnSQL.prepare(_query_lookup_ks_server_profile)
    h.execute(ks_session_id=ks_session_id, profile_type_label='sync_profile')
    row = h.fetchone_dict()
    if not row:
        log_debug(4, "No server profile of the right type found; nothing to do")
        return

    server_profile_id = row['server_profile_id']
    if server_profile_id is None:
        log_debug(4, "No server profile associated with this kickstart session")
        return

    # There is an "on delete cascade" constraint on
    # rhnKickstartSession.server_profile_id and on
    # rhnServerProfilePacakge.server_profile_id
    h = rhnSQL.prepare(_query_delete_server_profile)
    h.execute(server_profile_id=server_profile_id)

