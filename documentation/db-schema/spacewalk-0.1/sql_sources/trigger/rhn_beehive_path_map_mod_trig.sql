-- created by Oraschemadoc Fri Jun 13 14:06:09 2008
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE TRIGGER "RHNSAT"."RHN_BEEHIVE_PATH_MAP_MOD_TRIG" 
before insert or update on rhnBeehivePathMap
for each row
begin
    :new.modified := SYSDATE;
end rhn_beehive_mod_trig;
ALTER TRIGGER "RHNSAT"."RHN_BEEHIVE_PATH_MAP_MOD_TRIG" ENABLE
 
/
