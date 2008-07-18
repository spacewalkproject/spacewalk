--
-- $Id$
--

create sequence rhn_reltype_id_seq;

create table
rhnRelationshipType
(
	id			number
				constraint rhn_reltype_id_nn not null,
	label			varchar2(32)
				constraint rhn_reltype_label_nn not null,
	description		varchar2(256),
	created			date default(sysdate)
				constraint rhn_reltype_created_nn not null,
	modified		date default(sysdate)
				constraint rhn_reltype_modified_nn not null
)
	storage ( freelists 16 )
	enable row movement
	initrans 32;

create index rhn_reltype_id_label_idx
	on rhnRelationshipType ( id, label )
	tablespace [[64k_tbs]]
	storage ( freelists 16 )
	initrans 32;
alter table rhnRelationshipType add constraint rhn_reltype_id_pk
	primary key ( id );

create index rhn_reltype_label_id_idx
	on rhnRelationshipType ( label, id )
	tablespace [[64k_tbs]]
	storage ( freelists 16 )
	initrans 32;
alter table rhnRelationshipType add constraint rhn_reltype_label_uq
	unique ( label );

create or replace trigger
rhn_reltype_mod_trig
before insert or update on rhnRelationshipType
for each row
begin
	:new.modified := sysdate;
end;
/
show errors
			
-- $Log$
-- Revision 1.1  2003/03/03 17:11:58  pjones
-- progeny relationships for channel and errata
--
