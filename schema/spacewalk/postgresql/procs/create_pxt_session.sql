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

create or replace function
create_pxt_session_autonomous(p_web_user_id in numeric, p_expires in numeric, p_value in varchar)
returns numeric as $$
declare
	l_id numeric;
begin
	select
		sequence_nextval( 'pxt_id_seq' ) into id
	from
		dual;

	insert into PXTSessions (id, value, expires, web_user_id)
	values (l_id, p_value, p_expires, p_web_user_id);

	return id;
end;
$$ language plpgsql;

create or replace function
create_pxt_session(web_user_id in numeric, expires in numeric, value in varchar)
returns numeric as $$
declare
	ret numeric;
begin
	select retcode
	into ret
	from dblink( 'dbname='||current_database(),
			'select create_pxt_session_autonomous( '
			|| coalesce( web_user_id::varchar, 'null' ) || ', '
			|| coalesce( expires::varchar, 'null' ) || ', '
			|| coalesce( quote_literal( value ), 'null' ) ||
			')' )
			as f( retcode int );

	return ret;
end;
$$ language plpgsql;

