--
-- $Id$
--

create sequence rhn_prod_line_id_seq start with 101;

create table
rhnProductLine
(
	id		number
			constraint rhn_prod_line_id_nn not null,
	label		varchar2(128)
			constraint rhn_prod_line_label_nn not null,
	name		varchar2(128)
			constraint rhn_prod_line_name_nn not null,
	last_modified	date default (sysdate)
			constraint rhn_prod_line_lm_nn not null,
	created		date default (sysdate)
			constraint rhn_prod_line_created_nn not null,
	modified	date default (sysdate)
			constraint rhn_prod_line_modified_nn not null
)
	storage ( freelists 16 )
	enable row movement
	initrans 32;

create index rhn_prod_line_id_idx
	on rhnProductLine ( id )
	tablespace [[64k_tbs]]
	storage ( freelists 16 )
	initrans 32;
alter table rhnProductLine add constraint rhn_prod_line_id_pk
	primary key ( id );

create index rhn_prod_line_label_idx
	on rhnProductLine(label)
	tablespace [[64k_tbs]]
	storage ( freelists 16 )
	initrans 32;
alter table rhnProductLine add constraint rhn_prod_line_label_uq
	unique ( label );

create index rhn_prod_line_name_idx
	on rhnProductLine(name)
	tablespace [[64k_tbs]]
	storage ( freelists 16 )
	initrans 32;
alter table rhnProductLine add constraint rhn_prod_line_name_uq
	unique ( name );

create or replace trigger
rhn_prod_line_mod_trig
before insert or update on rhnProductLine
for each row
begin
	:new.modified := sysdate;
	:new.last_modified := sysdate;
end;
/
show errors

-- $Log$
-- Revision 1.1  2003/03/11 00:37:16  pjones
-- bugzilla: 85516
--
-- public errata schema checkin
--
-- bretm, you owe me cookies.
--
