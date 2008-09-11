--
-- $Id$
--

insert into rhnRelationshipType ( id, label, description ) values (
	rhn_reltype_id_seq.nextval, 'cloned_from',
	'was cloned from'
);

-- $Log$
-- Revision 1.2  2003/03/05 18:18:48  rnorwood
-- bugzilla: 83783 - store and display the rhnchannelrelationship when a channel is cloned.
--
-- Revision 1.1  2003/03/03 17:11:58  pjones
-- progeny relationships for channel and errata
--
