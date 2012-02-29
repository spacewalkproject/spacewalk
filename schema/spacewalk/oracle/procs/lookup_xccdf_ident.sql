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
lookup_xccdf_ident(system_in in varchar2, identifier_in in varchar2)
return number
is
    pragma autonomous_transaction;
    xccdf_ident_id number;
    ident_sys_id number;
begin
    begin
        select id
          into ident_sys_id
          from rhnXccdfIdentSystem
         where system = system_in;
    exception when no_data_found then
        begin
            ident_sys_id := insert_xccdf_ident_system(system_in);
        exception when dup_val_on_index then
            select id
              into ident_sys_id
              from rhnXccdfIdentSystem
             where system = system_in;
        end;
    end;

    select id
      into xccdf_ident_id
      from rhnXccdfIdent
     where identsystem_id = ident_sys_id and identifier = identifier_in;
    return xccdf_ident_id;
exception when no_data_found then
    begin
        xccdf_ident_id := insert_xccdf_ident(ident_sys_id, identifier_in);
    exception when dup_val_on_index then
        select id
          into xccdf_ident_id
          from rhnXccdfIdent
         where identsystem_id = ident_sys_id and identifier = identifier_in;
    end;
    return xccdf_ident_id;
end lookup_xccdf_ident;
/
show errors
