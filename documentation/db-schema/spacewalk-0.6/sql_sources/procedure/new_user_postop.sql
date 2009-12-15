-- created by Oraschemadoc Mon Aug 31 10:54:41 2009
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE PROCEDURE "MIM1"."NEW_USER_POSTOP" 
(
    user_id_in IN number
)
is
    org_id_val		number;
    admin_group_val	number;
begin
    select org_id into org_id_val
      from web_contact
     where id = user_id_in;

    select id into admin_group_val
      from rhnUserGroup
     where org_id = org_id_val
       and group_type = (
		select	id
		from	rhnUserGroupType
		where	label = 'org_admin'
	   );

    insert into rhnUserGroupMembers
        (user_group_id, user_id)
    values
        (admin_group_val, user_id_in);

    insert into rhnUserInfo
        (user_id)
    values
        (user_id_in);
end;
 
/
