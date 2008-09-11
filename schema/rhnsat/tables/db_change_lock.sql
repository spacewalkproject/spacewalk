--
-- $Id$
--

create table
db_change_lock
(
	locked			char(1)
				constraint dc_lock_locked_nn not null,
	bug_id			number
				constraint dc_lock_bid_nn not null,
	seq_no			number
				constraint dc_lock_sn_nn not null,
	owner			varchar2(255)
				constraint dc_lock_owner_nn not null,
	lock_date		date
				constraint dc_lock_ld_nn not null
)
	storage ( freelists 16 )
	initrans 32;

COMMENT ON TABLE db_change_lock IS
	'DBCLK  Database change lock for synchronization ';

create unique index dc_lock_locked_uq
	on db_change_lock( locked )
	tablespace [[4m_tbs]]
	storage ( freelists 16 )
	initrans 32;

--
-- $Log$
-- Revision 1.1  2004/05/24 21:49:37  pjones
-- bugzilla: none -- db change schema scripts
--
