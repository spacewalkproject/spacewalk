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

    
        server_group       record; --server_group_by_label%ROWTYPE;

        
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

        user_curs_id	numeric;

        servers cursor (org_id_in numeric) for
        select  id
        from    rhnServer
        where   org_id = org_id_in;

        servers_curs_id	numeric;

        config_channels cursor for
        select id
        from rhnConfigChannel
        where org_id = org_id_in;

        conf_channel_curs_id	numeric;

        custom_channels cursor for
        select  id
        from    rhnChannel
        where   org_id = org_id_in;

        cust_channel_curs_id	numeric;

        errata cursor for
        select  id
        from    rhnErrata
        where   org_id = org_id_in;

        errata_curs_id	numeric;

    begin

        if org_id_in = 1 then
            perform rhn_exception.raise_exception('cannot_delete_base_org');
        end if;

        -- Delete all users.
        open users;
        loop
		fetch users into user_curs_id;
		exit when not found;
		perform rhn_org.delete_user(user_curs_id, 1);
        end loop;
        close users;
        

        -- Delete all servers.
        open servers(org_id_in);
        loop
		fetch servers into servers_curs_id;
		exit when not found;
		perform delete_server(servers_curs_id);
        end loop;
        close servers;
        
        -- Delete all config channels.
	open config_channels;
	loop
		fetch config_channels into conf_channel_curs_id;
		exit when not found;
		perform rhn_config.delete_channel(conf_channel_curs_id);	
	end loop;
	close config_channels;
        

        -- Delete all custom channels.
        open custom_channels;
        loop
		fetch custom_channels into cust_channel_curs_id;
		exit when not found;
		delete from rhnServerChannel where channel_id = cust_channel_curs_id;
          delete from rhnServerProfilePackage where server_profile_id in (
            select id from rhnServerProfile where base_channel = cust_channel_curs_id
          );
          delete from rhnServerProfile where base_channel = cust_channel_curs_id;
		
        end loop;
        close custom_channels;
        
        -- Delete all errata packages
	open errata;
	loop
		fetch errata into errata_curs_id;
		exit when not found;
		delete from rhnErrataPackage where errata_id = errata_curs_id;
	end loop;
        close errata;
        

        -- Give the org's entitlements back to the main org.
        perform rhn_entitlements.remove_org_entitlements(org_id_in);

        -- Clean up tables where we don't have a cascading delete.
        delete from rhnChannel where org_id = org_id_in;
        delete from rhnDailySummaryQueue where org_id = org_id_in;
        delete from rhnOrgQuota where org_id = org_id_in;
        delete from rhnOrgInfo where org_id = org_id_in;
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

    -- ////////////////////////////////////////////////////////

                create or replace function delete_user(user_id_in in numeric, deleting_org in numeric) returns void 
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

                 iadmin_curs_counter	numeric;

                                
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

		sg_curs_id	numeric;
                                
                messages cursor for
                        select  message_id
                        from    rhnUserMessage
                        where   user_id = user_id_in;

		msg_curs_id	numeric;
		
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
                begin
                        select  id, 1
                        into    other_user_id, other_users
                        from    web_contact
                        where   1=1
                                and org_id = our_org_id
                                and id != user_id_in
                                and rownum = 1;
                exception
                        when division_by_zero then
                                other_users := 0;
                end;

                -- now do org admin stuff
                if other_users != 0 then
			open is_admin;
                        --for ignore in is_admin loop
                        loop
				fetch is_admin into iadmin_curs_counter;
				exit when not found;
                                begin
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
                                                and rownum = 1;
                                if not found then 
                                end if;
                                
                                        --end if;
                        -- If we're deleting the org, we don't want to raise
                        -- the exception.
                        if deleting_org = 0 then
                                                perform rhn_exception.raise_exception('cannot_delete_user');
                        end if;
                                end;
				open servergroups_needing_admins;
				loop
					fetch servergroups_needing_admins into sg_curs_id;
					exit when not found;
                                --for sg in servergroups_needing_admins loop
                                        perform rhn_user.add_servergroup_perm(other_org_admin,sg_curs_id);
                                end loop;

                                close servergroups_needing_admins;
                        end loop;

                        close is_admin;
                end if;

                -- and now things for every user
                open messages;
                loop
			fetch messages into msg_curs_id;
			exit when not found;
                --for message in messages loop
                        delete
                                from    rhnUserMessage
                                where   user_id = user_id_in
                                        and message_id = msg_curs_id;
                        begin
                                select  1
                                into    users
                                from    rhnUserMessage
                                where   message_id = msg_curs_id
                                        and rownum = 1;
                                delete
                                        from    rhnMessage
                                        where   id = msgs_curs_id;
                        if not founf then 
                                null;
                        end if;        
                        end;
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
                                set             user_id = nvl(other_org_admin, other_user_id)
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


