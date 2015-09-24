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
lookup_package_key_type(label_in in varchar2)
return number
is
	package_key_type_id number;
begin
	select id into package_key_type_id from rhnPackageKeyType where label = label_in;
	return package_key_type_id;
exception
	when no_data_found then
		rhn_exception.raise_exception('package_key_type_not_found');
end;
/
show errors
