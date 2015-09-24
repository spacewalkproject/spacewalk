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

-- This finds the first valid instance of a path in a server's config channels
--
-- We could probably change this to a view if we need it to be a bit faster,
-- but right now it's a relatively uncommon code path, so I'm going to be
-- lazy and do it the easy way

create or replace function
lookup_first_matching_cf (
	server_id_in in number,
	path_in in varchar2
) return number is
	retval number := -1;
begin
	begin
		select	a.cfid
		into	retval
		from	(
			select	b.cfid,
				rownum rn
			from (
				-- We don't need to test latest any more, 
				-- because we're not looking for a revision at
				-- all, just the file with the right path
				select	cf.id cfid
				from	rhnConfigFile		cf,
					rhnConfigFileName	cfn,
					rhnConfigChannel	cc,
					rhnServerConfigChannel	scc
				where	scc.server_id = server_id_in
					and scc.config_channel_id = cc.id
					and cc.id = cf.config_channel_id
					and cf.state_id != lookup_cf_state('dead')
					and cfn.path = path_in
					and cf.config_file_name_id = cfn.id
				order by scc.position asc
				) b
			) a
		where a.rn = 1;
	exception
		when no_data_found then
			null;
	end;
	return retval;
end lookup_first_matching_cf;
/
show errors
