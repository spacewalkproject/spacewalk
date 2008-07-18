--
-- $Id$
--

create table
rhnErrataFilePackageSource
(
	package_id	number
			constraint rhn_efileps_pid_nn not null 
			constraint rhn_efileps_pid_fk
				references rhnPackageSource(id)
				on delete cascade,
	errata_file_id	number
			constraint rhn_efileps_fileid_nn not null
			constraint rhn_efileps_fileid_fk
				references rhnErrataFile(id)
				on delete cascade,
	created		date default (sysdate)
			constraint rhn_efileps_created_nn not null,
	modified	date default (sysdate)
			constraint rhn_efileps_modified_nn not null
)
	storage ( freelists 16 )
	enable row movement
	initrans 32;

create or replace trigger
rhn_efileps_mod_trig
before insert or update on rhnErrataFilePackageSource
for each row
begin
	:new.modified := sysdate;
end rhn_efileps_mod_trig;
/
show errors

create index rhn_efileps_efid_pid_idx
	on rhnErrataFilePackageSource ( errata_file_id, package_id )
	tablespace [[64k_tbs]]
	storage ( freelists 16 )
	initrans 32;
alter table rhnErrataFilePackageSource add constraint rhn_efileps_efid_uq
	unique ( errata_file_id );

-- $Log$
-- Revision 1.4  2004/12/07 23:17:01  misa
-- bugzilla: 141768  Dropping some unused triggers
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
