-- oracle equivalent source sha1 4f7ad899e4e2e19b707dfcf411b268f9fcea2c73
--
-- Copyright (c) 2008--2010 Red Hat, Inc.
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


create or replace function rhn_confrevision_mod_trig_func() returns trigger as
$$
begin
	new.modified := current_timestamp;
	return new;
end;
$$ language plpgsql;


create trigger
rhn_confrevision_mod_trig
before insert or update on rhnConfigRevision
for each row
execute procedure rhn_confrevision_mod_trig_func();

create or replace function rhn_confrevision_del_trig_fun() returns trigger 
as
$$
declare
         snapshot_curs_id	numeric;
begin
        for snapshot_curs_id in
                select  snapshot_id
                from    rhnSnapshotConfigRevision
                where   config_revision_id = old.id
	loop
		update rhnSnapshot
                        set invalid = lookup_snapshot_invalid_reason('cr_removed')
                        where id = snapshot_curs_id;
                delete from rhnSnapshotConfigRevision
                        where snapshot_id = snapshot_curs_id
                                and config_revision_id = old.id;
                               
	end loop;
	
        return old;
end;
$$ language plpgsql;


create trigger
rhn_confrevision_del_trig
before delete on rhnConfigRevision
for each row
execute procedure rhn_confrevision_del_trig_fun();
