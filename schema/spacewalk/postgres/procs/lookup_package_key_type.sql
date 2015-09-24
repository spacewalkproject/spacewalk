-- oracle equivalent source sha1 a348171ec851a9238ee3f38a48407e2d70521bf1
-- retrieved from ./1234445323/8c9aab43b76cfe2b234425a270944019bb987884/schema/spacewalk/rhnsat/procs/lookup_package_key_type.sql
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
lookup_package_key_type(label_in in varchar)
returns numeric
as
$$
declare
	package_key_type_id numeric;
begin
	select id into package_key_type_id from rhnPackageKeyType where label = label_in;

	if not found then
		perform rhn_exception.raise_exception('package_key_type_not_found');
	end if;

	return package_key_type_id;
end;
$$
language plpgsql;

