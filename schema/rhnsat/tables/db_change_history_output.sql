--
-- $Id$
--

create table
db_change_history_output
(
	bug_id		number
			constraint dc_historyoutput_bid_nn not null,
	seq_no		number
			constraint dc_historyoutput_sn_nn not null,
	line_no		number
			constraint dc_historyoutput_ln_nn not null,
	line		varchar2(1000)
			constraint dc_historyoutput_l_nn not null
)
	storage ( freelists 16 )
	initrans 32;

COMMENT ON TABLE db_change_history_output IS
	'DBCHO  Database change output lines';

create index dc_historyoutput_bid_sn_idx
	on db_change_history_output( bug_id, seq_no )
	tablespace [[8m_tbs]]
	storage ( freelists 16 )
	initrans 32;
alter table db_change_history_output add constraint dc_historyoutput_bid_sn_fk
	foreign key ( bug_id, seq_no )
	references db_change_script( bug_id, seq_no )
	on delete cascade;

