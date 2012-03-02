-- oracle equivalent source sha1 0a57ce96576666f671bcc864cb954452935db1cc

-- setup search_path so that these functions are created in appropriate schema.
update pg_settings set setting = 'rhn_entitlements,' || setting where name = 'search_path';

    -- *******************************************************************
    -- PROCEDURE: prune_group
    -- Unsubscribes servers consuming physical slots that over the org's
    --   limit.
    -- Called by: set_server_group_count, repoll_virt_guest_entitlements
    -- *******************************************************************
    create or replace function prune_group (
        group_id_in in numeric,
        quantity_in in numeric,
        update_family_countsYN in numeric default 1
    ) returns void
as $$
    declare
        sgrecord record;
      type_is_base char;
    begin
            update      rhnServerGroup
                set     max_members = quantity_in
                where   id = group_id_in;

            for sgrecord in (
		   select  server_id, server_group_id, sgt.id as group_type_id, sgt.label
		    from    rhnServerGroupType              sgt,
				    rhnServerGroup                  sg,
				    rhnServerGroupMembers   sgm
		    where   1=1
			    and sgm.server_group_id = group_id_in
			    and sgm.server_id in (
				    select  sep.server_id
				    from
					rhnServerEntitlementPhysical sep
				    where
					sep.server_group_id = group_id_in
				    order by sep.modified asc
				    offset quantity_in
				)
			    and sgm.server_group_id = sg.id
			    and sg.group_type = sgt.id
	    ) loop
                perform rhn_entitlements.remove_server_entitlement(sgrecord.server_id, sgrecord.label);
            
            select is_base 
            into type_is_base
            from rhnServerGroupType sgt
            where sgt.id = sgrecord.group_type_id;
 
            -- if we're removing a base ent, then be sure to
            -- remove the server's channel subscriptions.
            if ( type_is_base = 'Y' ) then
                   perform rhn_channel.clear_subscriptions(sgrecord.server_id, 0, update_family_countsYN);
            end if;

            end loop;
    end$$
language plpgsql;

    -- *******************************************************************
    -- PROCEDURE: assign_system_entitlement
    --
    -- Moves system entitlements from from_org_id_in to to_org_id_in.
    -- Can raise not_enough_entitlements_in_base_org if from_org_id_in
    -- does not have enough entitlements to cover the move.
    -- Takes care of unentitling systems if necessary by calling 
    -- set_server_group_count
    -- *******************************************************************
    create or replace function assign_system_entitlement(
        group_label_in in varchar,
        from_org_id_in in numeric,
        to_org_id_in in numeric,
        quantity_in in numeric
    ) returns void
as $$
    declare
        prev_ent_count numeric;
    to_org_prev_ent_count numeric;
        new_ent_count numeric;
    new_quantity numeric;
        group_type numeric;
    begin

            select max_members
            into prev_ent_count
            from rhnServerGroupType sgt,
                 rhnServerGroup sg
            where sg.org_id = from_org_id_in
              and sg.group_type = sgt.id
              and sgt.label = group_label_in;

            if not found then
                perform rhn_exception.raise_exception(
                              'not_enough_entitlements_in_base_org');
            end if;

            select max_members
            into to_org_prev_ent_count
            from rhnServerGroupType sgt,
                 rhnServerGroup sg
            where sg.org_id = to_org_id_in
              and sg.group_type = sgt.id
              and sgt.label = group_label_in;

            if not found then
                to_org_prev_ent_count := 0;
            end if;
    
            select id
            into group_type
            from rhnServerGroupType
            where label = group_label_in;

            if not found then
                perform rhn_exception.raise_exception(
                              'invalid_server_group');
            end if;

        new_ent_count := prev_ent_count - quantity_in;
    
        if prev_ent_count > new_ent_count then
            new_quantity := to_org_prev_ent_count + quantity_in;
        end if;
    
        if new_ent_count < 0 then
            perform rhn_exception.raise_exception(
                          'not_enough_entitlements_in_base_org');
        end if;


        perform rhn_entitlements.set_server_group_count(from_org_id_in,
                                         group_type,
                                         new_ent_count);

        perform rhn_entitlements.set_server_group_count(to_org_id_in,
                                         group_type,
                                         new_quantity);
        
        -- Create or delete the entries in rhnOrgEntitlementType
        if group_label_in = 'enterprise_entitled' then 
            if new_quantity > 0 then
                perform rhn_entitlements.set_customer_enterprise(to_org_id_in);
            else
                perform rhn_entitlements.unset_customer_enterprise(to_org_id_in);
            end if;
        end if;

        if group_label_in = 'provisioning_entitled' then
            if new_quantity > 0 then
                perform rhn_entitlements.set_customer_provisioning(to_org_id_in);
            else
                perform rhn_entitlements.unset_customer_provisioning(to_org_id_in);
            end if;
        end if;

        if group_label_in = 'monitoring_entitled' then
            if new_quantity > 0 then
                perform rhn_entitlements.set_customer_monitoring(to_org_id_in);
            else
                perform rhn_entitlements.unset_customer_monitoring(to_org_id_in);
            end if;
        end if;

    end$$
language plpgsql;

    -- *******************************************************************
    -- PROCEDURE: activate_system_entitlement
    --
    -- Sets the values in rhnServerGroup for a given rhnServerGroupType.
    -- 
    -- Calls: set_server_group_count to update, prune, or create the group.
    -- Called by: the code that activates a satellite cert. 
    --
    -- Raises not_enough_entitlements_in_base_org if all entitlements
    -- in the org are used so the free entitlements would not cover
    -- the difference when descreasing the number of entitlements.
    -- *******************************************************************
    create or replace function activate_system_entitlement(
        org_id_in in numeric,
        group_label_in in varchar,
        quantity_in in numeric
    ) returns void
as $$
    declare
        prev_ent_count numeric; 
        prev_ent_count_sum numeric; 
        group_type numeric;
    begin

        -- Fetch the current entitlement count for the org
        -- into prev_ent_count

            select current_members
            into prev_ent_count
            from rhnServerGroupType sgt,
                 rhnServerGroup sg
            where sg.group_type = sgt.id
              and sgt.label = group_label_in
              and sg.org_id = org_id_in;

            if not found then
                prev_ent_count := 0;
            end if;

            select id
            into group_type
            from rhnServerGroupType
            where label = group_label_in;

            if not found then
                perform rhn_exception.raise_exception(
                              'invalid_server_group');
            end if;

        -- If we're setting the total entitlemnt count to a lower value,
        -- and that value is less than the allocated count in this org,
        -- we need to raise an exception.
        if quantity_in < prev_ent_count then
            perform rhn_exception.raise_exception(
                          'not_enough_entitlements_in_base_org');
        else
            -- don't update family counts after every server
            -- will do bulk update afterwards
            perform rhn_entitlements.set_server_group_count(org_id_in,
                                             group_type,
                                             quantity_in,
                                             0);
            -- bulk update family counts
            perform rhn_channel.update_group_family_counts(group_label_in, org_id_in);
        end if;

    end$$
language plpgsql;


    create or replace function set_server_group_count (
        customer_id_in in numeric,  -- customer_id
        group_type_in in numeric,   -- rhn[User|Server]GroupType.id
        quantity_in in numeric,      -- quantity
                update_family_countsYN in numeric default 1
    ) returns void
as $$
    declare
        group_id numeric;
        quantity numeric;
        wasfound boolean;
    begin
        quantity := quantity_in;
        if quantity is not null and quantity < 0 then
            quantity := 0;
        end if;

        select  rsg.id
        into    group_id
        from    rhnServerGroup rsg
        where   1=1
            and rsg.org_id = customer_id_in
            and rsg.group_type = group_type_in;

        -- preserve the not found status across the rhn_entitlements.prune_group invocation
        wasfound := true;
        if not found then
            wasfound := false;
        end if;

        perform rhn_entitlements.prune_group(
            group_id,
            quantity,
                        update_family_countsYN
        );

        if not wasfound then
            insert into rhnServerGroup (
                    id, name, description, max_members, current_members,
                    group_type, org_id, created, modified
                ) (
                    select  nextval('rhn_server_group_id_seq'), name, name,
                            quantity, 0, id, customer_id_in,
                            current_timestamp, current_timestamp
                    from    rhnServerGroupType
                    where   id = group_type_in
            );
        end if;

    end$$
language plpgsql;

-- restore the original setting
update pg_settings set setting = overlay( setting placing '' from 1 for (length('rhn_entitlements')+1) ) where name = 'search_path';
