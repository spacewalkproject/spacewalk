--
-- $Id$
--
-- The types of files associated with an errata... normal, RPM, SRPM...?

create sequence rhn_erratafile_type_id_seq;

create table
rhnErrataFileType
(
	id		number
			constraint rhn_erratafile_type_id_nn not null,
	label		varchar2(128)
			constraint rhn_erratafile_type_label_nn not null
)
	storage ( freelists 16 )
	enable row movement
	initrans 32;
	
create index rhn_erratafile_type_id_idx
	on rhnErrataFileType ( id )
	tablespace [[64k_tbs]]
	storage ( freelists 16 )
	initrans 32;
alter table rhnErrataFileType add constraint rhn_erratafile_type_id_pk
	primary key ( id );

create index rhn_erratafile_type_label_idx
	on rhnErrataFileType ( label )
	tablespace [[64k_tbs]]
	storage ( freelists 16 )
	initrans 32;
alter table rhnErrataFileType add constraint rhn_erratafile_type_label_uq
	unique ( label );
-- $Log$
-- Revision 1.1  2003/03/11 00:37:16  pjones
-- bugzilla: 85516
--
-- public errata schema checkin
--
-- bretm, you owe me cookies.
--
