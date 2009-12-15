-- created by Oraschemadoc Mon Aug 31 10:54:39 2009
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE TRIGGER "MIM1"."RHN_PATH_CHANNEL_MAP_MOD_TRIG" 
before insert or update on rhnPathChannelMap
for each row
begin
	:new.modified := SYSDATE;
end rhn_beehive_mod_trig;
ALTER TRIGGER "MIM1"."RHN_PATH_CHANNEL_MAP_MOD_TRIG" ENABLE
 
/
