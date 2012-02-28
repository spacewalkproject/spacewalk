-- oracle equivalent source sha1 5f3ad99fd4ed1558cfa5e3d64eb1c2cf452b59cf
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
lookup_cve(name_in in varchar)
returns numeric
as $$
declare
    name_id     numeric;
begin
    select id
      into name_id
      from rhnCVE
     where name = name_in;

    if not found then
        name_id := nextval('rhn_cve_id_seq');
        begin
            perform pg_dblink_exec(
                'insert into rhnCVE (id, name) values (' || name_id || ', ' ||
                coalesce(quote_literal(name_in), 'NULL') || ')');
        exception when unique_violation then
            select id
              into strict name_id
              from rhnCVE
             where name = name_in;
        end;
    end if;

    return name_id;
end; $$ language plpgsql immutable;
