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
	id		numeric not null
			constraint rhn_act_p_id_pk primary key
--				using index tablespace [[8m_tbs]],
	action_id	numeric not null
			constraint rhn_act_p_act_fk
				references rhnAction(id) on delete cascade,
	parameter       varchar(128) default 'upgrade' not null
			constraint rhn_act_p_param_ck
			    CHECK(parameter IN ('upgrade', 'install', 'remove', 'downgrade')),
	name_id		numeric not null
			constraint rhn_act_p_name_fk
				references rhnPackageName(id),
	evr_id		numeric
			constraint rhn_act_p_evr_fk
				references rhnPackageEvr(id),
	package_arch_id	numeric
			constraint rhn_act_p_paid_fk
				references rhnPackageArch(id)
);

create index rhn_act_p_aid_idx
	on rhnActionPackage(action_id)
--	tablespace [[4m_tbs]]
;

