--
-- $Id$
--

create table
db_change_resource_types
(
	resource_type		varchar2(255)
				constraint dc_resourcetype_rt_nn not null
				constraint dc_resourcetype_rt_pk primary key
					using index tablespace [[64k_tbs]]
)
	storage ( freelists 16 )
	enable row movement
	initrans 32;

COMMENT ON TABLE db_change_resource_types IS
	'DBCRT  Types of resources that can be changed (table, view, stored procedure, etc.)';

--
-- $Log$
-- Revision 1.1  2004/05/24 21:49:37  pjones
-- bugzilla: none -- db change schema scripts
--
