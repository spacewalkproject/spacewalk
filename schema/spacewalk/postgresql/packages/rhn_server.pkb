create schema rhn_server;

-- setup search_path so that these functions are created in appropriate schema.
update pg_settings set setting = 'rhn_server,' || setting where name = 'search_path';



CREATE OR REPLACE FUNCTION system_service_level(server_id_in numeric, service_level_in character varying)
  RETURNS numeric AS
$$
    declare

    ents cursor for
      select label from rhnServerEntitlementView
      where server_id = server_id_in;

    ents_curs_label	varchar;

    retval numeric := 0;

    begin

	open ents;
	loop
	fetch ents into ents_curs_label;
	exit when not found;
		retval := rhn_entitlements.entitlement_grants_service (ent.label, service_level_in);

		if retval = 1 then
               return retval;
            end if;
	end loop;

         return retval;

    end;
    $$
  LANGUAGE 'plpgsql';



 CREATE OR REPLACE FUNCTION can_change_base_channel(server_id_in numeric)
  RETURNS numeric AS
$$
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

    
    end;
    $$
  LANGUAGE 'plpgsql';


  
CREATE OR REPLACE FUNCTION set_custom_value(server_id_in numeric, user_id_in numeric, key_label_in character varying, value_in character varying)
  RETURNS void AS
$$
declare
        key_id_val numeric;
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
            when unique_violation
                then
                update rhnServerCustomDataValue
                   set value = value_in,
                       last_modified_by = user_id_in
                 where server_id = server_id_in
                   and key_id = key_id_val;
        end;

end;
$$
LANGUAGE 'plpgsql';


create or replace function bulk_set_custom_value(key_label_in in varchar,value_in in varchar,set_label_in in varchar,set_uid_in in numeric)
    returns integer
    as
    $$
    declare
	set_iterator CURSOR (set_label_in VARCHAR, set_user_id_in NUMERIC) FOR
           SELECT user_id, label, element, element_two
             FROM rhnSet
            WHERE label = set_label_in
              AND user_id = set_user_id_in;

	set_itrtr_rec	RECORD;
    
	i integer := 0;
    begin
        i := 0;

	open set_iterator(set_label_in,set_uid_in);
        loop
		fetch set_iterator into set_itrtr_rec;
		exit when not found;
		if rhn_server.system_service_level(server.element, 'provisioning') = 1 then
			perform rhn_server.set_custom_value(server.element, set_uid_in, key_label_in, value_in);
			i := i + 1;
		end if;
		
        end loop;

    return i;
end;
$$
language plpgsql;
    

create or replace  function bulk_snapshot_tag(org_id_in in numeric,tagname_in in varchar,set_label_in in varchar,set_uid_in in numeric) returns void
as
$$
declare
        snapshot_id numeric;

        set_iterator CURSOR (set_label_in VARCHAR, set_user_id_in NUMERIC) FOR
           SELECT user_id, label, element, element_two
             FROM rhnSet
            WHERE label = set_label_in
              AND user_id = set_user_id_in;

	set_itrtr_rec	RECORD;
begin

	open set_iterator(set_label_in, set_uid_in);
	loop
		fetch set_iterator into set_itrtr_rec;
		exit when not found;
		
		if rhn_server.system_service_level(set_itrtr_rec.element, 'provisioning') = 1 then
                begin
                    select max(id) into snapshot_id
                    from rhnSnapshot
                    where server_id = server.element;
                if not found then
                        perform rhn_server.snapshot_server(set_itrtr_rec.element, 'tagging system:  ' || tagname_in);
                end if;

                        select max(id) into snapshot_id
                        from rhnSnapshot
                        where server_id = set_itrtr_rec.element;
                end;

                -- now have a snapshot_id to work with...
                begin
                    perform rhn_server.tag_snapshot(snapshot_id, org_id_in, tagname_in);
                exception
                    when 	UNIQUE_VIOLATION
                        then
                        -- do nothing, be forgiving...
                        null;
                end;
            end if;
	end loop;
	close set_iterator;
        
    end;
$$
language plpgsql;

create or replace function tag_delete(server_id_in in numeric, tag_id_in in numeric) returns void
as
$$
declare
        snapshots cursor for
                select  snapshot_id
                from    rhnSnapshotTag
                where   tag_id = tag_id_in;
        snaps_curs_id	numeric;
        tag_id_tmp numeric;
    begin
        select  id into tag_id_tmp
        from    rhnTag
        where   id = tag_id_in
        for update;

        delete
                from    rhnSnapshotTag
                where   server_id = server_id_in
                        and tag_id = tag_id_in;

	open snapshots;
	loop
		fetch snapshots into snaps_curs_id;
		exit when not found;
		return;
	end loop;
        
        delete from rhnTag where id = tag_id_in;
end;
$$
language plpgsql;

create or replace function tag_snapshot(snapshot_id_in in numeric,org_id_in in numeric, tagname_in in varchar) returns void
as
$$
    begin
        insert into rhnSnapshotTag (snapshot_id, server_id, tag_id)
        select snapshot_id_in, server_id, lookup_tag(org_id_in, tagname_in)
        from rhnSnapshot
        where id = snapshot_id_in;
end;
$$
language plpgsql;

create or replace function bulk_snapshot(reason_in in varchar, set_label_in in varchar,set_uid_in in numeric) returns void as
$$
declare
	set_iterator CURSOR (set_label_in VARCHAR, set_user_id_in NUMERIC) FOR
           SELECT user_id, label, element, element_two
             FROM rhnSet
            WHERE label = set_label_in
              AND user_id = set_user_id_in;

	set_itrtr_rec	RECORD;
    begin
	open set_iterator(set_label_in, set_uid_in);
	loop
		fetch set_iterator into set_itrtr_rec;
		exit when not found;
		if rhn_server.system_service_level(set_itrtr_rec.element, 'provisioning') = 1 then
			perform rhn_server.snapshot_server(set_itrtr_rec.element, reason_in);
            end if;
	end loop;
	close set_iterator;
        
end;
$$
language plpgsql;



create or replace function snapshot_server(server_id_in in numeric, reason_in in varchar) returns void
as
$$
declare
        snapshot_id_var numeric;
        revisions cursor for
                select distinct
                        cr.id
                from    rhnConfigRevision       cr,
                        rhnConfigFileName       cfn,
                        rhnConfigFile           cf,
                        rhnConfigChannel        cc,
                        rhnServerConfigChannel  scc
                where   1=1
                        and scc.server_id = server_id_in
                        and scc.config_channel_id = cc.id
                        and cc.id = cf.config_channel_id
                        and cf.id = cr.config_file_id
                        and cr.id = cf.latest_config_revision_id
                        and cf.config_file_name_id = cfn.id
                        and cf.id = lookup_first_matching_cf(scc.server_id, cfn.path);

	rev_curs_id	numeric;
                        
        locked integer;
    begin
        select rhn_snapshot_id_seq.nextval into snapshot_id_var; -- from dual;

        insert into rhnSnapshot (id, org_id, server_id, reason) (
                select  snapshot_id,
                        s.org_id,
                        server_id_in,
                        reason_in
                from    rhnServer s
                where   s.id = server_id_in
        );
        insert into rhnSnapshotChannel (snapshot_id, channel_id) (
                select  snapshot_id, sc.channel_id
                from    rhnServerChannel sc
                where   sc.server_id = server_id_in
        );
        insert into rhnSnapshotServerGroup (snapshot_id, server_group_id) (
                select  snapshot_id, sgm.server_group_id
                from    rhnServerGroupMembers sgm
                where   sgm.server_id = server_id_in
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
            exception when unique_violation then
                if locked = 1 then
                    raise exception '';
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
                select  snapshot_id, scc.config_channel_id
                from    rhnServerConfigChannel scc
                where   server_id = server_id_in
        );

	open revisions;
	loop
		fetch revisions into rev_curs_id;
		exit when not found;
		insert into rhnSnapshotConfigRevision (
                                snapshot_id, config_revision_id
                        ) values (
                                snapshot_id_var, revision.id
                        );
	end loop;
	
        
    end;
$$
language plpgsql;

create or replace function remove_action(server_id_in in numeric, action_id_in in numeric) returns void
as
$$
declare
        -- this really wants "nulls last", but 8.1.7.3.0 sucks ass.
        -- instead, we make a local table that holds our
        -- list of ids with null prereqs.  There's surely a better way
        -- (an array instead of a table maybe?  who knows...)
        -- but I've got code to do this handy that I can look at ;)
        chained_actions cursor for
                /*select  id, prerequisite
                from    rhnAction
                start with id = action_id_in
                connect by prior id = prerequisite
                order by prerequisite desc;*/
		select  id, prerequisite 
		from rhn_get_action_prerequisites( action_id_in ) 
		as f( id numeric, prerequisite numeric, level int);

                

	ch_act_curs_rec	record;
                
        sessions cursor for
                select  s.id
                from    rhnKickstartSession s
                where   server_id_in in (s.old_server_id, s.new_server_id)
                        and s.action_id = action_id_in
                        and not exists (
                                select  1
                                from    rhnKickstartSessionState ss
                                where   ss.id = s.state_id
                                        and ss.label in ('failed','complete')
                        );

	sess_curs_id	numeric;

        --chain_end_type numeric[]; --is table of number index by binary_integer;
        chain_ends numeric;--chain_end_type;
        i numeric;
        prereq numeric := 1;

        
    begin
        select  prerequisite
        into    prereq
        from    rhnAction
        where   id = action_id_in;

        if prereq is not null then
                perform rhn_exception.raise_exception('action_is_child');
        end if;

        i := 0;

        open chained_actions;
        loop
		fetch chained_actions into ch_act_curs_rec;
		exit when not found;
		if ch_act_curs_rec.prerequisite is null then
                        chain_ends[i] := ch_act_curs_rec.id;
                        i := i + 1;
                else
                        delete from rhnServerAction
                                where server_id = server_id_in
                                and action_id = ch_act_curs_rec.id;
                end if;
        end loop;
        close chained_actions;
        
                        
 

	FOR i IN COALESCE(array_lower(chain_ends,1),0) .. COALESCE(array_upper(chain_ends,1),-1) LOOP
		delete from rhnServerAction
                        where server_id = server_id_in
                        and action_id = chain_ends[i];
                        
	END LOOP;
        
        /*i := chain_ends.first;
        while i is not null loop
                delete from rhnServerAction
                        where server_id = server_id_in
                        and action_id = chain_ends[i];
                i := chain_ends.next[i];
        end loop;*/

        open sessions;
        loop
		fetch sessions into sess_curs_id;
		exit when not found;
		update rhnKickstartSession
                        set     state_id = (
                                        select  id
                                        from    rhnKickstartSessionState
                                        where   label = 'failed'
                                ),
                                action_id = null
                        where   id = sess_curs_id;
                perform set_ks_session_history_message(sess_curs_id, 'failed', 'Kickstart cancelled due to action removal');
        end loop;
        close sessions;
        
        
end;
$$
language plpgsql;

-- ////////////////////////////////////////////////////////////

create or replace function check_user_access(server_id_in in numeric, user_id_in in numeric) returns numeric
as
$$
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

	if not found then 
            return 0;
	end if;

        return 1;

end;
$$
language plpgsql;

    -- *******************************************************************
    -- FUNCTION: can_server_consume_virt_slot
    -- Returns 1 if the server id is eligible to consume a virtual slot,
    --   else returns 0.
    -- Called by: insert_into_servergroup, delete_from_servergroup
    -- *******************************************************************
create or replace function can_server_consume_virt_slot (server_id_in in numeric,group_type_in in rhnServerGroupType.label%TYPE) returns numeric
as
$$
declare

        server_virt_slots cursor for
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

	serv_virt_slots_id	numeric;

    begin
	open server_virt_slots;
	loop
		fetch server_virt_slots into serv_virt_slots_id;
		return 1;
	end loop;
	close server_virt_slots;
	
        return 0;
end;
$$
language plpgsql;


create or replace function insert_into_servergroup (server_id_in in numeric, server_group_id_in in numeric) returns void
as
$$
declare
       sg_users cursor for
                        select  user_id
                        from    rhnUserServerGroupPerms
                        where   server_group_id = server_group_id_in;
                        
	sgu_curs_id	numeric;

                used_slots numeric;
                max_slots numeric;
                org_id numeric;
                mgmt_available numeric;
                mgmt_upgrade numeric;
                mgmt_sgid numeric;
                prov_available numeric;
                prov_upgrade numeric;
                prov_sgid numeric;
                group_label rhnServerGroupType.label%TYPE;
                group_type numeric;
        begin
                -- frist, group_type = null, because it's easy...

                -- this will rowlock the servergroup we're trying to change;
                -- we probably need to lock the other one, but I think the chances
                -- of it being a real issue are very small for now...
                
                select  sg.group_type, sg.org_id, sg.current_members, sg.max_members
                into    group_type, org_id, used_slots, max_slots
                from    rhnServerGroup sg
                where   sg.id = server_group_id_in
                for update of sg; --.current_members;

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
			open sg_users;
			loop
				fetch sg_users into sgu_curs_id;
				exit when not found;
				perform rhn_cache.update_perms_for_user(sgu_curs_id);
			end loop;
			close sg_users;                                
                        
                        return;
                end if;

                -- now for group_type != null
                --
                select  label
                into    group_label
                from    rhnServerGroupType      sgt
                where   sgt.id = group_type;

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
                                perform rhn_exception.raise_exception('servergroup_max_members');
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
$$
language plpgsql;

create or replace function insert_into_servergroup_maybe (server_id_in in numeric, server_group_id_in in numeric) returns numeric as
$$
declare
                retval numeric := 0;
                servergroups cursor for
                        select  s.id, sg.id
                        from    rhnServerGroup  sg,
                                        rhnServer               s
                        where   s.id = server_id_in
                                and sg.id = server_group_id_in
                                and s.org_id = sg.org_id
                                and not exists (
                                        select  1
                                        from    rhnServerGroupMembers sgm
                                        where   sgm.server_id = s.id
                                                and sgm.server_group_id = sg.id
                                );

		sg_curs_server_id	numeric;
		sg_curs_server_g_id	numeric;
		
        begin
		open servergroups;
		loop
			fetch servergroups into sg_curs_server_id,sg_curs_server_g_id;
			exit when not found;
			perform rhn_server.insert_into_servergroup(sgm.server_id, sgm.server_group_id);
                        retval := retval + 1;
		end loop;
		close servergroups;
		 
                return retval;
end;
$$
language plpgsql;


create or replace function insert_set_into_servergroup (server_group_id_in in numeric, user_id_in in numeric, set_label_in in varchar) returns void
as
$$
declare
                servers cursor for
                        select  st.element
                        from    rhnSet          st
                        where   st.user_id = user_id_in
                                and st.label = set_label_in
                                and exists (
                                        select  1
                                        from    rhnUserManagedServerGroups umsg
                                        where   umsg.server_group_id = server_group_id_in
                                                and umsg.user_id = user_id_in
                                        )
                                and not exists (
                                        select  1
                                        from    rhnServerGroupMembers sgm
                                        where   sgm.server_id = st.element
                                                and sgm.server_group_id = server_group_id_in
                                );
		server_curs_id	numeric;
        begin
		open servers;
		loop
			fetch servers into server_curs_id;
			exit when not found;
			perform rhn_server.insert_into_servergroup(s.id, server_group_id_in);
		end loop;
		close servers;
end;
$$
language plpgsql;

create or replace function delete_from_servergroup (server_id_in in numeric,server_group_id_in in numeric) returns void
as
$$
declare
	sg_users cursor for
		select  user_id 
		from    rhnUserServerGroupPerms
                where   server_group_id = server_group_id_in;

	sgu_curs_id	numeric;

        server_virt_groups cursor for
            select 1
            from rhnServerEntitlementVirtual sev
            where sev.server_id = server_id_in
            and sev.server_group_id = server_group_id_in;

	serv_v_curs_counter	numeric;
	
                oid numeric;
                mgmt_sgid numeric;
                label rhnServerGroupType.label%TYPE;
                group_type numeric;
        begin
                begin
                        select  sg.group_type, sg.org_id
                        into    group_type,     oid
                        from    rhnServerGroupMembers   sgm,
                                        rhnServerGroup                  sg
                        where   sg.id = server_group_id_in
                                and sg.id = sgm.server_group_id
                                and sgm.server_id = server_id_in
                        for update of rhnServerGroup;--.current_members;
                        
                if not found then
                                perform rhn_exception.raise_exception('server_not_in_group');
		end if;
                end;

                -- do group_type is null first
                if group_type is null then
                        delete from rhnServerGroupMembers
                                where server_group_id = server_group_id_in
                                and     server_id = server_id_in;
                        update rhnServerGroup
                                set current_members = current_members - 1
                                where id = server_group_id_in;
			open sg_users;
			loop
				fetch sg_users into sgu_curs_id;
				exit when not found;
				perform rhn_cache.update_perms_for_user(sgu_curs_id);
			end loop;
			close sg_users;
                        
                        return;
                end if;

                select  sgt.label
                into    label
                from    rhnServerGroupType sgt
                where   sgt.id = group_type;

                if label in ('sw_mgr_entitled',
                     'enterprise_entitled',
                     'provisioning_entitled',
                     'monitoring_entitled',
                     'virtualization_host',
                     'virtualization_host_platform') then

            -- Only update current members if the system is consuming
            -- a physical slot.
            open server_virt_groups;
            loop
		fetch server_virt_groups into serv_v_curs_counter;
		exit when not found;
		delete from rhnServerGroupMembers
                where server_group_id = server_group_id_in
                and     server_id = server_id_in;
                return;
            end loop;
            close server_virt_groups;

            delete from rhnServerGroupMembers
            where server_group_id = server_group_id_in
            and server_id = server_id_in;

            update rhnServerGroup
            set current_members = current_members - 1
            where id = server_group_id_in;

                end if;
        end;
$$
language plpgsql;

create or replace function delete_set_from_servergroup (server_group_id_in in numeric, user_id_in in numeric, set_label_in in varchar) returns void
as
$$
declare
                servergroups cursor for
                        select  sgm.server_id, sgm.server_group_id
                        from    rhnSet st,
                                        rhnServerGroupMembers sgm
                        where   sgm.server_group_id = server_group_id_in
                                and st.user_id = user_id_in
                                and st.label = set_label_in
                                and sgm.server_id = st.element
                                and exists (
                                        select  1
                                        from    rhnUserManagedServerGroups usgp
                                        where   usgp.server_group_id = server_group_id_in
                                                and usgp.user_id = user_id_in
                                );

		sg_curs_server_id	numeric;
		sg_curs_server_g_id	numeric;
        begin
		open servergroups;
		loop
			fetch servergroups into sg_curs_server_id,sg_curs_server_g_id;
			exit when not found;
			perform rhn_server.delete_from_servergroup(sg_curs_server_id,sg_curs_server_g_id);
		end loop;
		
end;
$$
language plpgsql;


create or replace function clear_servergroup (server_group_id_in in numeric) returns void as
$$
declare
	servers cursor for
		select  sgm.server_id
                from    rhnServerGroupMembers sgm
                where   sgm.server_group_id = server_group_id_in;
	serv_curs_id	numeric;
begin
	open servers;
	loop
		fetch servers into serv_curs_id;
		exit when not found;
		perform rhn_server.delete_from_servergroup(serv_curs_id, server_group_id_in);
	end loop;
	close servers;
end;
$$
language plpgsql;

create or replace function delete_from_org_servergroups (server_id_in in numeric) returns void
as
$$
declare

       servergroups cursor is
                        select  sgm.server_group_id
                        from    rhnServerGroup sg,
                                        rhnServerGroupMembers sgm
                        where   sgm.server_id = server_id_in
                                and sgm.server_group_id = sg.id
                                and sg.group_type is null;
	sg_curs_id	numeric;
begin
	open servergroups;
	
	loop
		fetch servergroups into sg_curs_id;
		exit when not found;
		perform rhn_server.delete_from_servergroup(server_id_in, sg_curs_id);
	end loop;
	close servergroups;
                
end;
$$
language plpgsql;

create or replace function get_ip_address (server_id_in in numeric) returns varchar as
$$
declare
	interfaces cursor for
                        select  name, ip_addr
                        from    rhnServerNetInterface
                        where   server_id = server_id_in
                                and ip_addr != '127.0.0.1';
	interfaces_rec	record;
                                
                addresses cursor for
                        select  ipaddr
                        from    rhnServerNetwork
                        where   server_id = server_id_in
                                and ipaddr != '127.0.0.1';
	addresses_rec	record;	

        begin
		open interfaces;
		loop
			fetch interfaces into interfaces_rec;
			exit when not found;
			return interfaces.rec.ip_addr;
		end loop;
		close interfaces;

		open addresses;
		loop
			fetch addresses into addresses_rec;
			exit when not found;
			return addresses_rec.ipaddr;
		end loop;
		close addresses;
		
                return NULL;
end;
$$
language plpgsql;

-- restore the original setting
update pg_settings set setting = overlay( setting placing '' from 1 for (length('rhn_server')+1) ) where name = 'search_path';




