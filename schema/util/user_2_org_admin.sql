
declare

   org_admin_group_id number;
   user_id  number;

begin

   select ug.id, wc.id
   into org_admin_group_id, user_id
   from web_contact wc, rhnUserGroupType ugt, rhnUserGroup ug
   where ug.group_type = ugt.id
   and ugt.label = 'org_admin'
   and wc.org_id = ug.org_id
   and wc.login = '&login';

   rhn_user.add_to_usergroup (user_id, org_admin_group_id);

end;
/
