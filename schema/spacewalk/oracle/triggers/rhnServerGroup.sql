--
-- Copyright (c) 2008--2012 Red Hat, Inc.
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

create or replace trigger
rhn_server_group_mod_trig
before insert or update on rhnServerGroup
for each row
begin
        :new.modified := current_timestamp;
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
		where	server_group_id = :old.id
		order by snapshot_id;
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

