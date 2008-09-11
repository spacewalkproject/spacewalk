--
-- $Id$
--

create sequence rhn_confcontent_id_seq;

create table
rhnConfigContent
(
	id			number
				constraint rhn_confcontent_id_nn not null
				constraint rhn_confcontent_id_pk primary key
					using index tablespace [[2m_tbs]],
	contents		blob,
	file_size		number,
	md5sum			varchar2(64)
				constraint rhn_confcontent_md5_nn not null,
	is_binary	        char(1) default('N')
				constraint rhn_confcontent_isbin_nn not null
				constraint rhn_confcontent_isbin_ck
					check (is_binary in ('Y','N')),
	created			date default(sysdate)
				constraint rhn_confcontent_creat_nn not null,
	modified		date default(sysdate)
				constraint rhn_confcontent_mod_nn not null
)
	tablespace [[blob]]
	storage ( freelists 16 )
	initrans 32;

create index rhn_confcontent_md5_uq
	on rhnConfigContent( md5sum )
	tablespace [[2m_tbs]]
	storage ( freelists 16 )
	initrans 32;

create or replace trigger
rhn_confcontent_mod_trig
before insert or update on rhnConfigContent
for each row
begin
	:new.modified := sysdate;
end;
/
show errors

--
-- $Log$
-- Revision 1.4  2004/01/15 23:06:41  pjones
-- bugzilla: none -- make sure rhnConfigContent gets created in its own
-- tablespace
--
-- Revision 1.3  2003/11/13 23:59:16  cturner
-- bugzilla: 109861, add is_binary to config contents to flag if a file is to be considered binary by the web ui
--
-- Revision 1.2  2003/11/10 16:07:45  pjones
-- bugzilla: 109083 -- add file size
--
-- Revision 1.1  2003/11/07 18:05:42  pjones
-- bugzilla: 109083
-- kill old config file schema (currently just an exclude except for
--   rhnConfigFile which is replaced)
-- exclude the snapshot stuff, and comment it from triggers and procs
-- more to come, but the basic config file stuff is in.
--
