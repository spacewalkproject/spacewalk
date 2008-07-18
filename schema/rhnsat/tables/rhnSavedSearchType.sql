--
-- $Id$
--
-- this table holds the types for saved searches

create table
rhnSavedSearchType
(
	id		number
			constraint rhn_sstype_id_nn not null,
	label		varchar2(8)
			constraint rhn_sstype_label_nn not null,
	created		date default(sysdate)
			constraint rhn_sstype_created_nn not null,
	modified	date default(sysdate)
			constraint rhn_sstype_modified_nn not null
)
	storage( freelists 16 )
	enable row movement
	initrans 32;

create sequence rhn_sstype_id_seq;

create index rhn_sstype_id_label_idx
	on rhnSavedSearchType(id,label)
	tablespace [[64k_tbs]]
	storage( freelists 16 )
	initrans 32;
alter table rhnSavedSearchType add
	constraint rhn_sstype_id_pk primary key (id);

create index rhn_sstype_label_id_idx
	on rhnSavedSearchType(label,id)
	tablespace [[64k_tbs]]
	storage( freelists 16 )
	initrans 32;
alter table rhnSavedSearchType add
	constraint rhn_sstype_label_uq unique (label);

insert into rhnSavedSearchType (id, label)
	values (rhn_sstype_id_seq.nextval, 'system');
insert into rhnSavedSearchType (id, label)
	values (rhn_sstype_id_seq.nextval, 'package');
insert into rhnSavedSearchType (id, label)
	values (rhn_sstype_id_seq.nextval, 'errata');
commit;

-- $Log$
-- Revision 1.2  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.1  2002/11/15 20:51:26  pjones
-- add saved search schema
--
