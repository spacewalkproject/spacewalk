-- created by Oraschemadoc Fri Jun 13 14:06:10 2008
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE TRIGGER "RHNSAT"."RHN_ERRATATMP_MOD_TRIG" 
before insert or update on rhnerratatmp
for each row
begin
        :new.modified := sysdate;
        :new.last_modified := sysdate;
end;
ALTER TRIGGER "RHNSAT"."RHN_ERRATATMP_MOD_TRIG" ENABLE
 
/
