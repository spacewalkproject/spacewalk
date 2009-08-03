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

create or replace procedure
delete_errata (
	errata_id_in in number
) is
begin
	delete from rhnServerNeededCache where errata_id = errata_id_in;
	delete from rhnPaidErrataTempCache where errata_id = errata_id_in;
	delete from rhnErrataFile where errata_id = errata_id_in;
	delete from rhnErrataPackage where errata_id = errata_id_in;
	delete from rhnErrata where id = errata_id_in;
	delete from rhnErrataTmp where id = errata_id_in;
end delete_errata;
/
show errors

--
-- Revision 1.4  2004/12/04 21:24:51  cturner
-- bugzilla: 141768, and another one.  pre-delete from rhnErrataPackage to prevent trigger madness
--
-- Revision 1.3  2004/12/04 21:14:25  cturner
-- bugzilla: 141768, pre-delete from rhnErrataFile to prevent trigger madness
--
-- Revision 1.2  2004/09/13 20:56:44  pjones
-- bugzilla: 117597 --
-- 1) make the constraints look like they do in prod.
-- 2) remove the sat-only errata_id index
-- 3) remove duplicate server_id based index.
-- 4) make a new index that starts with errata
--
-- Revision 1.1  2003/08/15 20:45:44  pjones
-- bugzilla: 102263
--
-- delete_errata()
--
