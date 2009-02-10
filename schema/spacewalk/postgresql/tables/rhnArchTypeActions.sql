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
rhnArchTypeActions
(
	arch_type_id	numeric not null
			constraint rhn_archtypeacts_atid_fk
				references rhnArchType(id),
	action_style	varchar(64) not null,
	action_type_id	numeric not null
			constraint rhn_archtypeacts_actid_fk
				references rhnActionType(id),
	created		timestamp defalut(current_timestamp) not null,
	modified	timestamp defalut(current_timestamp) not null
)
--	enable row movement
  ;

create unique index rhn_archtypeacts_atid_as_uq
	on rhnArchTypeActions( arch_type_id, action_style )
--	tablespace [[64k_tbs]]
  ;


