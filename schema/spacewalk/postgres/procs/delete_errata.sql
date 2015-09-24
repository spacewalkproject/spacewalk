-- oracle equivalent source sha1 c741ff298550550675b31fc400bdfafd14dc59d8
--
-- Copyright (c) 2008--2015 Red Hat, Inc.
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
        delete from rhnErrataFile where errata_id = errata_id_in;
        delete from rhnErrataPackage where errata_id = errata_id_in;
        delete from rhnErrata where id = errata_id_in;
        delete from rhnErrataTmp where id = errata_id_in;
end;

$$ language plpgsql;

