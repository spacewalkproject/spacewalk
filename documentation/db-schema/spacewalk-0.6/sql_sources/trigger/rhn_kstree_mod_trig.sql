-- created by Oraschemadoc Mon Aug 31 10:54:38 2009
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE TRIGGER "MIM1"."RHN_KSTREE_MOD_TRIG" 
before insert or update on rhnKickstartableTree
for each row
begin
     if (:new.last_modified = :old.last_modified) or
        (:new.last_modified is null ) then
             :new.last_modified := sysdate;
     end if;

	:new.modified := sysdate;
end rhn_kstree_mod_trig;
ALTER TRIGGER "MIM1"."RHN_KSTREE_MOD_TRIG" ENABLE
 
/
