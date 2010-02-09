-- created by Oraschemadoc Fri Jan 22 13:40:53 2010
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE TRIGGER "SPACEWALK"."RHN_BEEHIVE_PATH_MAP_MOD_TRIG"
before insert or update on rhnBeehivePathMap
for each row
begin
    :new.modified := SYSDATE;
end rhn_beehive_mod_trig;
ALTER TRIGGER "SPACEWALK"."RHN_BEEHIVE_PATH_MAP_MOD_TRIG" ENABLE
 
/
