-- oracle equivalent source sha1 f21df49422ba551c60d0bc4a2a34639c91c144a2
-- retrieved from ./1241102873/cdc6d42049bf86fbc9f1d3a5c54275eeacbd641d/schema/spacewalk/oracle/triggers/rhnServerInfo.sql

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

create or replace function rhn_server_info_mod_trig_fun() returns trigger as
$$
begin
    if new.checkin is NULL
    then
        new.checkin := current_timestamp;
    end if;
    return new;
end;
$$ language plpgsql;

create trigger rhn_server_info_mod_trig
before insert or update
on rhnServerInfo
for each row
execute procedure rhn_server_info_mod_trig_fun();

