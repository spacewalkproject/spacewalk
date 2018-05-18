-- oracle equivalent source sha1 44d21fc191c81ec1bcda62f24f553925f98a6924
-- retrieved from ./1241042199/53fa26df463811901487b608eecc3f77ca7783a1/schema/spacewalk/oracle/procs/create_pxt_session.sql
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
create_pxt_session(p_web_user_id in numeric, p_expires in numeric, p_value in varchar)
returns numeric as $$
declare
	l_id numeric;
begin
    l_id := nextval( 'pxt_id_seq' );

    insert into PXTSessions (id, value, expires, web_user_id)
        values (l_id, p_value, p_expires, p_web_user_id)
        on conflict do nothing;

    select id
        into strict l_id
        from PXTSessions
        where value = p_value and expires = p_expires and web_user_id = p_web_user_id;

	  return l_id;
end;
$$ language plpgsql;
