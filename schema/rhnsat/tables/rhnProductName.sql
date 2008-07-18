create table rhnProductName
(
    id       number
             constraint rhn_productname_id_nn not null
             constraint rhn_productname_id_pk primary key,
    label    varchar2(128)
             constraint rhn_productname_lbl_nn not null,
    name     varchar2(128)
             constraint rhn_productname_name_nn not null,
    created  date default(sysdate)
             constraint product_name_created_nn not null,
    modified date default(sysdate)
             constraint product_name_modified_nn not null
)
	storage (freelists 16)
	enable row movement
	initrans 32;

create sequence rhn_productname_id_seq start with 101;

create unique index rhn_productname_label_uq
on rhnProductName(label)
storage (freelists 16)
initrans 32;

create unique index rhn_productname_name_uq
on rhnProductName(name)
storage (freelists 16)
initrans 32;

create or replace trigger product_name_mod_trig
before insert or update on rhnProductName
for each row
begin
    :new.modified := sysdate;
end;
/
show errors
