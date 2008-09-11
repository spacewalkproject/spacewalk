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
