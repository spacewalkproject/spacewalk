-- created by Oraschemadoc Fri Jan 22 13:40:59 2010
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE TRIGGER "MIM_H1"."RHN_PATH_CHANNEL_MAP_MOD_TRIG" 
before insert or update on rhnPathChannelMap
for each row
begin
	:new.modified := SYSDATE;
end rhn_beehive_mod_trig;
ALTER TRIGGER "MIM_H1"."RHN_PATH_CHANNEL_MAP_MOD_TRIG" ENABLE
 
/
