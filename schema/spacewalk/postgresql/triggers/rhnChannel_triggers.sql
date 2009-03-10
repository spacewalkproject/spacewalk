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

create or replace function rhn_channel_mod_trig_fun() returns trigger as
$$
begin
	new.modified := current_timestamp;
	-- this is a really bad way of saying "if all we''re
        -- changing is the date"
        if tg_op='UPDATE' then
                if (old.id != new.id) or
                  (old.parent_channel != new.parent_channel) or
                  (old.org_id != new.org_id) or
                  (old.channel_arch_id != new.channel_arch_id) or
                  (old.label != new.label) or
                  (old.basedir != new.basedir) or
                  (old.name != new.name) or
                  (old.summary != new.summary) or
                  (old.description != new.description) then
                        new.modified := current_timestamp;
                end if;
        end if;
	return new;
	
end;
$$ language plpgsql;



create trigger
rhn_channel_mod_trig
before insert or update on rhnChannel
for each row
execute procedure rhn_channel_mod_trig_fun();


create or replace function rhn_channel_del_trig_fun() returns trigger as
$$
declare
        snapshots cursor for
                select  snapshot_id
                from    rhnSnapshotChannel
                where   channel_id = old.id;
        snapshot_curs_id	numeric;
begin
	open snapshots;
	loop
		fetch snapshots into snapshot_curs_id;
		EXIT WHEN not found;
		update rhnSnapshot
                        set invalid = lookup_snapshot_invalid_reason('channel_removed')
                        where id = snapshot_curs_id;
                delete from rhnSnapshotChannel
                        where snapshot_id = snapshot_curs_id
                                and channel_id = old.id;
		
		
	end loop;

	return new;
	
end;
$$ language plpgsql;


create trigger
rhn_channel_del_trig
before delete on rhnChannel
for each row
execute procedure rhn_channel_del_trig_fun();


create or replace function rhn_channel_access_trig_fun() returns trigger as
$$
begin
	if old.channel_access = 'protected' and
      new.channel_access != 'protected'
   then
      delete from rhnChannelTrust where channel_id = old.id;
   end if;

	return new;
	
end;
$$ language plpgsql;



create trigger 
rhn_channel_access_trig
after update on rhnChannel
for each row
execute procedure rhn_channel_access_trig_fun();

