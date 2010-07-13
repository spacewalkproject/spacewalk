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
--
--
--

CREATE OR REPLACE
PACKAGE BODY rhn_org
IS
	body_version varchar2(100) := '';

    FUNCTION find_server_group_by_type(org_id_in NUMBER, group_label_in VARCHAR2) 
    RETURN NUMBER
    IS
	server_group       server_group_by_label%ROWTYPE;
    BEGIN
    	OPEN server_group_by_label(org_id_in, group_label_in);
	FETCH server_group_by_label INTO server_group;
	CLOSE server_group_by_label;

	RETURN server_group.id;
    END find_server_group_by_type;
    
    procedure delete_org (
        org_id_in in number
    )
    is
        cursor users is
        select id
        from web_contact
        where org_id = org_id_in;

	cursor servers(org_id_in in number) is
        select	id
        from	rhnServer
        where	org_id = org_id_in;

        cursor config_channels is
        select id
        from rhnConfigChannel
        where org_id = org_id_in;

	cursor custom_channels is
        select	id
        from	rhnChannel
        where	org_id = org_id_in;

	cursor errata is
        select	id
        from	rhnErrata
        where	org_id = org_id_in;

    begin

        if org_id_in = 1 then
            rhn_exception.raise_exception('cannot_delete_base_org');
        end if;

        -- Delete all users.
        for u in users loop
            rhn_org.delete_user(u.id, 1);
        end loop;

        -- Delete all servers.
        for s in servers(org_id_in) loop
            delete_server(s.id);
        end loop;

        -- Delete all config channels.
        for c in config_channels loop
            rhn_config.delete_channel(c.id);
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
        rhn_entitlements.remove_org_entitlements(org_id_in);

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

    end delete_org;

	procedure delete_user(user_id_in in number, deleting_org in number := 0) is
		cursor is_admin is
			select	1
			from	rhnUserGroupType	ugt,
					rhnUserGroup		ug,
					rhnUserGroupMembers	ugm
			where	ugm.user_id = user_id_in
				and ugm.user_group_id = ug.id
				and ug.group_type = ugt.id
				and ugt.label = 'org_admin';
		cursor servergroups_needing_admins is
			select	usgp.server_group_id	server_group_id
			from	rhnUserServerGroupPerms	usgp
			where	1=1
				and usgp.user_id = user_id_in
				and not exists (
					select	1
					from	rhnUserServerGroupPerms	sq_usgp
					where	1=1
						and sq_usgp.server_group_id = usgp.server_group_id
						and	sq_usgp.user_id != user_id_in
				);
		cursor messages is
			select	message_id id
			from	rhnUserMessage
			where	user_id = user_id_in;
		users			number;
		our_org_id		number;
		other_users		number;
		other_org_admin	number;
        other_user_id  number;
	begin
		select	wc.org_id
		into	our_org_id
		from	web_contact wc
		where	id = user_id_in;

		-- find any other users
		begin
			select	id, 1
			into	other_user_id, other_users
			from	web_contact
			where	1=1
				and org_id = our_org_id
				and id != user_id_in
				and rownum = 1;
		exception
			when no_data_found then
				other_users := 0;
		end;

		-- now do org admin stuff
		if other_users != 0 then
			for ignore in is_admin loop
				begin 
					select	new_ugm.user_id
					into	other_org_admin
					from	rhnUserGroupMembers	new_ugm,
							rhnUserGroupType	ugt,
							rhnUserGroup		ug,
							rhnUserGroupMembers	ugm
					where	ugm.user_id = user_id_in
						and ugm.user_group_id = ug.id
						and ug.group_type = ugt.id
						and ugt.label = 'org_admin'
						and ug.id = new_ugm.user_group_id
						and new_ugm.user_id != user_id_in
						and rownum = 1;
				exception
					when no_data_found then
                        -- If we're deleting the org, we don't want to raise
                        -- the exception.
                        if deleting_org = 0 then
    						rhn_exception.raise_exception('cannot_delete_user');
                        end if;
				end;

				for sg in servergroups_needing_admins loop
					rhn_user.add_servergroup_perm(other_org_admin,
						sg.server_group_id);
				end loop;
			end loop;
		end if;

		-- and now things for every user
		for message in messages loop
			delete
				from	rhnUserMessage
				where	user_id = user_id_in
					and message_id = message.id;
			begin
				select	1
				into	users
				from	rhnUserMessage
				where	message_id = message.id
					and rownum = 1;
				delete
					from	rhnMessage
					where	id = message.id;
			exception
				when no_data_found then
					null;
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
			update		rhnRegToken
				set		user_id = nvl(other_org_admin, other_user_id)
				where	org_id = our_org_id
					and user_id = user_id_in;
			begin
				delete from web_contact where id = user_id_in;
			exception
				when others then
					rhn_exception.raise_exception('cannot_delete_user');
			end;
        -- Just Delete the user
		else
            begin
                delete from web_contact where id = user_id_in;
		    exception
				when others then
					rhn_exception.raise_exception('cannot_delete_user');
			end;
		end if;
		return;
	end delete_user;

END rhn_org;
/
SHOW ERRORS

--
-- Revision 1.22  2004/10/29 04:50:49  pjones
-- bugzilla: 135179 -- fix org admin swapping during user deletion
--
-- Revision 1.21  2004/07/13 22:46:04  pjones
-- bugzilla: 125938 -- nothing uses update_errata_cache() any more, remove it
--
-- Revision 1.20  2004/07/02 22:24:38  pjones
-- bugzilla: none -- typo fix
--
-- Revision 1.19  2004/07/02 19:19:02  pjones
-- bugzilla: 125937 -- use rhn_user to grant roles to users
--
-- Revision 1.18  2004/05/28 22:21:36  pjones
-- bugzilla: none -- update for monitoring schema
--
-- Revision 1.17  2004/04/05 16:31:07  pjones
-- bugzilla: 120032 -- raise "cannot_delete_user" if web_contact or web_customer
-- has a cascade problem
--
-- Revision 1.16  2004/03/15 17:10:28  pjones
-- bugzilla: 118244 -- delete servers explicitly while deleting lone users
--
-- Revision 1.15  2004/02/09 17:14:54  pjones
-- bugzilla: none -- fix log garbage
--
-- Revision 1.14  2004/01/22 19:44:42  pjones
-- bugzilla: 106562 -- fix exceptions on delete_user()
--
-- Revision 1.13  2004/01/20 17:00:48  pjones
-- bugzilla: none -- try to make delete_user() succeed when there are
-- server groups that have been snapshotted
--
-- Revision 1.12  2004/01/14 20:22:03  pjones
-- bugzilla: 113344 -- no deleting from rhnServerGroup, use the api instead
--
-- Revision 1.11  2003/03/20 17:08:16  pjones
-- avoid the server group members trigger that updates last_modified; it'll
-- cause a mutating table error
--
-- Revision 1.10  2003/03/17 16:31:25  pjones
-- use "on delete set null" where applicable
--
-- Revision 1.9  2003/03/15 00:31:07  pjones
-- bugzilla: none
--
-- tested wrong table for perms on a server group
--
-- Revision 1.8  2003/03/15 00:23:36  pjones
-- bugzilla: 83631
--
-- working delete_user
--
-- Revision 1.7  2003/03/03 23:39:36  pjones
-- different delete_user; this one might actually work.
--
-- Takes about 18 seconds, which seems kindof slow, but isn't
-- intolerable I don't think...
--
-- Revision 1.6  2003/03/02 18:07:00  pjones
-- make it use marty's test instead of is_satellite(); in the sat env,
-- marty's test _is_ is_satellite()
--
-- Revision 1.5  2003/02/18 16:35:45  pjones
-- delete_user
--
-- Revision 1.4  2002/05/10 22:08:23  pjones
-- id/log
--
