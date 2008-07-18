--
-- $Id$
--

create sequence rhn_sproftype_id_seq;

create table
rhnServerProfileType
(
	id		number
			constraint rhn_sproftype_id_nn not null
			constraint rhn_sproftype_id_pk primary key
				using index tablespace [[64k_tbs]],
	label		varchar2(64)
			constraint rhn_sproftype_label_nn not null,
	name		varchar2(64)
			constraint rhn_sproftype_name_nn not null,
	created		date default(sysdate)
			constraint rhn_sproftype_creat_nn not null,
	modified	date default(sysdate)
			constraint rhn_sproftype_mod_nn not null
)
	storage ( freelists 16 )
	enable row movement
	initrans 32;

create index rhn_sproftype_label_id_idx
	on rhnServerProfileType( label, id )
	tablespace [[64k_tbs]]
	storage ( freelists 16 )
	initrans 32;

alter table rhnServerProfileType add constraint rhn_sproftype_label_uq
	unique ( label );

create or replace trigger
rhn_sproftype_mod_trig
before insert or update on rhnServerProfileType
for each row
begin
	:new.modified := sysdate;
end;
/
show errors

