-- oracle equivalent source sha1 6ed9b49c15d481a26c6fe75f381205de0ff71c50
-- retrieved from ./1235013416/07c0bfbb6902a98d09f8a41896bd55900645af6b/schema/spacewalk/rhnsat/procs/delete_server_bulk.sql
--
-- Copyright (c) 2008--2010 Red Hat, Inc.
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
)
returns void as
$$
declare
	rec record;
begin
	for rec in select s.element as id
			from	rhnSet s
			where	s.user_id = user_id_in
			and s.label = 'system_list'loop
		perform delete_server(rec.id);
	end loop;
end;
$$ language plpgsql;

