-- created by Oraschemadoc Fri Jan 22 13:41:01 2010
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE TRIGGER "SPACEWALK"."RHN_SERVER_ACTION_MOD_TRIG"
before insert or update on rhnServerAction
for each row
declare
	handle_status	number;
begin
	:new.modified := sysdate;
	handle_status := 0;
	if updating then
		if :new.status != :old.status then
			handle_status := 1;
		end if;
	else
		handle_status := 1;
	end if;

	if handle_status = 1 then
		if :new.status = 1 then
			:new.pickup_time := sysdate;
		elsif :new.status = 2 then
			:new.completion_time := sysdate;
		end if;
	end if;
end;
ALTER TRIGGER "SPACEWALK"."RHN_SERVER_ACTION_MOD_TRIG" ENABLE
 
/
