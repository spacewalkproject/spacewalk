--
-- $Id$
--

create sequence rhn_product_id_seq start with 101;

create table
rhnProduct
(
	id		number
			constraint rhn_product_id_nn not null,
	label		varchar2(128)
			constraint rhn_product_label_nn not null,
	name		varchar2(128)
			constraint rhn_product_name_nn not null,
	product_line_id	number
        		constraint rhn_product_cat_nn not null 
			constraint rhn_product_cat_fk
				references rhnProductLine(id)
				on delete cascade,
	last_modified	date default (sysdate)
			constraint rhn_product_lm_nn not null,
	created		date default (sysdate)
			constraint rhn_product_created_nn not null,
	modified	date default (sysdate)
			constraint rhn_product_modified_nn not null
)
	storage ( freelists 16 )
	initrans 32;

create index rhn_product_id_idx
	on rhnProduct(id)
	tablespace [[64k_tbs]]
	storage ( freelists 16 )
	initrans 32;
alter table rhnProduct add constraint rhn_product_id_pk
	primary key ( id );

create index rhn_product_label_idx
	on rhnProduct(label)
	tablespace [[64k_tbs]]
	storage ( freelists 16 )
	initrans 32;
alter table rhnProduct add constraint rhn_product_label_uq
	unique ( label );

create index rhn_product_name_idx
	on rhnProduct(name)
	tablespace [[64k_tbs]]
	storage ( freelists 16 )
	initrans 32;
alter table rhnProduct add constraint rhn_product_name_uq
	unique ( name );

create or replace trigger
rhn_product_mod_trig
before insert or update on rhnProduct
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
