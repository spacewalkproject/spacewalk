--
-- $Id$
--

create sequence rhn_erratafile_id_seq;

create table
rhnErrataFile
(
	id		number
			constraint rhn_erratafile_id_nn not null,
	errata_id       number
			constraint rhn_erratafile_errata_nn not null
			constraint rhn_erratafile_errata_fk
				references rhnErrata(id)
				on delete cascade,
	type		number
			constraint rhn_erratafile_type_nn not null
			constraint rhn_erratafile_type_fk
				references rhnErrataFileType(id),
	md5sum		varchar2(64)
			constraint rhn_erratafile_md5_nn not null,
	filename	varchar2(1024)
			constraint rhn_erratafile_name_nn not null,
	created		date default(sysdate)
			constraint rhn_erratafile_created_nn not null,
	modified	date default(sysdate)
			constraint rhn_erratafile_modified_nn not null
)
	storage ( freelists 16 )
	initrans 32;

create or replace trigger
rhn_errata_file_mod_trig
before insert or update on rhnErrataFile
for each row
begin
	:new.modified := sysdate;
end rhn_errata_file_mod_trig;
/
show errors

create index rhn_erratafile_id_idx
	on rhnErrataFile ( id )
	tablespace [[64k_tbs]]
	storage ( freelists 16 )
	initrans 32;
alter table rhnErrataFile add constraint rhn_erratafile_id_pk
	primary key ( id );

create index rhn_erratafile_eid_file_idx
	on rhnErrataFile ( errata_id, filename )
	tablespace [[64k_tbs]]
	storage ( freelists 16 )
	initrans 32;

alter table rhnErrataFile add constraint rhn_erratafile_eid_file_uq
       unique ( errata_id, filename );

-- $Log$
-- Revision 1.5  2004/12/07 23:17:01  misa
-- bugzilla: 141768  Dropping some unused triggers
--
-- Revision 1.4  2004/11/10 16:57:08  pjones
-- bugzilla: 137474 -- use "old" not "new" in delete triggers
--
-- Revision 1.3  2004/10/29 18:11:46  pjones
-- bugzilla: 137474 -- triggers to maintain last_modified everywhere
--
-- Revision 1.2  2003/08/14 20:01:13  pjones
-- bugzilla: 102263
--
-- delete cascades on rhnErrata and rhnErrataTmp where applicable
--
-- Revision 1.1  2003/03/11 00:37:16  pjones
-- bugzilla: 85516
--
-- public errata schema checkin
--
-- bretm, you owe me cookies.
--
