-- oracle equivalent source sha1 50928b37bee46d96787df912255e880ddf30088c
--
-- Copyright (c) 2008--2015 Red Hat, Inc.
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


    create or replace function entitlement_grants_service (
        entitlement_in in varchar,
        service_level_in in varchar
    ) returns numeric
as $$
    begin
        if service_level_in = 'management' then
            if entitlement_in = 'enterprise_entitled' then
                return 1;
            else
                return 0;
            end if;
        elsif service_level_in = 'updates' then
            return 1;
        else
            return 0;
        end if;
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
        type_label_in in varchar
    ) returns void
as $$
    declare
      sgid  numeric := 0;

    begin

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
                       when 'virtualization_host' then 'Virtualization'
                      end  );

            perform rhn_server.insert_into_servergroup (server_id_in, sgid);

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
        type_label_in in varchar
    ) returns void
as $$
    declare
      group_id numeric;
      type_is_base char;
    begin

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
                    when 'virtualization_host' then 'Virtualization'
                   end  );

         perform rhn_server.delete_from_servergroup(server_id_in, group_id);

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

   begin

      for servergroup in servergroups loop

         insert into rhnServerHistory ( id, server_id, summary, details )
         values ( nextval('rhn_event_id_seq'), server_id_in,
                  'removed system entitlement ',
                   case servergroup.label
                    when 'enterprise_entitled' then 'Management'
                    when 'virtualization_host' then 'Virtualization'
                   end  );

         perform rhn_server.delete_from_servergroup(server_id_in,
                                            servergroup.server_group_id );
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
                    'enterprise_entitled',
                    'virtualization_host'
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

-- restore the original setting
update pg_settings set setting = overlay( setting placing '' from 1 for (length('rhn_entitlements')+1) ) where name = 'search_path';
