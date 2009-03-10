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
	action_id		numeric not null
				constraint rhn_act_pd_aid_fk
					references rhnAction(id)
					on delete cascade,
	package_delta_id	numeric not null
				constraint rhn_act_pd_pdid_fk
					references rhnPackageDelta(id)
					on delete cascade,

	constraint rhn_act_pd_aid_pdid_idx unique (action_id, package_delta_id)
--		using index tablespace [[8m_tbs]]
);

