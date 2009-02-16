--
-- Copyright (c) 2008 Red Hat, Inc.
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
--
--
--

create or replace trigger
rhn_ks_session_mod_trig
before insert or update on rhnKickstartSession
for each row
begin
	:new.modified := sysdate;
end;
/
show errors

create or replace trigger
rhn_ks_session_history_trigger
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
--	if updating and :new.state_id = :old.state_id then
--		update rhnKickstartSessionHistory
--		   set time = :new.modified
--		 where kickstart_session_id = :new.id
--		   and state_id = :new.state_id;
--	end if;
end;
/
show errors

--
--
-- Revision 1.6  2003/11/25 16:40:27  pjones
-- bugzilla: none -- change when we're updating/inserting history in the trigger
--
-- Revision 1.5  2003/11/25 15:18:00  pjones
-- bugzilla: 110794
-- If we're updating, only touch the history table if state is changing
-- this fixes the delete case
--
-- Revision 1.4  2003/10/21 13:58:36  cturner
-- upsate time for current rhnKickstartSessionHistory when a state update occurs
--
-- Revision 1.3  2003/10/17 00:36:07  rnorwood
-- bugzilla: 106068 - fix status page issues.
--
-- Revision 1.2  2003/10/15 21:21:57  pjones
-- bugzilla: none
-- history must be an "after" trigger
--
-- Revision 1.1  2003/10/15 20:11:12  pjones
-- bugzilla: 106951
-- rhnKickstartSessionHistory, per robin's request
--
