-- created by Oraschemadoc Mon Aug 31 10:54:40 2009
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE TRIGGER "MIM1"."RHN_USER_INFO_MOD_TRIG" 
before insert or update on rhnUserInfo
for each row
begin
	:new.modified := sysdate;
end rhn_user_info_mod_trig;
ALTER TRIGGER "MIM1"."RHN_USER_INFO_MOD_TRIG" ENABLE
 
/
