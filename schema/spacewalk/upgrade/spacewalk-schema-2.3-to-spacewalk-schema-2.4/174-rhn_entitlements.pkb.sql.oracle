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
--
--
--

create or replace
package body rhn_entitlements
is
    body_version varchar2(100) := '';

   function find_compatible_sg (
      server_id_in    in   number,
      type_label_in   in   varchar2
   ) return number is

      cursor servergroups is
         select sg.id            id
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
      return null;
   end find_compatible_sg;

    function entitlement_grants_service (
        entitlement_in in varchar2,
        service_level_in in varchar2
    ) return number    is
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
    end entitlement_grants_service;

   function can_entitle_server (
        server_id_in in number,
        type_label_in in varchar2 )
   return number is
      cursor addon_servergroups (base_label_in in varchar2,
                                 addon_label_in in varchar2) is
         select
            addon_id
         from
            rhnSGTypeBaseAddonCompat
         where base_id = lookup_sg_type (base_label_in)
           and addon_id = lookup_sg_type (addon_label_in);

      previous_ent        rhn_entitlements.ents_array;
      is_base_in          char   := 'N';
      is_base_current     char   := 'N';
      i                   number := 0;
      sgid                number := 0;

   begin

      previous_ent := rhn_entitlements.ents_array();
      previous_ent := rhn_entitlements.get_server_entitlement(server_id_in);

      select distinct is_base
      into is_base_in
      from rhnServerGroupType
      where label = type_label_in;

      if previous_ent.count = 0 then
         sgid := find_compatible_sg (server_id_in, type_label_in);
         if (is_base_in = 'Y' and sgid is not null) then
            -- rhn_server.insert_into_servergroup (server_id_in, sgid);
            return 1;
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
         while is_base_current = 'N' and i <= previous_ent.count
         loop
            i := i + 1;
            select is_base
            into is_base_current
            from rhnServerGroupType
            where label = previous_ent(i);
         end loop;

         -- never found a base ent, that would be strange
         if is_base_current  = 'N' then
            -- rhn_exception.raise_exception ('invalid_base_entitlement');
            return 0;
         end if;

         -- this for loop verifies the validity of the addon path
         for addon_servergroup in addon_servergroups  (previous_ent(i), type_label_in) loop
            -- find an appropriate sgid for the addon and entitle the server
            sgid := find_compatible_sg (server_id_in, type_label_in);
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

   end can_entitle_server;

   function can_switch_base (
      server_id_in   in    integer,
      type_label_in  in    varchar2
   ) return number is

      type_label_in_is_base   char(1);
      sgid                    number;

   begin

      begin
         select is_base into type_label_in_is_base
         from rhnServerGroupType
         where label = type_label_in;
      exception
         when no_data_found then
            rhn_exception.raise_exception ( 'invalid_entitlement' );
      end;

      if type_label_in_is_base = 'N' then
         rhn_exception.raise_exception ( 'invalid_entitlement' );
      else
         sgid := find_compatible_sg ( server_id_in, type_label_in );
         if sgid is not null then
            return 1;
         else
            return 0;
         end if;
      end if;

   end can_switch_base;


    procedure entitle_server (
        server_id_in in number,
        type_label_in in varchar2
    ) is
      sgid  number := 0;

    begin

      if rhn_entitlements.can_entitle_server(server_id_in,
                                             type_label_in) = 1 then
         sgid := find_compatible_sg (server_id_in, type_label_in);
         if sgid is not null then
            insert into rhnServerHistory ( id, server_id, summary, details )
            values ( rhn_event_id_seq.nextval, server_id_in,
                     'added system entitlement ',
                      case type_label_in
                       when 'enterprise_entitled' then 'Management'
                       when 'virtualization_host' then 'Virtualization'
                      end  );

            rhn_server.insert_into_servergroup (server_id_in, sgid);

         else
            rhn_exception.raise_exception ('no_available_server_group');
         end if;
      else
         rhn_exception.raise_exception ('invalid_entitlement');
      end if;
   end entitle_server;

    procedure remove_server_entitlement (
        server_id_in in number,
        type_label_in in varchar2
    ) is
        group_id number;
        type_is_base char;
    begin
      begin

        select    sg.id, sgt.is_base
          into    group_id, type_is_base
          from    rhnServerGroupType sgt,
               rhnServerGroup sg,
                  rhnServerGroupMembers sgm,
                  rhnServer s
          where    s.id = server_id_in
              and s.id = sgm.server_id
              and sgm.server_group_id = sg.id
              and sg.org_id = s.org_id
              and sgt.label = type_label_in
              and sgt.id = sg.group_type;

      if ( type_is_base = 'Y' ) then
         -- unentitle_server should handle everything, don't really need to do anything else special here
         unentitle_server ( server_id_in );
      else

         insert into rhnServerHistory ( id, server_id, summary, details )
         values ( rhn_event_id_seq.nextval, server_id_in,
                  'removed system entitlement ',
                   case type_label_in
                    when 'enterprise_entitled' then 'Management'
                    when 'virtualization_host' then 'Virtualization'
                   end  );

         rhn_server.delete_from_servergroup(server_id_in, group_id);

      end if;

          exception
          when no_data_found then
                  rhn_exception.raise_exception('invalid_server_group_member');
      end;

     end remove_server_entitlement;


   procedure unentitle_server (server_id_in in number) is

      cursor servergroups is
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
         values ( rhn_event_id_seq.nextval, server_id_in,
                  'removed system entitlement ',
                   case servergroup.label
                    when 'enterprise_entitled' then 'Management'
                    when 'virtualization_host' then 'Virtualization'
                   end  );

         rhn_server.delete_from_servergroup(server_id_in,
                                            servergroup.server_group_id );
      end loop;

   end unentitle_server;


    function get_server_entitlement (
        server_id_in in number
    ) return ents_array is

        cursor server_groups is
            select    sgt.label
            from    rhnServerGroupType        sgt,
                    rhnServerGroup            sg,
                    rhnServerGroupMembers    sgm
            where    1=1
                and sgm.server_id = server_id_in
                and sg.id = sgm.server_group_id
                and sgt.id = sg.group_type
                and sgt.label in (
                    'enterprise_entitled',
                    'virtualization_host'
                    );

         ent_array ents_array;

    begin

      ent_array := ents_array();

        for sg in server_groups loop
         ent_array.extend;
         ent_array(ent_array.count) := sg.label;
        end loop;

        return ent_array;

    end get_server_entitlement;

end rhn_entitlements;
/
show errors

