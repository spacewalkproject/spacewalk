#
# Copyright (c) 2008--2009 Red Hat, Inc.
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
# this module handles the token registration code for a server
#

import string

from cStringIO import StringIO
from sets import Set

from common import rhnFlags
from common import rhnFault, rhnException, log_error, log_debug
from common.rhnTranslate import _
from server import rhnSQL, rhnChannel, rhnAction

from server_lib import join_server_group

VIRT_ENT_LABEL = 'virtualization_host'
VIRT_PLATFORM_ENT_LABEL = 'virtualization_host_platform'

# Convert a SQLError exception into the appropriate text
def sql_exception_text(e):
    if isinstance(e, rhnSQL.SQLSchemaError):
        return e.errmsg
    return str(e)

# Handle channel subscriptions for the registration token
def token_channels(server, server_arch, tokens_obj):
    assert(isinstance(tokens_obj, ActivationTokens))

    server_id, server_arch_id = server['id'], server['server_arch_id']

    # what channels are associated with this token (filter only those
    # compatible with this server)
    h = rhnSQL.prepare("""
    select 
        rtc.channel_id id, c.name, c.label, c.parent_channel
    from 
        rhnRegTokenChannels rtc, 
        rhnChannel c, 
        rhnServerChannelArchCompat scac
    where rtc.token_id = :token_id
        and rtc.channel_id = c.id
        and c.channel_arch_id = scac.channel_arch_id
        and scac.server_arch_id = :server_arch_id
    """)

    chash = {}
    base_channel_token = None
    base_channel_id = None
    
    for token in tokens_obj.tokens:
        token_id = token['token_id']
        h.execute(token_id=token_id, server_arch_id=server_arch_id)
        while 1:
            row = h.fetchone_dict()
            if not row:
                break
            channel_id = row['id']
            chash[channel_id] = row
            if row['parent_channel'] is not None:
                # Not a base channel
                continue

            # We only allow for one base channel
            if base_channel_id is not None and channel_id != base_channel_id:
                # Base channels conflict - are they coming from the same
                # token?
                if base_channel_token == token:
                    log_error("Token has multiple base channels", token_id, 
                        base_channel_id)
                    raise rhnFault(62, 
                        _("Token `%s' has more than one base channel assigned")
                        % token['note'])
                raise rhnFault(63, _("Conflicting base channels"))
            base_channel_id = channel_id
            base_channel_token = token

    bc = chash.get(base_channel_id)
    log_debug(4, "base channel", bc)
                
    # get the base channel for this server
    # Note that we are hitting this codepath after newserver.__save() has been
    # run, which means we've already chosen a base channel 
    # from rhnDistChannelMap
    sbc = rhnChannel.get_base_channel(server_id, none_ok = 1)

    # prepare the return value
    ret = []

    # now try to figure out which base channel we prefer
    if bc is None:
        if sbc is None:
            # we need at least one base channel definition
            log_error("Server has invalid release and "
                      "token contains no base channels", server_id, 
                        tokens_obj.tokens)
            ret.append("System registered without a base channel")
            ret.append("Unsupported release-architecture combination "
                "(%s, %s)" % (server["release"], server_arch))
            return ret
    else: # do we need to drop the one from sbc?
        if sbc and sbc["id"] != bc["id"]: # we need to prefer the token one
            # unsubscribe from old channel(s)
            rhnChannel.unsubscribe_all_channels(server_id)
            sbc = None # force true on the next test
        if sbc is None:
            # no base channel subscription at this point
            try:
                rhnChannel._subscribe_sql(server_id, bc["id"], commit=0)
            except rhnChannel.SubscriptionCountExceeded:
                ret.append("System registered without a base channel: "
                     "subscription count exceeded for channel %s (%s)" %
                     (bc["name"], bc["label"]))
                return ret
            
            ret.append("Subscribed to base channel '%s' (%s)" % (
                bc["name"], bc["label"]))
            sbc = bc
    
    # attempt to subscribe all non-base channels associated with this
    # token
    subscribe_channel = rhnSQL.Procedure("rhn_channel.subscribe_server")
    # Use a set here to ensure uniqueness of the
    # channel family ids used in the loop below.
    channel_family_ids = Set()
	
    for c in filter(lambda a: a["parent_channel"], chash.values()):
        # make sure this channel has the right parent
        if str(c["parent_channel"]) != str(sbc["id"]):
            ret.append("NOT subscribed to channel '%s' "\
                       "(not a child of '%s')" % (
                c["name"], sbc["name"]))
            continue                     
        try:
            # don't run the EC yet
            # XXX: test return code when this one will start returning
            # a status
            subscribe_channel(server_id, c["id"], 0, None, 0)
            child = rhnChannel.Channel()
            child.load_by_id(c["id"])
            child._load_channel_families()
            cfamid = child._channel_families[0]
            channel_family_ids.add(cfamid)
        except rhnSQL.SQLError, e:
            log_error("Failed channel subscription", server_id,
                      c["id"], c["label"], c["name"])
            ret.append("FAILED to subscribe to channel '%s'" % c["name"])
        else:
            ret.append("Subscribed to channel '%s'" % c["name"])

    log_debug(5, "cf ids: %s" % str(channel_family_ids))
    log_debug(5, "Server org_id: %s" % str(server['org_id']))
    #rhn_channel.update_family_counts(channel_family_id_val, server_org_id_val)
    update_family_counts = rhnSQL.Procedure("rhn_channel.update_family_counts")
    for famid in channel_family_ids:
        # Update the channel family counts separately at the end here
        # instead of in the loop above.  If you have an activation key
        # with lots of custom child channels you can end up repeatedly
        # updating the same channel family counts over and over and over
        # even thou you really only need todo it once.  
        log_debug(5, "calling update fam counts: %s" % famid)
        update_family_counts(famid, server['org_id'])
        
    return ret

_query_token_server_groups = rhnSQL.Statement("""
    select rtg.server_group_id, sg.name
      from rhnRegTokenGroups rtg, rhnServerGroup sg
     where rtg.token_id = :token_id
       and sg.id = rtg.server_group_id
""")

# Handle server group subscriptions for the registration token
def token_server_groups(server_id, tokens_obj):
    assert(isinstance(tokens_obj, ActivationTokens))
    h = rhnSQL.prepare(_query_token_server_groups)
    server_groups = {}
    for token in tokens_obj.tokens:
        token_id = token['token_id']
        h.execute(token_id=token_id)
        while 1:
            row = h.fetchone_dict()
            if not row:
                break
            server_group_id = row['server_group_id']
            server_groups[server_group_id] = row

    # Now try to subscribe server to group
    ret = []
    for server_group_id, sg in server_groups.items():
        log_debug(4, "token server group", sg)
        
        try:
            join_server_group(server_id, server_group_id)
        except rhnSQL.SQLError, e:
            log_error("Failed to add server to group", server_id,
                      server_group_id, sg["name"])
            raise rhnFault(80, _("Failed to add server to group %s") % 
                sg["name"])
        else:
            ret.append("Subscribed to server group '%s'" % sg["name"])
    return ret


_query_token_packages = rhnSQL.Statement("""
    select pn.id as name_id, pa.id as arch_id, pn.name
      from rhnPackageName pn, rhnPackageArch pa, rhnRegTokenPackages rtp
     where rtp.token_id = :token_id
       and rtp.name_id = pn.id
       and rtp.arch_id = pa.id(+)
     order by upper(pn.name)
""")
_query_token_packages_insert = rhnSQL.Statement("""
    insert into rhnActionPackage (id, action_id, name_id, parameter)
    values (sequence_nextval('rhn_act_p_id_seq'), :action_id, :name_id, 'upgrade')
""")

def token_packages(server_id, tokens_obj):
    assert(isinstance(tokens_obj, ActivationTokens))

    h = rhnSQL.prepare(_query_token_packages)
    package_names = {}
    for token in tokens_obj.tokens:
        token_id = token['token_id']
        h.execute(token_id=token_id)
        while True:
            row = h.fetchone_dict()
            if not row:
                break
            pn_id = row['name_id']
            pa_id = row['arch_id']
            package_names[(pn_id, pa_id)] = row['name']

    ret = []
    if not package_names:
        return ret

    package_arch_ids = package_names.keys()
    # Get the latest action scheduled for this token
    last_action_id = rhnFlags.get('token_last_action_id')

    action_id = rhnAction.schedule_server_packages_update_by_arch(server_id,
            package_arch_ids, org_id = token['org_id'],
            prerequisite = last_action_id,
            action_name = "Activation Key Package Auto-Install")

    # This action becomes the latest now
    rhnFlags.set('token_last_action_id', action_id)

    for p in package_names.values():
        ret.append("Scheduled for install:  '%s'" % p)

    rhnSQL.commit()

    return ret


# given 2 channels, with one pathname overlap, you'll get
# something like:
#  id=1,  '/etc/foo.txt',     priority=1
#  id=27, '/etc/foo.txt',     priority=2
#  id=53, '/var/tmp/baz.log', priority=2
_query_token_latest_revisions = rhnSQL.Statement("""
    select cf.latest_config_revision_id revision_id,
           cfn.path
      from rhnConfigFileName cfn,
           rhnConfigFile cf,
           rhnConfigChannelType cct,
           rhnConfigChannel cc,
           rhnServerConfigChannel scc
     where scc.server_id = :server_id
       and scc.config_channel_id = cc.id
       and cc.confchan_type_id = cct.id
       and cct.label != 'server_import'
       and cc.id = cf.config_channel_id
       and cf.config_file_name_id = cfn.id
           -- latest_config_revision_id should always be non-null but
           -- we should protect ourselves
       and cf.latest_config_revision_id is not null
    order by cfn.path, cct.priority, scc.position
""")

_query_add_revision_to_action = rhnSQL.Statement("""
    insert into rhnActionConfigRevision (id, action_id, server_id, config_revision_id)
    values (sequence_nextval('rhn_actioncr_id_seq'), :action_id, :server_id, :config_revision_id)
""")

def deploy_configs_if_needed(server):
    server_id = server['id']
    log_debug(4, server_id)
    # determine if there are actually any files to be deployed...
    revisions = {}

    h = rhnSQL.prepare(_query_token_latest_revisions)
    h.execute(server_id=server_id)

    while 1:
        row = h.fetchone_dict()
        if not row:
            break

        # only care about the 1st revision of a particular path due to
        # sql ordering...
        if not revisions.has_key(row['path']):
            revisions[row['path']] = row['revision_id']

    if not len(revisions):
        return None

    # Get the latest action scheduled for this token
    last_action_id = rhnFlags.get('token_last_action_id')
    
    action_id = rhnAction.schedule_server_action(
        server_id,
        action_type='activation.schedule_deploy',
        action_name="Activation Key Config File Deployment",
        delta_time=0, scheduler=None,
        org_id=server['org_id'],
        prerequisite=last_action_id,
        )

    # This action becomes the latest now
    rhnFlags.set('token_last_action_id', action_id)

    log_debug(4, "scheduled activation key config deploy")
    
    h = rhnSQL.prepare(_query_add_revision_to_action)
    # XXX should use executemany() or execute_bulk
    for revision_id in revisions.values():
        log_debug(5, action_id, revision_id)
        h.execute(server_id = server_id,
                  action_id = action_id,
                  config_revision_id = revision_id)

    return action_id


_query_token_config_channels = rhnSQL.Statement("""
    select rtcc.config_channel_id,
           rtcc.position, cc.name
      from rhnConfigChannel cc,
           rhnRegTokenConfigChannels rtcc
     where rtcc.token_id = :token_id
       and rtcc.config_channel_id = cc.id
    order by rtcc.position
""")

# XXX Same query exists in config/rhn_config_management.py
_query_set_server_config_channels = rhnSQL.Statement("""
    insert into rhnServerConfigChannel (server_id, config_channel_id, position)
    values (:server_id, :config_channel_id, :position)
""")

def _get_token_config_channels(token_id):
    h = rhnSQL.prepare(_query_token_config_channels)
    h.execute(token_id=token_id)

    return h.fetchall_dict() or []
   
_query_current_config_channels = rhnSQL.Statement("""
    select server_id, config_channel_id
      from rhnServerConfigChannel
""")

def _get_current_config_channels():
    h = rhnSQL.prepare(_query_current_config_channels)
    h.execute()

    current_ch = h.fetchall_dict() or []
    data = []
    for curr in current_ch:
        data.append((curr['server_id'],curr['config_channel_id']))
    return data

 
def token_config_channels(server, tokens_obj):
    assert(isinstance(tokens_obj, ActivationTokens))
    server_id = server['id']

    # If this is a re-registration token, it should not have any config
    # channel associated with it (and no deploy_configs either). We'll just
    # keep whatever config files they had on this profile
    if tokens_obj.is_rereg_token:
        return []

    # Activation key order matters; config channels are stacked in order

    config_channels = []
    config_channels_hash = {}
    no_deployment = 0
    for token in tokens_obj.tokens:
        channels = _get_token_config_channels(token['token_id'])
        # Check every token used and if any of them are set to not deploy configs
        # then we won't deploy configs for any config channels the system is subscribed to
        deploy_configs = token['deploy_configs']
        log_debug(2, "token_id: ", token['token_id'], " deploy_configs: ", deploy_configs)
	if deploy_configs == 'N':
            log_debug(2, "At least one token set to not deploy config files, so deploying none")
            no_deployment = 1
        for c in channels:
            config_channel_id = c['config_channel_id']
            if tokens_obj.forget_rereg_token:
               current_channels = _get_current_config_channels()
               if (server_id, c['config_channel_id']) in current_channels:
                   continue 
            if config_channels_hash.has_key(config_channel_id):
                # Already added
                continue
            position = len(config_channels) + 1
            # Update the position in the queue
            c['position'] = position
            config_channels.append(c)
            config_channels_hash[config_channel_id] = None

    ret = []
    if not config_channels:
        return ret

    h = rhnSQL.prepare(_query_set_server_config_channels)

    h.execute_bulk({
        'server_id'        : [server_id] * len(config_channels),
        'config_channel_id': map(lambda c: c['config_channel_id'], 
            config_channels),
        'position'         : map(lambda c: c['position'], config_channels),
        })

    for channel in config_channels:
        msg = "Subscribed to config channel %s" % channel['name']
        log_debug(4, msg)
        ret.append(msg)
    
    # Now that we have the server subscribed to config channels, 
    # determine if we have to deploy the files too
    # Don't pass tokens_obj, we only need the token that provided the config
    # channels in the first place
    if not no_deployment:
        log_debug(2, "All tokens have deploy_configs == Y, deploying configs")
        deploy_configs_if_needed(server)

    rhnSQL.commit()

    return ret


_query_server_token_used = rhnSQL.Statement("""
    insert into rhnServerTokenRegs (server_id, token_id)
    values (:server_id, :token_id)
""")

def server_used_token(server_id, token_id):
    h = rhnSQL.prepare(_query_server_token_used)
    h.execute(server_id=server_id, token_id=token_id)



_query_check_token_limits = rhnSQL.Statement("""
    select
       rt.usage_limit max_nr,
       ( select count(server_id) from rhnServerTokenRegs
         where token_id = :token_id ) curr_nr
    from rhnRegToken rt
    where rt.id = :token_id
""")

# check the token registration limits
# XXX: would be nice to have those done with triggers in the database
# land...
def check_token_limits(server_id, tokens_obj):
    assert(isinstance(tokens_obj, ActivationTokens))
    rhnSQL.transaction("check_token_limits")
    for token in tokens_obj.tokens:
        try:
            _check_token_limits(server_id, token)
        except:
            log_debug(4, "Rolling back transaction")
            rhnSQL.rollback("check_token_limits")
            raise
    return 0

def _check_token_limits(server_id, token_rec):
    token_id = token_rec["token_id"]   

    # Mark that we used this token
    server_used_token(server_id, token_id)
    
    # now check we're not using this token too much
    h = rhnSQL.prepare(_query_check_token_limits)
    h.execute(token_id = token_id)
    ret = h.fetchone_dict()
    if not ret:
        raise rhnException("Could not check usage limits for token",
                           server_id, token_rec)
    # See bug #79095: if usage_limit is NULL, it means unlimited reg tokens
    if ret["max_nr"] is not None and ret["max_nr"] < ret["curr_nr"]:
        log_error("Token usage limit exceeded", token_rec,
                  ret["max_nr"], server_id)
        raise rhnFault(61, _("Maximum usage count of %s reached") % ret["max_nr"])
    # all clean, we're below usage limits
    return 0

class ActivationTokens:
    """
    An aggregation of activation tokens, exposing important information
    like org_id, user_id etc in a unified manner.
    """
    is_rereg_token = 0
    forget_rereg_token = 0

    def __init__(self, tokens, user_id=None, org_id=None,
            kickstart_session_id=None, entitlements=[], deploy_configs=None):
        self.tokens = tokens
        self.user_id = user_id
        self.org_id = org_id
        self.kickstart_session_id = kickstart_session_id
#        self.entitlement_label = entitlement_label
#        self.entitlement_name = entitlement_name
        # Boolean
        self.deploy_configs = deploy_configs
        # entitlements is list of tuples [(name, label)]
        self.entitlements = entitlements

    def __nonzero__(self):
        return (len(self.tokens) > 0)

    def get_server_id(self):
        if not self:
            return None
	# We can have only one re-activation key
        for token in self.tokens:
            server_id = token.get('server_id')
            if server_id:
                return server_id
        # We hit this when no re-activation key
        return None

    def get_user_id(self):
        return self.user_id

    def get_org_id(self):
        return self.org_id

    def get_kickstart_session_id(self):
        return self.kickstart_session_id

    def get_entitlements(self):
        return self.entitlements

    def has_entitlement_label(self, entitlement):
        if entitlement in  map(lambda x: x[0], self.entitlements):
            return 1
        return 0

    def get_deploy_configs(self):
        return self.deploy_configs

    # Returns a string of the entitlement names that the token grants.
    # This function is poorly named.
    def get_names(self):
        token_names = map(lambda x: x[0], self.entitlements)
        if not token_names:
            return None
        return string.join(token_names, ",")

    def get_tokens(self):
        tokens = []
        for token in self.tokens:
            tokens.append(token['token'])

        return tokens

    def entitle(self, server_id, history, virt_type = None):
        """
        Entitle a server according to the entitlements we have configured.
        """
        log_debug(3, self.entitlements)

        entitle_server = rhnSQL.Procedure("rhn_entitlements.entitle_server")
        # TODO: entitle_server calls can_entitle_server, so we're doing this
        # twice for each successful call. Is it necessary for external error
        # handling or can we ditch it?
        can_entitle_server = rhnSQL.Function(
                "rhn_entitlements.can_entitle_server", rhnSQL.types.NUMBER())

        can_ent = None

        history["entitlement"] = ""

        # Do a quick check to see if both virt entitlements are present. (i.e.
        # activation keys stacked together) If so, give preference to the more
        # powerful virtualization platform and remove the regular virt 
        # entitlement from the list.
        found_virt = False
        found_virt_platform = False
        for entitlement in self.entitlements:
            if entitlement[0] == VIRT_ENT_LABEL:
                found_virt = True
            elif entitlement[0] == VIRT_PLATFORM_ENT_LABEL:
                found_virt_platform = True
          
        for entitlement in self.entitlements:
            if virt_type is not None and entitlement[0] in \
                    (VIRT_ENT_LABEL, VIRT_PLATFORM_ENT_LABEL):
                continue

            # If both virt entitlements are present, skip the least powerful:
            if found_virt and found_virt_platform and entitlement[0] == VIRT_ENT_LABEL:
                log_debug(1, "Virtualization and Virtualization Platform " +
                        "entitlements both present.")
                log_debug(1, "Skipping Virtualization.")
                continue

            try:
                 can_ent = can_entitle_server(server_id, entitlement[0])
            except rhnSQL.SQLSchemaError, e:
                 can_ent = 0

            try:
                # bugzilla #160077, skip attempting to entitle if we cant
                if can_ent:
                    entitle_server(server_id, entitlement[0])
            except rhnSQL.SQLSchemaError, e:
                log_error("Token failed to entitle server", server_id,
                          self.get_names(), entitlement[0], e.errmsg)
                if e.errno == 20220:
                    #ORA-20220: (servergroup_max_members) - Server group membership
                    #cannot exceed maximum membership
                    raise rhnFault(91, 
                        _("Registration failed: RHN Software Management service entitlements exhausted"))
                #No idea what error may be here...
                raise rhnFault(90, e.errmsg)
            except rhnSQL.SQLError, e:
                log_error("Token failed to entitle server", server_id,
                          self.get_names(), entitlement[0], e.args)
                raise rhnFault(90, str(e))
            else:
                history["entitlement"] = "Entitled as a %s member" % entitlement[1]



class ReRegistrationToken(ActivationTokens):
    """
    Subclass for re-registration keys.
    
    (i.e. used alone and not combined with other regular activation keys)
    """
    is_rereg_token = 1



class ReRegistrationActivationToken(ReRegistrationToken):
    """
    Subclass for re-registration keys and activation keys used together.
    """
    forget_rereg_token = 1

    def __init__(self, tokens, user_id=None, org_id=None,
            kickstart_session_id=None, entitlements=[], 
            remove_entitlements=[], deploy_configs=None):
        ReRegistrationToken.__init__(self, tokens, user_id, org_id, 
                kickstart_session_id, entitlements, deploy_configs)
        self.remove_entitlements = remove_entitlements # list of labels

    def entitle(self, server_id, history, virt_type = None):
        for ent in self.remove_entitlements:
            unentitle_server = rhnSQL.Procedure(
                    "rhn_entitlements.remove_server_entitlement")
            try:
                unentitle_server(server_id, ent, 0)
            except rhnSQL.SQLSchemaError, e:
                log_error("Failed to unentitle server", server_id,
                    ent, e.errmsg)
                raise rhnFault(90, e.errmsg)
            except rhnSQL.SQLError, e:
                log_error("Failed to unentitle server", server_id,
                    ent, e.args)
                raise rhnFault(90, str(e))

        # Call parent method:
        ReRegistrationToken.entitle(self, server_id, history, virt_type)



def sortAndUniqEntitlements(entitlements):
    pass

def _fetch_token_from_cursor(cursor):
    # Fetches a token from a prepared and executed cursor
    # Used by both fetch_token and fetch_org_token
    token_entry = None
    token_entitlements = {}
    while 1:
        row = cursor.fetchone_dict()
        if not row:
            break
        tup = (row['token_type'], row['token_desc'], row['is_base'])
        token_entitlements[tup] = None
        if token_entry:
            # We've seen this token already - the only thing that can be
            # different is the entitlement level, which we've already
            # saved

            # Double-check it's the same token
            assert token_entry['token_id'] == row['token_id'], \
                "Query returned different tokens - missing unique constraint" \
                " on rhnActivationKey.token?"
            continue

        # First entry of this type
        token_entry = row

    return token_entry, token_entitlements
    
def _categorize_token_entitlements(token_entitlements, entitlements_base,
        entitlements_extra):
    # Given a hash token_entitlements, splits the base ones and puts them in
    # the entitlements_base hash, and the extras in entitlements_extra
    for tup in token_entitlements.keys():
        is_base = tup[2]
        ent = (tup[0], tup[1])
        if is_base == 'Y':
            entitlements_base[ent] = None
        else:
            entitlements_extra[ent] = None

    return entitlements_base, entitlements_extra

def _validate_entitlements(token_string, rereg_ents, base_entitlements, 
        extra_entitlements, remove_entitlements):
    """
    Perform various checks on the final list of entitlements accumulated after
    processing all activation keys.

    rereg_ents passed in as a list of entitlement labels.

    Extra/base entitlements passed in as a hash of tuples ('label', 'Friendly 
    Name') mapping to None. (i.e. seems to be used as just a set)

    Remove entitlements being maintained as just a list of labels.
    """
    # Check for exactly one base entitlement:
    if len(base_entitlements.keys()) != 1:
        log_error("Tokens with different base entitlements", token_string,
            base_entitlements)
        raise rhnFault(63,
            _("Stacking of re-registration tokens with different base entitlements "
                "is not supported"), explain=0)

    # Don't allow an activation key to give virt entitlement to a system 
    # that's re-activating and already has virt platform: (or vice-versa)
    found_virt = False
    virt_tuple = None
    found_virt_platform = False
    for ent_tuple in extra_entitlements.keys():
        if ent_tuple[0] == VIRT_ENT_LABEL:
            found_virt = True
            virt_tuple = ent_tuple
        elif ent_tuple[0] == VIRT_PLATFORM_ENT_LABEL:
            found_virt_platform = True

    if found_virt and found_virt_platform and len(rereg_ents) > 0:
        # Both virt entitlements found, give preference to the most powerful.
        # (i.e. virtualization_host_platform) This may mean we have to remove
        # virtualization_host if a reregistration key is in use and contains
        # this entitlement.
        if VIRT_ENT_LABEL in rereg_ents:
            # The system already has virt host, so it must be removed:
            log_debug(1, "Removing Virtualization entitlement from profile.")
            remove_entitlements.append(virt_tuple[0])

        # NOTE: the call to entitle will actually skip the virtualization 
        # entitlement, so we can leave it in the list here.

_query_token = rhnSQL.Statement("""
    select rt.id as token_id,
           sgt.label as token_type,
           sgt.name as token_desc,
           sgt.is_base, 
           ak.token,
           rt.user_id,
           rt.org_id,
           rt.note,
           rt.usage_limit,
           rt.server_id,
           ak.ks_session_id kickstart_session_id,
           rt.deploy_configs
    from rhnActivationKey ak, rhnRegToken rt, rhnRegTokenEntitlement rte, rhnServerGroupType sgt
    where ak.token = :token
      and ak.reg_token_id = rt.id
      and rt.disabled = 0
      and rt.id = rte.reg_token_id
      and rte.server_group_type_id = sgt.id
""")

# Fetches a token from the database
def fetch_token(token_string):
    log_debug(3, token_string)
    # A token should always be passed to this function
    assert token_string
    tokens = string.split(token_string, ',')
    h = rhnSQL.prepare(_query_token)
    result = []
    rereg_token_found = 0
    num_of_rereg = 0
    # Global user_id and org_id
    user_id = None
    same_user_id = 1
    org_id = None
    ks_session_id_token = None
    deploy_configs = None
    entitlements_base = {}
    entitlements_extra = {}

    # List of re-registration entitlements labels (if found):
    rereg_ents = []

    for token in tokens:
        h.execute(token=token)
        token_entry, token_entitlements = _fetch_token_from_cursor(h)

        if not token_entry:
            # Unable to find the token
            log_error("Invalid token '%s'" % token)
            raise rhnFault(60, _("Could not find token '%s'") % token, explain=0)

        row = token_entry

        if row.get('server_id'):
            rereg_token_found = row
            num_of_rereg += 1

            # Store the re-reg ents:
            for tup in token_entitlements.keys():
                rereg_ents.append(tup[0])
            
        # Check user_id
        token_user_id = row.get('user_id')

        #4/27/05 wregglej - Commented this line out 'cause the token_user_id should
        #be allowed to be None. This line was causing problems when registering with
        #an activation key whose creator had been deleted.
        #assert(token_user_id is not None)

        if same_user_id and user_id is not None and user_id != token_user_id:
            log_debug(4, "Different user ids: %s, %s" % (same_user_id, user_id))
            # This token has a different user id than the rest
            same_user_id = 0
        else:
            user_id = token_user_id

        # Check org_id
        token_org_id = row.get('org_id')
        assert(token_org_id is not None)
        if org_id is not None and org_id != token_org_id:
            # Cannot use activation keys from different orgs
            raise rhnFault(63, _("Tokens from mismatching orgs"), explain=0)
        org_id = token_org_id

        # Check kickstart session ids
        token_ks_session_id = row.get('kickstart_session_id')
        if token_ks_session_id is not None:
            if ks_session_id_token is not None:
                ks_session_id = ks_session_id_token['kickstart_session_id']
                if ks_session_id != token_ks_session_id:
                    # Two tokens with different kickstart sessions
                    raise rhnFault(63, _("Kickstart session mismatch"), 
                        explain=0)
            else:
                # This token has kickstart session id info
                ks_session_id_token = row

        # Iterate through the entitlements from this token
        # and intead of picking one entitlement, create a union of
        # all the entitlemts as a list of tuples of (name, label) aka 
        # (token_type, token_desc)
        _categorize_token_entitlements(token_entitlements, entitlements_base,
            entitlements_extra)

        # Deploy configs?
        deploy_configs = deploy_configs or (row['deploy_configs'] == 'Y')
        result.append(row)

    # One should not stack re-activation tokens
    if num_of_rereg > 1:
        raise rhnFault(63, 
            _("Stacking of re-registration tokens is not supported"), explain=0)

    entitlements_remove = [] 
    _validate_entitlements(token_string, rereg_ents, entitlements_base, 
            entitlements_extra, entitlements_remove)
    log_debug(5, "entitlements_base = %s" % entitlements_base)
    log_debug(5, "entitlements_extra = %s" % entitlements_extra)

    if ks_session_id_token:
        ks_session_id = ks_session_id_token['kickstart_session_id']
    else:
        ks_session_id = None

    # akl add entitles array constructed above to kwargs
    kwargs = {
        'user_id'               : user_id,
        'org_id'                : org_id,
        'kickstart_session_id'  : ks_session_id,
        'entitlements'          : entitlements_base.keys() + entitlements_extra.keys(),
        'deploy_configs'        : deploy_configs,
    }
    log_debug(4, "Values", kwargs)

    if rereg_token_found and len(result) > 1:
        log_debug(4,"re-activation stacked with activationkeys")
        kwargs['remove_entitlements'] = entitlements_remove
        return apply(ReRegistrationActivationToken, (result, ), kwargs)
    elif rereg_token_found:
        log_debug(4,"simple re-activation")
        return apply(ReRegistrationToken, ([ rereg_token_found ], ), kwargs)

    return apply(ActivationTokens, (result, ), kwargs)

# always be sure this query has matching columns as _query_token above...
_query_org_default_token = rhnSQL.Statement("""
    select rt.id as token_id,
           sgt.label as token_type,
           sgt.name as token_desc,
           sgt.is_base, 
           ak.token,
           rt.user_id,
           rt.org_id,
           rt.note,
           -- Default tokens have no usage limit
           NULL usage_limit,
           rt.server_id,
           NULL kickstart_session_id,
           rt.deploy_configs
      from rhnServerGroupType sgt,
           rhnActivationKey ak,
           rhnRegToken rt, 
           rhnRegTokenOrgDefault rtod,
           rhnRegTokenEntitlement rte
     where rtod.org_id = :org_id
       and rtod.reg_token_id = rt.id
       and rt.id =  rte.reg_token_id
       and rt.disabled = 0
       and rte.server_group_type_id = sgt.id
       and ak.reg_token_id = rtod.reg_token_id
""")

def fetch_org_token(org_id):
    log_debug(3, org_id)
    h = rhnSQL.prepare(_query_org_default_token)
    h.execute(org_id=org_id)
    token_entry, token_entitlements = _fetch_token_from_cursor(h)
    entitlements_base = {}
    entitlements_extra = {}
    _categorize_token_entitlements(token_entitlements, entitlements_base,
        entitlements_extra)

    kwargs = {}
    tokens = []
    if token_entry:
        kwargs = {
            'user_id'               : token_entry['user_id'],
            'org_id'                : token_entry['org_id'],
            'kickstart_session_id'  : token_entry['kickstart_session_id'],
            'entitlements'          : entitlements_base.keys() + entitlements_extra.keys(),
            'deploy_configs'        : token_entry['deploy_configs'] == 'Y',
        }
        tokens.append(token_entry)

    return apply(ActivationTokens, (tokens, ), kwargs)




_query_disable_token = rhnSQL.Statement("""
    update rhnRegToken
       set disabled = 1
     where id = :token_id
""")


def disable_token(tokens_obj):
    assert(isinstance(tokens_obj, ActivationTokens))
    h = rhnSQL.prepare(_query_disable_token)
    for token in tokens_obj.tokens:
        if token.get("server_id"):
            # only disable re-activation tokens
            h.execute(token_id=token["token_id"])

# perform registration tasks for a server as indicated by a token
def process_token(server, server_arch, tokens_obj, virt_type = None):
    assert(isinstance(tokens_obj, ActivationTokens))
    server_id = server['id']
    log_debug(1, server_id, tokens_obj.get_names())

    # Keep track of what we're doing
    history = {}        

    # the tokens are confirmed, mark this server as using it and make
    # sure we're within limits
    check_token_limits(server_id, tokens_obj)

    is_reactivation = rhnFlags.test('re_registration_token')
    
    if is_reactivation:
        # If it's a re-registration, the server is already entitled
        history["entitlement"] = "Re-activation: keeping previous entitlement level"
    else:
        tokens_obj.entitle(server_id, history, virt_type)

        
    # channels
    history["channels"] = token_channels(server, server_arch, tokens_obj)


    is_provisioning_entitled = None
    is_management_entitled = None
    
    if tokens_obj.has_entitlement_label('provisioning_entitled'):
        is_provisioning_entitled = 1

    if tokens_obj.has_entitlement_label('enterprise_entitled'):
        is_management_entitled = 1
 
    if is_reactivation:
        history["groups"] = ["Re-activation: keeping previous server groups"]
    else:
        # server groups - allowed for enterprise only
        if is_management_entitled or is_provisioning_entitled:
            history["groups"] = token_server_groups(server_id, tokens_obj)
        else:
            # FIXME:  better messaging about minimum service level
            history["groups"] = [
                "Not subscribed to any system groups: not entitled for "
                "RHN Management or RHN Provisioning"
            ]

    if is_provisioning_entitled:
        history["packages"] = token_packages(server_id, tokens_obj)
        history["config_channels"] = token_config_channels(server,
            tokens_obj)
    else:
        history["packages"] = [ "Insufficient service level for automatic package installation." ]
        history["config_channels"] = [ "Insufficient service level for config channel subscription." ]
    
    # build the report and send it back
    return history_report(history)

# build a mildly html-ized version of the history as a report
def history_report(history):    
    report = StringIO()
    # header information
    report.write("Entitlement Information:\n")
    report.write("<ul><li>%s</li></ul>" % history["entitlement"])
    report.write("\n")
    # print out channels
    report.write("Channel Subscription Information:\n")
    report.write("<ul>\n")
    for c in history["channels"]:
        report.write("<li>%s</li>\n" % c)        
    if len(history["channels"]) == 0:
        report.write("<li>The token does not include default "
                     "Channel Subscriptions</li>\n")
    report.write("</ul>\n")
    # print out the groups
    if history.has_key("groups"):
        report.write("System Group Membership Information:\n")
        report.write("<ul>\n")
        for g in history["groups"]:
            report.write("<li>%s</li>\n" % g)
        if len(history["groups"]) == 0:
            report.write("<li>The token does not include default "\
                         "System Group Membership</li>\n")
        report.write("</ul>\n")

    # auto-installed packages...
    if history.has_key("packages"):
        report.write("Packages Scheduled for Installation:\n")
        report.write("<ul>\n")

        for p in history['packages']:
            report.write("<li>%s</li>\n" % p)

        if len(history['packages']) == 0:
            report.write("<li>No packages scheduled for automatic installation</li>\n")
        
        report.write("</ul>\n")

    # config channels...
    if history.has_key('config_channels'):
        report.write("Config Channel Subscription Information:\n")
        report.write("<ul>\n")

        for c in history['config_channels']:
            report.write("<li>%s</li>\n" % c)

        if len(history['config_channels']) == 0:
            report.write("<li>The token does not include default configuration channels</li>\n")

        report.write("</ul>\n")
    
    ret = report.getvalue()
    report.close()
    del report
    # return what we got
    return ret

