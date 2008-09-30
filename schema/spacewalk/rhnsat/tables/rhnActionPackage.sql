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
--
--

create sequence rhn_act_p_id_seq;

create table
rhnActionPackage
(
	id		number
			constraint rhn_act_p_id_nn not null
			constraint rhn_act_p_id_pk primary key
				using index tablespace [[8m_tbs]],
	action_id	number
			constraint rhn_act_p_act_nn not null
			constraint rhn_act_p_act_fk
				references rhnAction(id) on delete cascade,
	parameter       varchar2(128) default 'upgrade'
			constraint rhn_act_p_param_nn not null
			constraint rhn_act_p_param_ck
			    CHECK(parameter IN ('upgrade', 'install', 'remove', 'downgrade')),
	name_id		number
			constraint rhn_act_p_name_nn not null
			constraint rhn_act_p_name_fk
				references rhnPackageName(id),
	evr_id		number
			constraint rhn_act_p_evr_fk
				references rhnPackageEvr(id),
	package_arch_id	number
			constraint rhn_act_p_paid_fk
				references rhnPackageArch(id)
)
	storage ( freelists 16 )
	enable row movement
	initrans 32;

create index rhn_act_p_aid_idx
	on rhnActionPackage(action_id)
	tablespace [[4m_tbs]]
	storage( pctincrease 1 freelists 16 )
	initrans 32
	nologging;

-- $Log$
-- Revision 1.18  2004/02/10 22:37:59  pjones
-- bugzilla: none -- more of the adding of rhnActionPackageAnswerfile
--
-- Revision 1.17  2004/02/10 22:33:16  pjones
-- bugzilla: none -- update rhnActionPackageAnswerfile to reference new pk
--
-- Revision 1.16  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.15  2002/11/14 17:31:37  pjones
-- more arch changes -- remove the old fields
--
-- Revision 1.14  2002/11/13 22:45:20  pjones
-- add appropriate arch fields.
-- haven't deleted the old ones yet though
--
-- Revision 1.13  2002/05/09 03:13:24  gafton
-- Fix storage clauses to have saner defaults for people at large...
--
-- Revision 1.12  2002/04/26 23:34:35  gafton
-- Add the required "on delete cascade" constraints to make these tables work
-- with the serverless actions cleanup scripts.
--
-- Chip, Peter, please make sure to integrate these changes into our devel,
-- QA and live anvrionments.
--
-- Revision 1.11  2002/04/26 15:05:09  pjones
-- trim logs that have satconish words in them
--
