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
