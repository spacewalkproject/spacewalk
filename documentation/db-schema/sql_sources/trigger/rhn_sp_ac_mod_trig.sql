-- created by Oraschemadoc Fri Mar  2 05:58:09 2012
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE TRIGGER "SPACEWALK"."RHN_SP_AC_MOD_TRIG" 
before insert or update on rhnServerPackageArchCompat
for each row
begin
        :new.modified := sysdate;
end;
ALTER TRIGGER "SPACEWALK"."RHN_SP_AC_MOD_TRIG" ENABLE
 
/
