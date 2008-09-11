--
-- $Id$
--

insert into rhnOrgChannelSettingsType ( id, label )
	values ( rhn_ocstngs_type_id_seq.nextval, 'not_globally_subscribable' );

commit;

-- $Log$
-- Revision 1.2  2003/07/25 18:18:52  cturner
-- missing reference to data for rhnOrgChannelSettingsType
--
-- Revision 1.1  2003/07/17 18:07:18  pjones
-- bugzilla: none
--
-- change this to be the new way which was discussed
--
