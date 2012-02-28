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

create or replace function insert_package_capability(name_in in varchar2, version_in in varchar2 default null)
return number
is
    pragma autonomous_transaction;
    name_id number;
begin
    insert into rhnPackageCapability (id, name, version)
        values (rhn_pkg_capability_id_seq.nextval, name_in, version_in) returning id into name_id;
    commit;
    return name_id;
end;
/
