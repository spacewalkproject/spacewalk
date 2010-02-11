-- created by Oraschemadoc Fri Jan 22 13:41:02 2010
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE TRIGGER "SPACEWALK"."RHN_UG_MEMBER_DEL_TRIG"
before delete on rhnUserGroupMembers
for each row
begin
        update rhnUserGroup
        set current_members = current_members - 1
        where id = :old.user_group_id;
end;
ALTER TRIGGER "SPACEWALK"."RHN_UG_MEMBER_DEL_TRIG" ENABLE
 
/
