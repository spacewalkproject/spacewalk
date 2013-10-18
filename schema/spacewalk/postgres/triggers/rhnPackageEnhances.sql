-- oracle equivalent source sha1 b31ae5f05f77f3e6fb83c8a7005e49e0a65424e6
--
-- Copyright (c) 2013 Novell, Inc.
--
-- This software is licensed to you under the GNU General Public License,
-- version 2 (GPLv2). There is NO WARRANTY for this software, express or
-- implied, including the implied warranties of MERCHANTABILITY or FITNESS
-- FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
-- along with this software; if not, see
-- http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
--
--

create or replace function rhn_pkg_enh_mod_trig_fun() returns trigger as
$$
begin
	new.modified := current_timestamp;

	return new;
end;
$$ language plpgsql;

create trigger
rhn_pkg_enh_mod_trig
before insert or update on rhnPackageEnhances
for each row
execute procedure rhn_pkg_enh_mod_trig_fun();
