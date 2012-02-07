-- oracle equivalent source sha1 aa213cf003af90f80ef228f0ecd1e3a36836d3ca
--
-- Copyright (c) 2008--2011 Red Hat, Inc.
--
-- This software is licensed to you under the GNU General Public License,
-- version 2 (GPLv2). There is NO WARRANTY for this software, express or
-- implied, including the implied warranties of MERCHANTABILITY or FITNESS
-- FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
-- along with this software; if not, see
-- http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
-- 
-- Red Hat trademarks are not licensed under GPLv2. No permission is
-- granted to use or replicate Red Hat trademarks that are incorporated
-- in this software or its documentation. 
--
--
--
--

-- create schema rhn_server;

--update pg_setting
update pg_settings set setting = 'rhn_server,' || setting where name = 'search_path';

    create or replace function system_service_level(
    	server_id_in in numeric,
	service_level_in in varchar
    ) returns numeric as $$
    declare
    ents cursor is 
      select label from rhnServerEntitlementView
      where server_id = server_id_in;

    retval numeric := 0;

    begin
         for ent in ents loop
            retval := rhn_entitlements.entitlement_grants_service (ent.label, service_level_in);
            if retval = 1 then
               return retval;
            end if;
         end loop;

         return retval;

    end$$ language plpgsql;

        
    create or replace function can_change_base_channel(server_id_in IN NUMERIC)
    returns numeric
    as $$
    declare
    	throwaway numeric;
    begin
    	-- the idea: if we get past this query, the server is
	-- neither sat nor proxy, so base channel is changeable
	
	select 1 into throwaway
	  from rhnServer S
	 where S.id = server_id_in
	   and not exists (select 1 from rhnSatelliteInfo SI where SI.server_id = S.id)
	   and not exists (select 1 from rhnProxyInfo PI where PI.server_id = S.id);

        if not found then
	    return 0;
        end if;
	   
	return 1;
    end$$ language plpgsql;
	        
    create or replace function set_custom_value(
    	server_id_in in numeric,
	user_id_in in numeric,
	key_label_in in varchar,
	value_in in varchar
    ) returns void
    as $$
    declare
    	key_id_val numeric;
    begin
    	select CDK.id into strict key_id_val
	  from rhnCustomDataKey CDK,
	       rhnServer S
	 where S.id = server_id_in
	   and S.org_id = CDK.org_id
	   and CDK.label = key_label_in;
	   
	begin
	    insert into rhnServerCustomDataValue (server_id, key_id, value, created_by, last_modified_by)
	    values (server_id_in, key_id_val, value_in, user_id_in, user_id_in);
	exception
	    when UNIQUE_VIOLATION
	    	then
		update rhnServerCustomDataValue
		   set value = value_in,
		       last_modified_by = user_id_in
		 where server_id = server_id_in
		   and key_id = key_id_val;		   
	end;
	
    end$$ language plpgsql;
    
    create or replace function bulk_set_custom_value(
    	key_label_in in varchar,
	value_in in varchar,
	set_label_in in varchar,
	set_uid_in in numeric
    )
    returns integer
    as $$
    declare
        i integer;
        server record;
    begin
        i := 0;
        for server in (
           SELECT user_id, label, element, element_two
	     FROM rhnSet
	    WHERE label = set_label_in
	      AND user_id = set_uid_in
	) loop
	    if rhn_server.system_service_level(server.element, 'provisioning') = 1 then
	    	perform rhn_server.set_custom_value(server.element, set_uid_in, key_label_in, value_in);
            i := i + 1;
	    end if;
	end loop;
    return i;
    end$$ language plpgsql;

    create or replace function bulk_snapshot_tag(
    	org_id_in in numeric,
        tagname_in in varchar,
	set_label_in in varchar,
	set_uid_in in numeric
    ) returns void
    as $$
    declare
        server record;
    	snapshot_id numeric;
    begin
        for server in (
           SELECT user_id, label, element, element_two
	     FROM rhnSet
	    WHERE label = set_label_in
	      AND user_id = set_uid_in
	    ) loop
	    if rhn_server.system_service_level(server.element, 'provisioning') = 1 then
	    	    select max(id) into snapshot_id
	    	    from rhnSnapshot
	    	    where server_id = server.element;

	    	    if snapshot_id is null then
		    	perform rhn_server.snapshot_server(server.element, 'tagging system:  ' || tagname_in);
			
			select max(id) into snapshot_id
			from rhnSnapshot
			where server_id = server.element;
		    end if;
		 
		-- now have a snapshot_id to work with...
		begin
		    perform rhn_server.tag_snapshot(snapshot_id, org_id_in, tagname_in);
		exception
		    when UNIQUE_VIOLATION
		    	then
			-- do nothing, be forgiving...
			null;
		end;
	    end if;
	end loop;    
    end$$ language plpgsql;

    create or replace function tag_delete(
    	server_id_in in numeric,
	tag_id_in in numeric
    ) returns void
    as $$
    declare
    	snapshots cursor is
		select	snapshot_id
		from	rhnSnapshotTag
		where	tag_id = tag_id_in;
	tag_id_tmp numeric;
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
    end$$ language plpgsql;

    create or replace function tag_snapshot(
        snapshot_id_in in numeric,
	org_id_in in numeric,
	tagname_in in varchar
    ) returns void
    as $$
    begin
    	insert into rhnSnapshotTag (snapshot_id, server_id, tag_id)
	select snapshot_id_in, server_id, lookup_tag(org_id_in, tagname_in)
	from rhnSnapshot
	where id = snapshot_id_in;
    end$$ language plpgsql;

    create or replace function bulk_snapshot(
    	reason_in in varchar,
	set_label_in in varchar,
	set_uid_in in numeric
    ) returns void
    as $$
    declare
        server record;
    begin
        for server in (
           SELECT user_id, label, element, element_two
	     FROM rhnSet
	    WHERE label = set_label_in
	      AND user_id = set_uid_in
	    ) loop
    	    if rhn_server.system_service_level(server.element, 'provisioning') = 1 then
	    	perform rhn_server.snapshot_server(server.element, reason_in);
	    end if;
	end loop;
    end$$ language plpgsql;

    create or replace function snapshot_server(
    	server_id_in in numeric,
	reason_in in varchar
    ) returns void
    as $$
    declare
    	snapshot_id_v numeric;
	revisions cursor is
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
    	select nextval('rhn_snapshot_id_seq') into snapshot_id_v;

	insert into rhnSnapshot (id, org_id, server_id, reason) (
		select	snapshot_id_v,
			s.org_id,
			server_id_in,
			reason_in
		from	rhnServer s
		where	s.id = server_id_in
	);
	insert into rhnSnapshotChannel (snapshot_id, channel_id) (
		select	snapshot_id_v, sc.channel_id
		from	rhnServerChannel sc
		where	sc.server_id = server_id_in
	);
	insert into rhnSnapshotServerGroup (snapshot_id, server_group_id) (
		select	snapshot_id_v, sgm.server_group_id
		from	rhnServerGroupMembers sgm
		where	sgm.server_id = server_id_in
	);
        locked := 0;
        <<iloop>>
        while true loop
            begin
                insert into rhnPackageNEVRA (id, name_id, evr_id, package_arch_id)
                select nextval('rhn_pkgnevra_id_seq'), sp.name_id, sp.evr_id, sp.package_arch_id
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
                exit iloop;
            exception when unique_violation then
                if locked = 1 then
                    raise;
                else
                    lock table rhnPackageNEVRA in exclusive mode;
                    locked := 1;
                end if;
            end;
        end loop;
	insert into rhnSnapshotPackage (snapshot_id, nevra_id) (
                select distinct snapshot_id_v, nevra.id
                from    rhnServerPackage sp, rhnPackageNEVRA nevra
                where   sp.server_id = server_id_in
                        and nevra.name_id = sp.name_id
                        and nevra.evr_id = sp.evr_id
                        and (nevra.package_arch_id = sp.package_arch_id
                            or (nevra.package_arch_id is null
                                and sp.package_arch_id is null))
	);

	insert into rhnSnapshotConfigChannel ( snapshot_id, config_channel_id ) (
		select	snapshot_id_v, scc.config_channel_id
		from	rhnServerConfigChannel scc
		where	server_id = server_id_in
	);

	for revision in revisions loop
		insert into rhnSnapshotConfigRevision (
				snapshot_id, config_revision_id
			) values (
				snapshot_id_v, revision.id
			);
	end loop;
    end$$ language plpgsql;

    create or replace function remove_action(
    	server_id_in in numeric,
	action_id_in in numeric
    ) returns void
    as $$
    declare
    	-- this really wants "nulls last", but 8.1.7.3.0 sucks ass.
	-- instead, we make a local table that holds our
	-- list of ids with null prereqs.  There's surely a better way
	-- (an array instead of a table maybe?  who knows...)
	-- but I've got code to do this handy that I can look at ;)
    	chained_actions cursor is
                with recursive r(id, prerequisite) as (
			select	id, prerequisite
			from	rhnAction
			where id = action_id_in
		union all
			select	r1.id, r1.prerequisite
			from	rhnAction r1, r
			where r.id = r1.prerequisite
		)
		select * from r
		order by prerequisite desc;
	sessions cursor is
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
	chain_ends numeric[];
	i numeric;
	prereq numeric := 1;
    begin
	select	prerequisite
	into	prereq
	from	rhnAction
	where	id = action_id_in;

	if prereq is not null then
		perform rhn_exception.raise_exception('action_is_child');
	end if;

        chain_ends := '{}';
	i := 1;
	for action in chained_actions loop
		if action.prerequisite is null then
			chain_ends[i] := action.id;
			i := i + 1;
		else
			delete from rhnServerAction
				where server_id = server_id_in
				and action_id = action.id;
		end if;
	end loop;

	delete from rhnServerAction
		where server_id = server_id_in
		and action_id = any(chain_ends);

	for s in sessions loop
		update rhnKickstartSession
			set 	state_id = (
					select	id
					from	rhnKickstartSessionState
					where	label = 'failed'
				),
				action_id = null
			where	id = s.id;
		perform set_ks_session_history_message(s.id, 'failed', 'Kickstart cancelled due to action removal');
	end loop;
    end$$ language plpgsql;
   
    create or replace function check_user_access(server_id_in in numeric, user_id_in in numeric)
    returns numeric
    as $$
    declare
    	has_access numeric;
    begin
    	-- first check; if this returns no rows, then the server/user are in different orgs, and we bail
        select 1 into has_access
	  from rhnServer S,
	       web_contact wc
	 where wc.org_id = s.org_id
	   and s.id = server_id_in
	   and wc.id = user_id_in;

        if not found then
          return 0;
        end if;

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
	   and USG.user_id = user_id_in;

        if not found then
          return 0;
        end if;
	   
	return 1;
    end$$ language plpgsql;

    -- *******************************************************************
    -- FUNCTION: can_server_consume_virt_slot
    -- Returns 1 if the server id is eligible to consume a virtual slot,
    --   else returns 0.
    -- Called by: insert_into_servergroup, delete_from_servergroup
    -- *******************************************************************
    create or replace function can_server_consume_virt_slot(server_id_in in numeric,
                                           group_type_in in varchar)
    returns numeric                                           
    as $$
    declare
        server_virt_slots cursor is
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
    end$$ language plpgsql;


    create or replace function insert_into_servergroup (
		server_id_in in numeric,
		server_group_id_in in numeric
    ) returns void
    as $$
    declare
		used_slots numeric;
		max_slots numeric;
		org_id numeric;
		mgmt_available numeric;
		mgmt_upgrade numeric;
		mgmt_sgid numeric;
		prov_available numeric;
		prov_upgrade numeric;
		prov_sgid numeric;
		group_label varchar;
		group_type numeric;
	begin
		-- first, group_type = null, because it's easy...

		-- this will rowlock the servergroup we're trying to change;
		-- we probably need to lock the other one, but I think the chances
		-- of it being a real issue are very small for now...
		select	sg.group_type, sg.org_id, sg.current_members, sg.max_members
		into	group_type, org_id, used_slots, max_slots
		from	rhnServerGroup sg
		where	sg.id = server_group_id_in
		for update of sg;

		if group_type is null then
			if used_slots >= max_slots then
				perform rhn_exception.raise_exception('servergroup_max_members');
			end if;

			insert into rhnServerGroupMembers(
					server_id, server_group_id
				) values (
					server_id_in, server_group_id_in
				);
			update rhnServerGroup
				set current_members = current_members + 1
				where id = server_group_id_in;

			perform rhn_cache.update_perms_for_server_group(server_group_id_in);
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
               (rhn_server.can_server_consume_virt_slot(server_id_in, group_label) != 1) 
               then
				perform rhn_exception.raise_exception('servergroup_max_members');
			end if;

			insert into rhnServerGroupMembers(
					server_id, server_group_id
				) values (
					server_id_in, server_group_id_in
				);

            -- Only update current members if the system in consuming a 
            -- physical slot.
            if rhn_server.can_server_consume_virt_slot(server_id_in, group_label) = 0 then
                update rhnServerGroup
                set current_members = current_members + 1
                where id = server_group_id_in;
            end if;                

			return;
		end if;
	end$$ language plpgsql;

	create or replace function insert_into_servergroup_maybe (
		server_id_in in numeric,
		server_group_id_in in numeric
	) returns numeric as $$ 
    declare
		retval numeric := 0;
		servergroups cursor is
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
			perform rhn_server.insert_into_servergroup(sgm.server_id, sgm.server_group_id);
			retval := retval + 1;
		end loop;
		return retval;
	end$$ language plpgsql;

	create or replace function insert_set_into_servergroup (
		server_group_id_in in numeric,
		user_id_in in numeric,
		set_label_in in varchar
	) returns void
        as $$
    declare
		servers cursor is
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
			perform rhn_server.insert_into_servergroup(s.id, server_group_id_in);
		end loop;
	end$$ language plpgsql;
		
    create or replace function delete_from_servergroup (
    	server_id_in in numeric,
		server_group_id_in in numeric
    ) returns void
    as $$
    declare
        server_virt_groups cursor is
            select 1
            from rhnServerEntitlementVirtual sev
            where sev.server_id = server_id_in
            and sev.server_group_id = server_group_id_in;

		oid numeric;
		mgmt_sgid numeric;
		label varchar;
		group_type numeric;
	begin
			select	sg.group_type, sg.org_id
			into	group_type,	oid
			from	rhnServerGroupMembers	sgm,
					rhnServerGroup			sg
			where	sg.id = server_group_id_in
				and sg.id = sgm.server_group_id
				and sgm.server_id = server_id_in
			for update of sg;

			if not found then
				perform rhn_exception.raise_exception('server_not_in_group');
			end if;

		-- do group_type is null first
		if group_type is null then
			delete from rhnServerGroupMembers
				where server_group_id = server_group_id_in
				and	server_id = server_id_in;
			update rhnServerGroup
				set current_members = current_members - 1
				where id = server_group_id_in;
			perform rhn_cache.update_perms_for_server_group(server_group_id_in);
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
	end$$ language plpgsql;

	create or replace function delete_set_from_servergroup (
		server_group_id_in in numeric,
		user_id_in in numeric,
		set_label_in in varchar
	) returns void
        as $$	
        declare
		servergroups cursor is
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
			perform rhn_server.delete_from_servergroup(sgm.server_id, server_group_id_in);
		end loop;
	end$$ language plpgsql;

	create or replace function clear_servergroup (
		server_group_id_in in numeric
	) returns void
        as $$
        declare
		servers cursor is
			select	sgm.server_id	id
			from	rhnServerGroupMembers sgm
			where	sgm.server_group_id = server_group_id_in;
	begin
		for s in servers loop
			perform rhn_server.delete_from_servergroup(s.id, server_group_id_in);
		end loop;
	end$$ language plpgsql;

	create or replace function delete_from_org_servergroups (
		server_id_in in numeric
	) returns void
        as $$
        declare
		servergroups cursor is
			select	sgm.server_group_id id
			from	rhnServerGroup sg,
					rhnServerGroupMembers sgm
			where	sgm.server_id = server_id_in
				and sgm.server_group_id = sg.id
				and sg.group_type is null;
	begin
		for sg in servergroups loop
			perform rhn_server.delete_from_servergroup(server_id_in, sg.id);
		end loop;
	end$$ language plpgsql;

	create or replace function get_ip_address (
		server_id_in in numeric
	) returns varchar as $$
        declare
		interfaces cursor is
			select	ni.name as name, na4.address as address
			from	rhnServerNetInterface ni,
			        rhnServerNetAddress4 na4
			where	server_id = server_id_in
                and ni.id = na4.interface_id
				and na4.address != '127.0.0.1';
		addresses cursor is
			select	ipaddr ip_addr
			from	rhnServerNetwork
			where	server_id = server_id_in
				and ipaddr != '127.0.0.1';
	begin
		for addr in addresses loop
			return addr.ip_addr;
		end loop;
		for iface in interfaces loop
			return iface.address;
		end loop;
		return NULL;
	end$$ language plpgsql;

    create or replace function update_needed_cache(
        server_id_in in numeric
	) returns void as $$
    begin
        delete from rhnServerNeededCache
         where server_id = server_id_in;
        insert into rhnServerNeededCache
               (server_id, errata_id, package_id)
               (select distinct server_id, errata_id, package_id
                  from rhnServerNeededView
                 where server_id = server_id_in);
	end$$ language plpgsql;

-- restore the original setting
update pg_settings set setting = overlay( setting placing '' from 1 for (length('rhn_server')+1) ) where name = 'search_path';
