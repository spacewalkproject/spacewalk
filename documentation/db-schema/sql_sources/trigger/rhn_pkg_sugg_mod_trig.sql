-- created by Oraschemadoc Tue Jul 19 17:31:33 2011
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE TRIGGER "SPACEWALK"."RHN_PKG_SUGG_MOD_TRIG" 
before insert or update on rhnPackageSuggests
for each row
begin
        :new.modified := sysdate;
end;
ALTER TRIGGER "SPACEWALK"."RHN_PKG_SUGG_MOD_TRIG" ENABLE
 
/
