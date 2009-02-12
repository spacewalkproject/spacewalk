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
-- Revision 1.25  2004/11/01 17:53:03  pjones
-- bugzilla: 136124 -- Fix the "no data found" when deleting rhn_sat_cluster
--
--
--
--
-- This deletes a list of server. 
--

create or replace
function delete_server_bulk (
	user_id_in in numeric
) as
$$
declare
	systems cursor for
		select	s.element id
		from	rhnSet s
		where	s.user_id = user_id_in
			and s.label = 'system_list';
begin
	for s in systems loop
                delete_server(s.id);
	end loop;
end delete_server_bulk;
$$ language plpgsql;

