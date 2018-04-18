-- oracle equivalent source sha1 cf499cee6f4107ee1ae27312cf1b92b8650333eb
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

create or replace function
lookup_xccdf_ident(system_in in varchar, identifier_in in varchar)
returns numeric
as
$$
declare
    xccdf_ident_id numeric;
    ident_sys_id numeric;
begin
    select id
      into ident_sys_id
      from rhnXccdfIdentSystem
     where system = system_in;
    if not found then
        ident_sys_id := nextval('rhn_xccdf_identsytem_id_seq');

        insert into rhnXccdfIdentSystem (id, system)
            values (ident_sys_id, system_in)
            on conflict do nothing;

        select id
            into strict ident_sys_id
            from rhnXccdfIdentSystem
            where system = system_in;
    end if;

    select id
      into xccdf_ident_id
      from rhnXccdfIdent
     where identsystem_id = ident_sys_id and identifier = identifier_in;
    if not found then
        xccdf_ident_id := nextval('rhn_xccdf_ident_id_seq');

        insert into rhnXccdfIdent (id, identsystem_id, identifier)
            values (xccdf_ident_id, ident_sys_id, identifier_in)
            on conflict do nothing;

        select id
            into strict xccdf_ident_id
            from rhnXccdfIdent
            where identsystem_id = ident_sys_id and identifier = identifier_in;
    end if;
    return xccdf_ident_id;
end;
$$ language plpgsql;
