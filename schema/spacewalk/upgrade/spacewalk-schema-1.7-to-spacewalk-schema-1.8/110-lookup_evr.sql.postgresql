-- oracle equivalent source sha1 b14267384bc104605623a41b755e68e0103b5aa8
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
lookup_evr(e_in in varchar, v_in in varchar, r_in in varchar)
returns numeric
as
$$
declare
    evr_id  numeric;
begin
    select id
      into evr_id
      from rhnPackageEVR
     where ((epoch is null and e_in is null) or (epoch = e_in)) and
           version = v_in and
           release = r_in;
            
    if not found then
        evr_id := nextval('rhn_pkg_evr_seq');
        declare
            e_text varchar = coalesce(quote_literal(e_in), 'NULL');
            v_text varchar = coalesce(quote_literal(v_in), 'NULL');
            r_text varchar = coalesce(quote_literal(r_in), 'NULL');
        begin
            perform pg_dblink_exec(
                'insert into rhnPackageEVR(id, epoch, version, release, evr) values (' ||
                evr_id || ', ' || e_text || ', ' || v_text || ', ' || r_text
		|| ', evr_t(' || e_text || ', ' || v_text || ', ' || r_text || '))'
            );
        exception when unique_violation then
            select id
              into strict evr_id
              from rhnPackageEVR
             where ((epoch is null and e_in is null) or (epoch = e_in)) and
                   version = v_in and
                   release = r_in;
        end;
    end if;

    return evr_id;
end;
$$ language plpgsql immutable;
