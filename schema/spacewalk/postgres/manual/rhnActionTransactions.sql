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
-- transaction Ids for a rollback action

create table
rhnActionTransactions
(
	action_id	numeric not null
			constraint rhn_at_aid_fk
				references rhnAction(id)
				on delete cascade,
	from_trans_id	numeric not null
			constraint rhn_at_ftid_fk
				references rhnTransaction(id)
				on delete cascade,
	to_trans_id	numeric not null
			constraint rhn_at_ttid_fk
				references rhnTransaction(id)
				on delete cascade,

	constraint rhn_at_aid_ftid_ttid_uq unique (action_id, from_trans_id, to_trans_id)
--		using index tablespace [[64k_tbs]]
);

create index rhn_act_trans_from_to_idx
on rhnActionTransactions ( from_trans_id, to_trans_id, action_id )
--   tablespace [[64k_tbs]]
;

create index rhn_act_trans_to_from_idx
on rhnActionTransactions ( to_trans_id, from_trans_id, action_id )
--   tablespace [[64k_tbs]]
;

