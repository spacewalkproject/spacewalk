--
-- $Id$
--

create table
rhnErrataFilePackageTmp
(
	package_id	number
			constraint rhn_efileptmp_pid_nn not null 
			constraint rhn_efileptmp_pid_fk
				references rhnPackage(id)
				on delete cascade,
	errata_file_id	number
			constraint rhn_efileptmp_fileid_nn not null
			constraint rhn_efileptmp_fileid_fk
				references rhnErrataFileTmp(id)
				on delete cascade,
	created		date default (sysdate)
			constraint rhn_efileptmp_created_nn not null,
	modified	date default (sysdate)
			constraint rhn_efileptmp_modified_nn not null
)
	storage ( freelists 16 )
	enable row movement
	initrans 32;

create or replace trigger
rhn_efileptmp_mod_trig
before insert or update on rhnErrataFilePackageTmp
for each row
begin
	:new.modified := sysdate;
end rhn_efilep_mod_trig;
/
show errors

create index rhn_efileptmp_efid_pid_idx
	on rhnErrataFilePackageTmp( errata_file_id, package_id )
	tablespace [[2m_tbs]]
	storage ( freelists 16 )
	initrans 32;
alter table rhnErrataFilePackageTmp add constraint rhn_efileptmp_efid_uq
	unique ( errata_file_id );

-- robin tells me we only delete on this, so that's all we're indexing.
-- hope he's right ;)
create index rhn_efileptmp_pid_idx
	on rhnErrataFilePackageTmp ( package_id )
	tablespace [[2m_tbs]]
	storage ( freelists 16 )
	initrans 32;

-- $Log$
-- Revision 1.2  2005/02/23 19:50:01  jslagle
-- bz #149067
-- Foreign keys should point to rhnErrataTmp.
-- Fixed trigger typo.
--
-- Revision 1.1  2005/02/21 21:33:31  jslagle
-- bz #149067
-- Create tables/synonyms/grants for rhnErrataFileChannelTmp and
-- rhnErrataFilePackageTmp
--
-- Revision 1.5  2004/12/07 23:17:01  misa
-- bugzilla: 141768  Dropping some unused triggers
--
-- Revision 1.4  2004/10/29 18:11:46  pjones
-- bugzilla: 137474 -- triggers to maintain last_modified everywhere
--
-- Revision 1.3  2003/03/18 20:33:45  pjones
-- make package deletion faster
--
-- Revision 1.2  2003/03/15 00:07:59  pjones
-- bugzilla: none
--
-- foreign key cascades on new errata relationship tables.
--
-- Revision 1.1  2003/03/11 00:37:16  pjones
-- bugzilla: 85516
--
-- public errata schema checkin
--
-- bretm, you owe me cookies.
--
