--
-- $Id$
--
insert into rhnArchType (id, label, name) values
	(rhn_archtype_id_seq.nextval, 'rpm', 'RPM');
insert into rhnArchType (id, label, name) values
	(rhn_archtype_id_seq.nextval, 'sysv-solaris', 'SysV-Solaris');
insert into rhnArchType (id, label, name) values
	(rhn_archtype_id_seq.nextval, 'tar', 'tar');
insert into rhnArchType (id, label, name) values
	(rhn_archtype_id_seq.nextval, 'solaris-patch', 'Solaris Patch');
insert into rhnArchType (id, label, name) values
	(rhn_archtype_id_Seq.nextval, 'solaris-patch-cluster',
		'Solaris Patch Cluster');
commit;

--
-- $Log$
-- Revision 1.3  2004/02/13 20:47:23  pjones
-- bugzilla: none -- add solaris-patch-cluster
--
-- Revision 1.2  2004/02/09 20:55:04  pjones
-- bugzilla: none -- add rhnArchType for solaris patches
--
-- Revision 1.1  2004/02/05 17:33:12  pjones
-- bugzilla: 115009 -- rhnArchType is new, and has changes to go with it
--
