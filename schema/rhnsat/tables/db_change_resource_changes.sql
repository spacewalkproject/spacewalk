--
-- $Id$
-- 

create table
db_change_resource_changes
(
	change_type		varchar2(10)
				constraint dc_resourcechange_type_nn not null
)
	storage ( freelists 16 )
	enable row movement
	initrans 32;

COMMENT ON TABLE db_change_resource_changes IS
	'DBCRC Recognized types of resource changes';

create index dc_resourcechange_type_idx
	on db_change_resource_changes( change_type )
	tablespace [[64k_tbs]]
	storage ( freelists 16 )
	initrans 32;
alter table db_change_resource_changes add constraint dc_resourcechange_type_pk
	primary key ( change_type );

--
-- $Log$
-- Revision 1.1  2004/05/24 21:49:37  pjones
-- bugzilla: none -- db change schema scripts
--
