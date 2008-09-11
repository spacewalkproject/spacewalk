--
-- $Id$
--

insert into rhnServerProfileType(id, label, name) values (
	rhn_sproftype_id_seq.nextval, 'normal',
	'A normal server profile');

insert into rhnServerProfileType(id, label, name) values (
	rhn_sproftype_id_seq.nextval, 'sync_profile',
	'A server profile associated with a package sync');

commit;
--
-- $Log$
-- Revision 1.1  2003/11/12 04:55:26  cturner
-- bugzilla: 109080, schema for server profile types
--
