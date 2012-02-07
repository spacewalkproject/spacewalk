-- oracle equivalent source sha1 182b6404387aa344bf16ebfb5b45ee955d81e168
--
-- Copyright (c) 2012 Red Hat, Inc.
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

create or replace function time_series_purge_mod_trig_fun() returns trigger as
$$
begin
    new.modified := current_timestamp;
    return new;
end;
$$ language plpgsql;

create trigger time_series_purge_mod_trig before insert or update on time_series_purge
for each row
execute procedure time_series_purge_mod_trig_fun();
