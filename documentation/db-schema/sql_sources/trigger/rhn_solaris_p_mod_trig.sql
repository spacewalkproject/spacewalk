-- created by Oraschemadoc Thu Apr 21 10:04:19 2011
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE TRIGGER "SPACEWALK"."RHN_SOLARIS_P_MOD_TRIG" 
before update on rhnSolarisPatch
for each row
begin
   :new.modified := sysdate;
end;
ALTER TRIGGER "SPACEWALK"."RHN_SOLARIS_P_MOD_TRIG" ENABLE
 
/
