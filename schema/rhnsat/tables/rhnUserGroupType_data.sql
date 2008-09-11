--
-- $Id$
--
-- data for rhnUserGroupType

insert into rhnUserGroupType (id, label, name) values (
	rhn_usergroup_type_seq.nextval,
	'satellite_admin',
	'Satellite Administrator'
);

insert into rhnUserGroupType (id, label, name) values (
	rhn_usergroup_type_seq.nextval,
	'org_admin',
	'Organization Administrator'
);

insert into rhnUserGroupType (id, label, name) values (
	rhn_usergroup_type_seq.nextval,
	'org_applicant',
	'Organization Applicant'
);

insert into rhnUserGroupType (id, label, name) values (
	rhn_usergroup_type_seq.nextval,
	'channel_admin',
	'Channel Administrator'
);

insert into rhnUserGroupType (id, label, name) values (
	rhn_usergroup_type_seq.nextval,
	'rhn_support',
	'Red Hat Network Support Administrator'
);

insert into rhnUserGroupType (id, label, name) values (
	rhn_usergroup_type_seq.nextval,
	'rhn_superuser',
	'Red Hat Network Superuser'
);

insert into rhnUserGroupType (id, label, name) values (
	rhn_usergroup_type_seq.nextval,
	'coma_admin',
	'Coma CMS Administrator'
);

insert into rhnUserGroupType (id, label, name) values (
	rhn_usergroup_type_seq.nextval,
	'coma_author',
	'Coma CMS Author'
);

insert into rhnUserGroupType (id, label, name) values (
	rhn_usergroup_type_seq.nextval,
	'coma_publisher',
	'Coma CMS Publisher'
);

insert into rhnUserGroupType (id, label, name) values (
	rhn_usergroup_type_seq.nextval,
	'config_admin',
	'Configuration Administrator'
);

insert into rhnUserGroupType (id, label, name) values (
	rhn_usergroup_type_seq.nextval,
	'monitoring_admin',
	'Monitoring Administrator'
);

insert into rhnUserGroupType (id, label, name) values (
	rhn_usergroup_type_seq.nextval,
	'system_group_admin',
	'System Group Administrator'
);

insert into rhnUserGroupType (id, label, name) values (
	rhn_usergroup_type_seq.nextval,
	'activation_key_admin',
	'Activation Key Administrator'
);

insert into rhnUserGroupType (id, label, name) values (
	rhn_usergroup_type_seq.nextval,
	'cert_admin',
	'Certificate Administrator'
);

commit;

-- $Log$
-- Revision 1.8  2004/07/09 18:39:00  pjones
-- bugzilla: 126751 -- cert admin
--
-- Revision 1.7  2004/06/22 16:05:05  pjones
-- bugzilla: 126461 -- add user groups for new roles
--
-- Revision 1.6  2004/06/21 16:56:21  pjones
-- bugzilla: 125648 -- user group role.
--
-- Revision 1.5  2004/04/16 12:29:54  misa
-- Removing duplicates to make nightly builds happy
--
-- Revision 1.4  2004/04/15 21:18:20  pjones
-- bugzilla: 118940 -- fix user group type names to be consistent.
--
-- Revision 1.3  2003/08/21 02:20:32  rnorwood
-- bugzilla: 102046 - SQL changes for config admin role.
--
-- Revision 1.2  2002/09/05 22:47:40  cturner
-- sql for support entitlement
--
-- Revision 1.1  2002/03/08 23:01:05  pjones
-- split imports out into seperate files
--
