-- created by Oraschemadoc Thu Jan 20 13:58:21 2011
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE TRIGGER "SPACEWALK"."RHN_SOLARIS_P_MOD_TRIG" 
before update on rhnSolarisPatch
for each row
begin
   :new.modified := sysdate;
end;
ALTER TRIGGER "SPACEWALK"."RHN_SOLARIS_P_MOD_TRIG" ENABLE
 
/
