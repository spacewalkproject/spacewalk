-- oracle equivalent source none
--
-- Copyright (c) 2012 Red Hat, Inc.
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

create or replace function pg_dblink_exec(in_sql in varchar) returns void as
$$
begin
    if in_sql is null then
	raise 'pg_dblink_exec in_sql is null';
    end if;
    perform dblink_connect('at_conn', 'dbname=' || current_database());
    begin
        perform dblink_exec('at_conn', in_sql, true);
    exception when others then
        perform dblink_disconnect('at_conn');
        raise;
    end;
    perform dblink_disconnect('at_conn');
end;
$$
language plpgsql;
