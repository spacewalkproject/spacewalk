-- created by Oraschemadoc Fri Mar  2 05:58:05 2012
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE TRIGGER "SPACEWALK"."RHN_CHANNEL_ERRATA_MOD_TRIG" 
before insert or update on rhnChannelErrata
for each row
begin
	:new.modified := sysdate;
end rhn_channel_errata_mod_trig;
ALTER TRIGGER "SPACEWALK"."RHN_CHANNEL_ERRATA_MOD_TRIG" ENABLE
 
/
