-- created by Oraschemadoc Fri Jun 13 14:06:11 2008
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE FUNCTION "RHNSAT"."IS_USER_ORG_ADMIN" 
(
    user_id_in IN number
)
return number
is
    org_id_val		number;
    app_group_val	number;
    org_admin           number;
begin
    select org_id into org_id_val
      from web_contact
     where id = user_id_in;
    select id into app_group_val
      from rhnUserGroup
     where org_id = org_id_val
       and group_type = (
		select	id
		from	rhnUserGroupType
		where	label = 'org_admin'
	   );
    select count(1) into org_admin
      from rhnUserGroupMembers
     where user_group_id = app_group_val
       and user_id = user_id_in;
   return org_admin;
end;
 
/
