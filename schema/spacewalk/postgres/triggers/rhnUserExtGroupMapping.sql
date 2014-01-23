-- oracle equivalent source sha1 5e09b4fcc80f2925fe93e38e362990e809398e7b
--
-- Copyright (c) 2014 Red Hat, Inc.
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

create or replace function rhn_userextgrmap_mod_trig_fun() returns trigger as
$$
begin
        if new.id is null then
            new.id := nextval('rhn_userextgroupmap_seq');
        end if;
        new.modified := current_timestamp;
        return new;
end;
$$ language plpgsql;

create trigger
rhn_userextgrmap_mod_trig
before insert or update on rhnUserExtGroupMapping
for each row
execute procedure rhn_userextgrmap_mod_trig_fun();
