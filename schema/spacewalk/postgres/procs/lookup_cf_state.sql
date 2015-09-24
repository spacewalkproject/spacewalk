-- oracle equivalent source sha1 0bd250032eb24c601c377da3f75f93a2f242f596
-- retrieved from ./1235013416/07c0bfbb6902a98d09f8a41896bd55900645af6b/schema/spacewalk/rhnsat/procs/lookup_cf_state.sql
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
lookup_cf_state(
	label_in in varchar
) returns numeric 
as
$$
declare
	state_id numeric;
begin
	select	id
	into	state_id
	from	rhnConfigFileState
	where	label = label_in;

	return state_id;
end;
$$
language plpgsql
stable;

