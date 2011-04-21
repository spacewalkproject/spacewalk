-- created by Oraschemadoc Thu Apr 21 10:04:16 2011
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE TRIGGER "SPACEWALK"."RHN_ACTION_STATUSMOD_TRIG" 
before insert or update on rhnActionStatus
for each row
begin
        :new.modified := sysdate;
end;
ALTER TRIGGER "SPACEWALK"."RHN_ACTION_STATUSMOD_TRIG" ENABLE
 
/
