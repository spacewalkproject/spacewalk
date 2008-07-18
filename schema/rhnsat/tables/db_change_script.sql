--
-- $Id$
--

create table
db_change_script
(
	bug_id		number
			constraint dc_script_bid_nn not null,
	seq_no		number
			constraint dc_script_sn_nn not null,
	owner		varchar2(255)
			constraint dc_script_owner_nn not null,
	description	varchar2(4000),
	release		varchar2(255),
	run_as		varchar2(255),
   expect_fail char(1) default 0
)
	enable row movement
;

COMMENT ON TABLE db_change_script IS
	'DBCSC  Database change script meta-data';

create index dc_script_bid_sn_idx
	on db_change_script( bug_id, seq_no )
	tablespace [[64k_tbs]]
	storage ( freelists 16 )
	initrans 32;
alter table db_change_script add constraint dc_script_bid_sn_pk
	primary key ( bug_id, seq_no );

--
-- $Log$
-- Revision 1.1  2004/05/24 21:49:37  pjones
-- bugzilla: none -- db change schema scripts
--
