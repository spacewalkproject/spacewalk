-- oracle equivalent source sha1 fc69313728322bbff58aa5e7b9ca861d346e0bcc
-- retrieved from ./1241057068/d2f16725f65bddae85cd4782cd82e0c84c0a776d/schema/spacewalk/oracle/procs/lookup_arch_type.sql
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
lookup_arch_type(label_in in varchar)
returns numeric
as
$$
declare
	arch_type_id numeric;
begin
	select id into arch_type_id from rhnArchType where label = label_in;

	if not found then
		perform rhn_exception.raise_exception('arch_type_not_found');
	end if;

	return arch_type_id;
end;
$$ language plpgsql;
