-- created by Oraschemadoc Mon Aug 31 10:54:41 2009
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE PROCEDURE "MIM1"."SET_KS_SESSION_HISTORY_MESSAGE" (
	kickstart_session_id_in in number,
	state_label_in in varchar2,
	message_in in varchar2
) is
	cursor states is
		select	id
		from	rhnKickstartSessionState
		where	label = state_label_in;
	cursor history_items(state_id_in in number) is
		select	id
		from	rhnKickstartSessionHistory
		where	kickstart_session_id = kickstart_session_id_in
			and state_id = state_id_in
		order by time desc;
begin
	for state in states loop
		for item in history_items(state.id) loop
			update rhnKickstartSessionHistory
				set message = message_in
				where id = item.id;
			return;
		end loop;
		insert into rhnKickstartSessionHistory (
				id, kickstart_session_id, state_id, message
			) values (
				rhn_ks_sessionhist_id_seq.nextval,
				kickstart_session_id_in,
				state.id,
				message_in
			);
		return;
	end loop;
end;
 
/
