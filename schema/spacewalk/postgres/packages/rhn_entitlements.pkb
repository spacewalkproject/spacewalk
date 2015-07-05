-- oracle equivalent source sha1 555bb31cfef3ea09d3b8e0e1260d23dc5485201c
--
-- Copyright (c) 2008--2012 Red Hat, Inc.
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

-- create schema rhn_entitlements;

-- setup search_path so that these functions are created in appropriate schema.
update pg_settings set setting = 'rhn_entitlements,' || setting where name = 'search_path';

   create or replace function find_compatible_sg (
      server_id_in in numeric,
      type_label_in in varchar
   )
   returns numeric
as $$
    declare
      servergroups cursor for
         select sg.id
           from rhnServerGroupType             sgt,
                rhnServerGroup                 sg,
                rhnServer                     s,
                rhnServerServerGroupArchCompat ssgac
          where s.id = server_id_in
            and s.org_id = sg.org_id
            and sgt.label = type_label_in
            and sg.group_type = sgt.id
            and ssgac.server_group_type = sgt.id
            and ssgac.server_arch_id = s.server_arch_id
            and not exists (
                     select 1
                      from rhnServerGroupMembers sgm
                     where sgm.server_group_id = sg.id
                       and sgm.server_id = s.id);


   begin
      for servergroup in servergroups loop
         return servergroup.id;
      end loop;

      --no servergroup found
      return NULL;
   end$$
language plpgsql;

    -- *******************************************************************
    -- PROCEDURE: remove_org_entitlements
    --
    -- Removes both system entitlements and channel subscriptions
    -- that are currently assigned to an org and re-assigns to the
    -- master org (org_id = 1).
    --
    -- When we call this we expect everything to already be unentitled
    -- which shoul be handled by delete_org.
    --
    -- Called by: delete_org
    -- *******************************************************************
    create or replace function remove_org_entitlements (
        org_id_in numeric
    ) returns void
as $$
    declare
        system_ents cursor for
        select sg.id, sg.max_members, sg.group_type
        from rhnServerGroup sg
        where group_type is not null
          and org_id = org_id_in;

    begin

        for system_ent in system_ents loop
            update rhnServerGroup
            set max_members = max_members + system_ent.max_members
            where org_id = 1
              and group_type = system_ent.group_type;
        end loop;

        update rhnServerGroup
        set max_members = 0
        where org_id = org_id_in;

    end$$
language plpgsql;

    create or replace function entitlement_grants_service (
        entitlement_in in varchar,
        service_level_in in varchar
    ) returns numeric
as $$
    begin
        if service_level_in = 'provisioning' then
            if entitlement_in = 'provisioning_entitled' then
                return 1;
            else
                return 0;
            end if;
        elsif service_level_in = 'management' then
            if entitlement_in = 'enterprise_entitled' then
                return 1;
            else
                return 0;
            end if;
        elsif service_level_in = 'monitoring' then
            if entitlement_in = 'monitoring_entitled' then
                return 1;
            end if;
        elsif service_level_in = 'updates' then
            return 1;
        else
            return 0;
        end if;
    end$$
language plpgsql;

    create or replace function lookup_entitlement_group (
        org_id_in in numeric,
        type_label_in in varchar default 'sw_mgr_entitled'
    ) returns numeric
as $$
    declare
        server_groups cursor for
            select  sg.id               server_group_id
            from    rhnServerGroup      sg,
                    rhnServerGroupType  sgt
            where   sgt.label = type_label_in
                and sgt.id = sg.group_type
                and sg.org_id = org_id_in;
    begin
        for sg in server_groups loop
            return sg.server_group_id;
        end loop;
        return rhn_entitlements.create_entitlement_group(
                org_id_in,
                type_label_in
            );
    end$$
language plpgsql;

    create or replace function create_entitlement_group (
        org_id_in in numeric,
        type_label_in in varchar default 'sw_mgr_entitled'
    ) returns numeric
as $$
    declare
        sg_id_val numeric;
    begin
        select  nextval('rhn_server_group_id_seq')
        into    sg_id_val;

        insert into rhnServerGroup (
                id, name, description, max_members, current_members,
                group_type, org_id
            ) (
                select  sg_id_val, sgt.label, sgt.label,
                        0, 0, sgt.id, org_id_in
                from    rhnServerGroupType sgt
                where   sgt.label = type_label_in
            );

        return sg_id_val;
    end$$
language plpgsql;

   create or replace function can_entitle_server (
      server_id_in   in numeric,
      type_label_in  in varchar
   )
   returns numeric
as $$
    declare
      addon_servergroups cursor (base_label_in varchar,
                                 addon_label_in varchar) for
         select
            addon_id
         from
            rhnSGTypeBaseAddonCompat
         where base_id = lookup_sg_type (base_label_in)
           and addon_id = lookup_sg_type (addon_label_in);

      previous_ent        varchar[];
      is_base_in          char   := 'N';
      is_base_current     char   := 'N';
      i                   numeric := 0;
      sgid                numeric := 0;

   begin

      previous_ent := rhn_entitlements.get_server_entitlement(server_id_in);

      select distinct is_base
      into is_base_in
      from rhnServerGroupType
      where label = type_label_in;

      if array_upper(previous_ent, 1) is null or array_upper(previous_ent, 1) = 0 then
         if is_base_in = 'Y' then
            sgid := rhn_entitlements.find_compatible_sg (server_id_in, type_label_in);
            if sgid is not null then
              -- rhn_server.insert_into_servergroup (server_id_in, sgid);
              return 1;
            else
              -- rhn_exception.raise_exception ('invalid_base_entitlement');
              return 0;
            end if;
         else
            -- rhn_exception.raise_exception ('invalid_base_entitlement');
            return 0;
         end if;

      -- there are previous ents, first make sure we're not trying to entitle a base ent
      elsif is_base_in = 'Y' then
         -- rhn_exception.raise_exception ('invalid_addon_entitlement');
         return 0;

      -- it must be an addon, so proceed with the entitlement
      else

         -- find the servers base ent
         is_base_current := 'N';
         i := 0;
         while is_base_current = 'N' and i < array_upper(previous_ent, 1)
         loop
            i := i + 1;
            select is_base
            into is_base_current
            from rhnServerGroupType
            where label = previous_ent[i];
         end loop;

         -- never found a base ent, that would be strange
         if is_base_current  = 'N' then
            -- rhn_exception.raise_exception ('invalid_base_entitlement');
            return 0;
         end if;

         -- this for loop verifies the validity of the addon path
         for addon_servergroup in addon_servergroups  (previous_ent[i], type_label_in) loop
            -- find an appropriate sgid for the addon and entitle the server
            sgid := rhn_entitlements.find_compatible_sg (server_id_in, type_label_in);
            if sgid is not null then
               -- rhn_server.insert_into_servergroup (server_id_in, sgid);
               return 1;
            else
               -- rhn_exception.raise_exception ('invalid_addon_entitlement');
               return 0;
            end if;
         end loop;

      end if;

      return 0;

   end$$
language plpgsql;

   create or replace function can_switch_base (
      server_id_in   in    integer,
      type_label_in  in    varchar
   )
   returns numeric
as $$
   declare
      type_label_in_is_base   char(1);
      sgid                    numeric;

   begin

       select is_base into type_label_in_is_base
       from rhnServerGroupType
       where label = type_label_in;

       if not found then
          perform rhn_exception.raise_exception ( 'invalid_entitlement' );
       end if;

      if type_label_in_is_base = 'N' then
         perform rhn_exception.raise_exception ( 'invalid_entitlement' );
      else
         sgid := rhn_entitlements.find_compatible_sg ( server_id_in,
                                                       type_label_in );
         if sgid is not null then
           return 1;
         else
           return 0;
         end if;
      end if;

   end$$
language plpgsql;

    create or replace function entitle_server (
        server_id_in in numeric,
        type_label_in in varchar default 'sw_mgr_entitled'
    ) returns void
as $$
    declare
      sgid  numeric := 0;
      is_virt numeric := 0;

    begin

      select 1 into is_virt
        from rhnServerEntitlementView
        where server_id = server_id_in
          and label in ('virtualization_host', 'virtualization_host_platform');

      if not found then
          is_virt := 0;
      end if;

      if is_virt = 0 and (type_label_in = 'virtualization_host' or
                          type_label_in = 'virtualization_host_platform') then

        is_virt := 1;
      end if;

      if rhn_entitlements.can_entitle_server(server_id_in,
                                             type_label_in) = 1 then
         sgid := rhn_entitlements.find_compatible_sg (server_id_in,
                                                      type_label_in);
         if sgid is not null then
            insert into rhnServerHistory ( id, server_id, summary, details )
            values ( nextval('rhn_event_id_seq'), server_id_in,
                     'added system entitlement ',
                      case type_label_in
                       when 'enterprise_entitled' then 'Management'
                       when 'sw_mgr_entitled' then 'Update'
                       when 'provisioning_entitled' then 'Provisioning'
                       when 'monitoring_entitled' then 'Monitoring'
                       when 'virtualization_host' then 'Virtualization'
                       when 'virtualization_host_platform' then
                            'Virtualization Platform' end  );

            perform rhn_server.insert_into_servergroup (server_id_in, sgid);

            if is_virt = 1 then
              perform rhn_entitlements.repoll_virt_guest_entitlements(server_id_in);
            end if;

         else
            perform rhn_exception.raise_exception ('no_available_server_group');
         end if;
      else
         perform rhn_exception.raise_exception ('invalid_entitlement');
      end if;
   end$$
language plpgsql;

    create or replace function remove_server_entitlement (
        server_id_in in numeric,
        type_label_in in varchar default 'sw_mgr_entitled',
        repoll_virt_guests in numeric default 1
    ) returns void
as $$
    declare
      group_id numeric;
      type_is_base char;
      is_virt numeric := 0;
    begin
      -- would be nice if there were a virt attribute of entitlement types, not have to specify 2 different ones...
        select 1 into is_virt
          from rhnServerEntitlementView
          where server_id = server_id_in
            and label in ('virtualization_host', 'virtualization_host_platform');
        if not found then
            is_virt := 0;
        end if;

        select  sg.id, sgt.is_base
        into group_id, type_is_base
        from    rhnServerGroupType sgt,
            rhnServerGroup sg,
                rhnServerGroupMembers sgm,
                rhnServer s
        where   s.id = server_id_in
            and s.id = sgm.server_id
            and sgm.server_group_id = sg.id
            and sg.org_id = s.org_id
            and sgt.label = type_label_in
            and sgt.id = sg.group_type;

        if not found then
          perform rhn_exception.raise_exception('invalid_server_group_member');
        end if;

      if ( type_is_base = 'Y' ) then
         -- unentitle_server should handle everything, don't really need to do anything else special here
         perform rhn_entitlements.unentitle_server ( server_id_in );
      else

         insert into rhnServerHistory ( id, server_id, summary, details )
         values ( nextval('rhn_event_id_seq'), server_id_in,
                  'removed system entitlement ',
                   case type_label_in
                    when 'enterprise_entitled' then 'Management'
                    when 'sw_mgr_entitled' then 'Update'
                    when 'provisioning_entitled' then 'Provisioning'
                    when 'monitoring_entitled' then 'Monitoring'
                    when 'virtualization_host' then 'Virtualization'
                    when 'virtualization_host_platform' then
                         'Virtualization Platforrm' end  );

         perform rhn_server.delete_from_servergroup(server_id_in, group_id);

         if is_virt = 1 and repoll_virt_guests = 1 then
           perform rhn_entitlements.repoll_virt_guest_entitlements(server_id_in);
         end if;
      end if;

    end$$
language plpgsql;

    create or replace function unentitle_server (
        server_id_in in numeric
    ) returns void
as $$
    declare
      servergroups cursor for
         select distinct sgt.label, sg.id server_group_id
         from  rhnServerGroupType sgt,
               rhnServerGroup sg,
               rhnServer s,
               rhnServerGroupMembers sgm
         where s.id = server_id_in
            and s.org_id = sg.org_id
            and sg.group_type = sgt.id
            and sgm.server_group_id = sg.id
            and sgm.server_id = s.id;

     is_virt numeric := 0;

   begin

      select 1 into is_virt
        from rhnServerEntitlementView
        where server_id = server_id_in
         and label in ('virtualization_host', 'virtualization_host_platform');

      if not found then
          is_virt := 0;
      end if;

      for servergroup in servergroups loop

         insert into rhnServerHistory ( id, server_id, summary, details )
         values ( nextval('rhn_event_id_seq'), server_id_in,
                  'removed system entitlement ',
                   case servergroup.label
                    when 'enterprise_entitled' then 'Management'
                    when 'sw_mgr_entitled' then 'Update'
                    when 'provisioning_entitled' then 'Provisioning'
                    when 'monitoring_entitled' then 'Monitoring'
                    when 'virtualization_host' then 'Virtualization'
                    when 'virtualization_host_platform' then
                         'Virtualization Platform' end  );

         perform rhn_server.delete_from_servergroup(server_id_in,
                                            servergroup.server_group_id );
      end loop;

      if is_virt = 1 then
        perform rhn_entitlements.repoll_virt_guest_entitlements(server_id_in);
      end if;

   end$$
language plpgsql;


    -- *******************************************************************
    -- PROCEDURE: repoll_virt_guest_entitlements
    --
    --   Whenever we add/remove a virtualization_host* entitlement from
    --   a host, we can call this procedure to update what type of slots
    --   the guests are consuming.
    --
    --   If you're removing the entitlement, it's
    --   possible the guests will become unentitled if you don't have enough
    --   physical slots to cover them.
    --
    --   If you're adding the entitlement, you end up freeing up physical
    --   slots for other systems.
    --
    -- *******************************************************************
    create or replace function repoll_virt_guest_entitlements(
        server_id_in in numeric
    ) returns void
as $$
    declare
        -- All of server group types associated with the guests of
        -- server_id_in
        group_types cursor for
            select distinct sg.group_type, sgt.label, sg.org_id
            from
                rhnServerGroupType sgt,
                rhnServerGroup sg,
                rhnServerGroupMembers sgm,
                rhnVirtualInstance vi
            where
                vi.host_system_id = server_id_in
                and vi.virtual_system_id = sgm.server_id
                and sgm.server_group_id = sg.id
                and sg.group_type = sgt.id;

        -- Virtual servers from a certain family belonging to a specific
        -- host that are consuming physical system slots over the limit.
        virt_servers_sgt cursor(group_type_in numeric, quantity_in numeric) for
                select vi.virtual_system_id
                from
                    rhnServerGroup sg,
                    rhnServerGroupMembers sgm,
                    rhnVirtualInstance vi
                where
                    vi.host_system_id = server_id_in
                    and vi.virtual_system_id = sgm.server_id
                    and sgm.server_group_id = sg.id
                    and sg.group_type = group_type_in
                order by sgm.modified desc
                limit quantity_in;

        org_id_val numeric;
        max_members_val numeric;
        max_flex_val numeric;
        current_members_calc numeric;
        sg_id numeric;
        is_virt numeric := 0;
        free_slots numeric := 0;
    begin
          select 1 into is_virt
                from rhnServerEntitlementView
           where server_id = server_id_in
                 and label in ('virtualization_host', 'virtualization_host_platform');

      if not found then
          is_virt := 0;
      end if;

        select org_id
        into org_id_val
        from rhnServer
        where id = server_id_in;

        for a_group_type in group_types loop
          -- get the current *physical* members of the system entitlement type for the org...
          --
          -- unlike channel families, it appears the standard rhnServerGroup.max_members represents
          -- *physical* slots, vs physical+virt ... boy that's confusing...

          select max_members, id
            into max_members_val, sg_id
            from rhnServerGroup
            where group_type = a_group_type.group_type
            and org_id = a_group_type.org_id;


      select count(sep.server_id) into current_members_calc
            from rhnServerEntitlementPhysical sep
           where sep.server_group_id = sg_id
             and sep.server_group_type_id = a_group_type.group_type;

          if current_members_calc > max_members_val then
            -- A virtualization_host* ent must have been removed, and we're over the limit, so unsubscribe guests
            for virt_server in virt_servers_sgt(a_group_type.group_type,
                                                current_members_calc - max_members_val) loop
              perform rhn_entitlements.remove_server_entitlement(virt_server.virtual_system_id, a_group_type.label);

              -- decrement current_members_calc, we'll use it to reset current_members for the group at the end...
              current_members_calc := current_members_calc - 1;
            end loop;

          end if;

          update rhnServerGroup set current_members = current_members_calc
           where org_id = a_group_type.org_id
             and group_type = a_group_type.group_type;

          -- I think that's all the house-keeping we have to do...
        end loop;

    end$$
language plpgsql;

    create or replace function get_server_entitlement (
        server_id_in in numeric
    ) returns varchar[]
as $$
    declare
        server_groups cursor for
            select  sgt.label
            from    rhnServerGroupType      sgt,
                    rhnServerGroup          sg,
                    rhnServerGroupMembers   sgm
            where   1=1
                and sgm.server_id = server_id_in
                and sg.id = sgm.server_group_id
                and sgt.id = sg.group_type
                and sgt.label in (
                    'sw_mgr_entitled','enterprise_entitled',
                    'provisioning_entitled', 'nonlinux_entitled',
                    'monitoring_entitled', 'virtualization_host',
                                        'virtualization_host_platform'
                    );

         ent_array varchar[];

    begin

      ent_array := '{}';

      for sg in server_groups loop
         ent_array := ent_array || sg.label;
      end loop;

      return ent_array;

    end$$
language plpgsql;

    -- this desperately needs to be table driven.
    create or replace function modify_org_service (
        org_id_in in numeric,
        service_label_in in varchar,
        enable_in in char
    ) returns void
as $$
    declare
        roles_to_process varchar[];
        roles cursor(role_label_in varchar) for
            select  label, id
            from    rhnUserGroupType
            where   label = role_label_in;
        org_roles cursor(role_label_in varchar) for
            select  1
            from    rhnUserGroup ug,
                    rhnUserGroupType ugt
            where   ugt.label = role_label_in
                and ug.org_id = org_id_in
                and ugt.id = ug.group_type;

        ents_to_process varchar[];
        ents cursor(ent_label_in varchar) for
            select  label, id
            from    rhnOrgEntitlementType
            where   label = ent_label_in;
        org_ents cursor(ent_label_in varchar) for
            select  1
            from    rhnOrgEntitlements oe,
                    rhnOrgEntitlementType oet
            where   oet.label = ent_label_in
                and oe.org_id = org_id_in
                and oet.id = oe.entitlement_id;
        create_row char(1);
    begin
        ents_to_process := '{}';
        roles_to_process := '{}';
        -- a bit kludgy, but only for 3.4 really.  Certainly no
        -- worse than the old code...
        if service_label_in = 'enterprise' or
           service_label_in = 'management' then
            ents_to_process := array_append(ents_to_process, 'sw_mgr_enterprise');

            roles_to_process := array_append(roles_to_process, 'org_admin');

            roles_to_process := array_append(roles_to_process, 'system_group_admin');

            roles_to_process := array_append(roles_to_process, 'activation_key_admin');
        elsif service_label_in = 'provisioning' then
            ents_to_process := array_append(ents_to_process, 'rhn_provisioning');

            roles_to_process := array_append(roles_to_process, 'system_group_admin');

            roles_to_process := array_append(roles_to_process, 'activation_key_admin');

            roles_to_process := array_append(roles_to_process, 'config_admin');
            -- another nasty special case...
            if enable_in = 'Y' then
                ents_to_process := array_append(ents_to_process, 'sw_mgr_enterprise');
            end if;
        elsif service_label_in = 'monitoring' then
            ents_to_process := array_append(ents_to_process, 'rhn_monitor');

            roles_to_process := array_append(roles_to_process, 'monitoring_admin');
        elsif service_label_in = 'virtualization' then
            ents_to_process := array_append(ents_to_process, 'rhn_virtualization');

            roles_to_process := array_append(roles_to_process, 'config_admin');
        elsif service_label_in = 'virtualization_platform' then
            ents_to_process := array_append(ents_to_process, 'rhn_virtualization_platform');
            roles_to_process := array_append(roles_to_process, 'config_admin');
    elsif service_label_in = 'nonlinux' then
            ents_to_process := array_append(ents_to_process, 'rhn_nonlinux');
            roles_to_process := array_append(roles_to_process, 'config_admin');
        end if;

        if enable_in = 'Y' then
            for i in 1..array_upper(ents_to_process, 1) loop
                for ent in ents(ents_to_process[i]) loop
                    create_row := 'Y';
                    for oe in org_ents(ent.label) loop
                        create_row := 'N';
                    end loop;
                    if create_row = 'Y' then
                        insert into rhnOrgEntitlements(org_id, entitlement_id)
                            values (org_id_in, ent.id);
                    end if;
                end loop;
            end loop;
            for i in 1..array_upper(roles_to_process, 1) loop
                for role in roles(roles_to_process[i]) loop
                    create_row := 'Y';
                    for o_r in org_roles(role.label) loop
                        create_row := 'N';
                    end loop;
                    if create_row = 'Y' then
                        insert into rhnUserGroup(
                                id, name, description, current_members,
                                group_type, org_id
                            ) (
                                select  nextval('rhn_user_group_id_seq'),
                                        ugt.name || 's',
                                        ugt.name || 's for Org ' ||
                                            o.name || ' ('|| o.id ||')',
                                        0, ugt.id, o.id
                                from    rhnUserGroupType ugt,
                                        web_customer o
                                where   o.id = org_id_in
                                    and ugt.id = role.id
                            );
                    end if;
                end loop;
            end loop;
        else
            for i in 1..coalesce(array_upper(ents_to_process, 1), 0) loop
                for ent in ents(ents_to_process[i]) loop
                    delete from rhnOrgEntitlements
                     where org_id = org_id_in
                       and entitlement_id = ent.id;
                end loop;
            end loop;
        end if;
    end$$
language plpgsql;

    create or replace function set_customer_enterprise (
        customer_id_in in numeric
    ) returns void
as $$
    begin
        perform rhn_entitlements.modify_org_service(customer_id_in, 'enterprise', 'Y');
    end$$
language plpgsql;

    create or replace function set_customer_provisioning (
        customer_id_in in numeric
    ) returns void
as $$
    begin
        perform rhn_entitlements.modify_org_service(customer_id_in, 'provisioning', 'Y');
    end$$
language plpgsql;

    create or replace function set_customer_monitoring (
        customer_id_in in numeric
    ) returns void
as $$
    begin
        perform rhn_entitlements.modify_org_service(customer_id_in, 'monitoring', 'Y');
    end$$
language plpgsql;

    create or replace function set_customer_nonlinux (
        customer_id_in in numeric
    ) returns void
as $$
    begin
        perform rhn_entitlements.modify_org_service(customer_id_in, 'nonlinux', 'Y');
    end$$
language plpgsql;

    create or replace function unset_customer_enterprise (
        customer_id_in in numeric
    ) returns void
as $$
    begin
        perform rhn_entitlements.modify_org_service(customer_id_in, 'enterprise', 'N');
    end$$
language plpgsql;

    create or replace function unset_customer_provisioning (
        customer_id_in in numeric
    ) returns void
as $$
    begin
        perform rhn_entitlements.modify_org_service(customer_id_in, 'provisioning', 'N');
    end$$
language plpgsql;

    create or replace function unset_customer_monitoring (
        customer_id_in in numeric
    ) returns void
as $$
    begin
        perform rhn_entitlements.modify_org_service(customer_id_in, 'monitoring', 'N');
    end$$
language plpgsql;

    create or replace function unset_customer_nonlinux (
        customer_id_in in numeric
    ) returns void
as $$
    begin
        perform rhn_entitlements.modify_org_service(customer_id_in, 'nonlinux', 'N');
    end$$
language plpgsql;

    -- *******************************************************************
    -- PROCEDURE: prune_group
    -- Unsubscribes servers consuming physical slots that over the org's
    --   limit.
    -- Called by: set_server_group_count, repoll_virt_guest_entitlements
    -- *******************************************************************
    create or replace function prune_group (
        group_id_in in numeric,
        quantity_in in numeric
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
                   perform rhn_channel.clear_subscriptions(sgrecord.server_id, 0);
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
                                             quantity_in);
        end if;

    end$$
language plpgsql;


    create or replace function set_server_group_count (
        customer_id_in in numeric,  -- customer_id
        group_type_in in numeric,   -- rhn[User|Server]GroupType.id
        quantity_in in numeric      -- quantity
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
            quantity
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

    -- this expects quantity_in to be the number of available slots, not the
    -- max_members of the server group.  If you give it too many, it'll fail
    -- and raise servergroup_max_members.
    -- We should NEVER run this unless we're SURE that we won't
    -- be violating the max.
    create or replace function entitle_last_modified_servers (
        customer_id_in in numeric,  -- customer_id
        type_label_in in varchar,   -- 'enterprise_entitled'
        quantity_in in numeric      -- 3
    ) returns void
as $$
    declare
        -- find the servers that aren't currently in slots
        servers cursor(cid_in numeric, quant_in numeric) for
                                    select  rs.id as server_id
                                    from    rhnServer rs
                                    where   1=1
                                        and rs.org_id = cid_in
                                        and not exists (
                                            select  1
                                            from    rhnServerGroup sg,
                                                    rhnServerGroupMembers rsgm
                                            where   rsgm.server_id = rs.id
                                                and rsgm.server_group_id = sg.id
                                                and sg.group_type is not null
                                        )
                                        and not exists (
                                            select 1
                                            from rhnVirtualInstance vi
                                            where vi.virtual_system_id =
                                                  rs.id
                                        )
                                    order by modified desc
                                    limit quant_in;
    begin
        for server in servers(customer_id_in, quantity_in) loop
            perform rhn_entitlements.entitle_server(server.server_id, type_label_in);
        end loop;
    end$$
language plpgsql;

-- restore the original setting
update pg_settings set setting = overlay( setting placing '' from 1 for (length('rhn_entitlements')+1) ) where name = 'search_path';
