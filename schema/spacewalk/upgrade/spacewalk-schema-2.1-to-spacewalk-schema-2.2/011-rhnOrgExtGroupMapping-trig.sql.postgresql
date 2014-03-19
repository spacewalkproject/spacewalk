-- oracle equivalent source sha1 7e035a04e678972654a3c3b9cdde1aa5567870a9
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

create or replace function rhn_userorgextgrmap_mod_trig_fun() returns trigger as
$$
begin
        if new.id is null then
            new.id := nextval('rhn_orgextgroupmap_seq');
        end if;
        new.modified := current_timestamp;
        return new;
end;
$$ language plpgsql;

create trigger
rhn_userorgextgrmap_mod_trig
before insert or update on rhnOrgExtGroupMapping
for each row
execute procedure rhn_userorgextgrmap_mod_trig_fun();
