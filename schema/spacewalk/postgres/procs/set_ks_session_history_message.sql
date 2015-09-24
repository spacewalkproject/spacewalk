-- oracle equivalent source sha1 e833bbe6da70cb068d20a4180f37f095dd4e30c9
-- retrieved from ./1241128047/984a347f2afbd47756e90584364799dd670b62db/schema/spacewalk/oracle/procs/set_ks_session_history_message.sql
--
-- Copyright (c) 2008--2015 Red Hat, Inc.
--
-- This software is licensed to you under the GNU General Public License,
-- version 2 (GPLv2). There is NO WARRANTY for this software, express or
-- implied, including the implied warranties of MERCHANTABILITY or FITNESS
-- FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
-- along with this software; if not, see
-- http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
-- 
-- Red Hat trademarks are not licensed under GPLv2. No permission is
-- granted to use or replicate Red Hat trademarks that are incorporated
-- in this software or its documentation. 
--

-- this seems like maybe it should have action_id as well?
-- maybe optional?

create or replace function
set_ks_session_history_message (
        kickstart_session_id_in in numeric,
        state_label_in in varchar,
        message_in in varchar
) returns void as
$$
declare
        states cursor is
                select  id
                from    rhnKickstartSessionState
                where   label = state_label_in;

                
		history_items cursor (state_id_in numeric) is
                select  id
                from    rhnKickstartSessionHistory
                where   kickstart_session_id = kickstart_session_id_in
                        and state_id = state_id_in
                order by time desc;

                id_states_curs numeric;
                id_history_items_curs numeric;
                
begin
	for id_states_curs in states
        loop
		for id_history_items_curs in history_items(id_states_curs.id)
                loop
                        update rhnKickstartSessionHistory
                                set message = message_in
                                where id = id_history_items_curs.id;
                        return;
                end loop;

                insert into rhnKickstartSessionHistory (
                                id, kickstart_session_id, state_id, message
                        ) values (
                                nextval('rhn_ks_sessionhist_id_seq'),
                                kickstart_session_id_in,
                                id_states_cursor,
                                message_in
                        );
                return;
        end loop;
end;
$$
language plpgsql;

