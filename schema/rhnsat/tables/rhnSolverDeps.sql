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
