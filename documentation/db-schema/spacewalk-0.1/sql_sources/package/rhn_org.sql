-- created by Oraschemadoc Fri Jun 13 14:06:12 2008
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE PACKAGE "RHNSAT"."RHN_ORG" 
IS
	version varchar2(100) := '$Id: universe.satellite.sql,v 1.2 2008/06/09 08:37:56 mmraka Exp $';
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
CREATE OR REPLACE PACKAGE BODY "RHNSAT"."RHN_ORG" 
IS
	body_version varchar2(100) := '$Id: universe.satellite.sql,v 1.2 2008/06/09 08:37:56 mmraka Exp $';
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
    begin
        if org_id_in = 1 then
            rhn_exception.raise_exception('cannot_delete_base_org');
        end if;
        for u in users loop
            rhn_org.delete_user(u.id, 1);
        end loop;
        for s in servers(org_id_in) loop
            delete_server(s.id);
        end loop;
        for c in config_channels loop
            rhn_config.delete_channel(c.id);
        end loop;
        rhn_entitlements.remove_org_entitlements(org_id_in);
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
		delete from rhn_contact_methods where contact_id = user_id_in;
		delete from rhn_redirects where contact_id = user_id_in;
		delete from rhnUserServerPerms where user_id = user_id_in;
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
