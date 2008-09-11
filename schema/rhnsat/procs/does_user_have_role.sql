--
-- $Id$
--

create or replace function
does_user_have_role
(
	user_id_in in number,
	role_in in varchar2
)
return number
is
	org_admin	number;
begin
	select	1
	into	org_admin
	from
		rhnUserGroupType	ugt,
		rhnUserGroup		ug,
		rhnUserGroupMembers	ugm
	where	1=1
		and ugm.user_id = user_id_in
		and ugm.user_group_id = ug.id
		and ugt.label = role_in
		and ugt.id = ug.group_type;
	return org_admin;
exception
	when no_data_found then
		return 0;
end;
/
show errors

-- $Log$
-- Revision 1.1  2003/07/16 18:56:36  pjones
-- bugzilla: none
--
-- generic user-role tester
--
