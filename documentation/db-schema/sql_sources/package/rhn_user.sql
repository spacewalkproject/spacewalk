-- created by Oraschemadoc Fri Jan 22 13:41:07 2010
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE PACKAGE "MIM_H1"."RHN_USER" 
is
	version varchar2(100) := '';

    function check_role(user_id_in in number, role_in in varchar2) return number;
    PRAGMA RESTRICT_REFERENCES(check_role, WNDS, RNPS, WNPS);

    function check_role_implied(user_id_in in number, role_in in varchar2) return number;
    PRAGMA RESTRICT_REFERENCES(check_role_implied, WNDS, RNPS, WNPS);

    function get_org_id(user_id_in in number) return number;
    PRAGMA RESTRICT_REFERENCES(get_org_id, WNDS, RNPS, WNPS);

	function find_mailable_address(user_id_in in number) return varchar2;

	procedure add_servergroup_perm(
		user_id_in in number,
		server_group_id_in in number
	);

	procedure remove_servergroup_perm(
		user_id_in in number,
		server_group_id_in in number
	);

	procedure add_to_usergroup(
		user_id_in in number,
		user_group_id_in in number
	);

	procedure add_users_to_usergroups(
		user_id_in in number
	);

	procedure remove_from_usergroup(
		user_id_in in number,
		user_group_id_in in number
	);

	procedure remove_users_from_servergroups(
		user_id_in in number
	);
end rhn_user;
CREATE OR REPLACE PACKAGE BODY "MIM_H1"."RHN_USER" 
is
	body_version varchar2(100) := '';

    function check_role(user_id_in in number, role_in in varchar2)
    return number
    is
    	throwaway number;
    begin
    	-- the idea: if we get past this query, the org has the setting, else catch the exception and return 0
	select 1 into throwaway
	  from rhnUserGroupType UGT,
	       rhnUserGroup UG,
	       rhnUserGroupMembers UGM
	 where UGM.user_id = user_id_in
	   and UGM.user_group_id = UG.id
	   and UG.group_type = UGT.id
	   and UGT.label = role_in;

	return 1;
    exception
    	when no_data_found
	    then
	    return 0;
    end check_role;

    function check_role_implied(user_id_in in number, role_in in varchar2)
    return number
    is
    	throwaway number;
    begin
    	-- if the user directly has the role, they win
    	if rhn_user.check_role(user_id_in, role_in) = 1
	then
	    return 1;
    	end if;

	-- config_admin and channel_admin are automatically implied for org admins
	if role_in = 'config_admin' and rhn_user.check_role(user_id_in, 'org_admin') = 1
	then
	    return 1;
	end if;

	if role_in = 'channel_admin' and rhn_user.check_role(user_id_in, 'org_admin') = 1
	then
	    return 1;
	end if;

	return 0;
    end check_role_implied;

    function get_org_id(user_id_in in number)
    return number
    is
    	org_id_out number;
    begin
    	select org_id into org_id_out
	  from web_contact
	 where id = user_id_in;

	return org_id_out;
    end get_org_id;

	-- paid users often don't have verified email addresses, so
	-- try to find an address that is useful to us.
	function find_mailable_address(user_id_in in number)
	return varchar2 is
		PRAGMA AUTONOMOUS_TRANSACTION;
		-- this would be so much prettier if we just had an order built
		-- into rhnEmailAddressState
		cursor addrs is
			select	ea.state_id, ea.address
			from	rhnEmailAddressState eas,
					rhnEmailAddress ea
			where	ea.user_id = user_id_in
				and eas.label = 'verified'
				and ea.state_id = eas.id
			union all
			select	ea.state_id, ea.address
			from	rhnEmailAddressState eas,
					rhnEmailAddress ea
			where	ea.user_id = user_id_in
				and eas.label = 'unverified'
				and ea.state_id = eas.id
			union all
			select	ea.state_id, ea.address
			from	rhnEmailAddressState eas,
					rhnEmailAddress ea
			where	ea.user_id = user_id_in
				and eas.label = 'pending'
				and ea.state_id = eas.id
			union all
			select	ea.state_id, ea.address
			from	rhnEmailAddressState eas,
					rhnEmailAddress ea
			where	ea.user_id = user_id_in
				and eas.label = 'pending_warned'
				and ea.state_id = eas.id
			union all
			select	ea.state_id, ea.address
			from	rhnEmailAddressState eas,
					rhnEmailAddress ea
			where	ea.user_id = user_id_in
				and eas.label = 'needs_verifying'
				and ea.state_id = eas.id
			union all
			select	-1 state_id,
					email address
			from	web_user_personal_info
			where	web_user_id = user_id_in;
		retval rhnEmailAddress.address%TYPE;
	begin
		for addr in addrs loop
			retval := addr.address;
			if addr.address is null then
				update web_user_contact_permission
					set email = 'N'
					where web_user_id = user_id_in;
				commit;
				return null;
			end if;
			if addr.state_id = -1 then
				insert into rhnEmailAddress (
						id, address,
						user_id, state_id
					) (
						select	rhn_eaddress_id_seq.nextval, addr.address,
								user_id_in, eas.id
						from	rhnEmailAddressState eas
						where	eas.label = 'unverified'
					);
			end if;
			commit;
			return retval;
		end loop;
		return null;
	end;

	procedure add_servergroup_perm(
		user_id_in in number,
		server_group_id_in in number
	) is
		cursor	orgs_match is
			select	1
			from	rhnServerGroup sg,
					web_contact u
			where	u.id = user_id_in
				and sg.id = server_group_id_in
				and sg.org_id = u.org_id;
	begin
		for okay in orgs_match loop
			insert into rhnUserServerGroupPerms(user_id, server_group_id)
				values (user_id_in, server_group_id_in);
			rhn_cache.update_perms_for_user(user_id_in);
			return;
		end loop;
		rhn_exception.raise_exception('usgp_different_orgs');
	exception when dup_val_on_index then
		rhn_exception.raise_exception('usgp_already_allowed');
	end add_servergroup_perm;

	procedure remove_servergroup_perm(
		user_id_in in number,
		server_group_id_in in number
	) is
		cursor perms is
			select	1
			from	rhnUserServerGroupPerms
			where	user_id = user_id_in
				and server_group_id = server_group_id_in;
	begin
		for perm in perms loop
			delete from rhnUserServerGroupPerms
				where	user_id = user_id_in
					and server_group_id = server_group_id_in;
			rhn_cache.update_perms_for_user(user_id_in);
			return;
		end loop;
		rhn_exception.raise_exception('usgp_not_allowed');
	end remove_servergroup_perm;

	procedure add_to_usergroup(
		user_id_in in number,
		user_group_id_in in number
	) is
		cursor perm_granting_usergroups is
			select	user_group_id_in
			from	rhnUserGroup		ug,
					rhnUserGroupType	ugt
			where	ugt.label in ('org_admin') -- and server_group_admin ?
				and ug.id = user_group_id_in
				and ug.group_type = ugt.id;
	begin
		insert into rhnUserGroupMembers(user_id, user_group_id)
			values (user_id_in, user_group_id_in);

		for ug in perm_granting_usergroups loop
			rhn_cache.update_perms_for_user(user_id_in);
			return;
		end loop;
	end add_to_usergroup;

	procedure add_users_to_usergroups(
		user_id_in in number
	) is
		cursor ugms is
			select	element user_id,
					element_two user_group_id
			from	rhnSet
			where	user_id = user_id_in
				and label = 'user_group_list';
	begin
		for ugm in ugms loop
			rhn_user.add_to_usergroup(ugm.user_id, ugm.user_group_id);
		end loop;
	end add_users_to_usergroups;

	procedure remove_from_usergroup(
		user_id_in in number,
		user_group_id_in in number
	) is
		cursor perm_granting_usergroups is
			select	label
			from	rhnUserGroupType	ugt,
					rhnUserGroupMembers	ugm,
					rhnUserGroup		ug
			where	1=1
				and ug.id = user_group_id_in
				and ugm.user_group_id = user_group_id_in
				and ug.group_type = ugt.id
				and ugm.user_id = user_id_in;
	begin
		-- we only do anything if you're really in the group, because
		-- testing is significantly cheaper than rebuilding the user's
		-- cache for no reason.
		for ug in perm_granting_usergroups loop
			delete from rhnUserGroupMembers
				where	user_id = user_id_in
					and user_group_id = user_group_id_in;
			if ug.label in ('org_admin') then
				rhn_cache.update_perms_for_user(user_id_in);
			end if;
		end loop;
	end remove_from_usergroup;

	procedure remove_users_from_servergroups(
		user_id_in in number
	) is
		cursor ugms is
			select	element user_id,
					element_two user_group_id
			from	rhnSet
			where	user_id = user_id_in
				and label = 'user_group_list';
	begin
		for ugm in ugms loop
			rhn_user.remove_from_usergroup(ugm.user_id, ugm.user_group_id);
		end loop;
	end remove_users_from_servergroups;
end rhn_user;
 
/
