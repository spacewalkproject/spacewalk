--
-- $Id$
--

create table
rhnServerArch
(
	id		number
			constraint rhn_sarch_id_nn not null,
	label		varchar2(64)
			constraint rhn_sarch_label_nn not null,
	name		varchar2(64)
			constraint rhn_sarch_name_nn not null,
	arch_type_id	number
			constraint rhn_sarch_atid_nn not null
			constraint rhn_sarch_atid_fk
				references rhnArchType(id),
	created		date default(sysdate)
			constraint rhn_sarch_created_nn not null,
	modified	date default(sysdate)
			constraint rhn_sarch_modified_nn not null
)
	storage( freelists 16 )
	enable row movement
	initrans 32;

create sequence rhn_server_arch_id_seq start with 1000;

-- these must be in this order.
create index rhn_sarch_id_l_n_idx
	on rhnServerArch(id,label,name)
	tablespace [[2m_tbs]]
	storage( freelists 16 )
	initrans 32;
alter table rhnServerArch add constraint rhn_sarch_id_pk primary key (id);

-- these too.
create index rhn_sarch_l_id_n_idx
	on rhnServerArch(label,id,name)
	tablespace [[2m_tbs]]
	storage( freelists 16 )
	initrans 32;
alter table rhnServerArch add constraint rhn_sarch_label_uq unique ( label );

create or replace trigger
rhn_sarch_mod_trig
before insert or update on rhnServerArch
for each row
begin
        :new.modified := sysdate;
end;
/
show errors

-- $Log$
-- Revision 1.5  2004/02/05 18:45:58  pjones
-- bugzilla: 115009 -- make the labels really big
--
-- Revision 1.4  2004/02/05 17:33:12  pjones
-- bugzilla: 115009 -- rhnArchType is new, and has changes to go with it
--
-- Revision 1.3  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.2  2002/11/13 22:30:53  misa
-- server arch stuff: added sequence and data
--
-- Revision 1.1  2002/11/13 21:50:21  pjones
-- new arch system
--
