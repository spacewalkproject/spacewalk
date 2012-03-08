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

create or replace
package body rhn_user
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

	function role_names (user_id_in in number)
	return varchar2
	is
		tmp varchar2(4000);
	begin
		for rec in (
			select type_name
			from rhnUserTypeBase
			where user_id = user_id_in
			order by type_id
			) loop
			if tmp is null then
				tmp := rec.type_name;
			else
				tmp := tmp || ', ' || rec.type_name;
			end if;
		end loop;
		return tmp;
	end;

end rhn_user;
/
SHOW ERRORS
