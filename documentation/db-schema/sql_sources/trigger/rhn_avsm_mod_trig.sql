-- created by Oraschemadoc Fri Jan 22 13:40:52 2010
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE TRIGGER "SPACEWALK"."RHN_AVSM_MOD_TRIG"
before insert or update on rhnActionVirtSetMemory
for each row
begin
    :new.modified := sysdate;
end;
ALTER TRIGGER "SPACEWALK"."RHN_AVSM_MOD_TRIG" ENABLE
 
/
