--
-- $Id$
--


create table rhnConfigFileType
(
	id			number
				constraint rhn_conffiletype_id_nn not null
				constraint rhn_conffiletype_id_pk primary key
					using index tablespace [[2m_tbs]],
   label    varchar2(64)
            constraint rhn_conffiletype_label_nn not null,
   name     varchar2(256)
            constraint rhn_conffiletype_name_nn not null,
	created			date default(sysdate)
				constraint rhn_conffiletype_creat_nn not null,
	modified		date default(sysdate)
				constraint rhn_conffiletype_mod_nn not null
)
	storage ( freelists 16 )
	enable row movement
	initrans 32;

create or replace trigger
rhn_conffiletype_mod_trig
before insert or update on rhnConfigFile
for each row
begin
	:new.modified := sysdate;
end;
/
show errors

--
-- $Log$
-- Revision 1.2  2005/02/10 21:45:41  jslagle
-- Added documentation changes
--
--
