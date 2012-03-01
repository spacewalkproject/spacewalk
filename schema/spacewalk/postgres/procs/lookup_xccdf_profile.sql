-- oracle equivalent source sha1 9d091d9787a9a3353e6e1b6d13b430f836dfad89
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
--

create or replace function
lookup_xccdf_profile(identifier_in in varchar, title_in in varchar)
returns numeric
as
$$
declare
    profile_id numeric;
begin
    select id
      into profile_id
      from rhnXccdfProfile
     where identifier = identifier_in and title = title_in;

    if not found then
        profile_id := nextval('rhn_xccdf_profile_id_seq');
        begin
            perform pg_dblink_exec(
                'insert into rhnXccdfProfile (id, identifier, title) values (' ||
                profile_id || ', ' ||
                coalesce(quote_literal(identifier_in), 'NULL') || ', ' ||
                coalesce(quote_literal(title_in), 'NULL') || ')' );
        exception when unique_violation then
            select id
              into profile_id
              from rhnXccdfProfile
             where identifier = identifier_in and title = title_in;
        end;
    end if;

    return profile_id;
end;
$$ language plpgsql;
