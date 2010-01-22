-- created by Oraschemadoc Fri Jan 22 13:40:59 2010
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE TRIGGER "MIM_H1"."RHN_KSTREE_MOD_TRIG" 
before insert or update on rhnKickstartableTree
for each row
begin
     if (:new.last_modified = :old.last_modified) or
        (:new.last_modified is null ) then
             :new.last_modified := sysdate;
     end if;

	:new.modified := sysdate;
end rhn_kstree_mod_trig;
ALTER TRIGGER "MIM_H1"."RHN_KSTREE_MOD_TRIG" ENABLE
 
/
