
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

create or replace trigger
rhn_server_action_mod_trig
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
/
show errors
