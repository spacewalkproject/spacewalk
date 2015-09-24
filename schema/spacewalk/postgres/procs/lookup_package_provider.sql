-- oracle equivalent source sha1 e975a8f7548c5df7c107654118fba1455164a118
-- retrieved from ./1234445323/8c9aab43b76cfe2b234425a270944019bb987884/schema/spacewalk/rhnsat/procs/lookup_package_provider.sql
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
lookup_package_provider(name_in in varchar)
returns numeric
as
$$
declare
	package_provider_id numeric;
begin
	select id into package_provider_id from rhnPackageProvider where name = name_in;

	if not found then
		perform rhn_exception.raise_exception('package_provider_not_found');
	end if;

	return package_provider_id;
end;
$$ language plpgsql;

