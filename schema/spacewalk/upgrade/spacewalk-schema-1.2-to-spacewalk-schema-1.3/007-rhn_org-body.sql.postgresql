-- oracle equivalent source sha1 559e892f7a81020c12bea5852dd563f43ddc2135
--
-- Copyright (c) 2011--2012 Red Hat, Inc.

-- setup search_path so that these functions are created in appropriate schema.
update pg_settings set setting = 'rhn_org,' || setting where name = 'search_path';

create or replace function delete_user(user_id_in in numeric, deleting_org in numeric default 0) returns void 
    as
    $$
    declare
    servergroups_needing_admins cursor for
            select    usgp.server_group_id    server_group_id
            from    rhnUserServerGroupPerms    usgp
            where    1=1
                and usgp.user_id = user_id_in
                and not exists (
                    select    1
                    from    rhnUserServerGroupPerms    sq_usgp
                    where    1=1
                        and sq_usgp.server_group_id = usgp.server_group_id
                        and    sq_usgp.user_id != user_id_in
                );
        users            numeric;
        our_org_id        numeric;
        other_users        numeric;
        other_org_admin    numeric;
        other_user_id  numeric;
        is_admin       numeric;
    begin
        select    wc.org_id
        into    our_org_id
        from    web_contact wc
        where    id = user_id_in;

        -- find any other users
        begin
            select    id, 1
            into    other_user_id, other_users
            from    web_contact
            where    1=1
                and org_id = our_org_id
                and id != user_id_in
                limit 1;
        exception
            when no_data_found then
                other_users := 0;
        end;

        -- now do org admin stuff
        if other_users != 0 then
            -- is user admin?
            select  count(1)
             into   is_admin
            from    rhnUserGroupType    ugt,
                    rhnUserGroup        ug,
                    rhnUserGroupMembers    ugm
            where    ugm.user_id = user_id_in
                and ugm.user_group_id = ug.id
                and ug.group_type = ugt.id
                and ugt.label = 'org_admin';
            if is_admin > 0 then
                begin
                    select    new_ugm.user_id
                    into    other_org_admin
                    from    rhnUserGroupMembers    new_ugm,
                            rhnUserGroupType    ugt,
                            rhnUserGroup        ug,
                            rhnUserGroupMembers    ugm
                    where    ugm.user_id = user_id_in
                        and ugm.user_group_id = ug.id
                        and ug.group_type = ugt.id
                        and ugt.label = 'org_admin'
                        and ug.id = new_ugm.user_group_id
                        and new_ugm.user_id != user_id_in
                        limit 1;
                exception
                    when no_data_found then
                        -- If we're deleting the org, we don't want to raise
                        -- the exception.
                        if deleting_org = 0 then
                           perform rhn_exception.raise_exception('cannot_delete_user');
                        end if;
                end;

                for sg in servergroups_needing_admins loop
                   perform rhn_user.add_servergroup_perm(other_org_admin,
                        sg.server_group_id);
                end loop;
            end if;
        end if;

        -- and now things for every user
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
        update rhnConfigRevision
           set changed_by_id = NULL
         where changed_by_id = user_id_in;
        if other_users != 0 then
            update        rhnRegToken
                set        user_id = coalesce(other_org_admin, other_user_id)
                where    org_id = our_org_id
                    and user_id = user_id_in;
        end if;

        begin
            delete from web_contact where id = user_id_in;
        exception
            when others then
               perform rhn_exception.raise_exception('cannot_delete_user');
        end;
        return;

        end;
        $$
        language plpgsql;

-- restore the original setting
update pg_settings set setting = overlay( setting placing '' from 1 for (length('rhn_org')+1) ) where name = 'search_path';
