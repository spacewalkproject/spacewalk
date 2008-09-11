--
-- $Id$
--

create table
db_change_ignore_errs
(
	bug_id		number
			constraint dc_ignoreerrs_bid_nn not null,
	seq_no		number
			constraint dc_ignoreerrs_sn_nn not null,
	err_no		number
			constraint dc_ignoreerrs_en_nn not null
)
	storage ( freelists 16 )
	initrans 32;

COMMENT ON TABLE db_change_ignore_errs IS
	'DBCIE  Error numbers that may be safely ignored ';

create index dc_ignoreerrs_bid_sn_idx
	on db_change_ignore_errs( bug_id, seq_no )
	tablespace [[8m_tbs]]
	storage ( freelists 16 )
	initrans 32;
alter table db_change_ignore_errs add constraint dc_ignorerrs_bid_sn_fk
	foreign key ( bug_id, seq_no )
	references db_change_script( bug_id, seq_no )
	on delete cascade;

--
-- $Log$
-- Revision 1.1  2004/05/24 21:49:37  pjones
-- bugzilla: none -- db change schema scripts
--
