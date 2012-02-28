-- oracle equivalent source sha1 3d574cd26eebe3152eb20bcb57fbbc4d264dfc12
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
lookup_package_name(name_in in varchar, ignore_null in numeric default 0)
returns numeric
as
$$
declare
    name_id     numeric;
begin
    if ignore_null = 1 and name_in is null then
        return null;
    end if;

    select id
      into name_id
      from rhnPackageName
     where name = name_in;

    if not found then
        name_id := nextval('rhn_pkg_name_seq');
        begin
            perform pg_dblink_exec(
                'insert into rhnPackageName(id, name) values (' || name_id || ', ' ||
                coalesce(quote_literal(name_in), 'NULL') || ')');
        exception when unique_violation then
            select id
              into strict name_id
              from rhnPackageName
             where name = name_in;
        end;
    end if;

    return name_id;
end;
$$ language plpgsql immutable;
