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

create or replace trigger
rhn_server_group_mod_trig
before insert or update on rhnServerGroup
for each row
begin
        :new.modified := sysdate;
end;
/
show errors

CREATE OR REPLACE TRIGGER
rhn_server_group_creation
AFTER INSERT ON rhnServerGroup
FOR EACH ROW
DECLARE
        org_admin_group      NUMBER;
        org_id_val           NUMBER;	
BEGIN
    	org_id_val := :new.org_id;

    	SELECT UG.id INTO org_admin_group
	  FROM rhnUserGroup UG,
	       rhnUserGroupType UGT
	 WHERE UGT.label = 'org_admin'
	   AND UGT.id = UG.group_type
	   AND UG.org_id = org_id_val;

EXCEPTION
        WHEN NO_DATA_FOUND THEN
          rhn_exception.raise_exception_val('no_org_admin_group', org_id_val);
END;
/
SHOW ERRORS

create or replace trigger
rhn_sg_del_trig
before delete on rhnServerGroup
for each row
declare
	cursor snapshots is
		select	snapshot_id id
		from	rhnSnapshotServerGroup
		where	server_group_id = :old.id;
begin
	for snapshot in snapshots loop
		update rhnSnapshot
			set invalid = lookup_snapshot_invalid_reason('sg_removed')
			where id = snapshot.id;
		delete from rhnSnapshotServerGroup
			where snapshot_id = snapshot.id
				and server_group_id = :old.id;
	end loop;
end;
/
show errors

--
--
-- Revision 1.12  2003/11/09 18:18:03  pjones
-- bugzilla: 109083 -- triggers for snapshot invalidation on confchan change
-- bugfix in server group snapshot invalidation
--
-- Revision 1.11  2003/11/09 18:13:20  pjones
-- bugzilla: 109083 -- re-enable snapshot invalidation
--
-- Revision 1.10  2003/11/07 18:05:42  pjones
-- bugzilla: 109083
-- kill old config file schema (currently just an exclude except for
--   rhnConfigFile which is replaced)
-- exclude the snapshot stuff, and comment it from triggers and procs
-- more to come, but the basic config file stuff is in.
--
-- Revision 1.9  2003/10/23 19:14:56  pjones
-- bugzilla: 105745
-- remove rhnSnapshotServerGroup after setting the snapshot invalid
--
-- Revision 1.8  2003/10/07 20:49:18  pjones
-- bugzilla: 106188
--
-- snapshot invalidation
--
-- Revision 1.7  2002/05/10 22:00:48  pjones
-- add rhnFAQClass, and make it a dep for rhnFAQ
-- add grants where appropriate
-- add cvs id/log where it's been missed
-- split data out where appropriate
-- add excludes where appropriate
-- make sure it still builds (at least as sat).
-- (really this time)
--
