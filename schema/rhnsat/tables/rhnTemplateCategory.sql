--
-- $Id$
--

create sequence rhn_template_cat_id_seq;

create table
rhnTemplateCategory
(
	id		number
			constraint rhn_template_cat_id_nn not null,
	label		varchar2(64)
			constraint rhn_template_cat_label_nn not null,
	description	varchar2(512)
			constraint rhn_template_cat_desc_nn not null,
	created		date default(sysdate)
			constraint rhn_template_cat_created_nn not null,
	modified	date default(sysdate)
			constraint rhn_template_cat_modified_nn not null
)
	storage ( freelists 16 )
	initrans 32;

create index rhn_template_cat_id_idx
	on rhnTemplateCategory ( id )
	tablespace [[64k_tbs]]
	storage ( freelists 16 )
	initrans 32;
alter table rhnTemplateCategory add constraint rhn_template_cat_id_pk
	primary key ( id );
create index rhn_template_cat_label_id_idx
	on rhnTemplateCategory ( label, id )
	tablespace [[64k_tbs]]
	storage ( freelists 16 )
	initrans 32;
alter table rhnTemplateCategory add constraint rhn_template_cat_label_uq
	unique ( label );

create or replace trigger
rhn_template_cat_mod_trig
before insert or update on rhnTemplateCategory
for each row
begin
	:new.modified := sysdate;
end;
/
show errors

-- $Log$
-- Revision 1.1  2003/02/11 16:56:48  pjones
-- add string templating
--
