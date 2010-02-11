-- created by Oraschemadoc Fri Jan 22 13:40:59 2010
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE TRIGGER "SPACEWALK"."RHN_KS_SESSION_HISTORY_TRIGGER"
after insert or update on rhnKickstartSession
for each row
begin
	if inserting or (updating and :new.state_id != :old.state_id) then
		insert into rhnKickstartSessionHistory (
				id, kickstart_session_id, action_id, state_id
			) values (
				rhn_ks_sessionhist_id_seq.nextval,
				:new.id,
				:new.action_id,
				:new.state_id
			);
	end if;

	-- rob says we want an update if the time changes, but I don't
	-- know of any way to do this that won't result in a mutating
	-- table during the trigger in the delete_server() case, so we're
	-- not doing it now.
end;
ALTER TRIGGER "SPACEWALK"."RHN_KS_SESSION_HISTORY_TRIGGER" ENABLE
 
/
