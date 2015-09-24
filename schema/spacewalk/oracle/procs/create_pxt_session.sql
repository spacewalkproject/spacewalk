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
--
--
--

create or replace function
create_pxt_session(web_user_id in number, expires in number, value in varchar)
return number
is
pragma autonomous_transaction;
	id number;
begin
	select
		pxt_id_seq.nextval into id
	from
		dual;

	insert into PXTSessions (id, value, expires, web_user_id)
	values (id, value, expires, web_user_id);
	commit;

	return id;
end;
/
show errors
