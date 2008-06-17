-- created by Oraschemadoc Fri Jun 13 14:06:10 2008
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE TRIGGER "RHNSAT"."RHN_PATH_CHANNEL_MAP_MOD_TRIG" 
before insert or update on rhnPathChannelMap
for each row
begin
	:new.modified := SYSDATE;
end rhn_beehive_mod_trig;
ALTER TRIGGER "RHNSAT"."RHN_PATH_CHANNEL_MAP_MOD_TRIG" ENABLE
 
/
