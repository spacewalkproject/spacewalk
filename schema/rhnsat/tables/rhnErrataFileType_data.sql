--
-- $Id$

insert into rhnErrataFileType ( id, label )
	values ( rhn_erratafile_type_id_seq.nextval, 'RPM' );
insert into rhnErrataFileType ( id, label )
	values ( rhn_erratafile_type_id_seq.nextval, 'SRPM' );
insert into rhnErrataFileType ( id, label )
	values ( rhn_erratafile_type_id_seq.nextval, 'IMG' );

-- $Log$
-- Revision 1.1  2003/03/11 00:37:16  pjones
-- bugzilla: 85516
--
-- public errata schema checkin
--
-- bretm, you owe me cookies.
--
