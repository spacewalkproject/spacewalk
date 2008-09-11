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
