--
-- $Id$
--

create sequence rhn_ocstngs_type_id_seq;

create table
rhnOrgChannelSettingsType
(
	id		number
			constraint rhn_ocstngs_type_id_nn not null
			constraint rhn_ocstngs_type_id_pk primary key,
	label		varchar2(32)
			constraint rhn_ocstngs_type_label_nn not null,
	created		date default(sysdate)
			constraint rhn_ocstngs_type_created_nn not null,
	modified	date default(sysdate)
			constraint rhn_ocstngs_type_modified_nn not null
)
	storage ( freelists 16 )
	initrans 32;

create index rhn_ocstngs_type_l_id_idx
	on rhnOrgChannelSettingsType( label, id )
	tablespace [[64k_tbs]]
	storage ( freelists 16 )
	initrans 32;

create or replace trigger
rhn_orgcsettings_type_mod_trig
before insert or update on rhnOrgChannelSettingsType
for each row
begin
	:new.modified := sysdate;
end;
/
show errors

-- $Log$
-- Revision 1.1  2003/07/17 18:07:18  pjones
-- bugzilla: none
--
-- change this to be the new way which was discussed
--
