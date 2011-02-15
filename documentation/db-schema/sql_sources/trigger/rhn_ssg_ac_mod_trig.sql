-- created by Oraschemadoc Thu Jan 20 13:58:23 2011
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE TRIGGER "SPACEWALK"."RHN_SSG_AC_MOD_TRIG" 
before insert or update on rhnServerServerGroupArchCompat
for each row
begin
        :new.modified := sysdate;
end;
ALTER TRIGGER "SPACEWALK"."RHN_SSG_AC_MOD_TRIG" ENABLE
 
/
