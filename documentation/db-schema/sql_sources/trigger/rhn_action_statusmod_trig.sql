-- created by Oraschemadoc Wed Dec 21 14:59:52 2011
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE TRIGGER "SPACEWALK"."RHN_ACTION_STATUSMOD_TRIG" 
before insert or update on rhnActionStatus
for each row
begin
        :new.modified := sysdate;
end;
ALTER TRIGGER "SPACEWALK"."RHN_ACTION_STATUSMOD_TRIG" ENABLE
 
/
