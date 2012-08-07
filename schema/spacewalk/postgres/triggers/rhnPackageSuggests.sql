-- oracle equivalent source sha1 e1adfb8d8046d85ac586a9b8a323c9b1eab76899
--
-- Copyright (c) 2010 Novell, Inc.
--
-- This software is licensed to you under the GNU General Public License,
-- version 2 (GPLv2). There is NO WARRANTY for this software, express or
-- implied, including the implied warranties of MERCHANTABILITY or FITNESS
-- FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
-- along with this software; if not, see
-- http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
--
--

create or replace function rhn_pkg_sugg_mod_trig_fun() returns trigger as
$$
begin
	new.modified := current_timestamp;

	return new;
end;
$$ language plpgsql;

create trigger
rhn_pkg_sugg_mod_trig
before insert or update on rhnPackageSuggests
for each row
execute procedure rhn_pkg_sugg_mod_trig_fun();

