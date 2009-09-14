-- created by Oraschemadoc Mon Aug 31 10:54:41 2009
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE FUNCTION "MIM1"."DOES_USER_HAVE_ROLE" 
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
