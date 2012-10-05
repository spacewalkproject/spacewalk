-- oracle equivalent source sha1 9433fdd8b4ba943878354cf4c5967bdab4e6bb3a
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

create or replace function rhn_package_mod_trig_fun() returns trigger as
$$
begin
    -- when we do a sat sync, we use last_modified to keep track
    -- of the upstream modification date.  So if we're setting
    -- it explicitly, don't override with sysdate.  But if we're
    -- not changing it, then this is a genuine update that needs
    -- tracking.
    --
    -- we're not using is_satellite() here instead, because we
    -- might want to use this to keep webdev in sync.
    if tg_op='UPDATE' then
      if new.last_modified = old.last_modified or
         new.last_modified is null then
           new.last_modified := current_timestamp;
      end if;
    else
      if new.last_modified is null then
           new.last_modified := current_timestamp;
      end if;
    end if;
    new.modified := current_timestamp;

    -- bz 619337 if we are updating the checksum, we need to
    -- update the last modified time on all the channels the package is in
    if tg_op='UPDATE' then
        if new.checksum_id != old.checksum_id then
            update rhnChannel
              set last_modified = current_timestamp
              where id in (select channel_id
                              from rhnChannelPackage
                              where package_id = new.id);
            insert into rhnRepoRegenQueue (id, CHANNEL_LABEL, REASON)
                   (select nextval('rhn_repo_regen_queue_id_seq'), C.label, 'checksum modification'
                    from rhnChannel C inner join
                         rhnChannelPackage CP on CP.channel_id = C.id
                    where CP.package_id = new.id);
            delete from rhnPackageRepodata where package_id = new.id;
        end if;
    end if;

    return new;
end;
$$ language plpgsql;

create trigger
rhn_package_mod_trig
before insert or update on rhnPackage
for each row
execute procedure rhn_package_mod_trig_fun();

