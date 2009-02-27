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


create or replace function rhn_server_group_mod_trig_fun() returns trigger 
as
$$

begin
        new.modified := current_timestamp;

        return new;
end;
$$ language plpgsql;


create trigger
rhn_server_group_mod_trig
before insert or update on rhnServerGroup
for each row
execute procedure rhn_server_group_mod_trig_fun();


CREATE OR REPLACE FUNCTION rhn_server_group_creation_fun() RETURNS TRIGGER
AS
$$
DECLARE
        org_admin_group      NUMERIC;
        org_id_val           NUMERIC;
BEGIN
        org_id_val := new.org_id;

        SELECT UG.id INTO org_admin_group
          FROM rhnUserGroup UG,
               rhnUserGroupType UGT
         WHERE UGT.label = 'org_admin'
           AND UGT.id = UG.group_type
           AND UG.org_id = org_id_val;

           IF NOT FOUND THEN
		PERFORM rhn_exception.raise_exception_val('no_org_admin_group', org_id_val);
           END IF;

END;
$$ LANGUAGE PLPGSQL;


CREATE TRIGGER
rhn_server_group_creation
AFTER INSERT ON rhnServerGroup
FOR EACH ROW
EXECUTE PROCEDURE rhn_server_group_creation_fun();



create or replace function rhn_sg_del_trig_fun() returns trigger
as
$$
declare
		snapshots cursor for
                select  snapshot_id
                from    rhnSnapshotServerGroup
                where   server_group_id = old.id;

                snapshot_curs_id	numeric;
begin

	open snapshots;
	loop
		fetch snapshots into snapshot_curs_id;
		exit when not found;

		update rhnSnapshot
                        set invalid = lookup_snapshot_invalid_reason('sg_removed')
                        where id = snapshot_curs_id;
                delete from rhnSnapshotServerGroup
                        where snapshot_id = snapshot_curs_id
                                and server_group_id = old.id;
		
	end loop;

	return new;

 end;
 $$
 language plpgsql;
 


create trigger
rhn_sg_del_trig
before delete on rhnServerGroup
for each row
execute procedure rhn_sg_del_trig_fun();


