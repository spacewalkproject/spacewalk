-- created by Oraschemadoc Fri Jun 13 14:06:10 2008
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE TRIGGER "RHNSAT"."RHN_ORGQUOTA_MOD_TRIG" 
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
ALTER TRIGGER "RHNSAT"."RHN_ORGQUOTA_MOD_TRIG" ENABLE
 
/
