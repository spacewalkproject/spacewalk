--
-- $Id$
-- EXCLUDE: all
--

create or replace view
rhnSolverResults
as
select	srp.name		dep,
	n.name			name,
	e.epoch			epoch,
	e.version		version,
	e.release		release,
	srp.preference		preference
from	rhnPackageName		n,
	rhnPackageEVR		e,
	rhnSolverResultsPrivate	srp
where	srp.solver_instance_id = rhn_depsolver.get_solver_instance_id()
	and srp.final = 'Y'
	and srp.name_id = n.id
	and srp.evr_id = e.id;

--
-- $Log$
-- Revision 1.1  2003/10/10 20:37:43  pjones
-- bugzilla: none
--
-- this solves for provides; not a full depsolver yet, but I'm
-- tired of it rattling around on my disk when it should be in CVS,
-- so I'm checking it in ;)
--
