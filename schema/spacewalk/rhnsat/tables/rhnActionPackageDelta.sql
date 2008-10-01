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

create table
rhnActionPackageDelta
(
	action_id		number
				constraint rhn_act_pd_aid_nn not null
				constraint rhn_act_pd_aid_fk
					references rhnAction(id)
					on delete cascade,
	package_delta_id	number
				constraint rhn_act_pd_pdid_nn not null
				constraint rhn_act_pd_pdid_fk
					references rhnPackageDelta(id)
					on delete cascade
)
	storage ( freelists 16 )
	enable row movement
	initrans 32;

create unique index rhn_act_pd_aid_pdid_idx
	on rhnActionPackageDelta(action_id, package_delta_id)
	tablespace [[8m_tbs]]
	storage ( pctincrease 1 freelists 16 )
	initrans 32
	nologging;

--
-- Revision 1.2  2003/07/01 14:09:11  pjones
-- bugzilla: 90374 -- fix missing constraint
--
-- Revision 1.1  2003/06/10 19:42:25  pjones
-- package delta actions
--
