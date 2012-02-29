-- oracle equivalent source sha1 007c497a31ad8fe3716d393fd154ad753dcdb41a
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

create or replace function
lookup_source_name(name_in in varchar)
returns numeric
as
$$
declare
    source_id   numeric;
begin
    select id
      into source_id
      from rhnSourceRPM
     where name = name_in;

    if not found then
        source_id := nextval('rhn_sourcerpm_id_seq');
        begin
            perform pg_dblink_exec(
                'insert into rhnSourceRPM(id, name) values (' ||
                source_id || ', ' || coalesce(quote_literal(name_in), 'NULL') || ')');
        exception when unique_violation then
            select id
              into strict source_id
              from rhnSourceRPM
             where name = name_in;
        end;
    end if;

    return source_id;
end;
$$
language plpgsql immutable;
