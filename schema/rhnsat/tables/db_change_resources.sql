--
-- $Id$
--

create table
db_change_resources
(
	bug_id		number
			constraint dc_resources_bid_nn not null,
	seq_no		number
			constraint dc_resources_sn_nn not null,
	resource_type	varchar2(255)
			constraint dc_resources_rt_nn not null,
	resource_name	varchar2(255)
			constraint dc_resources_rn_nn not null,
	change_type	varchar2(255)
			constraint dc_resources_ct_nn not null
)
	storage ( freelists 16 )
	initrans 32;

create index dc_resources_bid_sn_idx
	on db_change_resources( bug_id, seq_no )
	tablespace [[2m_tbs]]
	storage ( freelists 16 )
	initrans 32;
alter table db_change_resources add constraint dc_resources_bid_sn_fk
	foreign key ( bug_id, seq_no )
	references db_change_script( bug_id, seq_no )
	on delete cascade;

create index dc_resources_rt_rn_idx
	on db_change_resources( resource_type, resource_name )
	tablespace [[4m_tbs]]
	storage ( freelists 16 )
	initrans 32;
alter table db_change_resources add constraint dc_resources_rt_rn_fk
	foreign key ( resource_type, resource_name )
	references db_change_resource_names( resource_type, resource_name )
	on delete cascade;

create index dc_resources_ct_idx
	on db_change_resources( change_type )
	tablespace [[2m_tbs]]
	storage ( freelists 16 )
	initrans 32;
alter table db_change_resources add constraint dc_resources_ct_fk
	foreign key ( change_type )
	references db_change_resource_changes( change_type )
	on delete cascade;

--
-- $Log$
-- Revision 1.1  2004/05/24 21:49:37  pjones
-- bugzilla: none -- db change schema scripts
--
