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
--

create table
db_change_history
(
	bug_id		number
			constraint dc_history_bid_nn not null,
	seq_no		number
			constraint dc_history_sn_nn not null,
	date_applied	date
			constraint dc_history_da_nn not null,
	failed		char(1)
			constraint dc_history_f_nn not null,
   elapsed_seconds number (12,3) default 0
)
	storage ( freelists 16 )
	initrans 32;

COMMENT ON TABLE db_change_history IS
	'DBCHI  History of changes applied';

create index dc_history_bid_sn_idx
	on db_change_history( bug_id, seq_no )
	tablespace [[4m_tbs]]
	storage ( freelists 16 )
	initrans 32;
alter table db_change_history add constraint dc_history_bid_sn_fk
	foreign key ( bug_id, seq_no )
	references db_change_script( bug_id, seq_no )
	on delete cascade;

--
-- $Log$
-- Revision 1.1  2004/05/24 21:49:37  pjones
-- bugzilla: none -- db change schema scripts
--
