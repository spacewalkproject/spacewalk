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

create or replace function insert_package_nevra(
    name_id_in in varchar2,
    evr_id_in in varchar2,
    package_arch_id_in in varchar2
) return number
is
    pragma autonomous_transaction;
    nevra_id number;
begin
    insert into rhnPackageNEVRA(id, name_id, evr_id, package_arch_id) values
        (rhn_pkgnevra_id_seq.nextval,
         name_id_in,
         evr_id_in,
         package_arch_id_in) returning id into nevra_id;
    commit;
    return nevra_id;
end;
/
show errors
