-- created by Oraschemadoc Fri Jan 22 13:40:59 2010
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE TRIGGER "SPACEWALK"."RHN_ORGQUOTA_MOD_TRIG"
before insert or update on rhnOrgQuota
for each row
declare
	available_quota number;
begin
	:new.modified := sysdate;

	available_quota := :new.total + :new.bonus;
	if :new.used > available_quota then
		rhn_exception.raise_exception('not_enough_quota');
	end if;
end;
ALTER TRIGGER "SPACEWALK"."RHN_ORGQUOTA_MOD_TRIG" ENABLE
 
/
