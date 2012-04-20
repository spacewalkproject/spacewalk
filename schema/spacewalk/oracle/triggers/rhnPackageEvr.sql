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

create or replace trigger
rhn_pack_evr_no_updel_trig
before update or delete on rhnPackageEvr
declare
	operation varchar(20);
begin
	if updating then
		operation := 'UPDATE';
	elsif deleting then
		operation := 'DELETE';
	else
		raise_application_error(-20051, 'Unknown operation (no UPDATE and no DELETE)');
	end if;
	raise_application_error(-20050, 'Permission denied: ' || operation || ' is not allowed on RHNPACKAGEEVR');
end;
/
show errors
