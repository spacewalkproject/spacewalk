--
-- $Id$
-- EXCLUDE: all
--
-- depsolver results
--

create table
rhnSolverResultsPrivate
(
	solver_instance_id	number
				constraint rhn_solverrp_siid_nn not null,
	final			char(1) default('N')
				constraint rhn_solverrp_final_nn not null
				constraint rhn_solverrp_final_ck
					check (final in ('Y','N')),
	name			varchar2(256)
				constraint rhn_solverrp_name_nn not null,
	name_id			number
				constraint rhn_solverrp_nid_fk
					references rhnPackageName(id),
	evr_id			number
				constraint rhn_sovlerrp_eid_fk
					references rhnPackageEVR(id),
	preference		number
				constraint rhn_solverrp_pref_nn not null
				constraint rhn_solverrp_pref_ck
					check (preference in (1,2,3))
)
	storage ( freelists 16 )
	initrans 32;

-- we use this to pick the most preferred one, which we then mark
-- as final.
create index rhn_solverrp_siid_n_p_idx
	on rhnSolverResultsPrivate ( solver_instance_id, name, preference )
	tablespace [[2m_tbs]]
	storage ( freelists 16 )
	initrans 32;

--
-- $Log$
-- Revision 1.1  2003/10/10 20:37:43  pjones
-- bugzilla: none
--
-- this solves for provides; not a full depsolver yet, but I'm
-- tired of it rattling around on my disk when it should be in CVS,
-- so I'm checking it in ;)
--
