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
-- $Id$
-- EXCLUDE: all
--
-- depsolver that can be shared between web/backend/sql/whatever
--

create or replace package
rhn_depsolver
as
	rd_solver_instance_id number;

	function get_solver_instance_id
	return number;

	procedure set_solver_instance_id(
		solver_instance_id_in in number
	);

	function init(
		server_id_in in number,
		client_version_in in number
	) return number;

	procedure add_dep(
		name_in in varchar2
	);

	procedure finalize_results;

	procedure find_by_files;
	procedure find_by_provides;
	procedure find_by_packages;

	procedure solve_dependencies;

	procedure cleanup;

end rhn_depsolver;
/
show errors

-- $Log$
-- Revision 1.1  2003/10/10 20:37:43  pjones
-- bugzilla: none
--
-- this solves for provides; not a full depsolver yet, but I'm
-- tired of it rattling around on my disk when it should be in CVS,
-- so I'm checking it in ;)
--
