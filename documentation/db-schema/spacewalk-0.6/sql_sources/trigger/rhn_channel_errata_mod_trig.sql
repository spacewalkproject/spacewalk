-- created by Oraschemadoc Mon Aug 31 10:54:37 2009
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE TRIGGER "MIM1"."RHN_CHANNEL_ERRATA_MOD_TRIG" 
before insert or update on rhnChannelErrata
for each row
begin
	:new.modified := sysdate;
end rhn_channel_errata_mod_trig;
ALTER TRIGGER "MIM1"."RHN_CHANNEL_ERRATA_MOD_TRIG" ENABLE
 
/
