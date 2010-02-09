-- created by Oraschemadoc Fri Jan 22 13:41:07 2010
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE PACKAGE "SPACEWALK"."RHN_ORG"
IS
	version varchar2(100) := '';

    CURSOR server_group_by_label(org_id_in NUMBER, group_label_in VARCHAR2) IS
    	   SELECT SG.*
	     FROM rhnServerGroupType SGT,
	     	  rhnServerGroup SG
	    WHERE SG.group_type = SGT.id
	      AND SGT.label = group_label_in
	      AND SG.org_id = org_id_in;

    FUNCTION find_server_group_by_type(org_id_in NUMBER,
                                       group_label_in VARCHAR2)
    RETURN NUMBER;

    procedure delete_org(org_id_in in number);
    procedure delete_user(user_id_in in number, deleting_org in number := 0);

END rhn_org;
CREATE OR REPLACE PACKAGE BODY "SPACEWALK"."RHN_ORG"
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
