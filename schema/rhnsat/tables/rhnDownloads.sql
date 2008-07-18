--
-- $Id$
--

create table
rhnDownloads
(
	id		number
			constraint rhn_dl_id_nn not null
			constraint rhn_dl_id_pk primary key,
	channel_family_id  number
			constraint rhn_dl_cfid_nn not null
			constraint rhn_dl_cfid_fk
				references rhnChannelFamily(id),
	file_id 	number
			constraint rhn_dl_fid_nn not null
			constraint rhn_dl_fid_fk
			     	references rhnFile(id),
        name            varchar2(128)
	    	    	constraint rhn_dl_name_nn not null,			
        category        varchar2(128)
	    	    	constraint rhn_dl_cat_nn not null,
	ordering        number
			constraint rhn_dl_ord_nn not null,
        download_type  	number
			constraint rhn_dl_dltype_fk
				references rhnDownloadType(id),
	created		date default(sysdate)
			constraint rhn_dl_created_nn not null,
	modified	date default(sysdate)
			constraint rhn_dl_modified_nn not null,
	release_notes_url	varchar2(512)
)
	storage ( freelists 16 )
	enable row movement
	initrans 32;

create sequence rhn_download_id_seq;

create or replace trigger
rhn_download_mod_trig
before insert or update on rhnDownloads
for each row
begin
	:new.modified := sysdate;
end;
/
show errors

-- $Log$
-- Revision 1.11  2005/02/22 16:45:46  jslagle
-- bz #148015
-- Changed release_notes to release_notes_url to bring satellite in line with hosted
--
-- Revision 1.10  2004/10/05 20:45:05  jjb
-- bugzilla 120630 - changed spaces to tabs in my last mod to conform with rest of files
--
-- Revision 1.9  2004/10/05 20:41:28  jjb
-- bugzilla: 120630 - add a column for release notes url
--
-- Revision 1.8  2003/08/12 16:31:39  pjones
-- bugzilla: none
-- add constraint name for the rhnDownloadType foreign key
--
-- Revision 1.7  2003/08/05 15:59:05  bretm
-- bugzilla: 98685
--
-- add download_type
--
-- Revision 1.6  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.5  2002/05/10 21:54:44  pjones
-- add rhnFAQClass, and make it a dep for rhnFAQ
-- add grants where appropriate
-- add cvs id/log where it's been missed
-- split data out where appropriate
-- add excludes where appropriate
-- make sure it still builds (at least as sat).
--
