--
-- $Id$
-- EXCLUDE: all
--

create sequence rhn_solver_instance_id_seq;

create table
rhnSolverDeps
(
	solver_instance_id	number
				constraint rhn_depsolver_siid_nn not null,
	name			varchar2(256)
				constraint rhn_depsolver_name_nn not null
)
	storage ( freelists 16 )
	initrans 32;

create unique index rhn_solverdeps_siid_name_uq
	on rhnSolverDeps ( solver_instance_id, name )
	tablespace [[2m_tbs]]
	storage ( freelists 16 )
	initrans 32;

-- $Log$
-- Revision 1.1  2003/10/10 20:37:43  pjones
-- bugzilla: none
--
-- this solves for provides; not a full depsolver yet, but I'm
-- tired of it rattling around on my disk when it should be in CVS,
-- so I'm checking it in ;)
--
