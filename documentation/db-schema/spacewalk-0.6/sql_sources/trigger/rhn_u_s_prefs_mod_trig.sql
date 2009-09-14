-- created by Oraschemadoc Mon Aug 31 10:54:40 2009
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE TRIGGER "MIM1"."RHN_U_S_PREFS_MOD_TRIG" 
before insert or update on rhnUserServerPrefs
for each row
begin
        :new.modified := sysdate;
        :new.value := upper(:new.value);
end;
ALTER TRIGGER "MIM1"."RHN_U_S_PREFS_MOD_TRIG" ENABLE
 
/
