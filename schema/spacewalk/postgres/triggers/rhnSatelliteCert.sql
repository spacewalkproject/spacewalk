-- oracle equivalent source sha1 dbe15c8bb8f51d37c2bcaba77079c1536a03e99f
-- retrieved from ./1239053651/49a123cbe214299834e6ce97b10046d8d9c7642a/schema/spacewalk/oracle/triggers/rhnSatelliteCert.sql
--
-- Copyright (c) 2009--2010 Red Hat, Inc.
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

create or replace function rhn_satcert_mod_trig_fun() returns trigger as
$$
begin
    new.modified := CURRENT_TIMESTAMP;
    return new;
end;
$$ language plpgsql;

create trigger
rhn_satcert_mod_trig
before insert or update on rhnSatelliteCert
for each row
execute procedure rhn_satcert_mod_trig_fun();



