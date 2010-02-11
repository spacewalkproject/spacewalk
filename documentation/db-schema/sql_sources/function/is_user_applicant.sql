-- created by Oraschemadoc Fri Jan 22 13:41:03 2010
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE FUNCTION "SPACEWALK"."IS_USER_APPLICANT"
(
    user_id_in IN number
)
return number
is
    org_id_val		number;
    app_group_val	number;
    applicant           number;
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
		where	label = 'org_applicant'
	   );

    select count(1) into applicant
      from rhnUserGroupMembers
     where user_group_id = app_group_val
       and user_id = user_id_in;

   return applicant;
end;
 
/
