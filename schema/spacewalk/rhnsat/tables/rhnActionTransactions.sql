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
	action_id	number
			constraint rhn_at_aid_nn not null
			constraint rhn_at_aid_fk
				references rhnAction(id)
				on delete cascade,
	from_trans_id	number
			constraint rhn_at_ftid_nn not null
			constraint rhn_at_ftid_fk
				references rhnTransaction(id)
				on delete cascade,
	to_trans_id	number
			constraint rhn_at_ttid_nn not null
			constraint rhn_at_ttid_fk
				references rhnTransaction(id)
				on delete cascade
)
	enable row movement
  ;

create unique index rhn_at_aid_ftid_ttid_uq
	on rhnActionTransactions(action_id, from_trans_id, to_trans_id)
	tablespace [[64k_tbs]]
  ;

create index rhn_act_trans_from_to_idx
on rhnActionTransactions ( from_trans_id, to_trans_id, action_id )
   tablespace [[64k_tbs]]
  ;


create index rhn_act_trans_to_from_idx
on rhnActionTransactions ( to_trans_id, from_trans_id, action_id )
   tablespace [[64k_tbs]]
  ;

--
-- Revision 1.5  2003/08/25 14:59:44  pjones
-- bugzilla: none
--
-- fix rhnAction cascades
--
-- Revision 1.4  2003/08/05 16:33:12  bretm
-- bugzilla:  101595
--
-- deleting a system that had scheduled action transactions would hork, needed delete cascades
--
-- Revision 1.3  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.2  2002/12/13 19:49:10  cturner
-- first pass at conversion script
--
-- Revision 1.1  2002/10/22 20:38:57  pjones
-- map transactions to actions in rhnActionTransactions
--
				
