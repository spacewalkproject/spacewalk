-- oracle equivalent source sha1 21bc8f72e16e20e6f82872f19143b8c43c937ba6
-- retrieved from ./1235561447/a7740e6945947b753ef3359998c3a103d464f765/schema/spacewalk/rhnsat/procs/delete_errata.sql
--
-- Copyright (c) 2008 Red Hat, Inc.
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
--
--
--
create or replace function
delete_errata (
        errata_id_in in numeric
) returns void as
$$
begin
        delete from rhnServerNeededCache where errata_id = errata_id_in;
        delete from rhnPaidErrataTempCache where errata_id = errata_id_in;
        delete from rhnErrataFile where errata_id = errata_id_in;
        delete from rhnErrataPackage where errata_id = errata_id_in;
        delete from rhnErrata where id = errata_id_in;
        delete from rhnErrataTmp where id = errata_id_in;
end;

$$ language plpgsql;

