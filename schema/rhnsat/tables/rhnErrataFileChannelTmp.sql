--
-- $Id$
--
-- This is needed because noarch and source packages can span channels
-- using the same path; i.e., noarch packages for the sparc and i386
-- channels of RHL 6.2
--

create table
rhnErrataFileChannelTmp
(
	channel_id	number
			constraint rhn_efilectmp_cid_nn not null 
			constraint rhn_efilectmp_cid_fk
				references rhnChannel(id)
				on delete cascade,
	errata_file_id	number
			constraint rhn_efilectmp_eid_nn not null
			constraint rhn_efilectmp_eid_fk
				references rhnErrataFileTmp(id)
				on delete cascade,
	created		date default (sysdate)
			constraint rhn_efilectmp_created_nn not null,
	modified	date default (sysdate)
			constraint rhn_efilectmp_modified_nn not null
)
	storage ( freelists 16 )
	enable row movement
	initrans 32;

create or replace trigger
rhn_efilectmp_mod_trig
before insert or update on rhnErrataFileChannelTmp
for each row
begin
	:new.modified := sysdate;
end rhn_efilectmp_mod_trig;
/
show errors

create index rhn_efilectmp_efid_cid_idx
	on rhnErrataFileChannelTmp(errata_file_id, channel_id)
	tablespace [[64k_tbs]]
	storage ( freelists 16 )
	initrans 32;
alter table rhnErrataFileChannelTmp add constraint rhn_efilectmp_efid_cid_uq
	unique ( errata_file_id, channel_id );

create index rhn_efilectmp_cid_efid_idx
	on rhnErrataFileChannelTmp(channel_id, errata_file_id)
	tablespace [[64k_tbs]]
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
-- Revision 1.4  2004/12/10 16:17:20  cturner
-- bugzilla: 142550, fix the horribly broken triggers
--
-- Revision 1.3  2004/10/29 18:11:46  pjones
-- bugzilla: 137474 -- triggers to maintain last_modified everywhere
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
