-- oracle equivalent source sha1 1e7ce43d973dd29d955854e69598836614ecae99
-- retrieved from ./1241042199/53fa26df463811901487b608eecc3f77ca7783a1/schema/spacewalk/oracle/procs/create_pxt_session.sql
--
-- Copyright (c) 2008--2012 Red Hat, Inc.
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

    perform pg_dblink_exec(
        'insert into PXTSessions (id, value, expires, web_user_id) values (' ||
        l_id || ', ' || coalesce(quote_literal(p_value), 'NULL') ||
        ', ' || p_expires || ', ' || p_web_user_id || '); commit');

	return l_id;
end;
$$ language plpgsql;
