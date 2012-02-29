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

create or replace function insert_xccdf_ident_system(system_in varchar2)
return number
is
    pragma autonomous_transaction;
    ident_sys_id number;
begin
    insert into rhnXccdfIdentSystem (id, system)
    values (rhn_xccdf_identsytem_id_seq.nextval, system_in) returning id into ident_sys_id;
    commit;
    return ident_sys_id;
end;
/
show errors
