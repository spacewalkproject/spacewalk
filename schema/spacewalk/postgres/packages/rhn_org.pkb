--
-- Copyright (c) 2008 Red Hat, Inc.
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

-- create schema rhn_org;

-- setup search_path so that these functions are created in appropriate schema.
update pg_settings set setting = 'rhn_org,' || setting where name = 'search_path';

CREATE OR REPLACE FUNCTION find_server_group_by_type(org_id_in NUMERIC, group_label_in VARCHAR) 
    RETURNS NUMERIC
    AS
    $$
    DECLARE
	server_group_by_label CURSOR (org_id_in NUMERIC, group_label_in VARCHAR) FOR
           SELECT SG.*
             FROM rhnServerGroupType SGT,
                  rhnServerGroup SG
            WHERE SG.group_type = SGT.id
              AND SGT.label = group_label_in
              AND SG.org_id = org_id_in;

        server_group       record;
    BEGIN
        OPEN server_group_by_label(org_id_in, group_label_in);
        FETCH server_group_by_label INTO server_group;
        CLOSE server_group_by_label;

        RETURN server_group.id;
    END;
    $$
    LANGUAGE PLPGSQL;

create or replace function delete_org (
        org_id_in in numeric
    ) returns void
    as
    $$
    declare
        users cursor for
        select id
        from web_contact
        where org_id = org_id_in;

        servers cursor (org_id_in numeric) for
        select  id
        from    rhnServer
        where   org_id = org_id_in;

        config_channels cursor for
        select id
        from rhnConfigChannel
        where org_id = org_id_in;

        custom_channels cursor for
        select  id
        from    rhnChannel
        where   org_id = org_id_in;

        errata cursor for
        select  id
        from    rhnErrata
        where   org_id = org_id_in;

    begin

        if org_id_in = 1 then
            perform rhn_exception.raise_exception('cannot_delete_base_org');
        end if;

        -- Delete all users.
        for u in users loop
            perform rhn_org.delete_user(u.id, 1);
        end loop;

        -- Delete all servers.
        for s in servers(org_id_in) loop
            perform delete_server(s.id);
        end loop;

        -- Delete all config channels.
        for c in config_channels loop
            perform rhn_config.delete_channel(c.id);
        end loop;

        -- Delete all custom channels.
        for cc in custom_channels loop
          delete from rhnServerChannel where channel_id = cc.id;
          delete from rhnServerProfilePackage where server_profile_id in (
            select id from rhnServerProfile where base_channel = cc.id
          );
          delete from rhnServerProfile where base_channel = cc.id;
        end loop;

        -- Delete all errata packages 
        for e in errata loop
            delete from rhnErrataPackage where errata_id = e.id;
        end loop;

        -- Give the org's entitlements back to the main org.
        perform rhn_entitlements.remove_org_entitlements(org_id_in);

        -- Clean up tables where we don't have a cascading delete.
        delete from rhnChannel where org_id = org_id_in;
        delete from rhnDailySummaryQueue where org_id = org_id_in;
        delete from rhnOrgQuota where org_id = org_id_in;
        delete from rhnFileList where org_id = org_id_in;
        delete from rhnServerGroup where org_id = org_id_in;
        delete from rhn_check_suites where customer_id = org_id_in;
        delete from rhn_command_target where customer_id = org_id_in;
        delete from rhn_contact_groups where customer_id = org_id_in;
        delete from rhn_notification_formats where customer_id = org_id_in;
        delete from rhn_probe where customer_id = org_id_in;
        delete from rhn_redirects where customer_id = org_id_in;
        delete from rhn_sat_cluster where customer_id = org_id_in;
        delete from rhn_schedules where customer_id = org_id_in;

        -- Delete the org.
        delete from web_customer where id = org_id_in;

    end;
    $$
    language plpgsql;

create or replace function delete_user(user_id_in in numeric, deleting_org in numeric default 0) returns void 
        as
        $$
        declare
                is_admin cursor for
                        select  1
                        from    rhnUserGroupType        ugt,
                                        rhnUserGroup            ug,
                                        rhnUserGroupMembers     ugm
                        where   ugm.user_id = user_id_in
                                and ugm.user_group_id = ug.id
                                and ug.group_type = ugt.id
                                and ugt.label = 'org_admin';

                servergroups_needing_admins cursor for
                        select  usgp.server_group_id
                        from    rhnUserServerGroupPerms usgp
                        where   1=1
                                and usgp.user_id = user_id_in
                                and not exists (
                                        select  1
                                        from    rhnUserServerGroupPerms sq_usgp
                                        where   1=1
                                                and sq_usgp.server_group_id = usgp.server_group_id
                                                and     sq_usgp.user_id != user_id_in
                                );
                                
                messages cursor for
                        select  message_id
                        from    rhnUserMessage
                        where   user_id = user_id_in;
		
                users                   numeric;
                our_org_id              numeric;
                other_users             numeric;
                other_org_admin numeric;
                other_user_id  numeric;
        begin
                select  wc.org_id
                into    our_org_id
                from    web_contact wc
                where   id = user_id_in;

                -- find any other users
                select  id, 1
                into    other_user_id, other_users
                from    web_contact
                where   1=1
                        and org_id = our_org_id
                        and id != user_id_in
                limit 1;

                if not found then
                   other_users := 0;
                end if;

                -- now do org admin stuff
                if other_users != 0 then
                        for ignore in is_admin loop
                            select  new_ugm.user_id
                            into    other_org_admin
                            from    rhnUserGroupMembers     new_ugm,
                                            rhnUserGroupType        ugt,
                                            rhnUserGroup            ug,
                                            rhnUserGroupMembers     ugm
                            where   ugm.user_id = user_id_in
                                    and ugm.user_group_id = ug.id
                                    and ug.group_type = ugt.id
                                    and ugt.label = 'org_admin'
                                    and ug.id = new_ugm.user_group_id
                                    and new_ugm.user_id != user_id_in
                            limit 1;

                            if not found then 
                                -- If we're deleting the org, we don't want
                                -- to raise the exception.
                                if deleting_org = 0 then
                                    perform rhn_exception.raise_exception('cannot_delete_user');
                                end if;
                            end if;

                            for sg in servergroups_needing_admins loop
                                perform rhn_user.add_servergroup_perm(other_org_admin,sg.server_group_id);
                            end loop;
                        end loop;
                end if;

                -- and now things for every user
		for message in messages loop
                        delete
                                from    rhnUserMessage
                                where   user_id = user_id_in
                                        and message_id = message.id;

                                if exists(select  1
                                from    rhnUserMessage
                                where   message_id = message.id) then
                                    delete
                                        from    rhnMessage
                                        where   id = message.id;
                                end if;
                end loop;

                
                delete from rhn_command_queue_sessions where contact_id = user_id_in;
                delete from rhn_contact_groups
                where recid in (
                        select contact_group_id
                        from rhn_contact_group_members
                        where member_contact_method_id in (
                                select recid from rhn_contact_methods
                                where contact_id = user_id_in
                                )
                        )
                        and not exists (
                                select 1
                                from rhn_contact_group_members, rhn_contact_methods
                                where rhn_contact_groups.recid = rhn_contact_group_members.contact_group_id
                                        and rhn_contact_group_members.member_contact_method_id = rhn_contact_methods.recid
                                        and rhn_contact_methods.contact_id <> user_id_in
                        );
                delete from rhn_contact_methods where contact_id = user_id_in;
                delete from rhn_redirects where contact_id = user_id_in;
                delete from rhnUserServerPerms where user_id = user_id_in;
                delete from rhnAppInstallSession where user_id = user_id_in;
                if other_users != 0 then
                        update          rhnRegToken
                                set             user_id = coalesce(other_org_admin, other_user_id)
                                where   org_id = our_org_id
                                        and user_id = user_id_in;
                        begin
                                delete from web_contact where id = user_id_in;
                        exception
                                when others then
                                        perform rhn_exception.raise_exception('cannot_delete_user');
                        end;
        -- Just Delete the user
                else
            begin
                delete from web_contact where id = user_id_in;
                    exception
                                when others then
                                        perform rhn_exception.raise_exception('cannot_delete_user');
                        end;
                end if;
                return;
        end;
        $$
        language plpgsql;


-- restore the original setting
update pg_settings set setting = overlay( setting placing '' from 1 for (length('rhn_org')+1) ) where name = 'search_path';
