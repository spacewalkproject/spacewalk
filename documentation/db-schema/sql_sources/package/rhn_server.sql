-- created by Oraschemadoc Fri Jan 22 13:41:07 2010
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE PACKAGE "SPACEWALK"."RHN_SERVER"
is

    -- i.e., "can this box do management stuff?" and yes if provisioning box
    function system_service_level(
    	server_id_in in number,
	service_level_in in varchar2
    ) return number;

    function can_change_base_channel(
    	server_id_in in number
    ) return number;

    procedure set_custom_value(
    	server_id_in in number,
	user_id_in in number,
	key_label_in varchar2,
     	value_in in varchar2
    );

    function bulk_set_custom_value(
    	key_label_in in varchar2,
	value_in in varchar2,
	set_label_in in varchar2,
	set_uid_in in number
    ) return integer;

    procedure snapshot_server(
    	server_id_in in number,
	reason_in in varchar2
    );

    procedure bulk_snapshot(
    	reason_in in varchar2,
    	set_label_in in varchar2,
	set_uid_in in number
    );

    procedure tag_delete(
    	server_id_in in number,
	tag_id_in in number
    );

    procedure tag_snapshot(
    	snapshot_id_in in number,
	org_id_in in number,
    	tagname_in in varchar2
    );

    procedure bulk_snapshot_tag(
    	org_id_in in number,
    	tagname_in varchar2,
	set_label_in in varchar2,
	set_uid_in in number
    );

    procedure remove_action(
	server_id_in in number,
	action_id_in in number
    );

    function check_user_access(server_id_in in number, user_id_in in number) return number;


    function can_server_consume_virt_slot(server_id_in in number,
                                              group_type_in in
                                              rhnServerGroupType.label%TYPE)
    return number;

    procedure insert_into_servergroup (
	server_id_in in number,
	server_group_id_in in number
    );

    function insert_into_servergroup_maybe (
	server_id_in in number,
	server_group_id_in in number
    ) return number;

	procedure insert_set_into_servergroup (
	server_group_id_in in number,
	user_id_in in number,
	set_label_in in varchar2
	);

    procedure delete_from_servergroup (
	server_id_in in number,
	server_group_id_in in number
    );

	procedure delete_set_from_servergroup (
	server_group_id_in in number,
	user_id_in in number,
	set_label_in in varchar2
	);

	procedure clear_servergroup (
	server_group_id_in in number
	);

	procedure delete_from_org_servergroups (
	server_id_in in number
	);

	function get_ip_address (
		server_id_in in number
	) return varchar2;
end rhn_server;
CREATE OR REPLACE PACKAGE BODY "SPACEWALK"."RHN_SERVER"
is
    function system_service_level(
    	server_id_in in number,
	service_level_in in varchar2
    ) return number is

    cursor ents is
      select label from rhnServerEntitlementView
      where server_id = server_id_in;

    retval number := 0;

    begin
         for ent in ents loop
            retval := rhn_entitlements.entitlement_grants_service (ent.label, service_level_in);
            if retval = 1 then
               return retval;
            end if;
         end loop;

         return retval;

    end system_service_level;


    function can_change_base_channel(server_id_in IN NUMBER)
    return number
    is
    	throwaway number;
    begin
    	-- the idea: if we get past this query, the server is
	-- neither sat nor proxy, so base channel is changeable

	select 1 into throwaway
	  from rhnServer S
	 where S.id = server_id_in
	   and not exists (select 1 from rhnSatelliteInfo SI where SI.server_id = S.id)
	   and not exists (select 1 from rhnProxyInfo PI where PI.server_id = S.id);

	return 1;
    exception
    	when no_data_found
	    then
	    return 0;
    end can_change_base_channel;

    procedure set_custom_value(
    	server_id_in in number,
	user_id_in in number,
	key_label_in in varchar2,
	value_in in varchar2
    ) is
    	key_id_val number;
    begin
    	select CDK.id into key_id_val
	  from rhnCustomDataKey CDK,
	       rhnServer S
	 where S.id = server_id_in
	   and S.org_id = CDK.org_id
	   and CDK.label = key_label_in;

	begin
	    insert into rhnServerCustomDataValue (server_id, key_id, value, created_by, last_modified_by)
	    values (server_id_in, key_id_val, value_in, user_id_in, user_id_in);
	exception
	    when DUP_VAL_ON_INDEX
	    	then
		update rhnServerCustomDataValue
		   set value = value_in,
		       last_modified_by = user_id_in
		 where server_id = server_id_in
		   and key_id = key_id_val;
	end;

    end set_custom_value;

    function bulk_set_custom_value(
    	key_label_in in varchar2,
	value_in in varchar2,
	set_label_in in varchar2,
	set_uid_in in number
    )
    return integer
    is
    i integer := 0;
    begin
        i := 0;
    	for server in rhn_set.set_iterator(set_label_in, set_uid_in)
	loop
	    if rhn_server.system_service_level(server.element, 'provisioning') = 1 then
	    	rhn_server.set_custom_value(server.element, set_uid_in, key_label_in, value_in);
            i := i + 1;
	    end if;
	end loop server;
    return i;
    end bulk_set_custom_value;

    procedure bulk_snapshot_tag(
    	org_id_in in number,
        tagname_in in varchar2,
	set_label_in in varchar2,
	set_uid_in in number
    ) is
    	snapshot_id number;
    begin
    	for server in rhn_set.set_iterator(set_label_in, set_uid_in)
	loop
	    if rhn_server.system_service_level(server.element, 'provisioning') = 1 then
	    	begin
	    	    select max(id) into snapshot_id
	    	    from rhnSnapshot
	    	    where server_id = server.element;
	    	exception
	    	    when NO_DATA_FOUND then
		    	rhn_server.snapshot_server(server.element, 'tagging system:  ' || tagname_in);

			select max(id) into snapshot_id
			from rhnSnapshot
			where server_id = server.element;
		end;

		-- now have a snapshot_id to work with...
		begin
		    rhn_server.tag_snapshot(snapshot_id, org_id_in, tagname_in);
		exception
		    when DUP_VAL_ON_INDEX
		    	then
			-- do nothing, be forgiving...
			null;
		end;
	    end if;
	end loop server;
    end bulk_snapshot_tag;

    procedure tag_delete(
    	server_id_in in number,
	tag_id_in in number
    ) is
    	cursor snapshots is
		select	snapshot_id
		from	rhnSnapshotTag
		where	tag_id = tag_id_in;
	tag_id_tmp number;
    begin
    	select	id into tag_id_tmp
	from	rhnTag
	where	id = tag_id_in
	for update;

	delete
		from	rhnSnapshotTag
		where	server_id = server_id_in
			and tag_id = tag_id_in;
	for snapshot in snapshots loop
		return;
	end loop;
	delete
		from rhnTag
		where id = tag_id_in;
    end tag_delete;

    procedure tag_snapshot(
        snapshot_id_in in number,
	org_id_in in number,
	tagname_in in varchar2
    ) is
    begin
    	insert into rhnSnapshotTag (snapshot_id, server_id, tag_id)
	select snapshot_id_in, server_id, lookup_tag(org_id_in, tagname_in)
	from rhnSnapshot
	where id = snapshot_id_in;
    end tag_snapshot;

    procedure bulk_snapshot(
    	reason_in in varchar2,
	set_label_in in varchar2,
	set_uid_in in number
    ) is
    begin
    	for server in rhn_set.set_iterator(set_label_in, set_uid_in)
	loop
    	    if rhn_server.system_service_level(server.element, 'provisioning') = 1 then
	    	rhn_server.snapshot_server(server.element, reason_in);
	    end if;
	end loop server;
    end bulk_snapshot;

    procedure snapshot_server(
    	server_id_in in number,
	reason_in in varchar2
    ) is
    	snapshot_id number;
	cursor revisions is
		select distinct
			cr.id
		from	rhnConfigRevision	cr,
			rhnConfigFileName	cfn,
			rhnConfigFile		cf,
			rhnConfigChannel	cc,
			rhnServerConfigChannel	scc
		where	1=1
			and scc.server_id = server_id_in
			and scc.config_channel_id = cc.id
			and cc.id = cf.config_channel_id
			and cf.id = cr.config_file_id
			and cr.id = cf.latest_config_revision_id
			and cf.config_file_name_id = cfn.id
			and cf.id = lookup_first_matching_cf(scc.server_id, cfn.path);
	locked integer;
    begin
    	select rhn_snapshot_id_seq.nextval into snapshot_id from dual;

	insert into rhnSnapshot (id, org_id, server_id, reason) (
		select	snapshot_id,
			s.org_id,
			server_id_in,
			reason_in
		from	rhnServer s
		where	s.id = server_id_in
	);
	insert into rhnSnapshotChannel (snapshot_id, channel_id) (
		select	snapshot_id, sc.channel_id
		from	rhnServerChannel sc
		where	sc.server_id = server_id_in
	);
	insert into rhnSnapshotServerGroup (snapshot_id, server_group_id) (
		select	snapshot_id, sgm.server_group_id
		from	rhnServerGroupMembers sgm
		where	sgm.server_id = server_id_in
	);
        locked := 0;
        while true loop
            begin
                insert into rhnPackageNEVRA (id, name_id, evr_id, package_arch_id)
                select rhn_pkgnevra_id_seq.nextval, sp.name_id, sp.evr_id, sp.package_arch_id
                from rhnServerPackage sp
                where sp.server_id = server_id_in
                        and not exists
                        (select 1
                                from rhnPackageNEVRA nevra
                                where nevra.name_id = sp.name_id
                                        and nevra.evr_id = sp.evr_id
                                        and (nevra.package_arch_id = sp.package_arch_id
                                            or (nevra.package_arch_id is null
                                                and sp.package_arch_id is null)));
                exit;
            exception when dup_val_on_index then
                if locked = 1 then
                    raise;
                else
                    lock table rhnPackageNEVRA in exclusive mode;
                    locked := 1;
                end if;
            end;
        end loop;
	insert into rhnSnapshotPackage (snapshot_id, nevra_id) (
                select distinct snapshot_id, nevra.id
                from    rhnServerPackage sp, rhnPackageNEVRA nevra
                where   sp.server_id = server_id_in
                        and nevra.name_id = sp.name_id
                        and nevra.evr_id = sp.evr_id
                        and (nevra.package_arch_id = sp.package_arch_id
                            or (nevra.package_arch_id is null
                                and sp.package_arch_id is null))
	);

	insert into rhnSnapshotConfigChannel ( snapshot_id, config_channel_id ) (
		select	snapshot_id, scc.config_channel_id
		from	rhnServerConfigChannel scc
		where	server_id = server_id_in
	);

	for revision in revisions loop
		insert into rhnSnapshotConfigRevision (
				snapshot_id, config_revision_id
			) values (
				snapshot_id, revision.id
			);
	end loop;
    end snapshot_server;

    procedure remove_action(
    	server_id_in in number,
	action_id_in in number
    ) is
    	-- this really wants "nulls last", but 8.1.7.3.0 sucks ass.
	-- instead, we make a local table that holds our
	-- list of ids with null prereqs.  There's surely a better way
	-- (an array instead of a table maybe?  who knows...)
	-- but I've got code to do this handy that I can look at ;)
    	cursor chained_actions is
		select	id, prerequisite
		from	rhnAction
		start with id = action_id_in
		connect by prior id = prerequisite
		order by prerequisite desc;
	cursor sessions is
		select	s.id
		from	rhnKickstartSession s
		where	server_id_in in (s.old_server_id, s.new_server_id)
			and s.action_id = action_id_in
			and not exists (
				select	1
				from	rhnKickstartSessionState ss
				where	ss.id = s.state_id
					and ss.label in ('failed','complete')
			);
	type chain_end_type is table of number index by binary_integer;
	chain_ends chain_end_type;
	i number;
	prereq number := 1;
    begin
	select	prerequisite
	into	prereq
	from	rhnAction
	where	id = action_id_in;

	if prereq is not null then
		rhn_exception.raise_exception('action_is_child');
	end if;

	i := 0;
	for action in chained_actions loop
		if action.prerequisite is null then
			chain_ends(i) := action.id;
			i := i + 1;
		else
			delete from rhnServerAction
				where server_id = server_id_in
				and action_id = action.id;
		end if;
	end loop;
	i := chain_ends.first;
	while i is not null loop
		delete from rhnServerAction
			where server_id = server_id_in
			and action_id = chain_ends(i);
		i := chain_ends.next(i);
	end loop;
	for s in sessions loop
		update rhnKickstartSession
			set 	state_id = (
					select	id
					from	rhnKickstartSessionState
					where	label = 'failed'
				),
				action_id = null
			where	id = s.id;
		set_ks_session_history_message(s.id, 'failed', 'Kickstart cancelled due to action removal');
	end loop;
    end remove_action;

    function check_user_access(server_id_in in number, user_id_in in number)
    return number
    is
    	has_access number;
    begin
    	-- first check; if this returns no rows, then the server/user are in different orgs, and we bail
        select 1 into has_access
	  from rhnServer S,
	       web_contact wc
	 where wc.org_id = s.org_id
	   and s.id = server_id_in
	   and wc.id = user_id_in;

	-- okay, so they're in the same org.  if we have an org admin, they get a free pass
    	if rhn_user.check_role(user_id_in, 'org_admin') = 1
	then
	    return 1;
	end if;

    	select 1 into has_access
	  from rhnServerGroupMembers SGM,
	       rhnUserServerGroupPerms USG
	 where SGM.server_group_id = USG.server_group_id
	   and SGM.server_id = server_id_in
	   and USG.user_id = user_id_in
	   and rownum = 1;

	return 1;
    exception
    	when no_data_found
	    then
	    return 0;
    end check_user_access;

    -- *******************************************************************
    -- FUNCTION: can_server_consume_virt_slot
    -- Returns 1 if the server id is eligible to consume a virtual slot,
    --   else returns 0.
    -- Called by: insert_into_servergroup, delete_from_servergroup
    -- *******************************************************************
    function can_server_consume_virt_slot(server_id_in in number,
                                           group_type_in in
                                           rhnServerGroupType.label%TYPE)
    return number
    is

        cursor server_virt_slots is
            select vi.VIRTUAL_SYSTEM_ID
            from
                rhnVirtualInstance vi
            where
                -- server id is a virtual instance
                vi.VIRTUAL_SYSTEM_ID = server_id_in
                -- server id's host is virt entitled
                and exists ( select 1
                     from rhnServerEntitlementView sev
                 where vi.HOST_SYSTEM_ID = sev.server_id
                 and sev.label in ('virtualization_host',
                                   'virtualization_host_platform') )
                -- server id's host also has the ent we want
                and exists ( select 1
                     from rhnServerEntitlementView sev2
                 where vi.HOST_SYSTEM_ID = sev2.server_id
                 and sev2.label = group_type_in );

    begin
        for server_virt_slot in server_virt_slots loop
            return 1;
        end loop;
        return 0;
    end can_server_consume_virt_slot;


    procedure insert_into_servergroup (
		server_id_in in number,
		server_group_id_in in number
    ) is
		used_slots number;
		max_slots number;
		org_id number;
		mgmt_available number;
		mgmt_upgrade number;
		mgmt_sgid number;
		prov_available number;
		prov_upgrade number;
		prov_sgid number;
		group_label rhnServerGroupType.label%TYPE;
		group_type number;
	begin
		-- frist, group_type = null, because it's easy...

		-- this will rowlock the servergroup we're trying to change;
		-- we probably need to lock the other one, but I think the chances
		-- of it being a real issue are very small for now...
		select	sg.group_type, sg.org_id, sg.current_members, sg.max_members
		into	group_type, org_id, used_slots, max_slots
		from	rhnServerGroup sg
		where	sg.id = server_group_id_in
		for update of sg.current_members;

		if group_type is null then
			if used_slots >= max_slots then
				rhn_exception.raise_exception('servergroup_max_members');
			end if;

			insert into rhnServerGroupMembers(
					server_id, server_group_id
				) values (
					server_id_in, server_group_id_in
				);
			update rhnServerGroup
				set current_members = current_members + 1
				where id = server_group_id_in;

			rhn_cache.update_perms_for_server_group(server_group_id_in);
			return;
		end if;

		-- now for group_type != null
		--
		select	label
		into	group_label
		from	rhnServerGroupType	sgt
		where	sgt.id = group_type;

		-- the naive easy path that gets hit most often and has to be quickest.
		if group_label in ('sw_mgr_entitled',
                           'enterprise_entitled',
                           'monitoring_entitled',
                           'provisioning_entitled',
                           'virtualization_host',
                           'virtualization_host_platform') then
			if used_slots >= max_slots and
               (can_server_consume_virt_slot(server_id_in, group_label) != 1)
               then
				rhn_exception.raise_exception('servergroup_max_members');
			end if;

			insert into rhnServerGroupMembers(
					server_id, server_group_id
				) values (
					server_id_in, server_group_id_in
				);

            -- Only update current members if the system in consuming a
            -- physical slot.
            if can_server_consume_virt_slot(server_id_in, group_label) = 0 then
                update rhnServerGroup
                set current_members = current_members + 1
                where id = server_group_id_in;
            end if;

			return;
		end if;
	end;

	function insert_into_servergroup_maybe (
		server_id_in in number,
		server_group_id_in in number
	) return number is
		retval number := 0;
		cursor servergroups is
			select	s.id	server_id,
					sg.id	server_group_id
			from	rhnServerGroup	sg,
					rhnServer		s
			where	s.id = server_id_in
				and sg.id = server_group_id_in
				and s.org_id = sg.org_id
				and not exists (
					select	1
					from	rhnServerGroupMembers sgm
					where	sgm.server_id = s.id
						and sgm.server_group_id = sg.id
				);
	begin
		for sgm in servergroups loop
			rhn_server.insert_into_servergroup(sgm.server_id, sgm.server_group_id);
			retval := retval + 1;
		end loop;
		return retval;
	end insert_into_servergroup_maybe;

	procedure insert_set_into_servergroup (
		server_group_id_in in number,
		user_id_in in number,
		set_label_in in varchar2
	) is
		cursor servers is
			select	st.element	id
			from	rhnSet		st
			where	st.user_id = user_id_in
				and st.label = set_label_in
				and exists (
					select	1
					from	rhnUserManagedServerGroups umsg
					where	umsg.server_group_id = server_group_id_in
						and umsg.user_id = user_id_in
					)
				and not exists (
					select	1
					from	rhnServerGroupMembers sgm
					where	sgm.server_id = st.element
						and sgm.server_group_id = server_group_id_in
				);
	begin
		for s in servers loop
			rhn_server.insert_into_servergroup(s.id, server_group_id_in);
		end loop;
	end insert_set_into_servergroup;

    procedure delete_from_servergroup (
    	server_id_in in number,
		server_group_id_in in number
    ) is
        cursor server_virt_groups is
            select 1
            from rhnServerEntitlementVirtual sev
            where sev.server_id = server_id_in
            and sev.server_group_id = server_group_id_in;

		oid number;
		mgmt_sgid number;
		label rhnServerGroupType.label%TYPE;
		group_type number;
	begin
		begin
			select	sg.group_type, sg.org_id
			into	group_type,	oid
			from	rhnServerGroupMembers	sgm,
					rhnServerGroup			sg
			where	sg.id = server_group_id_in
				and sg.id = sgm.server_group_id
				and sgm.server_id = server_id_in
			for update of sg.current_members;
		exception
			when no_data_found then
				rhn_exception.raise_exception('server_not_in_group');
		end;

		-- do group_type is null first
		if group_type is null then
			delete from rhnServerGroupMembers
				where server_group_id = server_group_id_in
				and	server_id = server_id_in;
			update rhnServerGroup
				set current_members = current_members - 1
				where id = server_group_id_in;
			rhn_cache.update_perms_for_server_group(server_group_id_in);
			return;
		end if;

		select	sgt.label
		into	label
		from	rhnServerGroupType sgt
		where	sgt.id = group_type;

		if label in ('sw_mgr_entitled',
                     'enterprise_entitled',
                     'provisioning_entitled',
                     'monitoring_entitled',
                     'virtualization_host',
                     'virtualization_host_platform') then

            -- Only update current members if the system is consuming
            -- a physical slot.
            for server_virt_group in server_virt_groups loop
                delete from rhnServerGroupMembers
                where server_group_id = server_group_id_in
                and	server_id = server_id_in;
                return;
            end loop;

            delete from rhnServerGroupMembers
            where server_group_id = server_group_id_in
            and	server_id = server_id_in;

            update rhnServerGroup
            set current_members = current_members - 1
            where id = server_group_id_in;

		end if;
	end;

	procedure delete_set_from_servergroup (
		server_group_id_in in number,
		user_id_in in number,
		set_label_in in varchar2
	) is
		cursor servergroups is
			select	sgm.server_id, sgm.server_group_id
			from	rhnSet st,
					rhnServerGroupMembers sgm
			where	sgm.server_group_id = server_group_id_in
				and st.user_id = user_id_in
				and st.label = set_label_in
				and sgm.server_id = st.element
				and exists (
					select	1
					from	rhnUserManagedServerGroups usgp
					where	usgp.server_group_id = server_group_id_in
						and usgp.user_id = user_id_in
				);
	begin
		for sgm in servergroups loop
			rhn_server.delete_from_servergroup(sgm.server_id, server_group_id_in);
		end loop;
	end delete_set_from_servergroup;

	procedure clear_servergroup (
		server_group_id_in in number
	) is
		cursor servers is
			select	sgm.server_id	id
			from	rhnServerGroupMembers sgm
			where	sgm.server_group_id = server_group_id_in;
	begin
		for s in servers loop
			rhn_server.delete_from_servergroup(s.id, server_group_id_in);
		end loop;
	end clear_servergroup;

	procedure delete_from_org_servergroups (
		server_id_in in number
	) is
		cursor servergroups is
			select	sgm.server_group_id id
			from	rhnServerGroup sg,
					rhnServerGroupMembers sgm
			where	sgm.server_id = server_id_in
				and sgm.server_group_id = sg.id
				and sg.group_type is null;
	begin
		for sg in servergroups loop
			rhn_server.delete_from_servergroup(server_id_in, sg.id);
		end loop;
	end delete_from_org_servergroups;

	function get_ip_address (
		server_id_in in number
	) return varchar2 is
		cursor interfaces is
			select	name, ip_addr
			from	rhnServerNetInterface
			where	server_id = server_id_in
				and ip_addr != '127.0.0.1';
		cursor addresses is
			select	ipaddr ip_addr
			from	rhnServerNetwork
			where	server_id = server_id_in
				and ipaddr != '127.0.0.1';
	begin
		for addr in addresses loop
			return addr.ip_addr;
		end loop;
		for iface in interfaces loop
			return iface.ip_addr;
		end loop;
		return NULL;
	end get_ip_address;
end rhn_server;
 
/
