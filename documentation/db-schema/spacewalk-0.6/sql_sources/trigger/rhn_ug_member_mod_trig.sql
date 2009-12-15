-- created by Oraschemadoc Mon Aug 31 10:54:40 2009
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE TRIGGER "MIM1"."RHN_UG_MEMBER_MOD_TRIG" 
before insert or update on rhnUserGroupMembers
for each row
declare
        ug              rhnUserGroup%ROWTYPE;
begin
        :new.modified := sysdate;

        if inserting then
                select
                        * into ug
                from
                        rhnUserGroup
                where
                        id = :new.user_group_id;

                if ug.max_members is not null and
                ug.current_members+1 > ug.max_members then
                        rhn_exception.raise_exception('usergroup_max_members');
                end if;

                update rhnUserGroup
                set current_members = current_members + 1
                where id = :new.user_group_id;
        end if;
end;
ALTER TRIGGER "MIM1"."RHN_UG_MEMBER_MOD_TRIG" ENABLE
 
/
