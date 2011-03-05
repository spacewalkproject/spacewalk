-- oracle equivalent source sha1 e632fdaa9c6f71d350922d8f77962390642838e4
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

create or replace function rhn_pkg_supp_mod_trig_fun() returns trigger as
$$
begin
	new.modified := current_timestamp;

	return new;
end;
$$ language plpgsql;

create trigger
rhn_pkg_supp_mod_trig
before insert or update on rhnPackageSupplements
for each row
execute procedure rhn_pkg_supp_mod_trig_fun();

