-- oracle equivalent source sha1 b14267384bc104605623a41b755e68e0103b5aa8

-- setup search_path so that these functions are created in appropriate schema.
update pg_settings set setting = 'rhn_cache,' || setting where name = 'search_path';

	-- this means a server got added or removed, so we
	-- can't key off of a server anywhere.
create or replace function update_perms_for_server_group(
                server_group_id_in in numeric
        ) returns void 
as
$$
declare
       users cursor for
			-- org admins aren't affected, so don't test for them
			select	usgp.user_id id
			from	rhnUserServerGroupPerms usgp
			where	usgp.server_group_id = server_group_id_in
				and not exists (
					select	1
					from	rhnUserGroup ug,
							rhnUserGroupMembers ugm,
							rhnServerGroup sg,
							rhnUserGroupType ugt
					where	ugt.label = 'org_admin'
                                                and ugt.id = ug.group_type
						and sg.id = server_group_id_in
						and ugm.user_id = usgp.user_id
						and ug.org_id = sg.org_id
						and ugm.user_group_id = ug.id
					);
begin
	for u in users loop
		perform rhn_cache.update_perms_for_user(u.id);
	end loop;
end;
$$ language plpgsql;

-- restore the original setting
update pg_settings set setting = overlay( setting placing '' from 1 for (length('rhn_cache')+1) ) where name = 'search_path';
