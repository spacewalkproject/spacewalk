--
-- Copyright (c) 2008 Red Hat, Inc.
--
-- This software is licensed to you under the GNU General Public License,
-- version 2 (GPLv2). There is NO WARRANTY for this software, express or
-- implied, including the implied warranties of MERCHANTABILITY or FITNESS
-- FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
-- along with this software; if not, see
-- http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
-- 
-- Red Hat trademarks are not licensed under GPLv2. No permission is
-- granted to use or replicate Red Hat trademarks that are incorporated
-- in this software or its documentation. 
--
--
--
--

insert into rhnSnapshotInvalidReason (id, label, name)
	values (rhn_ssinvalid_id_seq.nextval, 'channel_removed',
		'A channel this snapshot was associated with no longer exists');

insert into rhnSnapshotInvalidReason (id, label, name)
	values (rhn_ssinvalid_id_seq.nextval, 'channel_modified',
		'A channel this snapshot is associated with has been modified');

insert into rhnSnapshotInvalidReason (id, label, name)
	values (rhn_ssinvalid_id_seq.nextval, 'sg_removed',
		'A server group this snapshot was associated with no longer exists');

insert into rhnSnapshotInvalidReason (id, label, name)
	values (rhn_ssinvalid_id_seq.nextval, 'ns_removed',
		'A namespace this snapshot was associated with no longer exists');

insert into rhnSnapshotInvalidReason (id, label, name)
	values (rhn_ssinvalid_id_seq.nextval, 'cr_removed',
		'A config revision this snapshot was associated with no longer exists');

insert into rhnSnapshotInvalidReason (id, label, name)
	values (rhn_ssinvalid_id_seq.nextval, 'cc_removed',
		'A config channel this snapshot was associated with no longer exists');

commit;

--
--
-- Revision 1.5  2004/03/22 19:51:47  pjones
-- bugzilla: none -- whitespace changes
--
-- Revision 1.4  2003/11/14 21:43:59  pjones
-- bugzilla: 110095 -- add cc_removed invalidation reason
--
-- Revision 1.3  2003/11/14 21:00:44  pjones
-- bugzilla: none -- snapshot invalid on config rev removal
--
-- Revision 1.2  2003/10/10 19:10:18  pjones
-- bugzilla: 106187
--
-- This implements snapshotting of namespaces.  Rolling them back to come
-- soon...
--
-- Revision 1.1  2003/10/07 20:49:18  pjones
-- bugzilla: 106188
--
-- snapshot invalidation
--
