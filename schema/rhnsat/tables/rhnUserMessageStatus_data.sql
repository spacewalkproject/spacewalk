--
-- $Id$
--
-- data for rhnUserMessageStatus

insert into rhnUserMessageStatus values (
	rhn_um_status_id_seq.nextval, 'New'
);
insert into rhnUserMessageStatus values (
	rhn_um_status_id_seq.nextval, 'Viewed'
);
insert into rhnUserMessageStatus values (
	rhn_um_status_id_seq.nextval, 'Archived'
);
commit;

-- $Log$
-- Revision 1.2  2002/08/07 18:12:42  pjones
-- add commit to rhnUserMessageStatus_data, check in everything else.
--
-- Revision 1.1  2002/07/25 19:56:34  pjones
-- message schema, take 2.
--
