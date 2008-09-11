--
-- $Id$
--

insert into rhnChannelPermissionRole (id, label, description)
	values (rhn_cperm_role_id_seq.nextval,
		'subscribe',
		'Permission to subscribe to channel');
insert into rhnChannelPermissionRole (id, label, description)
	values (rhn_cperm_role_id_seq.nextval,
		'manage',
		'Permission to manage channel');

-- $Log$
-- Revision 1.1  2003/07/15 17:36:50  pjones
-- bugzilla: 98933
--
-- channel permissions
--
