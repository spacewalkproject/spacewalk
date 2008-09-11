--
-- $Id$
--

create sequence rhn_confchantype_id_seq;

create table
rhnConfigChannelType
(
	id		number
			constraint rhn_confchantype_id_nn not null
			constraint rhn_confchantype_id_pk primary key
				using index tablespace [[64k_tbs]],
	label		varchar2(64)
			constraint rhn_confchantype_label_nn not null,
	name		varchar2(64)
			constraint rhn_confchantype_name_nn not null,
        priority        number default(0)
	                constraint rhn_confchantype_pri_nn not null,
	created		date default(sysdate)
			constraint rhn_confchantype_creat_nn not null,
	modified	date default(sysdate)
			constraint rhn_confchantype_mod_nn not null
)
	storage ( freelists 16 )
	initrans 32;

create index rhn_confchantype_label_id_idx
	on rhnConfigChannelType( label, id )
	tablespace [[64k_tbs]]
	storage ( freelists 16 )
	initrans 32;

alter table rhnConfigChannelType add constraint rhn_confchantype_label_uq
	unique ( label );

create or replace trigger
rhn_confchantype_mod_trig
before insert or update on rhnConfigChannelType
for each row
begin
	:new.modified := sysdate;
end;
/
show errors

--
-- $Log$
-- Revision 1.2  2003/11/09 20:50:38  cturner
-- toss priority back in... no idea if this is right or not. pjones, please berate me if not :)
--
-- Revision 1.1  2003/11/07 18:05:42  pjones
-- bugzilla: 109083
-- kill old config file schema (currently just an exclude except for
--   rhnConfigFile which is replaced)
-- exclude the snapshot stuff, and comment it from triggers and procs
-- more to come, but the basic config file stuff is in.
--
