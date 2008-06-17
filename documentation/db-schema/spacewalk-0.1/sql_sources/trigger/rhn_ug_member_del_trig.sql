-- created by Oraschemadoc Fri Jun 13 14:06:11 2008
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE TRIGGER "RHNSAT"."RHN_UG_MEMBER_DEL_TRIG" 
before delete on rhnUserGroupMembers
for each row
begin
        update rhnUserGroup
        set current_members = current_members - 1
        where id = :old.user_group_id;
end;
ALTER TRIGGER "RHNSAT"."RHN_UG_MEMBER_DEL_TRIG" ENABLE
 
/
