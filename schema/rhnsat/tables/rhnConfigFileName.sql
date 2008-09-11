--
-- $Id$
--

create sequence rhn_cfname_id_seq;

create table
rhnConfigFileName
(
	id		number
			constraint rhn_cfname_id_nn not null,
	path		varchar2(1024)
			constraint rhn_cfname_path_nn not null,
	created		date default(sysdate)
			constraint rhn_cfname_created_nn not null,
	modified	date default(sysdate)
			constraint rhn_cfname_modified_nn not null
)
	storage ( freelists 16 )
	initrans 32;

create index rhn_cfname_id_pk
	on rhnConfigFileName ( id )
	tablespace [[2m_tbs]]
	storage ( freelists 16 )
	initrans 32;
alter table rhnConfigFileName add constraint
	rhn_cfname_id_pk primary key ( id );

create unique index rhn_cfname_path_uq
	on rhnConfigFileName ( path )
	tablespace [[4m_tbs]]
	storage ( freelists 16 )
	initrans 32;

create or replace trigger
rhn_cfname_mod_trig
before insert or update on rhnConfigFileName
for each row
begin
	:new.modified := sysdate;
end;
/
	
-- $Log$
-- Revision 1.1  2003/07/30 23:37:21  pjones
-- bugzilla: none
-- config file schema
--
