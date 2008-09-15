-- created by Oraschemadoc Fri Jun 13 14:06:09 2008
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE TRIGGER "RHNSAT"."RHN_CHANNEL_PACKAGE_MOD_TRIG" 
before insert or update on rhnChannelPackage
for each row
begin
	:new.modified := sysdate;
end rhn_channel_package_mod_trig;
ALTER TRIGGER "RHNSAT"."RHN_CHANNEL_PACKAGE_MOD_TRIG" ENABLE
 
/
