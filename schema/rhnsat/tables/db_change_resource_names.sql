--
-- $Id$
--

create table
db_change_resource_names
(
	resource_type	varchar2(255)
			constraint dc_resourcename_rt_nn not null
			constraint dc_resourcename_rt_fk
				references db_change_resource_types(resource_type),
	resource_name	varchar2(255)
			constraint dc_resourcename_rn_nn not null
)
	storage ( freelists 16 )
	initrans 32;

COMMENT ON TABLE db_change_resource_names IS
	'DBCRN  Resources that can be changed (e.g. table WEB_USER)';

create index dc_resourcename_rt_rn_idx
	on db_change_resource_names( resource_type, resource_name )
	tablespace [[8m_tbs]]
	storage ( freelists 16 )
	initrans 32;
alter table db_change_resource_names add constraint dc_resourcename_rt_rn_pk
	primary key ( resource_type, resource_name );

--
-- $Log$
-- Revision 1.1  2004/05/24 21:49:37  pjones
-- bugzilla: none -- db change schema scripts
--
